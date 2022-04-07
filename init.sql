CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
-- TABLES --

CREATE TABLE IF NOT EXISTS roles (
  id SERIAL NOT NULL,
  role_name VARCHAR(255) NOT NULL,
  privileges TEXT [],
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS staff_accounts (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  role_id INTEGER REFERENCES roles(id) ON DELETE SET NULL,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  phone_number VARCHAR(100) DEFAULT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  active BOOLEAN DEFAULT TRUE,
  image TEXT DEFAULT NULL,
  placeholder TEXT DEFAULT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES staff_accounts(id),
  updated_by UUID REFERENCES staff_accounts(id),
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS categories (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID REFERENCES categories (id) ON DELETE SET NULL,
  category_name VARCHAR(255) NOT NULL UNIQUE,
  category_description TEXT,
  icon TEXT,
  image TEXT,
  placeholder TEXT,
  active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES staff_accounts(id),
  updated_by UUID REFERENCES staff_accounts(id),
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS products (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  slug TEXT NOT NULL UNIQUE,
  product_name VARCHAR(255) NOT NULL,
  sku VARCHAR(255),
  sale_price NUMERIC DEFAULT 0,
  compare_price NUMERIC DEFAULT 0,
  buying_price NUMERIC DEFAULT 0,
  quantity INTEGER DEFAULT 0,
  short_description VARCHAR(165) NOT NULL,
  product_description TEXT NOT NULL,
  published BOOLEAN DEFAULT FALSE,
  disable_out_of_stock BOOLEAN DEFAULT TRUE,
  note TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES staff_accounts(id),
  updated_by UUID REFERENCES staff_accounts(id),
  CHECK (sale_price > compare_price),
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS product_categories (
  product_id UUID REFERENCES products(id) NOT NULL,
  category_id UUID REFERENCES categories(id) NOT NULL,
  PRIMARY KEY (product_id, category_id)
);

CREATE TABLE IF NOT EXISTS product_shipping_info (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  product_id UUID REFERENCES products(id) ON DELETE SET NULL,
  weight NUMERIC DEFAULT 0,
  weight_unit VARCHAR(10),
  volume NUMERIC DEFAULT 0,
  volume_unit VARCHAR(10),
  dimension_width NUMERIC DEFAULT 0,
  dimension_height NUMERIC DEFAULT 0,
  dimension_depth NUMERIC DEFAULT 0,
  dimension_unit VARCHAR(10),
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS gallery (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  product_id UUID REFERENCES products(id),
  image TEXT NOT NULL,
  placeholder TEXT NOT NULL,
  is_thumbnail BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (id)
) PARTITION BY HASH(id);

CREATE TABLE IF NOT EXISTS attributes (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  attribute_name VARCHAR(255) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES staff_accounts(id),
  updated_by UUID REFERENCES staff_accounts(id),
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS attribute_values (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  attribute_id UUID REFERENCES attributes(id) NOT NULL,
  attribute_value VARCHAR(255) NOT NULL,
  color VARCHAR(50) DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS product_attributes (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  product_id UUID REFERENCES products(id) NOT NULL,
  attribute_id UUID REFERENCES attributes(id) NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS product_attribute_values (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  product_attribute_id UUID REFERENCES product_attributes(id) NOT NULL,
  attribute_value_id UUID REFERENCES attribute_values(id) NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS variant_options (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  image_id UUID REFERENCES gallery(id),
  sale_price NUMERIC DEFAULT 0,
  compare_price NUMERIC DEFAULT 0,
  buying_price NUMERIC DEFAULT 0,
  quantity INTEGER DEFAULT 0,
  sku VARCHAR(255),
  active BOOLEAN DEFAULT TRUE,
  PRIMARY KEY (id)
);

-- Means a product has 2 variants black/XL red/XL
CREATE TABLE IF NOT EXISTS variants (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  variant_option TEXT NOT NULL,
  product_id UUID REFERENCES products(id) NOT NULL,
  variant_option_id UUID REFERENCES variant_options(id) NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS variant_values (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  variant_id UUID REFERENCES variants(id) NOT NULL,
  product_attribute_value_id UUID REFERENCES product_attribute_values(id) NOT NULL, -- black or XL
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS customers (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  active BOOLEAN DEFAULT TRUE,
  registered_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS customer_addresses (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  customer_id UUID REFERENCES customers(id),
  address_line1 TEXT NOT NULL,
  address_line2 TEXT,
  phone_number VARCHAR(255) NOT NULL,
  dial_code VARCHAR(100) NOT NULL,
  country VARCHAR(255) NOT NULL,
  postal_code VARCHAR(255) NOT NULL,
  city VARCHAR(255) NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS coupons (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  code VARCHAR(50) NOT NULL UNIQUE,
  discount_value NUMERIC,
  discount_type VARCHAR(50) NOT NULL,
  times_used NUMERIC DEFAULT 0,
  max_usage NUMERIC DEFAULT null,
  order_amount_limit NUMERIC DEFAULT null,
  coupon_start_date TIMESTAMPTZ,
  coupon_end_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES staff_accounts(id),
  updated_by UUID REFERENCES staff_accounts(id),
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS product_coupons (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  product_id UUID REFERENCES products(id) NOT NULL,
  coupon_id UUID REFERENCES coupons(id) NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS shippings (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  shipper_name TEXT,
  active BOOLEAN DEFAULT TRUE,
  image TEXT DEFAULT NULL,
  placeholder TEXT DEFAULT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES staff_accounts(id),
  updated_by UUID REFERENCES staff_accounts(id),
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS product_shippings (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  shipping_id UUID REFERENCES shippings(id) NOT NULL,
  product_id UUID REFERENCES products(id) NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS product_shipping_options (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  product_shipping_id UUID REFERENCES product_shippings(id) NOT NULL,
  shipping_price NUMERIC DEFAULT 0, -- 0 means free shipping
  shipping_zones jsonb[],
  -- estimated_days NUMERIC,
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS order_statuses (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  status_name VARCHAR(255) NOT NULL,
  color VARCHAR(50) NOT NULL,
  privacy VARCHAR(10) CHECK (privacy IN ('public', 'private')) NOT NULL DEFAULT 'private',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES staff_accounts(id),
  updated_by UUID REFERENCES staff_accounts(id),
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS orders (
  id VARCHAR(50) NOT NULL,
  coupon_id UUID REFERENCES coupons(id) ON DELETE SET NULL,
  customer_id UUID REFERENCES customers(id),
  order_status_id UUID REFERENCES order_statuses(id) ON DELETE SET NULL,
  order_approved_at TIMESTAMPTZ,
  order_delivered_carrier_date TIMESTAMPTZ,
  order_delivered_customer_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_by UUID REFERENCES staff_accounts(id),
  PRIMARY KEY (id) -- It's better to use Two-Phase Locking inside your transaction (SELECT ... FOR UPDATE) to prevent double booking problems for this table.
);

CREATE TABLE IF NOT EXISTS order_items (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  product_id UUID REFERENCES products(id),
  order_id VARCHAR(50) REFERENCES orders(id),
  price NUMERIC NOT NULL,
  quantity INTEGER NOT NULL,
  shipping_id UUID REFERENCES shippings(id) ON DELETE SET NULL, 
  PRIMARY KEY (id) 
);

CREATE TABLE IF NOT EXISTS sells (
  id SERIAL NOT NULL,
  product_id UUID UNIQUE REFERENCES products(id),
  price NUMERIC NOT NULL,
  quantity INTEGER NOT NULL,
  PRIMARY KEY (id) 
);

CREATE TABLE IF NOT EXISTS slideshows (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  destination_url TEXT,
  image TEXT,
  placeholder TEXT,
  clicks INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES staff_accounts(id),
  updated_by UUID REFERENCES staff_accounts(id),
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS notifications (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  account_id UUID REFERENCES staff_accounts(id),
  title VARCHAR(100),
  content TEXT,
  seen BOOLEAN,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  receive_time TIMESTAMPTZ,
  notification_expiry_date DATE,
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS cards (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  customer_id UUID REFERENCES customers(id),
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS card_items (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  card_id UUID REFERENCES cards(id),
  product_id UUID REFERENCES products(id),
  quantity INTEGER DEFAULT 1,
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS tags (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  tag_name VARCHAR(255) NOT NULL,
  icon TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES staff_accounts(id),
  updated_by UUID REFERENCES staff_accounts(id),
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS product_tags (
  tag_id UUID REFERENCES tags(id) NOT NULL,
  product_id UUID REFERENCES products(id) NOT NULL,
  PRIMARY KEY (tag_id, product_id)
);

CREATE TABLE IF NOT EXISTS suppliers (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  supplier_name VARCHAR(255) NOT NULL,
  company VARCHAR(255),
  phone_number VARCHAR(255),
  dial_code VARCHAR(100),
  address_line1 TEXT NOT NULL,
  address_line2 TEXT,
  country VARCHAR(255),
  city VARCHAR(255),
  note TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES staff_accounts(id),
  updated_by UUID REFERENCES staff_accounts(id),
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS product_suppliers (
  supplier_id UUID REFERENCES suppliers(id) NOT NULL,
  product_id UUID REFERENCES products(id) NOT NULL,
  PRIMARY KEY (supplier_id, product_id)
);

-- FUNCTIONS --
CREATE OR REPLACE FUNCTION update_at_timestamp() RETURNS TRIGGER AS $$ BEGIN NEW.updated_at = NOW();
RETURN NEW;
  END;
  $$ language 'plpgsql';

-- TRIGGERS --
CREATE TRIGGER category_set_update BEFORE UPDATE ON categories FOR EACH ROW EXECUTE PROCEDURE update_at_timestamp();
CREATE TRIGGER gallery_set_update BEFORE UPDATE ON gallery FOR EACH ROW EXECUTE PROCEDURE update_at_timestamp();
CREATE TRIGGER attribute_set_update BEFORE UPDATE ON attributes FOR EACH ROW EXECUTE PROCEDURE update_at_timestamp();
CREATE TRIGGER product_set_update BEFORE UPDATE ON products FOR EACH ROW EXECUTE PROCEDURE update_at_timestamp();
CREATE TRIGGER staff_set_update BEFORE UPDATE ON staff_accounts FOR EACH ROW EXECUTE PROCEDURE update_at_timestamp();
CREATE TRIGGER coupon_set_update BEFORE UPDATE ON coupons FOR EACH ROW EXECUTE PROCEDURE update_at_timestamp();
CREATE TRIGGER customer_set_update BEFORE UPDATE ON customers FOR EACH ROW EXECUTE PROCEDURE update_at_timestamp();
CREATE TRIGGER order_set_update BEFORE UPDATE ON orders FOR EACH ROW EXECUTE PROCEDURE update_at_timestamp();
CREATE TRIGGER slideshow_set_update BEFORE UPDATE ON slideshows FOR EACH ROW EXECUTE PROCEDURE update_at_timestamp();
CREATE TRIGGER notification_set_update BEFORE UPDATE ON notifications FOR EACH ROW EXECUTE PROCEDURE update_at_timestamp();
CREATE TRIGGER shipping_set_update BEFORE UPDATE ON shippings FOR EACH ROW EXECUTE PROCEDURE update_at_timestamp();
CREATE TRIGGER tag_set_update BEFORE UPDATE ON tags FOR EACH ROW EXECUTE PROCEDURE update_at_timestamp();
CREATE TRIGGER order_statuse_set_update BEFORE UPDATE ON order_statuses FOR EACH ROW EXECUTE PROCEDURE update_at_timestamp();
CREATE TRIGGER suppliers_set_update BEFORE UPDATE ON suppliers FOR EACH ROW EXECUTE PROCEDURE update_at_timestamp();

-- PARTIOTIONS --
CREATE TABLE gallery_part1 PARTITION OF gallery FOR VALUES WITH (modulus 3, remainder 0);
CREATE TABLE gallery_part2 PARTITION OF gallery FOR VALUES WITH (modulus 3, remainder 1);
CREATE TABLE gallery_part3 PARTITION OF gallery FOR VALUES WITH (modulus 3, remainder 2);

-- INDEXES --
-- Declaration of a foreign key constraint does not automatically create an index on the referencing columns.

-- products
CREATE INDEX idx_product_id_publish ON products (id, published);
CREATE INDEX idx_product_slug_publish ON products (slug, published);
-- customers
CREATE INDEX idx_customer_email ON customers (email);
-- gallery
CREATE INDEX idx_image_gallery ON gallery (product_id, is_thumbnail);
-- attribute_values
CREATE INDEX idx_attribute_values ON attribute_values (attribute_id);
-- product_attribute_values
CREATE INDEX idx_product_attribute_values_product_attribute_id ON product_attribute_values (product_attribute_id);
-- product_attributes
CREATE INDEX idx_product_attribute_fk ON product_attributes (product_id, attribute_id);
-- product_shippings
CREATE INDEX idx_product_shippings_fk ON product_shippings (product_id);
-- product_shipping_options
CREATE INDEX idx_product_shipping_options_fk ON product_shipping_options (product_shipping_id);
-- variants
CREATE INDEX idx_product_id_variants ON variants (product_id);
-- variant_values
CREATE INDEX idx_variant_id_variant_values ON variant_values (variant_id);
-- coupons
CREATE INDEX idx_code_coupons ON coupons (code);
-- product_coupons
CREATE INDEX idx_product_id_coupon_id_product_coupons ON product_coupons (product_id, coupon_id);
-- orders
CREATE INDEX idx_order_customer_id ON orders (customer_id);
-- order_items
CREATE INDEX idx_product_id_order_item ON order_items (product_id);
CREATE INDEX idx_order_id_order_item ON order_items (order_id);
-- cards
CREATE INDEX idx_customer_id_card ON cards (customer_id);

-- DEFAULT DATA --
WITH att_id AS ( INSERT INTO attributes (attribute_name) VALUES ('Color'), ('Size') RETURNING * )
INSERT INTO attribute_values (attribute_id, attribute_value, color) VALUES
  ((SELECT id FROM att_id WHERE attribute_name = 'Color'), 'black', '#000'),
  (( SELECT id FROM att_id WHERE attribute_name = 'Color'), 'white', '#FFF'),
  (( SELECT id FROM att_id WHERE attribute_name = 'Color'), 'red', '#FF0000'),
  (( SELECT id FROM att_id WHERE attribute_name = 'Size'), 'S', null),
  (( SELECT id FROM att_id WHERE attribute_name = 'Size'), 'M', null),
  (( SELECT id FROM att_id WHERE attribute_name = 'Size'),'L', null),
  (( SELECT id FROM att_id WHERE attribute_name = 'Size'),'XL', null),
  (( SELECT id FROM att_id WHERE attribute_name = 'Size'),'2XL', null),
  (( SELECT id FROM att_id WHERE attribute_name = 'Size'),'3XL', null),
  (( SELECT id FROM att_id WHERE attribute_name = 'Size'),'4XL', null),
  (( SELECT id FROM att_id WHERE attribute_name = 'Size'), '5XL', null);
  
INSERT INTO order_statuses (status_name, color, privacy) VALUES
  ('Complete', '#5ae510','public'),
  ('Processing', '#ffe224', 'public'),
  ('Pending', '#20b9df', 'public'),
  ('On Hold', '#d6d6d6', 'public'),
  ('Shipped', '#71f9f7', 'public'),
  ('Cancelled', '#FD9F3D', 'public'),
  ('Faild', '#FF532F', 'private');
  
INSERT INTO roles (id, role_name, privileges) VALUES
  (1, 'Store Administrator', ARRAY ['super_admin_privilege', 'admin_read_privilege', 'admin_create_privilege', 'admin_update_privilege', 'admin_delete_privilege', 'staff_read_privilege', 'staff_create_privilege', 'staff_update_privilege', 'staff_delete_privilege']),
  (2, 'Sales Manager', ARRAY ['admin_read_privilege', 'admin_create_privilege', 'admin_update_privilege', 'admin_delete_privilege', 'staff_read_privilege', 'staff_create_privilege', 'staff_update_privilege', 'staff_delete_privilege']),
  (3, 'Sales Staff', ARRAY ['staff_read_privilege', 'staff_create_privilege', 'staff_update_privilege', 'staff_delete_privilege']),
  (4, 'Guest', ARRAY ['staff_read_privilege']),
  (5, 'Investor', ARRAY ['admin_read_privilege', 'staff_read_privilege']);

INSERT INTO tags (tag_name, icon) VALUES
  ( 'Tools', 'Tools'),
  ( 'Beauty Health', 'BeautyHealth'),
  ( 'Shirts', 'Shirts'),
  ( 'Accessories', 'Accessories');

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
