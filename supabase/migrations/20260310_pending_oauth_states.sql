-- OAuth state management table for CSRF protection
-- Replaces unsigned base64 state with server-side UUID lookup
CREATE TABLE pending_oauth_states (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  platform TEXT NOT NULL CHECK (platform IN ('youtube', 'instagram', 'tiktok')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL,
  used BOOLEAN DEFAULT FALSE
);

-- Index for cleanup of expired records
CREATE INDEX idx_pending_oauth_states_expires ON pending_oauth_states(expires_at);
