-- ═══════════════════════════════════════════════════════════════
-- Project : Olist E-Commerce Sales Intelligence
-- Date    : July 2026
-- Author  : Muhammad Ariffin Samsu
-- GitHub  : github.com/ariiffiin/sql-ecommerce-sales-intelligence
-- Dialect : SQLite (Kaggle Notebook environment)
-- File    : 02_category_performance.sql
-- Analysis: Revenue Trend based on Product Category
-- Note    : For MySQL, replace STRFTIME('%Y-%m', date)
--           with DATE_FORMAT(date, '%Y-%m')
--           and JULIANDAY(d2)-JULIANDAY(d1) with DATEDIFF(d2, d1)
-- ═══════════════════════════════════════════════════════════════

-- ── 02_category_performance.sql ─────────────────────────────────────

SELECT
    COALESCE(p.product_category_name, 'uncategorised') AS category,
    COUNT(DISTINCT o.order_id)            AS order_count,
    COUNT(oi.order_item_id)               AS items_sold,
    ROUND(SUM(oi.price), 2)              AS revenue,
    ROUND(AVG(oi.price), 2)              AS avg_item_price,
    ROUND(AVG(oi.freight_value), 2)      AS avg_freight,
    ROUND(SUM(oi.price) * 100.0 /
          SUM(SUM(oi.price)) OVER(), 2)  AS revenue_share_pct
FROM orders o
JOIN order_items oi ON o.order_id  = oi.order_id
JOIN products    p  ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered'
GROUP BY category
ORDER BY revenue DESC
LIMIT 15;