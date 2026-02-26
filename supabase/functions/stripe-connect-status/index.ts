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

    // プロフィールからconnect_id取得
    const { data: profiles } = await supabase
      .from('profiles')
      .select('stripe_connect_id')
      .eq('id', user.id)
      .limit(1)

    const connectId = profiles?.[0]?.stripe_connect_id
    if (!connectId) {
      return new Response(
        JSON.stringify({
          has_connect: false,
          payouts_enabled: false,
          details_submitted: false,
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Stripe Connectアカウント状態を取得
    const account = await stripe.accounts.retrieve(connectId)

    return new Response(
      JSON.stringify({
        has_connect: true,
        payouts_enabled: account.payouts_enabled,
        details_submitted: account.details_submitted,
        charges_enabled: account.charges_enabled,
        requirements: account.requirements?.currently_due || [],
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
