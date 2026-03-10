// supabase/functions/instagram-oauth-url/index.ts
// Instagram Graph API (via Facebook Login) OAuth URL生成
// 旧 Basic Display API は2024年9月に廃止済み
// Meta Business App + Facebook Login を使用

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

    // INSTAGRAM_CLIENT_ID = Meta App ID
    const appId = Deno.env.get('INSTAGRAM_CLIENT_ID')
    const redirectUri = Deno.env.get('INSTAGRAM_REDIRECT_URI') ||
      `${supabaseUrl}/functions/v1/oauth-callback`

    if (!appId) {
      return new Response(
        JSON.stringify({ error: 'Instagram not configured' }),
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
        platform: 'instagram',
        expires_at: expiresAt.toISOString(),
      })
      .select('id')
      .single()

    if (dbError || !stateRecord) {
      throw new Error('Failed to create OAuth state')
    }

    // Facebook Login OAuth (Instagram Graph API経由)
    // instagram_basic: プロフィール読み取り
    // instagram_content_publish: コンテンツ投稿（要アプリ審査）
    // pages_show_list: Facebookページ一覧
    // pages_read_engagement: ページインサイト
    const scope = 'instagram_basic,instagram_content_publish,pages_show_list,pages_read_engagement'

    const url = new URL('https://www.facebook.com/v21.0/dialog/oauth')
    url.searchParams.set('client_id', appId)
    url.searchParams.set('redirect_uri', redirectUri)
    url.searchParams.set('scope', scope)
    url.searchParams.set('response_type', 'code')
    url.searchParams.set('state', stateRecord.id)
    url.searchParams.set('auth_type', 'rerequest')

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
