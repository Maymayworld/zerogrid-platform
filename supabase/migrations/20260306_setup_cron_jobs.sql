-- ================================================================
-- 定期実行ジョブの設定 (pg_cron + pg_net + vault)
-- ================================================================
-- このマイグレーションで以下を行います:
--   1. pg_cron, pg_net 拡張機能の有効化
--   2. Vault に Service Role Key を保存
--   3. 1時間ごとの cron ジョブを登録
--
-- ※ マイグレーション適用前に、Supabase Dashboard > Project Settings
--    > API から Service Role Key を確認し、下記の
--    'YOUR_SERVICE_ROLE_KEY' を実際のキーに置き換えてください。
-- ================================================================

-- 拡張機能を有効化
create extension if not exists pg_cron with schema pg_catalog;
create extension if not exists pg_net with schema extensions;

-- ================================================================
-- 以下を Supabase Dashboard > SQL Editor で実行してください
-- 'YOUR_SERVICE_ROLE_KEY' を実際のキーに置き換えてください
-- ================================================================

-- Step 1: Vault に Service Role Key を保存（1回だけ実行）
-- select vault.create_secret(
--   'service_role_key',
--   'YOUR_SERVICE_ROLE_KEY',
--   'Supabase Service Role Key for Edge Function calls'
-- );

-- Step 2: 視聴回数の一括更新（1時間ごと）
-- ※ 更新完了後、自動で process-ended-campaigns を呼び出し、
--    期限切れ or 目標達成の案件を検出→報酬分配を実行します。
-- つまりこの1つのcronで以下が全て処理されます:
--   1. 全提出物の視聴回数を最新化
--   2. キャンペーンの total_views を再計算
--   3. 期限切れ/目標達成の案件を検出
--   4. 該当案件の報酬分配(10%プラットフォーム手数料含む)
--   5. 未使用予算の返金
--   6. オーガナイザーへの完了通知
--
-- select cron.schedule(
--   'update-all-view-counts',
--   '0 * * * *',
--   $$
--   select net.http_post(
--     url := 'https://gfzpegwatwyzbbbkcuvu.supabase.co/functions/v1/update-all-view-counts',
--     headers := jsonb_build_object(
--       'Authorization', 'Bearer ' || (
--         select decrypted_secret
--         from vault.decrypted_secrets
--         where name = 'service_role_key'
--         limit 1
--       ),
--       'Content-Type', 'application/json'
--     ),
--     body := '{}'::jsonb
--   ) as request_id;
--   $$
-- );

-- 確認用: 登録済みジョブ一覧
-- select * from cron.job;

-- 実行履歴確認
-- select * from cron.job_run_details order by start_time desc limit 20;
