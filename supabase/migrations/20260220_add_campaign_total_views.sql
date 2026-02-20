-- キャンペーンに合計視聴回数カラムを追加
ALTER TABLE campaigns
  ADD COLUMN IF NOT EXISTS total_views INTEGER NOT NULL DEFAULT 0;

-- インデックス追加
CREATE INDEX IF NOT EXISTS idx_campaigns_total_views ON campaigns(total_views);

-- 既存データの合計視聴回数を計算して更新
UPDATE campaigns c
SET total_views = COALESCE((
  SELECT SUM(view_count)
  FROM submission_requests sr
  WHERE sr.campaign_id = c.id
  AND sr.status = 'approved'
), 0);
