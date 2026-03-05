-- ================================================================
-- Supabase Dashboard > SQL Editor で実行してください
-- ================================================================
-- 実行手順:
--   1. Supabase Dashboard > Project Settings > API で
--      Service Role Key (secret) をコピー
--   2. 下の 'YOUR_SERVICE_ROLE_KEY' を実際のキーに置き換え
--   3. このSQL全体を SQL Editor に貼り付けて実行
-- ================================================================

-- Step 1: Vault に Service Role Key を保存
select vault.create_secret(
  'service_role_key',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdmenBlZ3dhdHd5emJiYmtjdXZ1Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NDM3OTQyNCwiZXhwIjoyMDc5OTU1NDI0fQ.vmbqKyZPfVOS658uIH83kpMprRjfj8mjGmBRRVtS-FM',
  'Supabase Service Role Key for Edge Function calls from pg_cron'
);

-- Step 2: 既存のジョブがあれば削除（冪等性）
select cron.unschedule('update-all-view-counts')
where exists (select 1 from cron.job where jobname = 'update-all-view-counts');

-- Step 3: 1時間ごとに視聴回数を一括更新するジョブを登録
-- このジョブ1つで以下が連鎖実行されます:
--   1. 全提出物の視聴回数を YouTube/TikTok/Instagram API から取得
--   2. submission_requests.view_count を更新
--   3. campaigns.total_views を再計算
--   4. 期限切れ/目標達成キャンペーンを検出
--   5. 報酬分配（10%プラットフォーム手数料込）
--   6. 未使用予算の返金 + 通知送信
select cron.schedule(
  'update-all-view-counts',
  '0 * * * *',
  $$
  select net.http_post(
    url := 'https://gfzpegwatwyzbbbkcuvu.supabase.co/functions/v1/update-all-view-counts',
    headers := jsonb_build_object(
      'Authorization', 'Bearer ' || (
        select decrypted_secret
        from vault.decrypted_secrets
        where name = 'service_role_key'
        limit 1
      ),
      'Content-Type', 'application/json'
    ),
    body := '{}'::jsonb
  ) as request_id;
  $$
);

-- Step 4: 登録確認
select jobid, jobname, schedule, command from cron.job;
