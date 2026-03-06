// supabase/functions/instagram-upload/index.ts
// Instagram Graph API で動画を自動投稿（Reels）
// 要: instagram_content_publish 権限（Meta アプリ審査通過後）
// 要: ユーザーがビジネス/クリエイターアカウント + Facebookページ連携

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// Instagram Graph APIの公開ステータスをポーリング
async function waitForMediaReady(
  igUserId: string,
  containerId: string,
  accessToken: string,
  maxRetries = 30,
): Promise<boolean> {
  for (let i = 0; i < maxRetries; i++) {
    const response = await fetch(
      `https://graph.facebook.com/v21.0/${containerId}?fields=status_code&access_token=${accessToken}`
    )
    const data = await response.json()

    if (data.status_code === 'FINISHED') return true
    if (data.status_code === 'ERROR') return false

    // 2秒待機
    await new Promise(resolve => setTimeout(resolve, 2000))
  }
  return false
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

    if (!submission_id) throw new Error('submission_id is required')

    // 1. 提出物情報を取得
    const { data: submission, error: subError } = await supabase
      .from('submission_requests')
      .select('*, campaigns(name)')
      .eq('id', submission_id)
      .single()

    if (subError || !submission) throw new Error('Submission not found')
    if (submission.platform !== 'instagram') throw new Error('Not an Instagram submission')
    if (!submission.local_video_url) throw new Error('No local video URL')

    // 2. Instagram接続情報を取得
    // access_token はページアクセストークン（長期トークン）
    // provider_account_id は Instagram Business Account ID
    const { data: connection } = await supabase
      .from('social_connections')
      .select('access_token, provider_account_id, provider_account_name')
      .eq('user_id', submission.creator_id)
      .eq('provider', 'instagram')
      .single()

    if (!connection) throw new Error('Instagram not connected')
    if (!connection.provider_account_id) throw new Error('No Instagram Business Account ID')

    const accessToken = connection.access_token
    const igUserId = connection.provider_account_id

    // 3. Instagram Graph API - メディアコンテナ作成
    // 注意: Instagram Graph API は公開URLが必要
    // local_video_url は Supabase Storage の公開URLなのでそのまま使える
    const videoUrl = submission.local_video_url as string
    const caption = submission.video_title || `Campaign: ${submission.campaigns?.name || ''}`

    const containerResponse = await fetch(
      `https://graph.facebook.com/v21.0/${igUserId}/media`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          media_type: 'REELS',
          video_url: videoUrl,
          caption: caption,
          access_token: accessToken,
        }),
      }
    )

    const containerData = await containerResponse.json()

    if (containerData.error) {
      // Check for auth-related errors (token expired)
      const errCode = containerData.error.code
      const errType = containerData.error.type
      if (errCode === 190 || errType === 'OAuthException') {
        // Mark connection as expired
        await supabase
          .from('social_connections')
          .update({ status: 'expired', updated_at: new Date().toISOString() })
          .eq('user_id', submission.creator_id)
          .eq('provider', 'instagram')
        throw new Error('Instagram token expired. Please reconnect your account.')
      }
      throw new Error(`Instagram container error: ${containerData.error.message}`)
    }

    const containerId = containerData.id
    if (!containerId) throw new Error('Failed to create media container')

    // 4. 動画処理を待つ（最大60秒）
    const isReady = await waitForMediaReady(igUserId, containerId, accessToken)

    if (!isReady) {
      throw new Error('Instagram video processing timed out or failed')
    }

    // 5. 公開リクエスト
    const publishResponse = await fetch(
      `https://graph.facebook.com/v21.0/${igUserId}/media_publish`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          creation_id: containerId,
          access_token: accessToken,
        }),
      }
    )

    const publishData = await publishResponse.json()

    if (publishData.error) {
      throw new Error(`Instagram publish error: ${publishData.error.message}`)
    }

    const mediaId = publishData.id

    // 6. パーマリンクを取得
    let permalink = ''
    try {
      const mediaResponse = await fetch(
        `https://graph.facebook.com/v21.0/${mediaId}?fields=permalink&access_token=${accessToken}`
      )
      const mediaData = await mediaResponse.json()
      permalink = mediaData.permalink || ''
    } catch {
      // パーマリンク取得失敗しても投稿は成功
      permalink = `https://www.instagram.com/p/${mediaId}/`
    }

    // 7. 提出物を更新
    await supabase
      .from('submission_requests')
      .update({
        platform_post_id: mediaId,
        platform_post_url: permalink,
        upload_status: 'posted',
        updated_at: new Date().toISOString(),
      })
      .eq('id', submission_id)

    return new Response(
      JSON.stringify({
        success: true,
        submission_id,
        media_id: mediaId,
        instagram_url: permalink,
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
