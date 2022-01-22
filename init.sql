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
  profile_img TEXT DEFAULT NULL,
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
  image_path TEXT,
  active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES staff_accounts(id),
  updated_by UUID REFERENCES staff_accounts(id),
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS products (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  product_name VARCHAR(255) NOT NULL,
  SKU VARCHAR(255),
  regular_price NUMERIC DEFAULT 0,
  discount_price NUMERIC DEFAULT 0,
  quantity INTEGER DEFAULT 0,
  short_description VARCHAR(165) NOT NULL,
  product_description TEXT NOT NULL,
  product_weight NUMERIC,
  published BOOLEAN DEFAULT TRUE,
  product_note VARCHAR(255),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES staff_accounts(id),
  updated_by UUID REFERENCES staff_accounts(id),
  CHECK (regular_price >= discount_price),
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS product_categories (
  product_id UUID REFERENCES products(id) ON DELETE SET NULL,
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  PRIMARY KEY (product_id, category_id)
);

CREATE TABLE IF NOT EXISTS galleries (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  product_id UUID REFERENCES products(id),
  image_path TEXT NOT NULL,
  thumbnail BOOLEAN DEFAULT FALSE,
  display_order SMALLINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES staff_accounts(id),
  updated_by UUID REFERENCES staff_accounts(id),
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

-- Make sure postgres creats individual index for product.id and attribute.id instead on conposite index
CREATE TABLE IF NOT EXISTS product_attributes (
  product_id UUID REFERENCES products(id) ON DELETE SET NULL,
  attribute_id UUID REFERENCES attributes(id) ON DELETE SET NULL,
  PRIMARY KEY (product_id, attribute_id)
);

CREATE TABLE IF NOT EXISTS attribute_values (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  attribute_id UUID REFERENCES attributes(id),
  attribute_value VARCHAR(255) NOT NULL,
  color VARCHAR(50) DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS variant_attribute_values (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  attribute_value_id UUID REFERENCES attribute_values(id),
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS variants (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  variant_attribute_value_id UUID REFERENCES variant_attribute_values(id),
  product_id UUID REFERENCES products(id),
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS variant_values (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  variant_id UUID REFERENCES variants(id),
  price NUMERIC DEFAULT 0,
  quantity INTEGER DEFAULT 0,
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS customers (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  phone_number VARCHAR(255),
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
  country VARCHAR(255) DEFAULT 'Morocco',
  postal_code VARCHAR(255) NOT NULL,
  city VARCHAR(255) NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS coupons (
  id SERIAL NOT NULL,
  code VARCHAR(50),
  coupon_description TEXT,
  discount_value NUMERIC,
  discount_type VARCHAR(50) NOT NULL,
  times_used NUMERIC DEFAULT 0,
  max_usage NUMERIC DEFAULT null,
  coupon_start_date TIMESTAMPTZ,
  coupon_end_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES staff_accounts(id),
  updated_by UUID REFERENCES staff_accounts(id),
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS product_coupons (
  product_id UUID REFERENCES products(id) ON DELETE SET NULL,
  coupon_id INTEGER REFERENCES coupons(id) ON DELETE SET NULL,
  PRIMARY KEY (product_id, coupon_id)
);

CREATE TABLE IF NOT EXISTS order_statuses (
  id SERIAL NOT NULL,
  status_name VARCHAR(255) NOT NULL,
  color VARCHAR(50) NOT NULL,
  privacy VARCHAR(50) DEFAULT 'private'
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES staff_accounts(id),
  updated_by UUID REFERENCES staff_accounts(id),
  PRIMARY KEY (id)
);
CREATE TABLE IF NOT EXISTS orders (
  id VARCHAR(50) NOT NULL,
  coupon_id INTEGER REFERENCES coupons(id) ON DELETE SET NULL,
  customer_id UUID REFERENCES customers(id),
  order_status_id INTEGER REFERENCES order_statuses(id) ON DELETE SET NULL,
  order_approved_at TIMESTAMPTZ,
  order_delivered_carrier_date TIMESTAMPTZ,
  order_delivered_customer_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_by UUID REFERENCES staff_accounts(id),
  PRIMARY KEY (id) -- It's better to use Two-Phase Locking inside your transaction (SELECT ... FOR UPDATE) to prevent double booking problems for this table.
);

CREATE TABLE IF NOT EXISTS shippings (
  id SERIAL NOT NULL,
  shipper_name TEXT,
  active BOOLEAN DEFAULT TRUE,
  shipper_icon_path TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES staff_accounts(id),
  updated_by UUID REFERENCES staff_accounts(id),
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS product_shippings (
  shipping_id INTEGER REFERENCES shippings(id) ON DELETE SET NULL,
  product_id UUID REFERENCES products(id),
  ship_charge NUMERIC,
  free BOOLEAN,
  estimated_days NUMERIC,
  PRIMARY KEY (shipping_id, product_id)
);
CREATE TABLE IF NOT EXISTS order_items (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  product_id UUID REFERENCES products(id),
  order_id VARCHAR(50) REFERENCES orders(id),
  price NUMERIC NOT NULL,
  quantity INTEGER NOT NULL,
  shipping_id INTEGER REFERENCES shippings(id) ON DELETE SET NULL, PRIMARY KEY (id) 
  -- For security reasons don't add total price from the frontend get it using product.id in the backend.
);
CREATE TABLE IF NOT EXISTS sells (
  id SERIAL NOT NULL,
  product_id UUID UNIQUE REFERENCES products(id),
  price NUMERIC NOT NULL,
  -- increment (product price may change)
  quantity INTEGER NOT NULL,
  PRIMARY KEY (id) 
);
CREATE TABLE IF NOT EXISTS slideshows (
  id SERIAL NOT NULL,
  destination_url TEXT,
  image_url TEXT,
  clicks INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES staff_accounts(id),
  updated_by UUID REFERENCES staff_accounts(id),
  PRIMARY KEY (id)
);
CREATE TABLE IF NOT EXISTS notifications (
  id SERIAL NOT NULL,
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
  id SERIAL NOT NULL,
  tag_name VARCHAR(255) NOT NULL,
  icon TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES staff_accounts(id),
  updated_by UUID REFERENCES staff_accounts(id),
  PRIMARY KEY (id)
);
CREATE TABLE IF NOT EXISTS product_tags (
  tag_id INTEGER REFERENCES tags(id),
  product_id UUID REFERENCES products(id),
  PRIMARY KEY (tag_id, product_id)
);
-- FUNCTIONS --
CREATE OR REPLACE FUNCTION update_at_timestamp() RETURNS TRIGGER AS $ $ BEGIN NEW.updated_at = NOW();
RETURN NEW;
  END;
  $ $ language 'plpgsql';

-- TRIGGERS --
CREATE TRIGGER category_set_update BEFORE UPDATE ON categories FOR EACH ROW EXECUTE PROCEDURE update_at_timestamp();
CREATE TRIGGER gallery_set_update BEFORE UPDATE ON galleries FOR EACH ROW EXECUTE PROCEDURE update_at_timestamp();
CREATE TRIGGER attribute_set_update BEFOR UPDATE ON attributes FOR EACH ROW EXECUTE PROCEDURE update_at_timestamp();
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
-- PARTIOTIONS --
CREATE TABLE galleries_part1 PARTITION OF galleries FOR VALUES WITH (modulus 3, remainder 0);
CREATE TABLE galleries_part2 PARTITION OF galleries FOR VALUES WITH (modulus 3, remainder 1);
CREATE TABLE galleries_part3 PARTITION OF galleries FOR VALUES WITH (modulus 3, remainder 2);
-- INDEXES --
-- products
CREATE INDEX idx_product_id_publish ON products (id, published);
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
-- orders
CREATE INDEX idx_order_customer_id ON orders (customer_id);
-- order_items
CREATE INDEX idx_product_id_order_item ON order_items (product_id);
CREATE INDEX idx_order_id_order_item ON order_items (order_id);
-- cards
CREATE INDEX idx_customer_id_card ON cards (customer_id);
-- DEFAULT DATA --
WITH att_id AS ( INSERT INTO attributes (attribute_name) VALUES ('color'), ('size') RETURNING * )

INSERT INTO attribute_values (attribute_id, attribute_value, color) VALUES
  ((SELECT id FROM att_id WHERE attribute_name = 'color'), 'black', '#000'),
  (( SELECT id FROM att_id WHERE attribute_name = 'color'), 'white', '#FFF'),
  (( SELECT id FROM att_id WHERE attribute_name = 'color'), 'red', '#FF0000'),
  (( SELECT id FROM att_id WHERE attribute_name = 'size'), 'S', null),
  (( SELECT id FROM att_id WHERE attribute_name = 'size'), 'M', null),
  (( SELECT id FROM att_id WHERE attribute_name = 'size'),'L', null),
  (( SELECT id FROM att_id WHERE attribute_name = 'size'), 'XL', null);
  
INSERT INTO order_statuses (status_name, color, privacy) VALUES
  ('Complete', '#5ae510','public'),
  ('Processing', '#ffe224', 'public'),
  ('Pending', '#20b9df', 'public'),
  ('On Hold', '#d6d6d6', 'public'),
  ('Shipped', '#71f9f7', 'public'),
  ('Cancelled', '#FD9F3D ', 'public'),
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
