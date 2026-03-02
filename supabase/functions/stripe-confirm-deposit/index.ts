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

    const { payment_intent_id, checkout_session_id } = await req.json()

    // Resolve payment_intent_id from checkout_session_id if needed
    let resolvedPaymentIntentId = payment_intent_id
    if (!resolvedPaymentIntentId && checkout_session_id) {
      const session = await stripe.checkout.sessions.retrieve(checkout_session_id)
      if (!session.payment_intent) {
        throw new Error('No payment intent found for this checkout session')
      }
      resolvedPaymentIntentId = typeof session.payment_intent === 'string'
        ? session.payment_intent
        : session.payment_intent.id
    }

    if (!resolvedPaymentIntentId) {
      throw new Error('payment_intent_id or checkout_session_id is required')
    }

    // Verify payment with Stripe
    const paymentIntent = await stripe.paymentIntents.retrieve(resolvedPaymentIntentId)

    if (paymentIntent.status !== 'succeeded') {
      throw new Error(`Payment not confirmed. Status: ${paymentIntent.status}`)
    }
    if (paymentIntent.metadata?.supabase_user_id !== user.id) {
      throw new Error('Payment does not belong to this user')
    }

    // Prevent double-processing
    const { data: txRows } = await admin
      .from('transactions')
      .select('id')
      .eq('stripe_payment_intent_id', resolvedPaymentIntentId)
      .limit(1)

    if (txRows && txRows.length > 0) {
      const { data: balRows } = await supabase
        .from('profiles')
        .select('balance')
        .eq('id', user.id)
        .limit(1)

      return new Response(
        JSON.stringify({ new_balance: balRows?.[0]?.balance ?? 0, already_processed: true }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Get current balance
    const { data: profRows, error: profErr } = await supabase
      .from('profiles')
      .select('balance')
      .eq('id', user.id)
      .limit(1)

    if (profErr) throw new Error(`Profile read: ${profErr.message}`)
    if (!profRows || profRows.length === 0) throw new Error('Profile not found')

    const depositAmount = paymentIntent.amount
    const newBalance = (profRows[0].balance ?? 0) + depositAmount

    // Update balance
    const { error: balErr } = await admin
      .from('profiles')
      .update({ balance: newBalance })
      .eq('id', user.id)

    if (balErr) throw new Error(`Balance update: ${balErr.message}`)

    // Record transaction
    const { error: txErr } = await admin
      .from('transactions')
      .insert({
        user_id: user.id,
        type: 'deposit',
        amount: depositAmount,
        balance_after: newBalance,
        stripe_payment_intent_id: resolvedPaymentIntentId,
        description: `Deposit ¥${depositAmount.toLocaleString()}`,
        status: 'completed',
      })

    if (txErr) throw new Error(`Transaction insert: ${txErr.message}`)

    return new Response(
      JSON.stringify({ new_balance: newBalance }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
