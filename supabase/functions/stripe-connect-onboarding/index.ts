import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"
import Stripe from "https://esm.sh/stripe@14.14.0?target=deno"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY')!, {
      apiVersion: '2023-10-16',
    })

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    )
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) throw new Error('Not authenticated')

    const admin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    const { return_url } = await req.json()

    // プロフィール取得
    const { data: profiles, error: readErr } = await supabase
      .from('profiles')
      .select('stripe_connect_id, display_name')
      .eq('id', user.id)
      .limit(1)

    if (readErr) throw new Error(`Profile read: ${readErr.message}`)
    if (!profiles || profiles.length === 0) throw new Error('Profile not found')
    const profile = profiles[0]

    let connectId: string = profile.stripe_connect_id

    // Connected Accountがなければ作成
    if (!connectId) {
      const account = await stripe.accounts.create({
        type: 'express',
        country: 'JP',
        email: user.email,
        capabilities: {
          transfers: { requested: true },
        },
        business_type: 'individual',
        metadata: { supabase_user_id: user.id },
      })
      connectId = account.id

      const { error: writeErr } = await admin
        .from('profiles')
        .update({ stripe_connect_id: connectId })
        .eq('id', user.id)

      if (writeErr) throw new Error(`Save connect ID: ${writeErr.message}`)
    }

    // オンボーディングリンク生成
    const accountLink = await stripe.accountLinks.create({
      account: connectId,
      refresh_url: return_url || 'https://zerogrid.jp/connect/refresh',
      return_url: return_url || 'https://zerogrid.jp/connect/return',
      type: 'account_onboarding',
    })

    return new Response(
      JSON.stringify({
        connect_id: connectId,
        onboarding_url: accountLink.url,
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
