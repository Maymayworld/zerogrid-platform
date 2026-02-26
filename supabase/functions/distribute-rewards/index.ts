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

    // 既に分配済みかチェック
    if (campaign.status === 'completed' && !force) {
      return new Response(
        JSON.stringify({ 
          success: false, 
          message: 'Campaign already completed and rewards distributed' 
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
    const achievementRate = targetViews > 0 ? Math.min(totalViews / targetViews, 1) : 0 // 最大100%
    const distributableAmount = Math.floor(budget * achievementRate)
    const refundAmount = budget - distributableAmount

    // クリエイター別の分配額を計算
    const creatorShares: CreatorShare[] = []
    for (const [creatorId, viewCount] of creatorViews) {
      const sharePercentage = totalViews > 0 ? viewCount / totalViews : 0
      const rewardAmount = Math.floor(distributableAmount * sharePercentage)
      
      creatorShares.push({
        creatorId,
        viewCount,
        sharePercentage: sharePercentage * 100,
        rewardAmount,
      })
    }

    // トランザクションとして分配を実行
    const now = new Date().toISOString()

    // 1. 各クリエイターに報酬を付与
    for (const share of creatorShares) {
      if (share.rewardAmount <= 0) continue

      // profiles の balance を更新
      const { data: profile } = await supabase
        .from('profiles')
        .select('balance')
        .eq('id', share.creatorId)
        .single()

      const currentBalance = (profile?.balance as number) || 0
      
      await supabase
        .from('profiles')
        .update({ balance: currentBalance + share.rewardAmount })
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

    // 2. 残額を企業に返金（refundAmount > 0 の場合）
    if (refundAmount > 0) {
      const { data: organizerProfile } = await supabase
        .from('profiles')
        .select('balance')
        .eq('id', campaign.organizer_id)
        .single()

      const organizerBalance = (organizerProfile?.balance as number) || 0
      
      await supabase
        .from('profiles')
        .update({ balance: organizerBalance + refundAmount })
        .eq('id', campaign.organizer_id)

      // トランザクション記録
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

    // 3. キャンペーンを完了状態に更新
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
