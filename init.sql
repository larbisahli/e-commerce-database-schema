CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS categories (
  category_uid UUID DEFAULT uuid_generate_v4(),
  category_name VARCHAR(255),
  category_description TEXT,
  is_active BOOLEAN,
  display_order SERIAL NOT NULL,
  UNIQUE(category_name),
  PRIMARY KEY (category_uid)
);

CREATE TABLE IF NOT EXISTS accounts (
  account_uid UUID DEFAULT uuid_generate_v4(),
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  username VARCHAR(50) NOT NULL,
  phone_number VARCHAR(100) NOT NULL,
  email VARCHAR(255) NOT NULL,
  password_hash TEXT NOT NULL,
  is_active BOOLEAN,
  profile_img TEXT,
  privileges TEXT[],
  registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(email),
  UNIQUE(username),
  UNIQUE(phone_number),
  PRIMARY KEY (account_uid)
);

CREATE TABLE IF NOT EXISTS products (
  product_uid UUID DEFAULT uuid_generate_v4(),
  category_uid UUID REFERENCES categories(category_uid),
  account_uid UUID REFERENCES accounts(account_uid),
  title TEXT NOT NULL,
  price FLOAT NOT NULL CHECK(price >= 0),
  discount FLOAT CHECK(discount >= 0 AND discount <= 100),
  warehouse_location VARCHAR(255) NOT NULL,
  product_description TEXT NOT NULL,
  short_description VARCHAR(165) NOT NULL,
  inventory SMALLINT NOT NULL,
  product_weight FLOAT NOT NULL,
  is_new BOOLEAN NOT NULL,
  note TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (product_uid)
);

CREATE TABLE IF NOT EXISTS images (
  image_uid UUID DEFAULT uuid_generate_v4(),
  product_uid UUID REFERENCES products(product_uid),
  image_path TEXT NOT NULL,
  thumbnail BOOLEAN,
  display_order SMALLINT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (image_uid)
) PARTITION BY HASH(image_uid);

CREATE TABLE IF NOT EXISTS attributes (
  attribute_uid UUID DEFAULT uuid_generate_v4(),
  product_uid UUID REFERENCES products(product_uid),
  attribute_name VARCHAR(100) NOT NULL,
  PRIMARY KEY (attribute_uid)
);

CREATE TABLE IF NOT EXISTS options (
  option_uid UUID DEFAULT uuid_generate_v4(),
  attribute_uid UUID REFERENCES attributes(attribute_uid),
  option_name VARCHAR(100) NOT NULL,
  additional_price FLOAT NOT NULL,
  color_hex VARCHAR(50),
  PRIMARY KEY (option_uid)
);

CREATE TABLE IF NOT EXISTS clients (
  client_uid UUID DEFAULT uuid_generate_v4(),
  shopping_cart UUID[],
  first_visit TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (client_uid)
) PARTITION BY HASH(client_uid);

CREATE TABLE IF NOT EXISTS customers (
  customer_uid UUID DEFAULT uuid_generate_v4(),
  client_uid UUID REFERENCES clients(client_uid),
  first_name VARCHAR(90) NOT NULL,
  last_name VARCHAR(90) NOT NULL,
  client_address TEXT NOT NULL,
  zip_code SMALLINT NOT NULL,
  country VARCHAR(90) NOT NULL,
  phone_number VARCHAR(100) NOT NULL,
  email TEXT NOT NULL,
  PRIMARY KEY (customer_uid)
);

CREATE TABLE IF NOT EXISTS orders (
  order_uid UUID DEFAULT uuid_generate_v4(),
  product_uid UUID REFERENCES products(product_uid),
  customer_uid UUID REFERENCES customers(customer_uid),
  quantity SMALLINT NOT NULL,
  options UUID[],
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (order_uid)
  -- for security reasons don't add total price from the frontend get it using product_uid
  -- isolation level 
);

CREATE TABLE IF NOT EXISTS sells (
  id UUID DEFAULT uuid_generate_v4(),
  product_uid UUID REFERENCES products(product_uid),
  price FLOAT NOT NULL,
  quantity SMALLINT NOT NULL,
  PRIMARY KEY (id)
  -- how many unit we sold, one row for each product
);

CREATE TABLE IF NOT EXISTS slideshow (
  id UUID DEFAULT uuid_generate_v4(),
  destination_url TEXT,
  image_url TEXT,
  clicks SMALLINT DEFAULT 0,
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS notifications (
  notification_uid UUID DEFAULT uuid_generate_v4(),
  account_uid UUID REFERENCES accounts(account_uid),
  title VARCHAR(100),
  content TEXT,
  seen BOOLEAN,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  receive_time TIMESTAMP,
  notification_expiry_date DATE,
  PRIMARY KEY (notification_uid)
);

-- Functions

CREATE OR REPLACE FUNCTION update_timestamp() RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = now(); 
   RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER product_update
  BEFORE UPDATE
  ON products
  FOR EACH ROW
  EXECUTE PROCEDURE update_timestamp();

-- Partitions

CREATE TABLE images_part1 PARTITION OF images FOR VALUES WITH (modulus 3, remainder 0);
CREATE TABLE images_part2 PARTITION OF images FOR VALUES WITH (modulus 3, remainder 1);
CREATE TABLE images_part3 PARTITION OF images FOR VALUES WITH (modulus 3, remainder 2);

CREATE TABLE clients_part1 PARTITION OF clients FOR VALUES WITH (modulus 3, remainder 0);
CREATE TABLE clients_part2 PARTITION OF clients FOR VALUES WITH (modulus 3, remainder 1);
CREATE TABLE clients_part3 PARTITION OF clients FOR VALUES WITH (modulus 3, remainder 2);


-- System Set

-- Tuning PostgreSQL config by hardware check https://pgtune.leopard.in.ua 
-- DB Version: 13
-- OS Type: linux
-- DB Type: web
-- Total Memory (RAM): 1 GB
-- CPUs num: 1
-- Data Storage: ssd

ALTER SYSTEM SET max_connections = '200';
ALTER SYSTEM SET shared_buffers = '256MB';
ALTER SYSTEM SET effective_cache_size = '768MB';
ALTER SYSTEM SET maintenance_work_mem = '64MB';
ALTER SYSTEM SET checkpoint_completion_target = '0.9';
ALTER SYSTEM SET wal_buffers = '7864kB';
ALTER SYSTEM SET default_statistics_target = '100';
ALTER SYSTEM SET random_page_cost = '1.1';
ALTER SYSTEM SET effective_io_concurrency = '200';
ALTER SYSTEM SET work_mem = '655kB';
ALTER SYSTEM SET min_wal_size = '1GB';
ALTER SYSTEM SET max_wal_size = '4GB';