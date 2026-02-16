-- Add Stripe customer ID and balance to profiles
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS stripe_customer_id TEXT,
  ADD COLUMN IF NOT EXISTS balance INTEGER NOT NULL DEFAULT 0;

-- Create transactions table for tracking all monetary movements
CREATE TABLE IF NOT EXISTS transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id),
  type TEXT NOT NULL CHECK (type IN ('deposit', 'campaign_charge', 'payout', 'refund')),
  amount INTEGER NOT NULL,
  balance_after INTEGER NOT NULL,
  stripe_payment_intent_id TEXT,
  campaign_id UUID,
  description TEXT,
  status TEXT NOT NULL DEFAULT 'completed' CHECK (status IN ('pending', 'completed', 'failed')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexes for transactions
CREATE INDEX IF NOT EXISTS idx_transactions_user_id ON transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_campaign_id ON transactions(campaign_id) WHERE campaign_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_transactions_stripe_pi ON transactions(stripe_payment_intent_id) WHERE stripe_payment_intent_id IS NOT NULL;

-- Enable RLS on transactions
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

-- Users can only read their own transactions
CREATE POLICY "Users can view own transactions"
  ON transactions FOR SELECT
  USING (auth.uid() = user_id);

-- Service role can manage all transactions (Edge Functions use this)
CREATE POLICY "Service role can manage transactions"
  ON transactions FOR ALL
  USING (auth.role() = 'service_role');
