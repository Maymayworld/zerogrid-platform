-- 動画アップロード対応: submission_requests に列追加
ALTER TABLE submission_requests
  ADD COLUMN IF NOT EXISTS local_video_url TEXT,
  ADD COLUMN IF NOT EXISTS video_file_size INTEGER,
  ADD COLUMN IF NOT EXISTS video_duration INTEGER,
  ADD COLUMN IF NOT EXISTS upload_status TEXT DEFAULT 'pending',
  ADD COLUMN IF NOT EXISTS platform_post_id TEXT,
  ADD COLUMN IF NOT EXISTS platform_post_url TEXT;

-- video_url を nullable に変更（ファイルアップロード時はURLなし）
ALTER TABLE submission_requests ALTER COLUMN video_url DROP NOT NULL;

-- ストレージバケット作成
INSERT INTO storage.buckets (id, name, public)
VALUES
  ('videos', 'videos', true),
  ('thumbnails', 'thumbnails', true),
  ('temp', 'temp', false)
ON CONFLICT (id) DO NOTHING;

-- videos バケットポリシー
CREATE POLICY "Users can upload videos" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'videos' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "Videos are publicly accessible" ON storage.objects
  FOR SELECT TO public
  USING (bucket_id = 'videos');

CREATE POLICY "Users can delete own videos" ON storage.objects
  FOR DELETE TO authenticated
  USING (bucket_id = 'videos' AND (storage.foldername(name))[1] = auth.uid()::text);

-- thumbnails バケットポリシー
CREATE POLICY "Users can upload thumbnails" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'thumbnails' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "Thumbnails are publicly accessible" ON storage.objects
  FOR SELECT TO public
  USING (bucket_id = 'thumbnails');

CREATE POLICY "Users can delete own thumbnails" ON storage.objects
  FOR DELETE TO authenticated
  USING (bucket_id = 'thumbnails' AND (storage.foldername(name))[1] = auth.uid()::text);

-- temp バケットポリシー
CREATE POLICY "Users can upload to temp" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'temp' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "Users can read own temp files" ON storage.objects
  FOR SELECT TO authenticated
  USING (bucket_id = 'temp' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "Users can delete own temp files" ON storage.objects
  FOR DELETE TO authenticated
  USING (bucket_id = 'temp' AND (storage.foldername(name))[1] = auth.uid()::text);
