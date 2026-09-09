-- Lab 01-sql / 01-joins-and-aggregation
-- Synthetic construction-material store schema.

CREATE TABLE customers (
    id            SERIAL PRIMARY KEY,
    name          TEXT NOT NULL,
    city          TEXT NOT NULL,
    customer_type TEXT NOT NULL CHECK (customer_type IN ('retail', 'contractor'))
);

CREATE TABLE products (
    id         SERIAL PRIMARY KEY,
    sku        TEXT NOT NULL UNIQUE,
    name       TEXT NOT NULL,
    category   TEXT NOT NULL,
    unit_price NUMERIC(10, 2) NOT NULL,
    unit       TEXT NOT NULL
);

CREATE TABLE orders (
    id          SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(id),
    order_date  DATE NOT NULL,
    status      TEXT NOT NULL CHECK (status IN ('completed', 'cancelled'))
);

CREATE TABLE order_items (
    id         SERIAL PRIMARY KEY,
    order_id   INTEGER NOT NULL REFERENCES orders(id),
    product_id INTEGER NOT NULL REFERENCES products(id),
    quantity   INTEGER NOT NULL,
    unit_price NUMERIC(10, 2) NOT NULL -- price at time of order, may differ from products.unit_price today
);
