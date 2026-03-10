// supabase/functions/revoke-oauth-token/index.ts
// Revokes OAuth tokens with platform APIs and disconnects the account
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
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

    const { connection_id } = await req.json()

    if (!connection_id) {
      return new Response(
        JSON.stringify({ error: 'connection_id is required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Fetch connection — verify ownership via user_id match
    const { data: connection, error: fetchError } = await supabase
      .from('social_connections')
      .select('*')
      .eq('id', connection_id)
      .eq('user_id', user.id)
      .single()

    if (fetchError || !connection) {
      return new Response(
        JSON.stringify({ error: 'Connection not found' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const { provider, access_token } = connection

    // Revoke tokens with platform API (best-effort)
    if (access_token) {
      try {
        if (provider === 'youtube') {
          await fetch(`https://oauth2.googleapis.com/revoke?token=${access_token}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
          })
        } else if (provider === 'tiktok') {
          const clientKey = Deno.env.get('TIKTOK_CLIENT_KEY')!
          const clientSecret = Deno.env.get('TIKTOK_CLIENT_SECRET')!
          await fetch('https://open.tiktokapis.com/v2/oauth/revoke/', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: new URLSearchParams({
              client_key: clientKey,
              client_secret: clientSecret,
              token: access_token,
            }),
          })
        } else if (provider === 'instagram') {
          await fetch(
            `https://graph.facebook.com/v21.0/me/permissions?access_token=${access_token}`,
            { method: 'DELETE' }
          )
        }
      } catch (revokeError) {
        // Log but don't fail — token may already be expired/revoked
        console.error(`Token revocation failed for ${provider}:`, revokeError)
      }
    }

    // Clear tokens and mark disconnected
    const { error: updateError } = await supabase
      .from('social_connections')
      .update({
        status: 'disconnected',
        access_token: null,
        refresh_token: null,
        updated_at: new Date().toISOString(),
      })
      .eq('id', connection_id)

    if (updateError) {
      throw new Error(`Database error: ${updateError.message}`)
    }

    return new Response(
      JSON.stringify({ success: true }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    console.error('Revoke OAuth token error:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
