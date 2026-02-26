-- feed_likes テーブル作成
CREATE TABLE IF NOT EXISTS feed_likes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  submission_id UUID NOT NULL REFERENCES submission_requests(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, submission_id)
);

-- インデックス
CREATE INDEX IF NOT EXISTS idx_feed_likes_user ON feed_likes(user_id);
CREATE INDEX IF NOT EXISTS idx_feed_likes_submission ON feed_likes(submission_id);

-- RLS有効化
ALTER TABLE feed_likes ENABLE ROW LEVEL SECURITY;

-- ポリシー: ユーザーは自分のいいねを閲覧・作成・削除可能
CREATE POLICY "Users can view own likes" ON feed_likes
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own likes" ON feed_likes
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own likes" ON feed_likes
  FOR DELETE USING (auth.uid() = user_id);

-- 承認済みの提出を全ユーザーが閲覧可能にする
CREATE POLICY "All users can view approved submissions" ON submission_requests
  FOR SELECT USING (status = 'approved');
