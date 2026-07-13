-- ═══════════════════════════════════════════════════════════════
-- Project : Olist E-Commerce Sales Intelligence
-- Date    : July 2026
-- Author  : Muhammad Ariffin Samsu
-- GitHub  : github.com/ariiffiin/sql-ecommerce-sales-intelligence
-- Dialect : SQLite (Kaggle Notebook environment)
-- File    : 04_seller_ranking.sql
-- Analysis: Seller Performance Analysis
-- Note    : For MySQL, replace STRFTIME('%Y-%m', date)
--           with DATE_FORMAT(date, '%Y-%m')
--           and JULIANDAY(d2)-JULIANDAY(d1) with DATEDIFF(d2, d1)
-- ═══════════════════════════════════════════════════════════════

-- ── 04_seller_ranking.sql ───────────────────────────────────────────
-- 04.01 Seller ranked by Total Revenue
WITH seller_stats AS (
    SELECT
        s.seller_id,
        s.seller_state,
        COUNT(DISTINCT o.order_id)              AS orders_completed,
        ROUND(SUM(oi.price), 2)                 AS total_revenue,
        ROUND(AVG(r.review_score), 2)           AS avg_rating,
        COUNT(DISTINCT p.product_category_name) AS category_diversity
    FROM sellers      s
    JOIN order_items  oi ON s.seller_id   = oi.seller_id
    JOIN orders       o  ON oi.order_id   = o.order_id
    JOIN order_reviews r ON o.order_id    = r.order_id
    JOIN products     p  ON oi.product_id = p.product_id
    WHERE o.order_status = 'delivered'
    GROUP BY s.seller_id, s.seller_state
    HAVING orders_completed >= 10
),
seller_ranked AS (
    SELECT *,
        RANK() OVER (ORDER BY total_revenue DESC)   AS revenue_rank,
        RANK() OVER (ORDER BY avg_rating DESC)      AS rating_rank,
        NTILE(4) OVER (ORDER BY total_revenue DESC) AS revenue_quartile
    FROM seller_stats
)
SELECT
    seller_id,
    seller_state,
    orders_completed,
    total_revenue,
    avg_rating,
    category_diversity,
    revenue_rank,
    rating_rank,
    CASE revenue_quartile
        WHEN 1 THEN 'Q1 — Top 25%'
        WHEN 2 THEN 'Q2 — Upper Mid'
        WHEN 3 THEN 'Q3 — Lower Mid'
        WHEN 4 THEN 'Q4 — Bottom 25%'
    END AS performance_tier
FROM seller_ranked
ORDER BY total_revenue DESC
LIMIT 10;

-- 04.02 Distribution of sellers by State

WITH state_stats AS (
    SELECT
        s.seller_state,

        COUNT(DISTINCT s.seller_id)   AS num_sellers,
        COUNT(DISTINCT o.order_id)    AS total_orders,
        ROUND(SUM(oi.price), 2)       AS total_revenue,
        ROUND(AVG(r.review_score), 2) AS avg_rating

    FROM sellers s
    JOIN order_items oi
        ON s.seller_id = oi.seller_id
    JOIN orders o
        ON oi.order_id = o.order_id
    JOIN order_reviews r
        ON o.order_id = r.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY s.seller_state
)

SELECT
    seller_state,
    num_sellers,
    total_orders,

    -- % of total orders
    ROUND(
        total_orders * 100.0 / SUM(total_orders) OVER(),
        2
    ) AS pct_orders,
    
    total_revenue,

    -- % of total revenue
    ROUND(
        total_revenue * 100.0 / SUM(total_revenue) OVER(),
        2
    ) AS pct_revenue,
    
    avg_rating




FROM state_stats
ORDER BY total_revenue DESC
LIMIT 10;
