-- Add google_calendar to social_connections platform options
-- First, drop the existing check constraint
ALTER TABLE social_connections DROP CONSTRAINT IF EXISTS social_connections_platform_check;

-- Add new check constraint including google_calendar
ALTER TABLE social_connections ADD CONSTRAINT social_connections_platform_check 
  CHECK (platform IN ('youtube', 'instagram', 'tiktok', 'google_calendar'));
