-- reference_id カラムを追加（campaign_idのエイリアスとして使用）
ALTER TABLE transactions
  ADD COLUMN IF NOT EXISTS reference_id UUID;

-- 既存のcampaign_idをreference_idにコピー
UPDATE transactions
SET reference_id = campaign_id
WHERE reference_id IS NULL AND campaign_id IS NOT NULL;

-- withdrawal タイプを追加
ALTER TABLE transactions
  DROP CONSTRAINT IF EXISTS transactions_type_check;

ALTER TABLE transactions
  ADD CONSTRAINT transactions_type_check
  CHECK (type IN ('deposit', 'campaign_charge', 'payout', 'refund', 'withdrawal'));

-- balance_after をオプショナルに（Edge Functionで計算が難しい場合）
ALTER TABLE transactions
  ALTER COLUMN balance_after DROP NOT NULL;

-- インデックス追加
CREATE INDEX IF NOT EXISTS idx_transactions_reference_id ON transactions(reference_id) WHERE reference_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_transactions_type ON transactions(type);
