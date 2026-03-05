-- submission_requests テーブルに外部キー制約を追加
-- PostgREST の埋め込みクエリ（campaigns:campaign_id, profiles:creator_id 等）に必要

ALTER TABLE submission_requests
  ADD CONSTRAINT fk_submission_requests_campaign
    FOREIGN KEY (campaign_id) REFERENCES campaigns(id) ON DELETE CASCADE,
  ADD CONSTRAINT fk_submission_requests_creator
    FOREIGN KEY (creator_id) REFERENCES profiles(id) ON DELETE CASCADE,
  ADD CONSTRAINT fk_submission_requests_organizer
    FOREIGN KEY (organizer_id) REFERENCES profiles(id) ON DELETE CASCADE;

-- Realtime を有効化（Stream API で未処理リクエスト数の監視に必要）
ALTER PUBLICATION supabase_realtime ADD TABLE submission_requests;

-- PostgREST スキーマキャッシュをリロード
NOTIFY pgrst, 'reload schema';
