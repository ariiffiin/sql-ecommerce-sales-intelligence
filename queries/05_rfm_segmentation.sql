-- ═══════════════════════════════════════════════════════════════
-- Project : Olist E-Commerce Sales Intelligence
-- Date    : July 2026
-- Author  : Muhammad Ariffin Samsu
-- GitHub  : github.com/ariiffiin/sql-ecommerce-sales-intelligence
-- Dialect : SQLite (Kaggle Notebook environment)
-- File    : 05_rfm_segmentation.sql
-- Analysis: Customer RFM Analysis
-- Note    : For MySQL, replace STRFTIME('%Y-%m', date)
--           with DATE_FORMAT(date, '%Y-%m')
--           and JULIANDAY(d2)-JULIANDAY(d1) with DATEDIFF(d2, d1)
-- ═══════════════════════════════════════════════════════════════

-- ── 05_rfm_segmentation.sql ─────────────────────────────────────────

WITH rfm_base AS (
    SELECT
        c.customer_unique_id,
        CAST(
            JULIANDAY('2018-09-01') -
            JULIANDAY(MAX(o.order_purchase_timestamp))
        AS INTEGER)                  AS recency_days,
        COUNT(DISTINCT o.order_id)   AS frequency,
        ROUND(SUM(oi.price), 2)      AS monetary
    FROM customers   c
    JOIN orders      o  ON c.customer_id  = o.customer_id
    JOIN order_items oi ON o.order_id     = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
rfm_scored AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY recency_days ASC)   AS r_score,
        NTILE(5) OVER (ORDER BY frequency DESC)     AS f_score,
        NTILE(5) OVER (ORDER BY monetary DESC)      AS m_score
    FROM rfm_base
),
rfm_segmented AS (
    SELECT *,
        (r_score + f_score + m_score) AS rfm_total,
        CASE
            WHEN (r_score + f_score + m_score) >= 13  THEN 'Champions'
            WHEN (r_score + f_score + m_score) >= 10  THEN 'Loyal Customers'
            WHEN r_score >= 4 AND f_score <= 2        THEN 'New Customers'
            WHEN r_score <= 2 AND f_score >= 3        THEN 'At Risk'
            WHEN r_score <= 2 AND m_score >= 3        THEN 'Cant Lose Them'
            ELSE 'Needs Attention'
        END AS segment
    FROM rfm_scored
)
SELECT
    segment,
    COUNT(*)                          AS customer_count,
    ROUND(AVG(recency_days), 0)       AS avg_recency_days,
    ROUND(AVG(frequency), 1)          AS avg_orders,
    ROUND(AVG(monetary), 2)           AS avg_spend_brl,
    ROUND(SUM(monetary), 2)           AS total_segment_revenue
FROM rfm_segmented
GROUP BY segment
ORDER BY total_segment_revenue DESC;