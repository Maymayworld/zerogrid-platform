// supabase/functions/fetch-view-counts/index.ts
// 視聴回数取得 Edge Function
// YouTube, TikTok, Instagram の動画視聴回数を取得

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

// TikTok動画IDを抽出
function extractTikTokVideoId(url: string): string | null {
  const patterns = [
    /tiktok\.com\/@[^/]+\/video\/(\d+)/,
    /tiktok\.com\/t\/([a-zA-Z0-9]+)/,
    /vm\.tiktok\.com\/([a-zA-Z0-9]+)/,
  ]
  for (const pattern of patterns) {
    const match = url.match(pattern)
    if (match) return match[1]
  }
  return null
}

// Instagram投稿IDを抽出
function extractInstagramPostId(url: string): string | null {
  const patterns = [
    /instagram\.com\/p\/([a-zA-Z0-9_-]+)/,
    /instagram\.com\/reel\/([a-zA-Z0-9_-]+)/,
  ]
  for (const pattern of patterns) {
    const match = url.match(pattern)
    if (match) return match[1]
  }
  return null
}

// YouTube視聴回数取得
async function getYouTubeViewCount(videoId: string): Promise<number | null> {
  const apiKey = Deno.env.get('YOUTUBE_API_KEY')
  if (!apiKey) {
    console.error('YOUTUBE_API_KEY not set')
    return null
  }

  try {
    const response = await fetch(
      `https://www.googleapis.com/youtube/v3/videos?part=statistics&id=${videoId}&key=${apiKey}`
    )
    const data = await response.json()
    
    if (data.items && data.items.length > 0) {
      return parseInt(data.items[0].statistics.viewCount, 10)
    }
    return null
  } catch (error) {
    console.error('YouTube API error:', error)
    return null
  }
}

// TikTok視聴回数取得（公式APIまたはスクレイピング代替）
async function getTikTokViewCount(videoId: string, accessToken?: string): Promise<number | null> {
  // TikTok公式APIを使用（accessTokenが必要）
  if (accessToken) {
    try {
      const response = await fetch(
        `https://open.tiktokapis.com/v2/video/query/?fields=view_count`,
        {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${accessToken}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            filters: { video_ids: [videoId] }
          }),
        }
      )
      const data = await response.json()
      if (data.data?.videos?.[0]?.view_count !== undefined) {
        return data.data.videos[0].view_count
      }
    } catch (error) {
      console.error('TikTok API error:', error)
    }
  }
  
  // フォールバック: nullを返す（手動入力または別の方法が必要）
  return null
}

// Instagram視聴回数取得
async function getInstagramViewCount(postId: string, accessToken?: string): Promise<number | null> {
  if (!accessToken) {
    return null
  }

  try {
    // Instagram Graph API (ビジネスアカウント用)
    const response = await fetch(
      `https://graph.instagram.com/${postId}?fields=video_view_count&access_token=${accessToken}`
    )
    const data = await response.json()
    
    if (data.video_view_count !== undefined) {
      return data.video_view_count
    }
    return null
  } catch (error) {
    console.error('Instagram API error:', error)
    return null
  }
}

serve(async (req) => {
  // CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)

    const { submission_id, video_url, platform, user_id } = await req.json()

    let viewCount: number | null = null
    let accessToken: string | undefined

    // ユーザーのアクセストークンを取得（TikTok, Instagram用）
    if (user_id && (platform === 'tiktok' || platform === 'instagram')) {
      const { data: connection } = await supabase
        .from('social_connections')
        .select('access_token')
        .eq('user_id', user_id)
        .eq('platform', platform)
        .single()
      
      accessToken = connection?.access_token
    }

    // プラットフォームごとに視聴回数を取得
    switch (platform.toLowerCase()) {
      case 'youtube': {
        const videoId = extractYouTubeVideoId(video_url)
        if (videoId) {
          viewCount = await getYouTubeViewCount(videoId)
        }
        break
      }
      case 'tiktok': {
        const videoId = extractTikTokVideoId(video_url)
        if (videoId) {
          viewCount = await getTikTokViewCount(videoId, accessToken)
        }
        break
      }
      case 'instagram': {
        const postId = extractInstagramPostId(video_url)
        if (postId) {
          viewCount = await getInstagramViewCount(postId, accessToken)
        }
        break
      }
    }

    // DBを更新
    if (submission_id && viewCount !== null) {
      await supabase
        .from('submission_requests')
        .update({ 
          view_count: viewCount,
          updated_at: new Date().toISOString()
        })
        .eq('id', submission_id)
    }

    return new Response(
      JSON.stringify({ 
        success: true, 
        view_count: viewCount,
        platform,
        submission_id
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
