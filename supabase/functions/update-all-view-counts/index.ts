// supabase/functions/update-all-view-counts/index.ts
// 全承認済み提出物の視聴回数を一括更新（定期実行用）
// platform_post_url を優先的に参照し、なければ video_url にフォールバック

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// YouTube動画IDを抽出
function extractYouTubeVideoId(url: string): string | null {
  const patterns = [
    /(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([a-zA-Z0-9_-]{11})/,
    /youtube\.com\/shorts\/([a-zA-Z0-9_-]{11})/,
  ]
  for (const pattern of patterns) {
    const match = url.match(pattern)
    if (match) return match[1]
  }
  return null
}

// YouTube視聴回数を一括取得（最大50件ずつ）
async function getYouTubeViewCounts(videoIds: string[]): Promise<Map<string, number>> {
  const apiKey = Deno.env.get('YOUTUBE_API_KEY')
  if (!apiKey) {
    console.error('YOUTUBE_API_KEY not set')
    return new Map()
  }

  const results = new Map<string, number>()

  const chunks = []
  for (let i = 0; i < videoIds.length; i += 50) {
    chunks.push(videoIds.slice(i, i + 50))
  }

  for (const chunk of chunks) {
    try {
      const ids = chunk.join(',')
      const response = await fetch(
        `https://www.googleapis.com/youtube/v3/videos?part=statistics&id=${ids}&key=${apiKey}`
      )
      const data = await response.json()

      if (data.items) {
        for (const item of data.items) {
          results.set(item.id, parseInt(item.statistics.viewCount, 10))
        }
      }
    } catch (error) {
      console.error('YouTube API error:', error)
    }

    // レート制限対策
    await new Promise(resolve => setTimeout(resolve, 100))
  }

  return results
}

// 提出物から最適なURLを取得
function getEffectiveUrl(submission: any): string | null {
  return submission.platform_post_url || submission.video_url || null
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)

    // アクティブなキャンペーンの承認済み提出物を取得
    const { data: submissions, error: fetchError } = await supabase
      .from('submission_requests')
      .select(`
        id,
        video_url,
        platform_post_url,
        platform,
        creator_id,
        campaign_id,
        view_count,
        social_connection_id,
        campaigns!inner(status, deadline)
      `)
      .eq('status', 'approved')
      .eq('campaigns.status', 'active')
      .gt('campaigns.deadline', new Date().toISOString())

    if (fetchError) {
      throw new Error(`Failed to fetch submissions: ${fetchError.message}`)
    }

    if (!submissions || submissions.length === 0) {
      return new Response(
        JSON.stringify({ success: true, message: 'No active submissions to update', updated: 0 }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // プラットフォーム別に分類
    const youtubeSubmissions = submissions.filter(s => s.platform === 'youtube')
    const tiktokSubmissions = submissions.filter(s => s.platform === 'tiktok')
    const instagramSubmissions = submissions.filter(s => s.platform === 'instagram')

    let updatedCount = 0

    // YouTube一括処理
    if (youtubeSubmissions.length > 0) {
      const videoIdMap = new Map<string, string>() // videoId -> submissionId

      for (const sub of youtubeSubmissions) {
        const url = getEffectiveUrl(sub)
        if (!url) continue

        const videoId = extractYouTubeVideoId(url)
        if (videoId) {
          videoIdMap.set(videoId, sub.id)
        }
      }

      const videoIds = Array.from(videoIdMap.keys())
      if (videoIds.length > 0) {
        const viewCounts = await getYouTubeViewCounts(videoIds)

        for (const [videoId, viewCount] of viewCounts) {
          const submissionId = videoIdMap.get(videoId)
          if (submissionId) {
            const { error } = await supabase
              .from('submission_requests')
              .update({
                view_count: viewCount,
                updated_at: new Date().toISOString()
              })
              .eq('id', submissionId)

            if (!error) updatedCount++
          }
        }
      }
    }

    // TikTok/Instagram は個別のアクセストークンが必要
    // fetch-view-counts を個別に呼ぶ（per-user token）
    for (const sub of [...tiktokSubmissions, ...instagramSubmissions]) {
      const url = getEffectiveUrl(sub)
      if (!url) continue

      try {
        const funcUrl = `${supabaseUrl}/functions/v1/fetch-view-counts`
        const response = await fetch(funcUrl, {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${supabaseKey}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            submission_id: sub.id,
            video_url: url,
            platform: sub.platform,
            user_id: sub.creator_id,
            social_connection_id: sub.social_connection_id,
          }),
        })

        const result = await response.json()
        if (result.success && result.view_count !== null) {
          updatedCount++
        }
      } catch (error) {
        console.error(`Failed to update ${sub.platform} submission ${sub.id}:`, error)
      }
    }

    // キャンペーンごとの合計視聴回数を計算して更新
    const campaignIds = [...new Set(submissions.map(s => s.campaign_id))]

    for (const campaignId of campaignIds) {
      const { data: campaignSubs } = await supabase
        .from('submission_requests')
        .select('view_count')
        .eq('campaign_id', campaignId)
        .eq('status', 'approved')

      const totalViews = campaignSubs?.reduce((sum: number, s: any) => sum + (s.view_count || 0), 0) || 0

      await supabase
        .from('campaigns')
        .update({
          total_views: totalViews,
          updated_at: new Date().toISOString()
        })
        .eq('id', campaignId)
    }

    // 視聴回数更新後、終了案件の検出＋報酬分配を実行
    let processResult = null
    try {
      const funcUrl = `${supabaseUrl}/functions/v1/process-ended-campaigns`
      const processResponse = await fetch(funcUrl, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${supabaseKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({}),
      })
      processResult = await processResponse.json()
      console.log('process-ended-campaigns result:', processResult)
    } catch (error) {
      console.error('Failed to call process-ended-campaigns:', error)
      processResult = { error: error.message }
    }

    return new Response(
      JSON.stringify({
        success: true,
        updated: updatedCount,
        total_submissions: submissions.length,
        youtube: youtubeSubmissions.length,
        tiktok: tiktokSubmissions.length,
        instagram: instagramSubmissions.length,
        campaigns_processed: campaignIds.length,
        ended_campaigns: processResult
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    console.error('Error:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
