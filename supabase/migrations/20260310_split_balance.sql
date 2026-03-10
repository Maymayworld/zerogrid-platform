-- Wallet separation: split single balance into organizer_balance and creator_balance
-- This prevents cross-role fund access vulnerability

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS organizer_balance INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS creator_balance INTEGER NOT NULL DEFAULT 0;

-- Migrate existing data based on role
UPDATE profiles SET organizer_balance = balance WHERE role = 'organizer';
UPDATE profiles SET creator_balance = balance WHERE role = 'creator';
