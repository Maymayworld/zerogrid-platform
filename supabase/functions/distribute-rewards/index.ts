// supabase/functions/distribute-rewards/index.ts
// 報酬分配処理
// キャンペーン終了時（目標達成 or 締め切り）に実行

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface CreatorShare {
  creatorId: string
  viewCount: number
  sharePercentage: number
  rewardAmount: number
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)

    const { campaign_id, force } = await req.json()

    if (!campaign_id) {
      throw new Error('campaign_id is required')
    }

    // キャンペーン情報を取得
    const { data: campaign, error: campaignError } = await supabase
      .from('campaigns')
      .select('*')
      .eq('id', campaign_id)
      .single()

    if (campaignError || !campaign) {
      throw new Error('Campaign not found')
    }

    // 既に分配済みかチェック（completed = 分配済み）
    if (campaign.status === 'completed' && !force) {
      return new Response(
        JSON.stringify({
          success: false,
          message: 'Campaign already completed and rewards distributed'
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 冪等性チェック: このキャンペーンに対するpayoutトランザクションが既に存在するか
    const { data: existingPayouts } = await supabase
      .from('transactions')
      .select('id')
      .eq('reference_id', campaign_id)
      .eq('type', 'payout')
      .limit(1)

    if (existingPayouts && existingPayouts.length > 0 && !force) {
      // 既に分配済み — キャンペーンを完了状態にして終了
      await supabase
        .from('campaigns')
        .update({ status: 'completed' })
        .eq('id', campaign_id)

      return new Response(
        JSON.stringify({
          success: false,
          message: 'Rewards already distributed for this campaign (idempotency check)'
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 承認済み提出物を取得
    const { data: submissions, error: subError } = await supabase
      .from('submission_requests')
      .select('creator_id, view_count')
      .eq('campaign_id', campaign_id)
      .eq('status', 'approved')

    if (subError) {
      throw new Error(`Failed to fetch submissions: ${subError.message}`)
    }

    if (!submissions || submissions.length === 0) {
      // 参加者がいない場合、予算を企業に返金
      await supabase
        .from('campaigns')
        .update({ status: 'completed' })
        .eq('id', campaign_id)

      return new Response(
        JSON.stringify({ 
          success: true, 
          message: 'No submissions - campaign closed',
          distributed: 0,
          refunded: campaign.budget
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // クリエイター別に視聴回数を集計
    const creatorViews = new Map<string, number>()
    for (const sub of submissions) {
      const current = creatorViews.get(sub.creator_id) || 0
      creatorViews.set(sub.creator_id, current + (sub.view_count || 0))
    }

    const totalViews = Array.from(creatorViews.values()).reduce((a, b) => a + b, 0)
    const targetViews = campaign.target_views
    const budget = campaign.budget

    // 分配計算
    // 目標達成率を計算
    const PLATFORM_FEE_RATE = 0.10 // 10% プラットフォーム手数料
    const achievementRate = targetViews > 0 ? Math.min(totalViews / targetViews, 1) : 0 // 最大100%
    const distributableAmount = Math.floor(budget * achievementRate)
    const platformFee = Math.floor(distributableAmount * PLATFORM_FEE_RATE)
    const creatorPool = distributableAmount - platformFee
    const refundAmount = budget - distributableAmount

    // クリエイター別の分配額を計算（手数料控除後の原資から按分）
    const creatorShares: CreatorShare[] = []
    let totalDistributed = 0
    for (const [creatorId, viewCount] of creatorViews) {
      const sharePercentage = totalViews > 0 ? viewCount / totalViews : 0
      const rewardAmount = Math.floor(creatorPool * sharePercentage)

      creatorShares.push({
        creatorId,
        viewCount,
        sharePercentage: sharePercentage * 100,
        rewardAmount,
      })
      totalDistributed += rewardAmount
    }

    // floor切り捨てによる端数をプラットフォーム手数料に加算
    const remainder = creatorPool - totalDistributed
    const totalPlatformFee = platformFee + remainder

    // トランザクションとして分配を実行
    const now = new Date().toISOString()

    // 1. 各クリエイターに報酬を付与
    for (const share of creatorShares) {
      if (share.rewardAmount <= 0) continue

      // profiles の creator_balance を更新
      const { data: profile } = await supabase
        .from('profiles')
        .select('creator_balance')
        .eq('id', share.creatorId)
        .single()

      const currentBalance = (profile?.creator_balance as number) || 0

      await supabase
        .from('profiles')
        .update({ creator_balance: currentBalance + share.rewardAmount })
        .eq('id', share.creatorId)

      // トランザクション記録
      await supabase
        .from('transactions')
        .insert({
          user_id: share.creatorId,
          type: 'payout',
          amount: share.rewardAmount,
          description: `Reward for campaign: ${campaign.name}`,
          reference_id: campaign_id,
          created_at: now,
        })

      // 通知設定を確認してから送信
      const { data: notifPref } = await supabase
        .from('notification_preferences')
        .select('earnings')
        .eq('user_id', share.creatorId)
        .maybeSingle()

      if (!notifPref || notifPref.earnings !== false) {
        await supabase
          .from('notifications')
          .insert({
            user_id: share.creatorId,
            type: 'reward_received',
            title: 'Reward Received! 🎉',
            body: `You earned ¥${share.rewardAmount.toLocaleString()} from "${campaign.name}"`,
            data: {
              campaign_id,
              amount: share.rewardAmount,
              view_count: share.viewCount
            },
            created_at: now,
          })
      }
    }

    // 2. プラットフォーム手数料をトランザクションに記録（端数含む）
    if (totalPlatformFee > 0) {
      await supabase
        .from('transactions')
        .insert({
          user_id: campaign.organizer_id,
          type: 'platform_fee',
          amount: totalPlatformFee,
          description: `Platform fee (10%) for campaign: ${campaign.name}`,
          reference_id: campaign_id,
          created_at: now,
        })
    }

    // 3. 企業のorganizer_balanceから予算を差し引き、未使用分を返金
    {
      const { data: organizerProfile } = await supabase
        .from('profiles')
        .select('organizer_balance')
        .eq('id', campaign.organizer_id)
        .single()

      const organizerBalance = (organizerProfile?.organizer_balance as number) || 0

      // 予算全額を控除し、未使用分を返金（ネット: distributableAmount の控除）
      await supabase
        .from('profiles')
        .update({ organizer_balance: organizerBalance - budget + refundAmount })
        .eq('id', campaign.organizer_id)

      // 予算消費のトランザクション記録
      await supabase
        .from('transactions')
        .insert({
          user_id: campaign.organizer_id,
          type: 'campaign_expense',
          amount: budget,
          description: `Budget deducted for campaign: ${campaign.name}`,
          reference_id: campaign_id,
          created_at: now,
        })

      // 返金がある場合のトランザクション記録
      if (refundAmount > 0) {
        await supabase
          .from('transactions')
          .insert({
            user_id: campaign.organizer_id,
            type: 'refund',
            amount: refundAmount,
            description: `Unused budget refund for campaign: ${campaign.name}`,
            reference_id: campaign_id,
            created_at: now,
          })
      }
    }

    // 4. キャンペーンを完了状態に更新
    await supabase
      .from('campaigns')
      .update({ 
        status: 'completed',
        total_views: totalViews,
        updated_at: now,
      })
      .eq('id', campaign_id)

    return new Response(
      JSON.stringify({ 
        success: true,
        campaign_id,
        total_views: totalViews,
        target_views: targetViews,
        achievement_rate: achievementRate * 100,
        distributed: distributableAmount,
        platform_fee: totalPlatformFee,
        creator_pool: creatorPool,
        refunded: refundAmount,
        creator_shares: creatorShares,
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    console.error('Error:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
