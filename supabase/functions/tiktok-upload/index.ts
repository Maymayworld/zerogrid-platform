// supabase/functions/tiktok-upload/index.ts
// TikTok Direct Post API で動画を自動投稿
// 要: video.upload スコープ（Sandbox審査通過後）

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// TikTokトークンリフレッシュ
async function refreshTikTokToken(refreshToken: string): Promise<{ access_token: string; refresh_token: string } | null> {
  const clientKey = Deno.env.get('TIKTOK_CLIENT_KEY')
  const clientSecret = Deno.env.get('TIKTOK_CLIENT_SECRET')

  if (!clientKey || !clientSecret) return null

  try {
    const response = await fetch('https://open.tiktokapis.com/v2/oauth/token/', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        client_key: clientKey,
        client_secret: clientSecret,
        grant_type: 'refresh_token',
        refresh_token: refreshToken,
      }),
    })

    const data = await response.json()
    if (data.access_token) {
      return {
        access_token: data.access_token,
        refresh_token: data.refresh_token || refreshToken,
      }
    }
    return null
  } catch {
    return null
  }
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)

    const { submission_id } = await req.json()

    if (!submission_id) {
      throw new Error('submission_id is required')
    }

    // 1. 提出物情報を取得
    const { data: submission, error: subError } = await supabase
      .from('submission_requests')
      .select('*, campaigns(name)')
      .eq('id', submission_id)
      .single()

    if (subError || !submission) throw new Error('Submission not found')
    if (submission.platform !== 'tiktok') throw new Error('Not a TikTok submission')
    if (!submission.local_video_url) throw new Error('No local video URL')

    // 2. TikTok接続情報を取得
    const { data: connection } = await supabase
      .from('social_connections')
      .select('access_token, refresh_token, provider_account_id')
      .eq('user_id', submission.creator_id)
      .eq('provider', 'tiktok')
      .single()

    if (!connection) throw new Error('TikTok not connected')

    // 3. トークンリフレッシュ
    let accessToken = connection.access_token
    if (connection.refresh_token) {
      const refreshed = await refreshTikTokToken(connection.refresh_token)
      if (refreshed) {
        accessToken = refreshed.access_token
        await supabase
          .from('social_connections')
          .update({
            access_token: refreshed.access_token,
            refresh_token: refreshed.refresh_token,
          })
          .eq('user_id', submission.creator_id)
          .eq('provider', 'tiktok')
      }
    }

    // 4. Supabase Storage から動画をダウンロード
    const videoUrl = submission.local_video_url as string
    const urlObj = new URL(videoUrl)
    const pathMatch = urlObj.pathname.match(/\/storage\/v1\/object\/public\/videos\/(.+)/)

    if (!pathMatch) throw new Error('Invalid video URL format')

    const storagePath = decodeURIComponent(pathMatch[1])
    const { data: videoData, error: dlError } = await supabase
      .storage.from('videos').download(storagePath)

    if (dlError || !videoData) throw new Error('Failed to download video')

    const videoBytes = new Uint8Array(await videoData.arrayBuffer())

    // 5. TikTok Direct Post API - Step 1: Initialize upload
    const title = submission.video_title || submission.campaigns?.name || 'ZeroGrid Video'

    const initResponse = await fetch(
      'https://open.tiktokapis.com/v2/post/publish/video/init/',
      {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          post_info: {
            title: title.substring(0, 150),
            privacy_level: 'PUBLIC_TO_EVERYONE',
            disable_duet: false,
            disable_comment: false,
            disable_stitch: false,
          },
          source_info: {
            source: 'FILE_UPLOAD',
            video_size: videoBytes.length,
            chunk_size: videoBytes.length,
            total_chunk_count: 1,
          },
        }),
      }
    )

    const initData = await initResponse.json()

    if (initData.error?.code) {
      throw new Error(`TikTok init error: ${initData.error.message || initData.error.code}`)
    }

    const uploadUrl = initData.data?.upload_url
    const publishId = initData.data?.publish_id

    if (!uploadUrl || !publishId) {
      throw new Error('Failed to get TikTok upload URL')
    }

    // 6. Upload video chunk
    const uploadResponse = await fetch(uploadUrl, {
      method: 'PUT',
      headers: {
        'Content-Type': 'video/mp4',
        'Content-Range': `bytes 0-${videoBytes.length - 1}/${videoBytes.length}`,
      },
      body: videoBytes,
    })

    if (!uploadResponse.ok) {
      throw new Error(`TikTok upload failed: ${uploadResponse.status}`)
    }

    // 7. Check publish status (may take time to process)
    // TikTok processes asynchronously, so we save what we have
    const tiktokUrl = `https://www.tiktok.com/@${connection.provider_account_id}/video/${publishId}`

    // 8. 提出物を更新
    await supabase
      .from('submission_requests')
      .update({
        platform_post_id: publishId,
        platform_post_url: tiktokUrl,
        upload_status: 'posted',
        updated_at: new Date().toISOString(),
      })
      .eq('id', submission_id)

    return new Response(
      JSON.stringify({
        success: true,
        submission_id,
        publish_id: publishId,
        tiktok_url: tiktokUrl,
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
