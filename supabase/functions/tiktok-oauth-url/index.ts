// supabase/functions/tiktok-oauth-url/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Authenticate user via JWT
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'Missing Authorization header' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)

    const token = authHeader.replace('Bearer ', '')
    const { data: { user }, error: authError } = await supabase.auth.getUser(token)

    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: 'Invalid or expired token' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const clientKey = Deno.env.get('TIKTOK_CLIENT_KEY')
    const redirectUri = Deno.env.get('TIKTOK_REDIRECT_URI') ||
      `${supabaseUrl}/functions/v1/oauth-callback`

    if (!clientKey) {
      return new Response(
        JSON.stringify({ error: 'TikTok not configured' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Insert state record into DB (expires in 10 minutes)
    const expiresAt = new Date()
    expiresAt.setMinutes(expiresAt.getMinutes() + 10)

    const { data: stateRecord, error: dbError } = await supabase
      .from('pending_oauth_states')
      .insert({
        user_id: user.id,
        platform: 'tiktok',
        expires_at: expiresAt.toISOString(),
      })
      .select('id')
      .single()

    if (dbError || !stateRecord) {
      throw new Error('Failed to create OAuth state')
    }

    // TikTok Login Kit OAuth URL
    const scope = 'user.info.basic,video.list,video.upload'

    const url = new URL('https://www.tiktok.com/v2/auth/authorize/')
    url.searchParams.set('client_key', clientKey)
    url.searchParams.set('redirect_uri', redirectUri)
    url.searchParams.set('scope', scope)
    url.searchParams.set('response_type', 'code')
    url.searchParams.set('state', stateRecord.id)

    return new Response(
      JSON.stringify({ url: url.toString() }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
