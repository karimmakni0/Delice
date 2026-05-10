-- Délice Distribution Database Schema

CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  role VARCHAR(10) NOT NULL DEFAULT 'magasin' CHECK (role IN ('admin', 'magasin')),
  magasin_name VARCHAR(150),
  phone VARCHAR(20),
  address TEXT,
  points_balance INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  description TEXT,
  image VARCHAR(255),
  category VARCHAR(100),
  price NUMERIC(10,3) NOT NULL,
  stock INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS orders (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id),
  total_amount NUMERIC(10,3) NOT NULL,
  points_used INTEGER NOT NULL DEFAULT 0,
  discount_amount NUMERIC(10,3) NOT NULL DEFAULT 0,
  final_total NUMERIC(10,3) NOT NULL,
  points_earned INTEGER NOT NULL DEFAULT 0,
  status VARCHAR(30) NOT NULL DEFAULT 'En attente'
    CHECK (status IN ('En attente','En préparation','En livraison','Livré','Annulé')),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS order_items (
  id SERIAL PRIMARY KEY,
  order_id INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id INTEGER NOT NULL REFERENCES products(id),
  quantity INTEGER NOT NULL,
  unit_price NUMERIC(10,3) NOT NULL,
  subtotal NUMERIC(10,3) NOT NULL
);

CREATE TABLE IF NOT EXISTS points_transactions (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id),
  order_id INTEGER REFERENCES orders(id),
  type VARCHAR(4) NOT NULL CHECK (type IN ('EARN','USE')),
  points INTEGER NOT NULL,
  amount_value NUMERIC(10,3),
  created_at TIMESTAMP DEFAULT NOW()
);
