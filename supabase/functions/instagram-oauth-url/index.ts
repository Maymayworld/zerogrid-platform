// supabase/functions/instagram-oauth-url/index.ts
// Instagram Graph API (via Facebook Login) OAuth URL生成
// 旧 Basic Display API は2024年9月に廃止済み
// Meta Business App + Facebook Login を使用

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { user_id } = await req.json()

    if (!user_id) {
      return new Response(
        JSON.stringify({ error: 'user_id is required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // INSTAGRAM_CLIENT_ID = Meta App ID
    const appId = Deno.env.get('INSTAGRAM_CLIENT_ID')
    const redirectUri = Deno.env.get('INSTAGRAM_REDIRECT_URI') ||
      `${Deno.env.get('SUPABASE_URL')}/functions/v1/oauth-callback`

    if (!appId) {
      return new Response(
        JSON.stringify({ error: 'Instagram not configured' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Facebook Login OAuth (Instagram Graph API経由)
    // instagram_basic: プロフィール読み取り
    // instagram_content_publish: コンテンツ投稿（要アプリ審査）
    // pages_show_list: Facebookページ一覧
    // pages_read_engagement: ページインサイト
    const scope = 'instagram_basic,instagram_content_publish,pages_show_list,pages_read_engagement'
    const state = btoa(JSON.stringify({ user_id, platform: 'instagram' }))

    const url = new URL('https://www.facebook.com/v21.0/dialog/oauth')
    url.searchParams.set('client_id', appId)
    url.searchParams.set('redirect_uri', redirectUri)
    url.searchParams.set('scope', scope)
    url.searchParams.set('response_type', 'code')
    url.searchParams.set('state', state)

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
