-- ═══════════════════════════════════════════════════════════════
-- Project : Olist E-Commerce Sales Intelligence
-- Date    : July 2026
-- Author  : Muhammad Ariffin Samsu
-- GitHub  : github.com/YOUR_USERNAME/sql-ecommerce-sales-intelligence
-- Dialect : SQLite (Kaggle Notebook environment)
-- File    : 00_exploration.sql
-- Analysis: Raw Data Exploration
-- Note    : For MySQL, replace STRFTIME('%Y-%m', date)
--           with DATE_FORMAT(date, '%Y-%m')
--           and JULIANDAY(d2)-JULIANDAY(d1) with DATEDIFF(d2, d1)
-- ═══════════════════════════════════════════════════════════════

-- ── 00_exploration.sql ──────────────────────────────────────────────

-- Row counts across all tables
SELECT 
                         'customers'       AS table_name, 
                         COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'orders',         COUNT(*) FROM orders
UNION ALL
SELECT 'order_items',    COUNT(*) FROM order_items
UNION ALL
SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL
SELECT 'order_reviews',  COUNT(*) FROM order_reviews
UNION ALL
SELECT 'products',       COUNT(*) FROM products
UNION ALL
SELECT 'sellers',        COUNT(*) FROM sellers;

-- Date range and total order count

SELECT
    MIN(order_purchase_timestamp) AS earliest_order,
    MAX(order_purchase_timestamp) AS latest_order,
    COUNT(DISTINCT order_id)      AS total_orders
FROM orders;

-- Order status breakdown

SELECT
    order_status,
    COUNT(*)                                          AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS pct
FROM orders
GROUP BY order_status
ORDER BY count DESC;