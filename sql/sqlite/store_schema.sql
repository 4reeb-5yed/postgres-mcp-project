-- Phase 1d: Claude Desktop MCP demo schema (SQLite)
-- Example schema for a small e-commerce checkout database. Run this with the
-- sqlite3 CLI, or any SQLite client, to create your own sample database file.

CREATE TABLE products (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  price_cents INTEGER NOT NULL,
  description TEXT NOT NULL,
  image TEXT NOT NULL,
  type TEXT NOT NULL,
  recurrence_period TEXT,
  recurrence_period_count INTEGER
);

CREATE TABLE carts (
  id TEXT PRIMARY KEY,
  session_id TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE cart_items (
  id TEXT PRIMARY KEY,
  cart_id TEXT NOT NULL,
  product_id TEXT NOT NULL,
  quantity INTEGER NOT NULL DEFAULT 1
);

CREATE TABLE orders (
  id TEXT PRIMARY KEY,
  session_id TEXT NOT NULL,
  subtotal_cents INTEGER NOT NULL,
  surcharge_cents INTEGER NOT NULL DEFAULT 0,
  total_cents INTEGER NOT NULL,
  status TEXT NOT NULL DEFAULT 'PENDING',
  guest_email TEXT,
  shipping_address TEXT,
  contact_phone TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_items (
  id TEXT PRIMARY KEY,
  order_id TEXT NOT NULL,
  product_id TEXT NOT NULL,
  name TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  unit_price_cents INTEGER NOT NULL
);

-- Sample seed rows for products:
INSERT INTO products (id, name, category, price_cents, description, image, type, recurrence_period, recurrence_period_count) VALUES
  ('smart-hub', 'Smart Hub', 'Devices', 14999, 'A demo smart hub device.', 'smart-hub.png', 'physical', NULL, NULL),
  ('wireless-mic', 'Wireless Mic Kit', 'Devices', 8999, 'A demo wireless mic kit.', 'wireless-mic.png', 'physical', NULL, NULL),
  ('pro-monthly', 'Pro Monthly Plan', 'Plans', 1499, 'A demo monthly subscription plan.', 'pro-monthly.png', 'subscription', 'MONTH', 1),
  ('pro-annual', 'Pro Annual Plan', 'Plans', 14999, 'A demo annual subscription plan.', 'pro-annual.png', 'subscription', 'YEAR', 1);

-- Quick sanity check after running the above:
-- SELECT * FROM products;
