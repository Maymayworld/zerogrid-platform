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

    const { data: profiles, error: readErr } = await supabase
      .from('profiles')
      .select('stripe_customer_id')
      .eq('id', user.id)
      .limit(1)

    if (readErr) throw new Error(`Profile read: ${readErr.message}`)
    if (!profiles || profiles.length === 0) throw new Error('Profile not found')

    const { action, payment_method_id } = await req.json()
    const customerId = profiles[0].stripe_customer_id

    // No customer yet → empty list for 'list', error for others
    if (!customerId) {
      if (action === 'list') {
        return new Response(
          JSON.stringify({ payment_methods: [] }),
          { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
      throw new Error('No Stripe customer found. Please add a payment method first.')
    }

    if (action === 'list') {
      const paymentMethods = await stripe.paymentMethods.list({
        customer: customerId,
        type: 'card',
      })

      const customer = await stripe.customers.retrieve(customerId) as Stripe.Customer
      const defaultPmId = customer.invoice_settings?.default_payment_method

      const methods = paymentMethods.data.map((pm) => ({
        id: pm.id,
        card: {
          brand: pm.card?.brand,
          last4: pm.card?.last4,
          exp_month: pm.card?.exp_month,
          exp_year: pm.card?.exp_year,
        },
        is_default: pm.id === defaultPmId,
      }))

      return new Response(
        JSON.stringify({ payment_methods: methods }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    if (action === 'detach') {
      if (!payment_method_id) throw new Error('payment_method_id is required')
      await stripe.paymentMethods.detach(payment_method_id)
      return new Response(
        JSON.stringify({ success: true }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    if (action === 'set_default') {
      if (!payment_method_id) throw new Error('payment_method_id is required')
      await stripe.customers.update(customerId, {
        invoice_settings: { default_payment_method: payment_method_id },
      })
      return new Response(
        JSON.stringify({ success: true }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    throw new Error('Invalid action. Use: list, detach, or set_default')
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
