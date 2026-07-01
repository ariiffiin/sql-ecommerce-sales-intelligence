-- ═══════════════════════════════════════════════════════════════
-- Project : Olist E-Commerce Sales Intelligence
-- Date    : July 2026
-- Author  : Muhammad Ariffin Samsu
-- GitHub  : github.com/YOUR_USERNAME/sql-ecommerce-sales-intelligence
-- Dialect : SQLite (Kaggle Notebook environment)
-- File    : 06_bonus_mom_growth.sql
-- Analysis: Month-on-Month Revenue Growth
-- Note    : For MySQL, replace STRFTIME('%Y-%m', date)
--           with DATE_FORMAT(date, '%Y-%m')
--           and JULIANDAY(d2)-JULIANDAY(d1) with DATEDIFF(d2, d1)
-- ═══════════════════════════════════════════════════════════════

-- ── 06_mom_growth.sql ─────────────────────────────────────────

WITH monthly AS (
    SELECT
        STRFTIME('%Y-%m', o.order_purchase_timestamp) AS order_month,
        ROUND(SUM(oi.price), 2)                        AS revenue,
        COUNT(DISTINCT o.order_id)                     AS orders
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp < '2018-09-01'
    GROUP BY order_month
)
SELECT
    order_month,
    revenue,
    orders,
    LAG(revenue) OVER (ORDER BY order_month)          AS prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY order_month))
        / LAG(revenue) OVER (ORDER BY order_month) * 100,
    1)                                                 AS mom_growth_pct,
    ROUND(
        SUM(revenue) OVER (ORDER BY order_month),
    2)                                                 AS cumulative_revenue
FROM monthly
ORDER BY order_month;