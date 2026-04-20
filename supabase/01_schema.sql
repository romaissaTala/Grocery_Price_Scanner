-- =============================================
-- GROCERY PRICE SCANNER — SUPABASE SCHEMA
-- =============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================
-- TABLE: categories
-- =============================================
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  icon_name TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- TABLE: stores
-- =============================================
CREATE TABLE stores (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  logo_url TEXT,
  website TEXT,
  city TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- TABLE: products
-- =============================================
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  barcode TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  brand TEXT,
  image_url TEXT,
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  description TEXT,
  -- Nutrition info (for flip card)
  calories_per_100g NUMERIC(8,2),
  protein_g NUMERIC(8,2),
  carbs_g NUMERIC(8,2),
  fat_g NUMERIC(8,2),
  fiber_g NUMERIC(8,2),
  sugar_g NUMERIC(8,2),
  sodium_mg NUMERIC(8,2),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_products_barcode ON products(barcode);
CREATE INDEX idx_products_category ON products(category_id);

-- =============================================
-- TABLE: prices
-- =============================================
CREATE TABLE prices (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  price NUMERIC(10,2) NOT NULL,
  currency TEXT DEFAULT 'DZD',
  is_on_sale BOOLEAN DEFAULT FALSE,
  sale_price NUMERIC(10,2),
  verified_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(product_id, store_id)  -- one price per product per store (upsert pattern)
);

CREATE INDEX idx_prices_product ON prices(product_id);
CREATE INDEX idx_prices_store ON prices(store_id);

-- =============================================
-- TABLE: price_history (insert-only, never update)
-- =============================================
CREATE TABLE price_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  price NUMERIC(10,2) NOT NULL,
  currency TEXT DEFAULT 'DZD',
  recorded_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_price_history_product ON price_history(product_id, recorded_at DESC);

-- =============================================
-- TABLE: scan_history (per user scan log)
-- =============================================
CREATE TABLE scan_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL,  -- references auth.users
  product_id UUID REFERENCES products(id) ON DELETE SET NULL,
  barcode TEXT NOT NULL,
  scanned_at TIMESTAMPTZ DEFAULT NOW(),
  is_batch BOOLEAN DEFAULT FALSE,
  folder_name TEXT DEFAULT 'General',
  notes TEXT
);

CREATE INDEX idx_scan_history_user ON scan_history(user_id, scanned_at DESC);

-- =============================================
-- TABLE: tracked_products (user bookmarks)
-- =============================================
CREATE TABLE tracked_products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL,
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  target_price NUMERIC(10,2),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

-- =============================================
-- TRIGGER: auto-update products.updated_at
-- =============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER products_updated_at
  BEFORE UPDATE ON products
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =============================================
-- TRIGGER: on prices update → insert price_history
-- =============================================
CREATE OR REPLACE FUNCTION log_price_history()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO price_history(product_id, store_id, price, currency)
  VALUES (NEW.product_id, NEW.store_id, NEW.price, NEW.currency);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER prices_history_log
  AFTER INSERT OR UPDATE ON prices
  FOR EACH ROW EXECUTE FUNCTION log_price_history();