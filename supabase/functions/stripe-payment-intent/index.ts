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

    // Read profile
    const { data: profiles, error: readErr } = await supabase
      .from('profiles')
      .select('stripe_customer_id, display_name')
      .eq('id', user.id)
      .limit(1)

    if (readErr) throw new Error(`Profile read: ${readErr.message}`)
    if (!profiles || profiles.length === 0) throw new Error('Profile not found')
    const profile = profiles[0]

    let customerId: string = profile.stripe_customer_id

    if (!customerId) {
      const customer = await stripe.customers.create({
        email: user.email,
        name: profile.display_name,
        metadata: { supabase_user_id: user.id },
      })
      customerId = customer.id

      const admin = createClient(
        Deno.env.get('SUPABASE_URL')!,
        Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
      )
      const { error: writeErr } = await admin
        .from('profiles')
        .update({ stripe_customer_id: customerId })
        .eq('id', user.id)

      if (writeErr) throw new Error(`Save customer ID: ${writeErr.message}`)
    }

    const { amount } = await req.json()
    if (!amount || amount < 50) {
      throw new Error('Minimum deposit is ¥50')
    }

    const ephemeralKey = await stripe.ephemeralKeys.create(
      { customer: customerId },
      { apiVersion: '2023-10-16' }
    )

    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount,
      currency: 'jpy',
      customer: customerId,
      payment_method_types: ['card'],
      metadata: {
        supabase_user_id: user.id,
        type: 'deposit',
      },
    })

    return new Response(
      JSON.stringify({
        client_secret: paymentIntent.client_secret,
        payment_intent_id: paymentIntent.id,
        customer_id: customerId,
        ephemeral_key_secret: ephemeralKey.secret,
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
