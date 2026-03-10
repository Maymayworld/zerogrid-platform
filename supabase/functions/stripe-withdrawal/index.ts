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

    const { amount } = await req.json()
    if (!amount || amount < 1000) throw new Error('Minimum withdrawal is ¥1,000')

    // プロフィール取得
    const { data: profiles, error: profErr } = await supabase
      .from('profiles')
      .select('stripe_connect_id, creator_balance')
      .eq('id', user.id)
      .limit(1)

    if (profErr) throw new Error(`Profile read: ${profErr.message}`)
    if (!profiles || profiles.length === 0) throw new Error('Profile not found')
    const profile = profiles[0]

    if (!profile.stripe_connect_id) {
      throw new Error('Payout setup not completed. Please set up your payout account first.')
    }

    const currentBalance = profile.creator_balance ?? 0
    if (amount > currentBalance) {
      throw new Error(`Insufficient balance. Available: ¥${currentBalance.toLocaleString()}`)
    }

    // Stripe Connectアカウントの状態確認
    const account = await stripe.accounts.retrieve(profile.stripe_connect_id)
    if (!account.payouts_enabled) {
      throw new Error('Payout account verification is not complete.')
    }

    // 1. 先に残高を差し引く（二重引き出し防止）
    const newBalance = currentBalance - amount
    const { error: balErr } = await admin
      .from('profiles')
      .update({ creator_balance: newBalance })
      .eq('id', user.id)

    if (balErr) throw new Error(`Balance update: ${balErr.message}`)

    // 2. Stripe Transfer: プラットフォーム → Connected Account
    let transfer
    try {
      transfer = await stripe.transfers.create({
        amount: amount,
        currency: 'jpy',
        destination: profile.stripe_connect_id,
        metadata: {
          supabase_user_id: user.id,
          type: 'creator_withdrawal',
        },
      })
    } catch (stripeError) {
      // Transfer失敗 → 残高を復元
      await admin
        .from('profiles')
        .update({ creator_balance: currentBalance })
        .eq('id', user.id)
      throw new Error(`Stripe transfer failed: ${stripeError.message}`)
    }

    // 3. トランザクション記録
    const { error: txErr } = await admin
      .from('transactions')
      .insert({
        user_id: user.id,
        type: 'withdrawal',
        amount: -amount,
        balance_after: newBalance,
        stripe_payment_intent_id: transfer.id,
        description: `Withdrawal ¥${amount.toLocaleString()}`,
        status: 'completed',
      })

    if (txErr) {
      // トランザクション記録失敗はログのみ（Transfer成功済みなので残高は戻さない）
      console.error('Transaction insert failed (transfer already succeeded):', txErr)
    }

    // 通知設定を確認してから送信
    const { data: notifPref } = await admin
      .from('notification_preferences')
      .select('earnings')
      .eq('user_id', user.id)
      .maybeSingle()

    if (!notifPref || notifPref.earnings !== false) {
      await admin.from('notifications').insert({
        user_id: user.id,
        type: 'reward_received',
        title: 'Withdrawal Processed',
        body: `¥${amount.toLocaleString()} has been sent to your bank account`,
        data: { transfer_id: transfer.id, amount },
      })
    }

    return new Response(
      JSON.stringify({
        new_balance: newBalance,
        transfer_id: transfer.id,
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
