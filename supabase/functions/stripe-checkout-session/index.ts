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

    const { mode, amount, success_url, cancel_url } = await req.json()

    if (!success_url || !cancel_url) {
      throw new Error('success_url and cancel_url are required')
    }

    // Get or create Stripe customer
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
      await admin
        .from('profiles')
        .update({ stripe_customer_id: customerId })
        .eq('id', user.id)
    }

    if (mode === 'setup') {
      // Setup mode: save a payment method without charging
      const session = await stripe.checkout.sessions.create({
        mode: 'setup',
        customer: customerId,
        payment_method_types: ['card'],
        success_url: `${success_url}?setup_success=true`,
        cancel_url: cancel_url,
      })

      return new Response(
        JSON.stringify({ checkout_url: session.url }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    } else {
      // Payment mode: deposit funds
      if (!amount || amount < 50) {
        throw new Error('Minimum deposit is 50 JPY')
      }

      const session = await stripe.checkout.sessions.create({
        mode: 'payment',
        customer: customerId,
        line_items: [{
          price_data: {
            currency: 'jpy',
            product_data: { name: 'Zero Grid Wallet Deposit' },
            unit_amount: amount,
          },
          quantity: 1,
        }],
        payment_intent_data: {
          metadata: {
            supabase_user_id: user.id,
            type: 'deposit',
          },
        },
        success_url: `${success_url}?checkout_session_id={CHECKOUT_SESSION_ID}`,
        cancel_url: cancel_url,
      })

      return new Response(
        JSON.stringify({
          checkout_url: session.url,
          session_id: session.id,
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
