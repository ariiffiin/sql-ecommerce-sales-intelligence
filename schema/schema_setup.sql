-- ═══════════════════════════════════════════════════════════════════════
-- Project  : Olist E-Commerce Sales Intelligence
-- Date    : July 2026
-- Author  : Muhammad Ariffin Samsu
-- GitHub  : github.com/ariiffiin/sql-ecommerce-sales-intelligence
-- File     : schema/schema_setup.sql
-- Dialect  : SQLite
-- Purpose  : DDL reference for all 7 tables in the Olist dataset.
--            The actual database is loaded via Kaggle's hosted SQLite
--            file — this file documents the schema for portfolio
--            reference and serves as a rebuild script if needed.
-- ═══════════════════════════════════════════════════════════════════════

-- SQLite does not enforce FK constraints by default.
-- Enable it per connection if you need referential integrity checks.
-- PRAGMA foreign_keys = ON;

-- ───────────────────────────────────────────────
-- TABLE 1: customers
-- One row per unique customer_id (tied to one order).
-- customer_unique_id groups repeat buyers across orders.
-- ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS customers (
    customer_id              TEXT PRIMARY KEY,
    customer_unique_id       TEXT        NOT NULL,
    customer_zip_code_prefix TEXT,
    customer_city            TEXT,
    customer_state           TEXT        -- 2-letter Brazilian state code e.g. SP, RJ
);

-- ───────────────────────────────────────────────
-- TABLE 2: orders
-- Core fact table. One row per order.
-- All timestamp columns stored as TEXT in ISO 8601 format:
-- 'YYYY-MM-DD HH:MM:SS' — compatible with SQLite's STRFTIME & JULIANDAY.
-- ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS orders (
    order_id                      TEXT PRIMARY KEY,
    customer_id                   TEXT NOT NULL,
    order_status                  TEXT,
    order_purchase_timestamp      TEXT,
    order_approved_at             TEXT,
    order_delivered_carrier_date  TEXT,
    order_delivered_customer_date TEXT,
    order_estimated_delivery_date TEXT,
    FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
);

-- ───────────────────────────────────────────────
-- TABLE 3: products
-- One row per unique product SKU.
-- product_category_name is in Portuguese — use as-is for analysis.
-- ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS products (
    product_id                 TEXT PRIMARY KEY,
    product_category_name      TEXT,
    product_name_lenght        INTEGER,  -- note: typo kept from original dataset
    product_description_lenght INTEGER,
    product_photos_qty         INTEGER,
    product_weight_g           REAL,
    product_length_cm          REAL,
    product_height_cm          REAL,
    product_width_cm           REAL
);

-- ───────────────────────────────────────────────
-- TABLE 4: sellers
-- One row per registered seller on the Olist platform.
-- ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS sellers (
    seller_id                TEXT PRIMARY KEY,
    seller_zip_code_prefix   TEXT,
    seller_city              TEXT,
    seller_state             TEXT
);

-- ───────────────────────────────────────────────
-- TABLE 5: order_items
-- Bridge table — links orders to products and sellers.
-- One order can have multiple items (multiple rows per order_id).
-- Composite PK: (order_id, order_item_id).
-- ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS order_items (
    order_id            TEXT    NOT NULL,
    order_item_id       INTEGER NOT NULL,  -- item sequence within the order
    product_id          TEXT    NOT NULL,
    seller_id           TEXT    NOT NULL,
    shipping_limit_date TEXT,
    price               REAL,
    freight_value       REAL,
    PRIMARY KEY (order_id, order_item_id),
    FOREIGN KEY (order_id)   REFERENCES orders   (order_id),
    FOREIGN KEY (product_id) REFERENCES products (product_id),
    FOREIGN KEY (seller_id)  REFERENCES sellers  (seller_id)
);

-- ───────────────────────────────────────────────
-- TABLE 6: order_payments
-- One order can have multiple payment methods (payment_sequential).
-- e.g. part credit card + part voucher = 2 rows for same order_id.
-- ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS order_payments (
    order_id             TEXT    NOT NULL,
    payment_sequential   INTEGER NOT NULL,  -- 1 = primary, 2+ = supplementary
    payment_type         TEXT,              -- credit_card, boleto, voucher, debit_card
    payment_installments INTEGER,
    payment_value        REAL,
    FOREIGN KEY (order_id) REFERENCES orders (order_id)
);

-- ───────────────────────────────────────────────
-- TABLE 7: order_reviews
-- Customer satisfaction data.
-- review_score: 1 (worst) to 5 (best).
-- One review per order (occasionally missing).
-- ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS order_reviews (
    review_id                VARCHAR(50) PRIMARY KEY,
    order_id                 TEXT NOT NULL,
    review_score             INTEGER,
    review_creation_date     TEXT,
    review_answer_timestamp  TEXT,
    FOREIGN KEY (order_id) REFERENCES orders (order_id)
);

-- ═══════════════════════════════════════════════════════════════════════
-- SCHEMA NOTES
-- ───────────────────────────────────────────────
-- SQLite TYPE AFFINITY REMINDER:
--   TEXT    → stores strings, dates (as ISO 8601 text)
--   INTEGER → whole numbers
--   REAL    → floating point (price, freight, weight)
--   No DATETIME type in SQLite — use TEXT + STRFTIME() / JULIANDAY()
--
-- KEY RELATIONSHIPS:
--   orders ──< order_items >── products
--   orders ──< order_items >── sellers
--   orders ──< order_payments
--   orders ──< order_reviews
--   orders >── customers
--
-- ANALYST TIPS:
--   Always filter WHERE order_status = 'delivered' for revenue analysis.
--   Use customer_unique_id (not customer_id) for repeat-buyer analysis.
--   order_items.price is per item — SUM() to get order total.
--   order_payments.payment_value already totals per payment method.
-- ═══════════════════════════════════════════════════════════════════════