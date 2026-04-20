-- =============================================
-- STEP 1: Create the function FIRST (before the trigger)
-- =============================================

-- Function to handle new user creation
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_profiles (id, full_name)
  VALUES (NEW.id, NEW.raw_user_meta_data->>'full_name');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- STEP 2: Create user_profiles table
-- =============================================

CREATE TABLE IF NOT EXISTS public.user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT,
  avatar_url TEXT,
  preferred_city TEXT,
  notifications_enabled BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- STEP 3: Now create the trigger (function already exists)
-- =============================================

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- =============================================
-- STEP 4: Add trigger for updated_at on user_profiles
-- =============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS user_profiles_updated_at ON user_profiles;
CREATE TRIGGER user_profiles_updated_at
  BEFORE UPDATE ON user_profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =============================================
-- STEP 5: Now add all missing columns to existing tables
-- =============================================

-- Add missing columns to stores table
ALTER TABLE stores 
ADD COLUMN IF NOT EXISTS address TEXT,
ADD COLUMN IF NOT EXISTS phone TEXT;

-- Add missing columns to products table
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS ingredients TEXT;

-- Add missing columns to scan_history table
ALTER TABLE scan_history 
ADD COLUMN IF NOT EXISTS product_name TEXT,
ADD COLUMN IF NOT EXISTS product_image_url TEXT;

-- Verify sale_price column exists in prices
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'prices' AND column_name = 'sale_price'
    ) THEN
        ALTER TABLE prices ADD COLUMN sale_price NUMERIC(10,2);
    END IF;
END $$;

-- =============================================
-- STEP 6: Create search function
-- =============================================

CREATE OR REPLACE FUNCTION search_products(search_query TEXT)
RETURNS TABLE(id UUID, name TEXT, brand TEXT, barcode TEXT, image_url TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id,
    p.name,
    p.brand,
    p.barcode,
    p.image_url
  FROM products p
  WHERE p.name ILIKE '%' || search_query || '%'
     OR p.brand ILIKE '%' || search_query || '%'
     OR p.barcode = search_query
  LIMIT 20;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- STEP 7: Create cheapest price function
-- =============================================

CREATE OR REPLACE FUNCTION get_cheapest_price(product_id_param UUID)
RETURNS TABLE(store_id UUID, store_name TEXT, price NUMERIC, sale_price NUMERIC) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    s.id,
    s.name,
    p.price,
    p.sale_price
  FROM prices p
  JOIN stores s ON s.id = p.store_id
  WHERE p.product_id = product_id_param
  ORDER BY COALESCE(p.sale_price, p.price) ASC
  LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- STEP 8: Create view for products with best price
-- =============================================

CREATE OR REPLACE VIEW products_with_best_price AS
SELECT 
  p.*,
  MIN(COALESCE(pr.sale_price, pr.price)) as best_price,
  (SELECT s.name FROM stores s 
   JOIN prices pr2 ON pr2.store_id = s.id 
   WHERE pr2.product_id = p.id 
   ORDER BY COALESCE(pr2.sale_price, pr2.price) ASC 
   LIMIT 1) as cheapest_store
FROM products p
LEFT JOIN prices pr ON pr.product_id = p.id
GROUP BY p.id;

-- =============================================
-- STEP 9: Add RLS policies for user_profiles
-- =============================================

ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users read own profile" ON user_profiles;
CREATE POLICY "Users read own profile" ON user_profiles 
  FOR SELECT USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users update own profile" ON user_profiles;
CREATE POLICY "Users update own profile" ON user_profiles 
  FOR UPDATE USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users insert own profile" ON user_profiles;
CREATE POLICY "Users insert own profile" ON user_profiles 
  FOR INSERT WITH CHECK (auth.uid() = id);

-- =============================================
-- STEP 10: Add missing RLS policies for existing tables
-- =============================================

-- Add INSERT policy for scan_history
DROP POLICY IF EXISTS "Users insert own scan_history" ON scan_history;
CREATE POLICY "Users insert own scan_history" ON scan_history 
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Add UPDATE policy for scan_history
DROP POLICY IF EXISTS "Users update own scan_history" ON scan_history;
CREATE POLICY "Users update own scan_history" ON scan_history 
  FOR UPDATE USING (auth.uid() = user_id);

-- Add DELETE policy for scan_history
DROP POLICY IF EXISTS "Users delete own scan_history" ON scan_history;
CREATE POLICY "Users delete own scan_history" ON scan_history 
  FOR DELETE USING (auth.uid() = user_id);

-- Add INSERT policy for tracked_products
DROP POLICY IF EXISTS "Users insert own tracked_products" ON tracked_products;
CREATE POLICY "Users insert own tracked_products" ON tracked_products 
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Add DELETE policy for tracked_products
DROP POLICY IF EXISTS "Users delete own tracked_products" ON tracked_products;
CREATE POLICY "Users delete own tracked_products" ON tracked_products 
  FOR DELETE USING (auth.uid() = user_id);

-- =============================================
-- STEP 11: Add missing indexes for performance
-- =============================================

CREATE INDEX IF NOT EXISTS idx_products_name ON products(name);
CREATE INDEX IF NOT EXISTS idx_prices_price ON prices(price);
CREATE INDEX IF NOT EXISTS idx_scan_history_barcode ON scan_history(barcode);
CREATE INDEX IF NOT EXISTS idx_price_history_store ON price_history(store_id);
CREATE INDEX IF NOT EXISTS idx_tracked_products_user ON tracked_products(user_id);

-- =============================================
-- STEP 12: Grant permissions
-- =============================================

GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON scan_history, tracked_products, user_profiles TO authenticated;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- =============================================
-- STEP 13: Add more seed data (Optional)
-- =============================================

-- Add more categories
INSERT INTO categories (id, name, icon_name) VALUES
  ('11111111-0000-0000-0000-000000000006', 'Fruits & Vegetables', 'local_grocery_store'),
  ('11111111-0000-0000-0000-000000000007', 'Meat & Poultry', 'restaurant'),
  ('11111111-0000-0000-0000-000000000008', 'Frozen Foods', 'ac_unit'),
  ('11111111-0000-0000-0000-000000000009', 'Personal Care', 'bathroom'),
  ('11111111-0000-0000-0000-000000000010', 'Household', 'home')
ON CONFLICT (id) DO NOTHING;

-- Add more stores
INSERT INTO stores (id, name, logo_url, city, website, is_active, address, phone) VALUES
  ('22222222-0000-0000-0000-000000000006', 'Supérette', NULL, 'Alger', NULL, true, '123 Rue Didouche Mourad, Alger', '+213 123 456 789')
ON CONFLICT (id) DO NOTHING;

-- Add more products
INSERT INTO products (id, barcode, name, brand, image_url, category_id, calories_per_100g, protein_g, carbs_g, fat_g, fiber_g, sugar_g, sodium_mg, description) VALUES
  ('33333333-0000-0000-0000-000000000006','5449000131106','Coca-Cola 1.5L','Coca-Cola','https://images.openfoodfacts.org/images/products/544/900/013/1106/front_fr.8.full.jpg','11111111-0000-0000-0000-000000000002', 42, 0, 10.6, 0, 0, 10.6, 12, 'Refreshing carbonated soft drink.'),
  ('33333333-0000-0000-0000-000000000007','8000500310427','Barilla Pasta 500g','Barilla','https://images.openfoodfacts.org/images/products/800/050/031/0427/front_fr.6.full.jpg','11111111-0000-0000-0000-000000000004', 350, 12, 71, 2, 3, 3, 0, 'Italian pasta made with durum wheat.'),
  ('33333333-0000-0000-0000-000000000008','8076800195057','Milk 1L','Candia','https://via.placeholder.com/200','11111111-0000-0000-0000-000000000001', 64, 3.3, 4.8, 3.6, 0, 4.8, 50, 'Fresh pasteurized milk.')
ON CONFLICT (id) DO NOTHING;

-- Add more prices
INSERT INTO prices (product_id, store_id, price, currency, is_on_sale, sale_price) VALUES
  -- Coca-Cola
  ('33333333-0000-0000-0000-000000000006','22222222-0000-0000-0000-000000000001', 180.00, 'DZD', false, NULL),
  ('33333333-0000-0000-0000-000000000006','22222222-0000-0000-0000-000000000002', 170.00, 'DZD', false, NULL),
  ('33333333-0000-0000-0000-000000000006','22222222-0000-0000-0000-000000000003', 175.00, 'DZD', false, NULL),
  -- Barilla Pasta
  ('33333333-0000-0000-0000-000000000007','22222222-0000-0000-0000-000000000001', 250.00, 'DZD', false, NULL),
  ('33333333-0000-0000-0000-000000000007','22222222-0000-0000-0000-000000000002', 240.00, 'DZD', false, NULL),
  ('33333333-0000-0000-0000-000000000007','22222222-0000-0000-0000-000000000005', 230.00, 'DZD', false, NULL),
  -- Milk
  ('33333333-0000-0000-0000-000000000008','22222222-0000-0000-0000-000000000001', 140.00, 'DZD', false, NULL),
  ('33333333-0000-0000-0000-000000000008','22222222-0000-0000-0000-000000000002', 135.00, 'DZD', false, NULL),
  ('33333333-0000-0000-0000-000000000008','22222222-0000-0000-0000-000000000006', 130.00, 'DZD', false, NULL)
ON CONFLICT (product_id, store_id) DO NOTHING;

-- =============================================
-- VERIFICATION QUERIES
-- =============================================

-- Check if function exists
SELECT proname, prosrc 
FROM pg_proc 
WHERE proname = 'handle_new_user';

-- Check if trigger exists
SELECT tgname, tgrelid::regclass 
FROM pg_trigger 
WHERE tgname = 'on_auth_user_created';

-- Check if all columns exist
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'stores' 
ORDER BY ordinal_position;

-- Test the search function
SELECT * FROM search_products('coffee');

-- Test the cheapest price function
SELECT * FROM get_cheapest_price('33333333-0000-0000-0000-000000000003');