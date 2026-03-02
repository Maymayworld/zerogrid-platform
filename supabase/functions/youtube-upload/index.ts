// supabase/functions/youtube-upload/index.ts
// YouTube 自動投稿 Edge Function
// クリエイターの動画をYouTubeに自動投稿し、投稿URLを保存

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// Google OAuth トークンリフレッシュ
async function refreshGoogleToken(refreshToken: string): Promise<string | null> {
  const clientId = Deno.env.get('GOOGLE_CLIENT_ID')
  const clientSecret = Deno.env.get('GOOGLE_CLIENT_SECRET')

  if (!clientId || !clientSecret) {
    console.error('Google OAuth credentials not set')
    return null
  }

  try {
    const response = await fetch('https://oauth2.googleapis.com/token', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        client_id: clientId,
        client_secret: clientSecret,
        refresh_token: refreshToken,
        grant_type: 'refresh_token',
      }),
    })

    const data = await response.json()
    if (data.access_token) {
      return data.access_token
    }
    console.error('Token refresh failed:', data)
    return null
  } catch (error) {
    console.error('Token refresh error:', error)
    return null
  }
}

// YouTube にリザマブルアップロードを開始
async function initiateYouTubeUpload(
  accessToken: string,
  title: string,
  description: string,
  videoSize: number,
): Promise<string | null> {
  try {
    const metadata = {
      snippet: {
        title: title || 'ZeroGrid Video',
        description: description || 'Uploaded via ZeroGrid',
        categoryId: '22', // People & Blogs
      },
      status: {
        privacyStatus: 'public',
        selfDeclaredMadeForKids: false,
      },
    }

    const response = await fetch(
      'https://www.googleapis.com/upload/youtube/v3/videos?uploadType=resumable&part=snippet,status',
      {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${accessToken}`,
          'Content-Type': 'application/json; charset=UTF-8',
          'X-Upload-Content-Length': videoSize.toString(),
          'X-Upload-Content-Type': 'video/mp4',
        },
        body: JSON.stringify(metadata),
      }
    )

    if (response.status === 200) {
      // レスポンスヘッダーからアップロードURIを取得
      const uploadUri = response.headers.get('Location')
      return uploadUri
    }

    console.error('YouTube initiate upload failed:', response.status, await response.text())
    return null
  } catch (error) {
    console.error('YouTube initiate upload error:', error)
    return null
  }
}

// YouTube にチャンクアップロード
async function uploadVideoToYouTube(
  uploadUri: string,
  videoData: Uint8Array,
): Promise<{ videoId: string } | null> {
  try {
    const response = await fetch(uploadUri, {
      method: 'PUT',
      headers: {
        'Content-Type': 'video/mp4',
        'Content-Length': videoData.length.toString(),
      },
      body: videoData,
    })

    if (response.status === 200 || response.status === 201) {
      const data = await response.json()
      return { videoId: data.id }
    }

    console.error('YouTube upload failed:', response.status, await response.text())
    return null
  } catch (error) {
    console.error('YouTube upload error:', error)
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

    if (subError || !submission) {
      throw new Error('Submission not found')
    }

    if (submission.platform !== 'youtube') {
      throw new Error('Submission is not a YouTube submission')
    }

    if (!submission.local_video_url) {
      throw new Error('No local video URL found')
    }

    // 2. クリエイターのYouTube接続情報を取得
    const { data: connection, error: connError } = await supabase
      .from('social_connections')
      .select('access_token, refresh_token')
      .eq('user_id', submission.creator_id)
      .eq('provider', 'youtube')
      .single()

    if (connError || !connection) {
      throw new Error('YouTube not connected for this creator')
    }

    // 3. アクセストークンをリフレッシュ
    let accessToken = connection.access_token
    if (connection.refresh_token) {
      const newToken = await refreshGoogleToken(connection.refresh_token)
      if (newToken) {
        accessToken = newToken
        // 新しいトークンを保存
        await supabase
          .from('social_connections')
          .update({ access_token: newToken })
          .eq('user_id', submission.creator_id)
          .eq('provider', 'youtube')
      }
    }

    if (!accessToken) {
      throw new Error('Failed to get valid access token')
    }

    // 4. Supabase Storage から動画をダウンロード
    // local_video_url からパスを抽出
    const videoUrl = submission.local_video_url as string
    const urlObj = new URL(videoUrl)
    const pathMatch = urlObj.pathname.match(/\/storage\/v1\/object\/public\/videos\/(.+)/)

    if (!pathMatch) {
      throw new Error('Invalid video URL format')
    }

    const storagePath = decodeURIComponent(pathMatch[1])
    const { data: videoData, error: downloadError } = await supabase
      .storage
      .from('videos')
      .download(storagePath)

    if (downloadError || !videoData) {
      throw new Error('Failed to download video from storage')
    }

    const videoBytes = new Uint8Array(await videoData.arrayBuffer())

    // 5. YouTube にアップロード
    const title = submission.video_title || submission.campaigns?.name || 'ZeroGrid Video'
    const description = `Campaign: ${submission.campaigns?.name || ''}\n\nUploaded via ZeroGrid`

    // リザマブルアップロードの開始
    const uploadUri = await initiateYouTubeUpload(
      accessToken,
      title,
      description,
      videoBytes.length,
    )

    if (!uploadUri) {
      throw new Error('Failed to initiate YouTube upload')
    }

    // 動画のアップロード
    const result = await uploadVideoToYouTube(uploadUri, videoBytes)

    if (!result) {
      throw new Error('Failed to upload video to YouTube')
    }

    const youtubeVideoUrl = `https://www.youtube.com/watch?v=${result.videoId}`

    // 6. 提出物を更新
    await supabase
      .from('submission_requests')
      .update({
        platform_post_id: result.videoId,
        platform_post_url: youtubeVideoUrl,
        video_url: youtubeVideoUrl,
        upload_status: 'posted',
        updated_at: new Date().toISOString(),
      })
      .eq('id', submission_id)

    return new Response(
      JSON.stringify({
        success: true,
        submission_id,
        youtube_video_id: result.videoId,
        youtube_url: youtubeVideoUrl,
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
