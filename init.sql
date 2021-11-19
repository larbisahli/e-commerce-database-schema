CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- TABLES --

CREATE TABLE IF NOT EXISTS categories (
  category_id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID REFERENCES categories (category_id) ON DELETE SET NULL,
  category_name VARCHAR(70) NOT NULL UNIQUE,
  category_description TEXT,
  active BOOLEAN DEFAULT TRUE,
  icon TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (category_id)
);

CREATE TABLE IF NOT EXISTS staff_accounts (
  account_id UUID NOT NULL DEFAULT uuid_generate_v4(),
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  phone_number VARCHAR(100),
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  active BOOLEAN DEFAULT TRUE,
  profile_img TEXT,
  staff_privileges TEXT[],
  registered_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (account_id)
);

CREATE TABLE IF NOT EXISTS products (
  product_id UUID NOT NULL DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  regular_price NUMERIC CHECK (regular_price > 0),
  discount_price NUMERIC DEFAULT 0,
  product_description TEXT NOT NULL,
  short_description VARCHAR(165) NOT NULL,
  quantity INTEGER DEFAULT 0,
  product_weight NUMERIC,
  product_note TEXT,
  published BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CHECK (regular_price > discount_price),
  PRIMARY KEY (product_id)
);

CREATE TABLE IF NOT EXISTS product_categories (
  product_id UUID REFERENCES products(product_id),
  category_id UUID REFERENCES categories(category_id),
  PRIMARY KEY (product_id, category_id)
);

CREATE TABLE IF NOT EXISTS galleries (
  gallery_id UUID NOT NULL DEFAULT uuid_generate_v4(),
  product_id UUID REFERENCES products(product_id),
  image_path TEXT NOT NULL,
  thumbnail BOOLEAN DEFAULT FALSE,
  display_order SMALLINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (gallery_id)
) PARTITION BY HASH(gallery_id);

CREATE TABLE IF NOT EXISTS attributes (
  attribute_id UUID NOT NULL DEFAULT uuid_generate_v4(),
  attribute_name VARCHAR(100) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (attribute_id)
);

-- Make sure postgres creats individual index for product_id and attribute_id instead on conposite index
CREATE TABLE IF NOT EXISTS product_attributes (
  product_id UUID REFERENCES products(product_id),
  attribute_id UUID REFERENCES attributes(attribute_id),
  PRIMARY KEY (product_id, attribute_id)
);

CREATE TABLE IF NOT EXISTS attribute_values (
  attribute_value_id UUID NOT NULL DEFAULT uuid_generate_v4(),
  attribute_id UUID REFERENCES attributes(attribute_id),
  attribute_value VARCHAR(255) NOT NULL,
  color VARCHAR(50) DEFAULT NULL,
  PRIMARY KEY (attribute_value_id)
);

CREATE TABLE IF NOT EXISTS variant_attribute_values (
  variant_attribute_value_id UUID NOT NULL DEFAULT uuid_generate_v4(),
  attribute_value_id UUID REFERENCES attribute_values(attribute_value_id),
  PRIMARY KEY (variant_attribute_value_id)
);

CREATE TABLE IF NOT EXISTS variants (
  variant_id UUID NOT NULL DEFAULT uuid_generate_v4(),
  variant_attribute_value_id UUID REFERENCES variant_attribute_values(variant_attribute_value_id),
  product_id UUID REFERENCES products(product_id),
  PRIMARY KEY (variant_id)
);

CREATE TABLE IF NOT EXISTS variant_values (
  variant_value_id UUID NOT NULL DEFAULT uuid_generate_v4(),
  variant_id UUID REFERENCES variants(variant_id),
  price NUMERIC DEFAULT 0,
  quantity INTEGER DEFAULT 0,
  PRIMARY KEY (variant_value_id)
);

CREATE TABLE IF NOT EXISTS customers (
  customer_id UUID NOT NULL DEFAULT uuid_generate_v4(),
  first_name VARCHAR(90) NOT NULL,
  last_name VARCHAR(90) NOT NULL,
  customer_address TEXT,
  zip_code SMALLINT,
  country VARCHAR(90),
  city VARCHAR(90),
  customer_state VARCHAR(90),
  phone_number VARCHAR(100),
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT,
  registered_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  active BOOLEAN DEFAULT TRUE,
  PRIMARY KEY (customer_id)
);

CREATE TABLE IF NOT EXISTS sales_orders (
  order_id VARCHAR(50) NOT NULL,
  coupon_id INTEGER,
  customer_id UUID REFERENCES customers(customer_id),
  order_date TIMESTAMPTZ,
  total NUMERIC NOT NULL,
  order_status VARCHAR(50),
  order_purchase_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  order_approved_at TIMESTAMPTZ,
  order_delivered_carrier_date TIMESTAMPTZ,
  order_delivered_customer_date TIMESTAMPTZ,
  PRIMARY KEY (order_id)
  -- Use Two-Phase Locking to prevent double booking problem.
);

CREATE TABLE IF NOT EXISTS order_items (
  order_item_id UUID NOT NULL DEFAULT uuid_generate_v4(),
  product_id UUID REFERENCES products(product_id),
  order_id VARCHAR(50) REFERENCES sales_orders(order_id),
  order_status VARCHAR(50),
  price NUMERIC NOT NULL,
  quantity INTEGER NOT NULL,
  freight_price NUMERIC DEFAULT 0,
  PRIMARY KEY (order_item_id)
  -- For security reasons don't add total price from the frontend get it using product_id.
);

CREATE TABLE IF NOT EXISTS sells (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  product_id UUID UNIQUE REFERENCES products(product_id),
  price NUMERIC NOT NULL, -- increment (product price may change)
  quantity INTEGER NOT NULL,
  PRIMARY KEY (id)
  -- How many unit we sold, one row for each product
);

CREATE TABLE IF NOT EXISTS slideshow (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  destination_url TEXT,
  image_url TEXT,
  clicks INTEGER DEFAULT 0,
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS notifications (
  notification_id UUID NOT NULL DEFAULT uuid_generate_v4(),
  account_id UUID REFERENCES staff_accounts(account_id),
  title VARCHAR(100),
  content TEXT,
  seen BOOLEAN,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  receive_time TIMESTAMPTZ,
  notification_expiry_date DATE,
  PRIMARY KEY (notification_id)
);

CREATE TABLE IF NOT EXISTS shopping (
  shopping_id UUID NOT NULL DEFAULT uuid_generate_v4(),
  ship_method TEXT,
  shipper TEXT,
  ship_charge NUMERIC,
  ship_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (shopping_id)
);

CREATE TABLE IF NOT EXISTS cards (
  card_id UUID NOT NULL DEFAULT uuid_generate_v4(),
  customer_id UUID REFERENCES customers(customer_id),
  PRIMARY KEY (card_id)
);

CREATE TABLE IF NOT EXISTS card_items (
  card_item_id UUID NOT NULL DEFAULT uuid_generate_v4(),
  card_id UUID REFERENCES cards(card_id),
  product_id UUID REFERENCES products(product_id),
  quantity INTEGER,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (card_item_id)
);

CREATE TABLE IF NOT EXISTS coupons (
  coupon_id SERIAL NOT NULL,
  code TEXT,
  coupon_description TEXT,
  active BOOLEAN,
  amount NUMERIC,
  multiple BOOLEAN DEFAULT TRUE,
  coupon_start_date TIMESTAMP,
  coupon_end_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (coupon_id)
);


-- FUNCTIONS --

CREATE OR REPLACE FUNCTION update_at_timestamp() RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = NOW(); 
   RETURN NEW;
END;
$$ language 'plpgsql';

-- TRIGGERS --

CREATE TRIGGER product_set_update
  BEFORE UPDATE ON products
  FOR EACH ROW
  EXECUTE PROCEDURE update_at_timestamp();

CREATE TRIGGER staff_set_update
  BEFORE UPDATE ON staff_accounts
  FOR EACH ROW
  EXECUTE PROCEDURE update_at_timestamp();

CREATE TRIGGER coupon_set_update
  BEFORE UPDATE ON coupons
  FOR EACH ROW
  EXECUTE PROCEDURE update_at_timestamp();

CREATE TRIGGER customer_set_update
  BEFORE UPDATE ON customers
  FOR EACH ROW
  EXECUTE PROCEDURE update_at_timestamp();

-- PARTIOTIONS --

CREATE TABLE galleries_part1 PARTITION OF galleries FOR VALUES WITH (modulus 3, remainder 0);
CREATE TABLE galleries_part2 PARTITION OF galleries FOR VALUES WITH (modulus 3, remainder 1);
CREATE TABLE galleries_part3 PARTITION OF galleries FOR VALUES WITH (modulus 3, remainder 2);

-- INDEXES --

-- products
CREATE INDEX idx_product_id_publish ON products (product_id, published);

-- customers
CREATE INDEX idx_customer_email ON customers (email);
CREATE INDEX idx_customer_phone_number ON customers (phone_number);
CREATE INDEX idx_customer_registered_at ON customers (registered_at);

-- galleries 
CREATE INDEX idx_image_gallery ON galleries (product_id, thumbnail);

-- attribute_values
CREATE INDEX idx_attribute_values ON attribute_values (attribute_id);

-- variants
CREATE INDEX idx_product_id_variants ON variants (product_id);

-- sales_orders
CREATE INDEX idx_sales_order_customer_id ON sales_orders (customer_id);

-- order_items
CREATE INDEX idx_product_id_order_item ON order_items (product_id);
CREATE INDEX idx_order_id_order_item ON order_items (order_id);

-- cards
CREATE INDEX idx_customer_id_card ON cards (customer_id);

-- DEFAULT DATA --

WITH att_id AS (INSERT INTO attributes (attribute_name) VALUES ('color'), ('size') RETURNING *)

INSERT INTO attribute_values (attribute_id, attribute_value, color) 
VALUES 
((SELECT attribute_id FROM att_id WHERE attribute_name = 'color'), 'black', '#000'), 
((SELECT attribute_id FROM att_id WHERE attribute_name = 'color'), 'white', '#FFF'), 
((SELECT attribute_id FROM att_id WHERE attribute_name = 'color'), 'red', '#FF0000'), 
((SELECT attribute_id FROM att_id WHERE attribute_name = 'size'), 'S', null), 
((SELECT attribute_id FROM att_id WHERE attribute_name = 'size'), 'M', null), 
((SELECT attribute_id FROM att_id WHERE attribute_name = 'size'), 'L', null), 
((SELECT attribute_id FROM att_id WHERE attribute_name = 'size'), 'XL', null);


-- Configuration --

-- Tuning PostgreSQL config by hardware check https://pgtune.leopard.in.ua 
-- DB Version: 14
-- OS Type: linux
-- Total Memory (RAM): 2 GB
-- DB Type: web
-- CPUs num: 1
-- Data Storage: ssd

ALTER SYSTEM SET max_connections = '200';
ALTER SYSTEM SET shared_buffers = '512MB';
ALTER SYSTEM SET effective_cache_size = '1536MB';
ALTER SYSTEM SET maintenance_work_mem = '128MB';
ALTER SYSTEM SET checkpoint_completion_target = '0.9';
ALTER SYSTEM SET wal_buffers = '16MB';
ALTER SYSTEM SET default_statistics_target = '100';
ALTER SYSTEM SET random_page_cost = '1.1';
ALTER SYSTEM SET effective_io_concurrency = '200';
ALTER SYSTEM SET work_mem = '1310kB';
ALTER SYSTEM SET min_wal_size = '1GB';
ALTER SYSTEM SET max_wal_size = '4GB';
