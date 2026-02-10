-- submission_requests テーブル作成
CREATE TABLE IF NOT EXISTS submission_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  campaign_id UUID NOT NULL,
  creator_id UUID NOT NULL,
  organizer_id UUID NOT NULL,
  
  -- 動画情報
  video_url TEXT NOT NULL,
  platform TEXT NOT NULL DEFAULT 'youtube',
  video_title TEXT,
  video_thumbnail_url TEXT,
  view_count INT DEFAULT 0,
  
  -- ステータス
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'skipped')),
  submitted_at TIMESTAMPTZ DEFAULT NOW(),
  reviewed_at TIMESTAMPTZ,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- インデックス
CREATE INDEX IF NOT EXISTS idx_submission_requests_organizer_status 
  ON submission_requests(organizer_id, status);
CREATE INDEX IF NOT EXISTS idx_submission_requests_campaign 
  ON submission_requests(campaign_id);
CREATE INDEX IF NOT EXISTS idx_submission_requests_creator 
  ON submission_requests(creator_id);

-- RLS有効化
ALTER TABLE submission_requests ENABLE ROW LEVEL SECURITY;

-- ポリシー: 企業は自分宛のリクエストを閲覧・更新可能
CREATE POLICY "Organizers can view their requests" ON submission_requests
  FOR SELECT USING (auth.uid() = organizer_id);

CREATE POLICY "Organizers can update their requests" ON submission_requests
  FOR UPDATE USING (auth.uid() = organizer_id);

-- ポリシー: クリエイターは自分のリクエストを閲覧・作成可能
CREATE POLICY "Creators can view their submissions" ON submission_requests
  FOR SELECT USING (auth.uid() = creator_id);

CREATE POLICY "Creators can insert submissions" ON submission_requests
  FOR INSERT WITH CHECK (auth.uid() = creator_id);

-- updated_at自動更新トリガー
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_submission_requests_updated_at ON submission_requests;
CREATE TRIGGER update_submission_requests_updated_at
  BEFORE UPDATE ON submission_requests
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
