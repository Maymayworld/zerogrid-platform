// supabase/functions/oauth-callback/index.ts
// OAuth コールバック処理（YouTube, TikTok, Instagram）
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const successHtml = `<html>
  <head><meta charset="utf-8"></head>
  <body style="font-family: system-ui; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0;">
    <div style="text-align: center;">
      <div style="font-size: 48px; margin-bottom: 16px;">&#x2713;</div>
      <h2 style="margin: 0 0 8px 0;">Connected!</h2>
      <p style="color: #666; margin: 0;">You can close this window</p>
    </div>
  </body>
  <script>setTimeout(() => { window.close(); }, 2000);</script>
</html>`

function errorHtml(message: string) {
  return `<html>
    <head><meta charset="utf-8"></head>
    <body style="font-family: system-ui; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0;">
      <div style="text-align: center;">
        <div style="font-size: 48px; margin-bottom: 16px;">&#x2717;</div>
        <h2 style="margin: 0 0 8px 0;">Connection Failed</h2>
        <p style="color: #666; margin: 0;">${message}</p>
      </div>
    </body>
    <script>setTimeout(() => { window.close(); }, 3000);</script>
  </html>`
}

serve(async (req) => {
  const url = new URL(req.url)
  const code = url.searchParams.get('code')
  const state = url.searchParams.get('state')
  const error = url.searchParams.get('error')

  if (error) {
    return new Response(errorHtml(error), { headers: { 'Content-Type': 'text/html' } })
  }

  if (!code || !state) {
    return new Response(errorHtml('Missing code or state'), { headers: { 'Content-Type': 'text/html' } })
  }

  try {
    // Parse state - TikTok uses csrfState|actualState format
    let stateData: { user_id: string; platform: string }
    if (state.includes('|')) {
      const [, actualState] = state.split('|')
      stateData = JSON.parse(atob(actualState))
    } else {
      stateData = JSON.parse(atob(state))
    }

    const { user_id, platform } = stateData

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)

    let accessToken: string
    let refreshToken: string = ''
    let platformUserId: string = ''
    let platformUsername: string | undefined

    if (platform === 'instagram') {
      // ========================================
      // Instagram Graph API (via Facebook Login)
      // ========================================
      const appId = Deno.env.get('INSTAGRAM_CLIENT_ID')!
      const appSecret = Deno.env.get('INSTAGRAM_CLIENT_SECRET')!
      const redirectUri = Deno.env.get('INSTAGRAM_REDIRECT_URI') ||
        `${supabaseUrl}/functions/v1/oauth-callback`

      // 1. Exchange code for short-lived Facebook token
      const tokenResponse = await fetch(
        `https://graph.facebook.com/v21.0/oauth/access_token?` +
        `client_id=${appId}&client_secret=${appSecret}&redirect_uri=${encodeURIComponent(redirectUri)}&code=${code}`
      )
      const tokenData = await tokenResponse.json()

      if (tokenData.error) {
        throw new Error(tokenData.error.message || 'Failed to get Facebook token')
      }

      const shortLivedToken = tokenData.access_token

      // 2. Exchange for long-lived token (60 days)
      const longTokenResponse = await fetch(
        `https://graph.facebook.com/v21.0/oauth/access_token?` +
        `grant_type=fb_exchange_token&client_id=${appId}&client_secret=${appSecret}&fb_exchange_token=${shortLivedToken}`
      )
      const longTokenData = await longTokenResponse.json()
      accessToken = longTokenData.access_token || shortLivedToken

      // 3. Get user's Facebook Pages
      const pagesResponse = await fetch(
        `https://graph.facebook.com/v21.0/me/accounts?access_token=${accessToken}`
      )
      const pagesData = await pagesResponse.json()

      if (!pagesData.data || pagesData.data.length === 0) {
        throw new Error('No Facebook Pages found. Instagram Business account requires a linked Facebook Page.')
      }

      // Use the first page's access token (long-lived page token)
      const page = pagesData.data[0]
      const pageAccessToken = page.access_token

      // 4. Get Instagram Business Account linked to the page
      const igResponse = await fetch(
        `https://graph.facebook.com/v21.0/${page.id}?fields=instagram_business_account&access_token=${pageAccessToken}`
      )
      const igData = await igResponse.json()

      if (!igData.instagram_business_account) {
        throw new Error('No Instagram Business account linked to this Facebook Page. Please convert to a Business or Creator account.')
      }

      const igUserId = igData.instagram_business_account.id

      // 5. Get Instagram username
      const igProfileResponse = await fetch(
        `https://graph.facebook.com/v21.0/${igUserId}?fields=username,name&access_token=${pageAccessToken}`
      )
      const igProfile = await igProfileResponse.json()

      platformUserId = igUserId
      platformUsername = igProfile.username || igProfile.name
      accessToken = pageAccessToken // Use page token for Instagram API calls
      refreshToken = '' // Page tokens are long-lived, no refresh needed

    } else if (platform === 'tiktok') {
      // ========================================
      // TikTok v2 API
      // ========================================
      const clientKey = Deno.env.get('TIKTOK_CLIENT_KEY')!
      const clientSecret = Deno.env.get('TIKTOK_CLIENT_SECRET')!
      const redirectUri = Deno.env.get('TIKTOK_REDIRECT_URI') ||
        `${supabaseUrl}/functions/v1/oauth-callback`

      const tokenResponse = await fetch('https://open.tiktokapis.com/v2/oauth/token/', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({
          client_key: clientKey,
          client_secret: clientSecret,
          grant_type: 'authorization_code',
          redirect_uri: redirectUri,
          code: code,
        }),
      })

      const tokenData = await tokenResponse.json()

      if (tokenData.error) {
        throw new Error(tokenData.error_description || tokenData.error)
      }

      accessToken = tokenData.access_token
      refreshToken = tokenData.refresh_token || ''
      platformUserId = tokenData.open_id

      // Get user info
      const userResponse = await fetch(
        'https://open.tiktokapis.com/v2/user/info/?fields=open_id,display_name,avatar_url',
        { headers: { 'Authorization': `Bearer ${accessToken}` } }
      )
      const userData = await userResponse.json()
      platformUsername = userData.data?.user?.display_name

    } else if (platform === 'youtube') {
      // ========================================
      // Google / YouTube OAuth
      // ========================================
      const clientId = Deno.env.get('GOOGLE_CLIENT_ID')!
      const clientSecret = Deno.env.get('GOOGLE_CLIENT_SECRET')!
      const redirectUri = Deno.env.get('GOOGLE_REDIRECT_URI') ||
        `${supabaseUrl}/functions/v1/oauth-callback`

      const tokenResponse = await fetch('https://oauth2.googleapis.com/token', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({
          client_id: clientId,
          client_secret: clientSecret,
          grant_type: 'authorization_code',
          redirect_uri: redirectUri,
          code: code,
        }),
      })

      const tokenData = await tokenResponse.json()

      if (tokenData.error) {
        throw new Error(tokenData.error_description || tokenData.error)
      }

      accessToken = tokenData.access_token
      refreshToken = tokenData.refresh_token || ''

      // Get YouTube channel info
      const channelResponse = await fetch(
        'https://www.googleapis.com/youtube/v3/channels?part=snippet&mine=true',
        { headers: { 'Authorization': `Bearer ${accessToken}` } }
      )
      const channelData = await channelResponse.json()
      const channel = channelData.items?.[0]
      platformUserId = channel?.id || ''
      platformUsername = channel?.snippet?.title

    } else {
      throw new Error(`Unknown platform: ${platform}`)
    }

    // Save to database
    const { data: existing } = await supabase
      .from('social_connections')
      .select('id')
      .eq('user_id', user_id)
      .eq('provider', platform)
      .maybeSingle()

    const connectionData = {
      user_id,
      provider: platform,
      provider_account_id: platformUserId,
      provider_account_name: platformUsername,
      access_token: accessToken,
      refresh_token: refreshToken,
      status: 'connected',
      updated_at: new Date().toISOString(),
    }

    let dbError
    if (existing) {
      const result = await supabase
        .from('social_connections')
        .update(connectionData)
        .eq('id', existing.id)
      dbError = result.error
    } else {
      const result = await supabase
        .from('social_connections')
        .insert(connectionData)
      dbError = result.error
    }

    if (dbError) {
      throw new Error(`Database error: ${dbError.message}`)
    }

    return new Response(successHtml, { headers: { 'Content-Type': 'text/html; charset=utf-8' } })
  } catch (error) {
    console.error('OAuth callback error:', error)
    return new Response(
      errorHtml(error.message),
      { headers: { 'Content-Type': 'text/html; charset=utf-8' } }
    )
  }
})
