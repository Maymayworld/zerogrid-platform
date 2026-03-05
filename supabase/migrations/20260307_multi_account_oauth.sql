-- 複数OAuthアカウント対応マイグレーション
-- social_connections: UNIQUE(user_id, platform) → UNIQUE(user_id, provider, provider_account_id)
-- submission_requests: social_connection_id カラム追加

-- 1. 既存のUNIQUE制約を削除（カラムリネーム前後の両方に対応）
ALTER TABLE social_connections
  DROP CONSTRAINT IF EXISTS social_connections_user_id_platform_key;
ALTER TABLE social_connections
  DROP CONSTRAINT IF EXISTS social_connections_user_id_provider_key;

-- 万が一、上記名前に該当しない場合のフォールバック
-- user_id + provider (または platform) を含む全UNIQUE制約を動的に削除
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN
    SELECT con.conname
    FROM pg_constraint con
    JOIN pg_class rel ON rel.oid = con.conrelid
    JOIN pg_namespace nsp ON nsp.oid = rel.relnamespace
    WHERE rel.relname = 'social_connections'
      AND nsp.nspname = 'public'
      AND con.contype = 'u'
      AND con.conname != 'social_connections_user_provider_account_key'
  LOOP
    EXECUTE format('ALTER TABLE social_connections DROP CONSTRAINT IF EXISTS %I', r.conname);
  END LOOP;
END $$;

-- 2. 新しいUNIQUE制約を追加（同じアカウントの重複接続を防止、別アカウントはOK）
-- IF NOT EXISTS は ALTER TABLE ADD CONSTRAINT に使えないため、DO ブロックで対応
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'social_connections_user_provider_account_key'
  ) THEN
    ALTER TABLE social_connections
      ADD CONSTRAINT social_connections_user_provider_account_key
      UNIQUE (user_id, provider, provider_account_id);
  END IF;
END $$;

-- 3. submission_requests に social_connection_id カラム追加
ALTER TABLE submission_requests
  ADD COLUMN IF NOT EXISTS social_connection_id UUID REFERENCES social_connections(id) ON DELETE SET NULL;

-- 4. インデックス追加
CREATE INDEX IF NOT EXISTS idx_submission_requests_social_connection_id
  ON submission_requests(social_connection_id);
