-- Add token expiry tracking columns to social_connections
ALTER TABLE social_connections
  ADD COLUMN IF NOT EXISTS access_token_expires_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS refresh_token_expires_at TIMESTAMPTZ;
