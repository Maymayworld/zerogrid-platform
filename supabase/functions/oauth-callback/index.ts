// supabase/functions/oauth-callback/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

serve(async (req) => {
  const url = new URL(req.url)
  const code = url.searchParams.get('code')
  const state = url.searchParams.get('state')
  const error = url.searchParams.get('error')

  if (error) {
    return new Response(
      `<html><body><script>window.close();</script>Error: ${error}</body></html>`,
      { headers: { 'Content-Type': 'text/html' } }
    )
  }

  if (!code || !state) {
    return new Response(
      '<html><body><script>window.close();</script>Missing code or state</body></html>',
      { headers: { 'Content-Type': 'text/html' } }
    )
  }

  try {
    // Parse state - handle TikTok's format (csrfState|actualState)
    let stateData: { user_id: string; platform: string }
    if (state.includes('|')) {
      const [, actualState] = state.split('|')
      stateData = JSON.parse(atob(actualState))
    } else {
      stateData = JSON.parse(atob(state))
    }

    const { user_id, platform } = stateData

    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)

    let accessToken: string
    let refreshToken: string = ''
    let platformUserId: string
    let platformUsername: string | undefined

    if (platform === 'instagram') {
      // Exchange code for access token
      const clientId = Deno.env.get('INSTAGRAM_CLIENT_ID')!
      const clientSecret = Deno.env.get('INSTAGRAM_CLIENT_SECRET')!
      const redirectUri = Deno.env.get('INSTAGRAM_REDIRECT_URI') || 
        `${supabaseUrl}/functions/v1/oauth-callback`

      const tokenResponse = await fetch('https://api.instagram.com/oauth/access_token', {
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
        throw new Error(tokenData.error_message || tokenData.error)
      }

      accessToken = tokenData.access_token
      refreshToken = tokenData.refresh_token || ''
      platformUserId = tokenData.user_id.toString()

      // Get username
      const userResponse = await fetch(
        `https://graph.instagram.com/me?fields=id,username&access_token=${accessToken}`
      )
      const userData = await userResponse.json()
      platformUsername = userData.username

    } else if (platform === 'tiktok') {
      // Exchange code for access token
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
        {
          headers: { 'Authorization': `Bearer ${accessToken}` },
        }
      )
      const userData = await userResponse.json()
      platformUsername = userData.data?.user?.display_name

    } else if (platform === 'youtube') {
      // Exchange code for access token via Google OAuth
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
        {
          headers: { 'Authorization': `Bearer ${accessToken}` },
        }
      )
      const channelData = await channelResponse.json()
      const channel = channelData.items?.[0]
      platformUserId = channel?.id || ''
      platformUsername = channel?.snippet?.title

    } else {
      throw new Error(`Unknown platform: ${platform}`)
    }

    // Save to database - check existing then insert or update
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

    // Return success page that closes the window
    return new Response(
      `<html>
        <head><meta charset="utf-8"></head>
        <body style="font-family: system-ui; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0;">
          <div style="text-align: center;">
            <div style="font-size: 48px; margin-bottom: 16px;">&#x2713;</div>
            <h2 style="margin: 0 0 8px 0;">Connected!</h2>
            <p style="color: #666; margin: 0;">You can close this window</p>
          </div>
        </body>
        <script>
          setTimeout(() => { window.close(); }, 2000);
        </script>
      </html>`,
      { headers: { 'Content-Type': 'text/html; charset=utf-8' } }
    )
  } catch (error) {
    console.error('OAuth callback error:', error)
    return new Response(
      `<html>
        <head><meta charset="utf-8"></head>
        <body style="font-family: system-ui; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0;">
          <div style="text-align: center;">
            <div style="font-size: 48px; margin-bottom: 16px;">&#x2717;</div>
            <h2 style="margin: 0 0 8px 0;">Connection Failed</h2>
            <p style="color: #666; margin: 0;">${error.message}</p>
          </div>
        </body>
        <script>
          setTimeout(() => { window.close(); }, 3000);
        </script>
      </html>`,
      { headers: { 'Content-Type': 'text/html; charset=utf-8' } }
    )
  }
})
