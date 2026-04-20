-- =============================================
-- ROW LEVEL SECURITY POLICIES
-- =============================================

-- Public reads (products, stores, prices, categories)
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE prices ENABLE ROW LEVEL SECURITY;
ALTER TABLE price_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE scan_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE tracked_products ENABLE ROW LEVEL SECURITY;

-- Anyone can read product catalog
CREATE POLICY "Public read products" ON products FOR SELECT USING (true);
CREATE POLICY "Public read stores" ON stores FOR SELECT USING (true);
CREATE POLICY "Public read prices" ON prices FOR SELECT USING (true);
CREATE POLICY "Public read price_history" ON price_history FOR SELECT USING (true);
CREATE POLICY "Public read categories" ON categories FOR SELECT USING (true);

-- Authenticated users manage their own scan history
CREATE POLICY "Users manage own scan history" ON scan_history
  FOR ALL USING (auth.uid() = user_id);

-- Authenticated users manage their tracked products
CREATE POLICY "Users manage own tracked products" ON tracked_products
  FOR ALL USING (auth.uid() = user_id);

-- Admin role can write products/stores/prices
-- (You'll set this up via supabase dashboard: create role 'admin')
CREATE POLICY "Admin write products" ON products
  FOR ALL USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admin write stores" ON stores
  FOR ALL USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admin write prices" ON prices
  FOR ALL USING (auth.jwt() ->> 'role' = 'admin');