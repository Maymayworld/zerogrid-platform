// supabase/functions/process-ended-campaigns/index.ts
// 終了したキャンペーンの自動処理（締め切り到達 or 目標達成）
// 定期実行（例: 1時間ごと）で呼び出す
// 修正: キャンペーンをprocessing状態にしてから処理し、重複通知を防止

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)

    const now = new Date().toISOString()

    // 1. 締め切りを過ぎたアクティブなキャンペーンを取得
    const { data: expiredCampaigns, error: expiredError } = await supabase
      .from('campaigns')
      .select('id, name, organizer_id, budget, target_views, deadline')
      .eq('status', 'active')
      .lt('deadline', now)

    if (expiredError) {
      throw new Error(`Failed to fetch expired campaigns: ${expiredError.message}`)
    }

    // 2. 目標達成したキャンペーンを取得
    const { data: activeCampaigns, error: activeError } = await supabase
      .from('campaigns')
      .select('id, name, organizer_id, budget, target_views, total_views')
      .eq('status', 'active')
      .gte('deadline', now)

    if (activeError) {
      throw new Error(`Failed to fetch active campaigns: ${activeError.message}`)
    }

    // 目標達成済みのキャンペーンをフィルタ
    const achievedCampaigns = (activeCampaigns || []).filter(c => {
      return (c.total_views || 0) >= c.target_views && c.target_views > 0
    })

    // 処理するキャンペーン一覧
    const campaignsToProcess = [
      ...(expiredCampaigns || []).map(c => ({ ...c, reason: 'deadline' })),
      ...achievedCampaigns.map(c => ({ ...c, reason: 'achieved' })),
    ]

    if (campaignsToProcess.length === 0) {
      return new Response(
        JSON.stringify({
          success: true,
          message: 'No campaigns to process',
          processed: 0
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 3. 全対象キャンペーンを先にprocessing状態にする（重複処理防止）
    const campaignIds = campaignsToProcess.map(c => c.id)
    await supabase
      .from('campaigns')
      .update({ status: 'processing', updated_at: now })
      .in('id', campaignIds)

    const results = []

    for (const campaign of campaignsToProcess) {
      try {
        // distribute-rewards を呼び出す
        const response = await fetch(
          `${supabaseUrl}/functions/v1/distribute-rewards`,
          {
            method: 'POST',
            headers: {
              'Authorization': `Bearer ${supabaseKey}`,
              'Content-Type': 'application/json',
            },
            body: JSON.stringify({ campaign_id: campaign.id }),
          }
        )

        const result = await response.json()
        results.push({
          campaign_id: campaign.id,
          campaign_name: campaign.name,
          reason: campaign.reason,
          ...result,
        })

        // 通知設定を確認してから企業に通知（重複チェック付き）
        const { data: existingNotif } = await supabase
          .from('notifications')
          .select('id')
          .eq('user_id', campaign.organizer_id)
          .eq('type', 'campaign_completed')
          .eq('data->>campaign_id', campaign.id)
          .maybeSingle()

        if (existingNotif) {
          // 既に通知済み → スキップ
          continue
        }

        const { data: notifPref } = await supabase
          .from('notification_preferences')
          .select('campaign')
          .eq('user_id', campaign.organizer_id)
          .maybeSingle()

        if (!notifPref || notifPref.campaign !== false) {
          await supabase
            .from('notifications')
            .insert({
              user_id: campaign.organizer_id,
              type: 'campaign_completed',
              title: 'Campaign Completed',
              body: campaign.reason === 'achieved'
                ? `"${campaign.name}" has reached its target views! Rewards have been distributed.`
                : `"${campaign.name}" has reached its deadline. Rewards have been distributed based on achieved views.`,
              data: {
                campaign_id: campaign.id,
                reason: campaign.reason
              },
              created_at: now,
            })
        }
      } catch (error) {
        // 処理失敗した場合、そのキャンペーンだけactiveに戻す
        await supabase
          .from('campaigns')
          .update({ status: 'active', updated_at: now })
          .eq('id', campaign.id)
          .eq('status', 'processing')

        results.push({
          campaign_id: campaign.id,
          campaign_name: campaign.name,
          error: error.message,
        })
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        processed: campaignsToProcess.length,
        results,
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
