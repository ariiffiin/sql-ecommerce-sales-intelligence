-- ═══════════════════════════════════════════════════════════════
-- Project : Olist E-Commerce Sales Intelligence
-- Date    : July 2026
-- Author  : Muhammad Ariffin Samsu
-- GitHub  : github.com/ariiffiin/sql-ecommerce-sales-intelligence
-- Dialect : SQLite (Kaggle Notebook environment)
-- File    : 03_delivery_sla.sql
-- Analysis: Delivery SLA Analysis
-- Note    : For MySQL, replace STRFTIME('%Y-%m', date)
--           with DATE_FORMAT(date, '%Y-%m')
--           and JULIANDAY(d2)-JULIANDAY(d1) with DATEDIFF(d2, d1)
-- ═══════════════════════════════════════════════════════════════

-- ── 03_delivery_sla.sql ─────────────────────────────────────────────
-- 03.01: Delivery Performance by SLA Distribution
SELECT
    CASE
        WHEN JULIANDAY(o.order_delivered_customer_date) -
             JULIANDAY(o.order_estimated_delivery_date) <= 0
             THEN 'On Time'
        WHEN JULIANDAY(o.order_delivered_customer_date) -
             JULIANDAY(o.order_estimated_delivery_date) BETWEEN 0 AND 7
             THEN '1–7 Days Late'
        WHEN JULIANDAY(o.order_delivered_customer_date) -
             JULIANDAY(o.order_estimated_delivery_date) BETWEEN 7 AND 14
             THEN '8–14 Days Late'
        ELSE '14+ Days Late'
    END AS delivery_band,
    COUNT(*)                                                AS order_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2)     AS pct_of_total,
    ROUND(AVG(
        JULIANDAY(o.order_delivered_customer_date) -
        JULIANDAY(o.order_estimated_delivery_date)
    ), 1)                                                   AS avg_days_deviation
FROM orders o
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY delivery_band
ORDER BY order_count DESC;

-- 03.02 Revenue & Order Impact by Delivery SLA Performance

SELECT
    CASE
        WHEN JULIANDAY(o.order_delivered_customer_date) -
             JULIANDAY(o.order_estimated_delivery_date) <= 0
             THEN 'On Time'
        WHEN JULIANDAY(o.order_delivered_customer_date) -
             JULIANDAY(o.order_estimated_delivery_date) BETWEEN 0 AND 7
             THEN '1–7 Days Late'
        WHEN JULIANDAY(o.order_delivered_customer_date) -
             JULIANDAY(o.order_estimated_delivery_date) BETWEEN 7 AND 14
             THEN '8–14 Days Late'
        ELSE '14+ Days Late'
    END AS delivery_band,

    COUNT(DISTINCT o.order_id) AS order_count,

    ROUND(SUM(p.payment_value), 2) AS revenue,

    ROUND(SUM(p.payment_value) * 100.0 / SUM(SUM(p.payment_value)) OVER(), 2) AS revenue_share_pct,

    ROUND(AVG(
        JULIANDAY(o.order_delivered_customer_date) -
        JULIANDAY(o.order_estimated_delivery_date)
    ), 1) AS avg_days_deviation

FROM orders o
    JOIN order_payments p
    ON o.order_id = p.order_id

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL

GROUP BY delivery_band
ORDER BY order_count DESC;