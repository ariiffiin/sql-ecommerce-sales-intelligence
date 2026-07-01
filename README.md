# 🛒 E-Commerce Sales Intelligence — SQL Portfolio Project

**Tool:** SQLite (via Kaggle Notebook)  
**Dataset:** [Olist Brazilian E-Commerce](https://www.kaggle.com/datasets/terencicp/e-commerce-dataset-by-olist-as-an-sqlite-database) — 100,000+ real orders (2016–2018)  
**Skills:** JOINs, CTEs, Window Functions, CASE, Aggregations, Date Functions, RFM Segmentation

---

## 📌 Project Overview

This project analyses 100k+ real e-commerce orders from Olist, Brazil's largest online marketplace aggregator. Using SQL on a normalised 7-table relational database, I extracted business insights across revenue trends, product performance, delivery operations, seller rankings, and customer segmentation.

Live Notebook: [View on Kaggle →] https://www.kaggle.com/code/ariffinsamsu/notebook2fec4d9996

---

## 📁 Repository Structure
-- queries/
-- ├── 00_exploration.sql       — Row counts, date range, status breakdown
-- ├── 01_monthly_revenue.sql   — Revenue & GMV trend by month
-- ├── 02_category_performance.sql — Top 15 categories by revenue
-- ├── 03_delivery_sla.sql      — On-time vs late delivery banding
-- ├── 04_seller_ranking.sql    — Seller performance with RANK() & NTILE()
-- ├── 05_rfm_segmentation.sql  — Customer segments: Champions, At Risk, etc.
-- └── 06_bonus_mom_growth.sql  — MoM growth % using LAG() + cumulative SUM()

---

## 🧠 SQL Concepts Demonstrated

| Concept | Where Used |
|---|---|
| Multi-table JOINs (4 tables) | Queries 01, 04, 05 |
| CTEs (`WITH` clause) | Queries 04, 05, 06 |
| Window functions: `RANK()`, `NTILE()`, `LAG()` | Queries 03, 04, 05, 06 |
| `SUM() OVER()` for running totals & percentages | Queries 02, 03, 06 |
| `CASE` for banding & segmentation | Queries 03, 05 |
| `COALESCE` for NULL handling | Query 02 |
| `JULIANDAY` for date arithmetic | Queries 03, 05 |
| `HAVING` for post-aggregation filtering | Query 04 |

---

*Dataset provided by Olist via Kaggle. Analysis by Muhammad Ariffin Samsu.*