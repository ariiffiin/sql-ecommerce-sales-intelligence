-- ═══════════════════════════════════════════════════════════════
-- Project : Olist E-Commerce Sales Intelligence
-- Date    : July 2026
-- Author  : Muhammad Ariffin Samsu
-- GitHub  : github.com/YOUR_USERNAME/sql-ecommerce-sales-intelligence
-- Dialect : SQLite (Kaggle Notebook environment)
-- File    : 01_monthly_revenue.sql
-- Analysis: Overall Revenue Trend
-- Note    : For MySQL, replace STRFTIME('%Y-%m', date)
--           with DATE_FORMAT(date, '%Y-%m')
--           and JULIANDAY(d2)-JULIANDAY(d1) with DATEDIFF(d2, d1)
-- ═══════════════════════════════════════════════════════════════

--── 01_monthly_revenue.sql ──────────────────────────────────────────
--01.01 Monthly Revenue & Order Volume by month
    STRFTIME('%Y-%m', o.order_purchase_timestamp)  AS order_month,
    COUNT(DISTINCT o.order_id)                     AS total_orders,
    ROUND(SUM(oi.price), 2)                        AS gross_revenue,
    ROUND(SUM(oi.freight_value), 2)                AS total_freight,
    ROUND(SUM(oi.price + oi.freight_value), 2)     AS total_gmv,
    ROUND(AVG(oi.price), 2)                        AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
  AND o.order_purchase_timestamp < '2018-09-01'
GROUP BY order_month
ORDER BY order_month;

/* Observations
    1)Overall monthly revenue and orders of the e-commerce store increase almost gradually from Sept 2016 to early-2018 which then stabilize for the rest of 2018.
    2)Significant spike on Nov 2017 was probably cause by surge of order for Black Friday as more than 15% of the orders for the month are purchased on Black Friday.
*/
--01.02 2017 Nov Revenue & Order Volume

SELECT
    STRFTIME('%Y-%m-%d', o.order_purchase_timestamp)  AS order_day,
    COUNT(DISTINCT o.order_id)                     AS total_orders,
    ROUND(SUM(oi.price), 2)                        AS gross_revenue,
    ROUND(SUM(oi.freight_value), 2)                AS total_freight,
    ROUND(SUM(oi.price + oi.freight_value), 2)     AS total_gmv,
    ROUND(AVG(oi.price), 2)                        AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
  AND o.order_purchase_timestamp >= '2017-11-01' AND o.order_purchase_timestamp < '2017-11-30'
GROUP BY order_day
ORDER BY order_day;

/* Observations
    1)Significant spike on Nov 2017 was probably cause by surge of order for Black Friday (24 Nov) as more than 15% of the orders for the month are purchased on Black Friday.
*/