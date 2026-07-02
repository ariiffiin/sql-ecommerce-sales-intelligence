# Olist E-Commerce — Schema Notes & ERD Reference

**Project:** E-Commerce Sales Intelligence  
**File:** `schema/olist_schema_notes.md`  
**Dialect:** SQLite (Kaggle hosted — `olist.db`)  
**Author:** Muhammad Ariffin Samsu  
**Dataset:** [Olist Brazilian E-Commerce (SQLite)](https://www.kaggle.com/datasets/terencicp/e-commerce-dataset-by-olist-as-an-sqlite-database)

---

## What is Olist?

Olist is Brazil's largest online marketplace aggregator. It connects small and medium-sized merchants to major Brazilian e-commerce platforms (like Mercado Livre, Americanas, etc.) through a single unified storefront. This dataset captures **100,000+ real orders** placed between September 2016 and October 2018, across sellers and buyers spread across all 26 Brazilian states.

The data is fully anonymised — customer and seller IDs are hashed. Product names and review comments have been replaced with category references.

---

## Entity Relationship Diagram (Text)

```
┌─────────────┐        ┌──────────────────┐        ┌──────────────┐
│  customers  │        │     orders       │        │ order_items  │
│─────────────│        │──────────────────│        │──────────────│
│ customer_id │◄───────│ customer_id  (FK)│        │ order_id(FK) │
│ customer_   │  1 : N │ order_id     (PK)│◄───────│ order_item_id│
│ unique_id   │        │ order_status     │  1 : N │ product_id(FK│
│ city        │        │ purchase_ts      │        │ seller_id(FK)│
│ state       │        │ approved_at      │        │ price        │
└─────────────┘        │ delivered_carrier│        │ freight_value│
                       │ delivered_cust   │        └──────┬───────┘
                       │ estimated_deliv  │               │
                       └──────┬───────────┘        ┌─────▼──────┐
                              │                     │  products  │
                              │ 1 : N               │────────────│
                    ┌─────────▼──────────┐          │ product_id │
                    │  order_payments    │          │ category   │
                    │────────────────────│          │ weight_g   │
                    │ order_id      (FK) │          │ photos_qty │
                    │ payment_sequential │          └────────────┘
                    │ payment_type       │
                    │ payment_value      │          ┌────────────┐
                    │ installments       │          │  sellers   │
                    └────────────────────┘          │────────────│
                              │                     │ seller_id  │
                    ┌─────────▼──────────┐          │ city       │
                    │  order_reviews     │          │ state      │
                    │────────────────────│          └────────────┘
                    │ review_id     (PK) │
                    │ order_id      (FK) │
                    │ review_score       │
                    │ review_creation_dt │
                    └────────────────────┘
```

**Cardinality legend:**
- `1 : N` — one row in the parent table maps to many rows in the child table
- `(PK)` — Primary Key
- `(FK)` — Foreign Key referencing the parent table
- `►` — direction of the relationship (parent ► child)

---

## Table-by-Table Reference

---

### Table 1 — `customers`

**Row count:** ~99,441  
**Grain:** One row per `customer_id` (tied to a single order)

| Column | Type | Description |
|---|---|---|
| `customer_id` | TEXT (PK) | Unique per order — NOT per person. A repeat buyer gets a new `customer_id` each time |
| `customer_unique_id` | TEXT | Hashed identifier that persists across orders. **Use this for repeat-buyer analysis** |
| `customer_zip_code_prefix` | TEXT | First 5 digits of the Brazilian CEP postal code |
| `customer_city` | TEXT | City name in Portuguese |
| `customer_state` | TEXT | 2-letter Brazilian state abbreviation (e.g. `SP`, `RJ`, `MG`) |

**Analyst notes:**
- Never use `customer_id` for cohort or loyalty analysis — it resets per order
- `customer_unique_id` is the correct field for RFM segmentation
- Most customers appear only once (Brazilian e-commerce repeat rate is low in this dataset)

---

### Table 2 — `orders`

**Row count:** ~99,441  
**Grain:** One row per order  
**This is the spine of the entire schema — every other table connects through it**

| Column | Type | Description |
|---|---|---|
| `order_id` | TEXT (PK) | Unique order identifier |
| `customer_id` | TEXT (FK → customers) | Links to the customer who placed the order |
| `order_status` | TEXT | Lifecycle status of the order (see values below) |
| `order_purchase_timestamp` | TEXT | When the customer placed the order |
| `order_approved_at` | TEXT | When payment was confirmed |
| `order_delivered_carrier_date` | TEXT | When the seller handed the parcel to logistics |
| `order_delivered_customer_date` | TEXT | When the customer received the parcel |
| `order_estimated_delivery_date` | TEXT | Olist's promised delivery date shown to the customer |

**Order status values:**

| Status | Meaning |
|---|---|
| `delivered` | Customer received the order ✅ — **use this for revenue analysis** |
| `shipped` | In transit to customer |
| `canceled` | Order was cancelled |
| `invoiced` | Invoice issued, awaiting shipment |
| `processing` | Being prepared by the seller |
| `unavailable` | Item became unavailable |
| `approved` | Payment approved, not yet processed |
| `created` | Order created but not approved |

**Analyst notes:**
- Always filter `WHERE order_status = 'delivered'` for revenue and delivery analysis
- `order_delivered_customer_date - order_estimated_delivery_date` = delivery SLA deviation
- All timestamps are stored as TEXT — use `JULIANDAY()` in SQLite for date arithmetic
- Incomplete final month: exclude `order_purchase_timestamp >= '2018-09-01'` to avoid partial-month distortion

---

### Table 3 — `products`

**Row count:** ~32,951  
**Grain:** One row per unique product SKU

| Column | Type | Description |
|---|---|---|
| `product_id` | TEXT (PK) | Hashed product identifier |
| `product_category_name` | TEXT | Category in Portuguese (e.g. `cama_mesa_banho`, `beleza_saude`) |
| `product_name_lenght` | INTEGER | Character count of the product name (typo kept from source data) |
| `product_description_lenght` | INTEGER | Character count of the product description |
| `product_photos_qty` | INTEGER | Number of photos in the product listing |
| `product_weight_g` | REAL | Weight in grams |
| `product_length_cm` | REAL | Length in centimetres |
| `product_height_cm` | REAL | Height in centimetres |
| `product_width_cm` | REAL | Width in centimetres |

**Analyst notes:**
- `product_category_name` is the key field for category performance analysis
- ~600 products have NULL category — handle with `COALESCE(product_category_name, 'uncategorised')`
- Note the intentional typo: `product_name_lenght` (not `length`) — kept to match the raw CSV header exactly

**Top categories by revenue (reference):**

| Category (Portuguese) | Rough translation |
|---|---|
| `cama_mesa_banho` | Bed, table & bath |
| `beleza_saude` | Beauty & health |
| `esporte_lazer` | Sports & leisure |
| `moveis_decoracao` | Furniture & decor |
| `informatica_acessorios` | Computers & accessories |

---

### Table 4 — `sellers`

**Row count:** ~3,095  
**Grain:** One row per registered seller on the Olist platform

| Column | Type | Description |
|---|---|---|
| `seller_id` | TEXT (PK) | Hashed seller identifier |
| `seller_zip_code_prefix` | TEXT | First 5 digits of seller's CEP |
| `seller_city` | TEXT | Seller's city |
| `seller_state` | TEXT | 2-letter state abbreviation |

**Analyst notes:**
- Most sellers are concentrated in São Paulo state (`SP`)
- Seller performance analysis requires joining through `order_items` — you cannot join `sellers` directly to `orders`
- Apply `HAVING orders_completed >= 10` when ranking sellers to exclude low-volume noise

---

### Table 5 — `order_items`

**Row count:** ~112,650  
**Grain:** One row per item within an order (composite PK: `order_id` + `order_item_id`)  
**This is the bridge table that links orders, products, and sellers together**

| Column | Type | Description |
|---|---|---|
| `order_id` | TEXT (FK → orders) | Links to the parent order |
| `order_item_id` | INTEGER | Item sequence within the order (1, 2, 3...) |
| `product_id` | TEXT (FK → products) | The specific product purchased |
| `seller_id` | TEXT (FK → sellers) | The seller who fulfilled this item |
| `shipping_limit_date` | TEXT | Latest date the seller must hand to carrier |
| `price` | REAL | Item price in BRL (Brazilian Real) — **per item, not per order** |
| `freight_value` | REAL | Shipping cost for this item in BRL |

**Analyst notes:**
- `price` is per item — always `SUM(price)` to get order-level revenue
- An order with 3 items has 3 rows in this table, each potentially from a different seller
- `price + freight_value` = total GMV (Gross Merchandise Value) per item
- Row count (112,650) > order count (99,441) because multi-item orders exist

**Join path reminder:**
```sql
orders  →  order_items  →  products
orders  →  order_items  →  sellers
```
Never try to join `orders` directly to `products` or `sellers` — the path always goes through `order_items`.

---

### Table 6 — `order_payments`

**Row count:** ~103,886  
**Grain:** One row per payment method per order (composite: `order_id` + `payment_sequential`)

| Column | Type | Description |
|---|---|---|
| `order_id` | TEXT (FK → orders) | Links to the parent order |
| `payment_sequential` | INTEGER | 1 = primary payment method, 2+ = supplementary |
| `payment_type` | TEXT | Method used (see values below) |
| `payment_installments` | INTEGER | Number of monthly instalments (parcelamento) |
| `payment_value` | REAL | Amount paid via this method in BRL |

**Payment type values:**

| Value | Description |
|---|---|
| `credit_card` | Credit card — dominant method, supports instalments |
| `boleto` | Brazilian bank slip — pay at bank/ATM, no instalments |
| `voucher` | Olist gift/discount voucher |
| `debit_card` | Debit card — immediate payment |
| `not_defined` | Unknown — filter these out in analysis |

**Analyst notes:**
- Row count slightly exceeds order count because some orders use split payment (e.g. voucher + credit card)
- When aggregating payment totals per order, filter to `payment_sequential = 1` OR use `SUM(payment_value)` grouped by `order_id`
- `payment_installments` averages ~3.7 — Brazilians heavily use parcelamento (interest-free instalments)
- Credit card users consistently show higher `AVG(payment_value)` than boleto users

---

### Table 7 — `order_reviews`

**Row count:** ~99,224  
**Grain:** One row per review (one review per order)

| Column | Type | Description |
|---|---|---|
| `review_id` | TEXT (PK) | Unique review identifier |
| `order_id` | TEXT (FK → orders) | Links to the reviewed order |
| `review_score` | INTEGER | Customer satisfaction: 1 (worst) to 5 (best) |
| `review_creation_date` | TEXT | When Olist sent the review request to the customer |
| `review_answer_timestamp` | TEXT | When the customer submitted their review |

**Analyst notes:**
- ~775 orders have no matching review — use `LEFT JOIN` if you want to include them
- Review scores are skewed positive — most customers give 5/5
- `review_score` distribution (approx): 5★ ≈ 57%, 4★ ≈ 19%, 1★ ≈ 11%, 3★ ≈ 8%, 2★ ≈ 5%
- Strong signal: orders delivered >7 days late see avg score drop below 3.0
- Review text columns (comment title/message) are excluded from the SQLite version of this dataset

---

## Key Join Paths (Quick Reference)

```sql
-- Revenue with product category
orders → order_items → products

-- Revenue with seller info
orders → order_items → sellers

-- Customer location + revenue
orders → customers

-- Payment method analysis
orders → order_payments → customers

-- Review score vs delivery
orders → order_reviews

-- Full join (all 6 tables)
orders
  JOIN order_items  ON orders.order_id      = order_items.order_id
  JOIN products     ON order_items.product_id = products.product_id
  JOIN sellers      ON order_items.seller_id  = sellers.seller_id
  JOIN customers    ON orders.customer_id     = customers.customer_id
  JOIN order_reviews ON orders.order_id      = order_reviews.order_id
  JOIN order_payments ON orders.order_id     = order_payments.order_id
```

---

## SQLite-Specific Function Reference

Functions that differ from MySQL — important when reading other SQL tutorials:

| Operation | MySQL | SQLite (what we use) |
|---|---|---|
| Format date as YYYY-MM | `DATE_FORMAT(col, '%Y-%m')` | `STRFTIME('%Y-%m', col)` |
| Date difference in days | `DATEDIFF(d2, d1)` | `JULIANDAY(d2) - JULIANDAY(d1)` |
| Current timestamp | `NOW()` | `DATETIME('now')` |
| String concatenation | `CONCAT(a, b)` | `a \|\| b` |
| Auto-increment PK | `INT AUTO_INCREMENT` | `INTEGER PRIMARY KEY` |
| Conditional value | `IFNULL(col, 0)` | `COALESCE(col, 0)` *(both work)* |

---

## Recommended Analysis Filter (Always Apply)

```sql
WHERE order_status = 'delivered'
  AND order_purchase_timestamp < '2018-09-01'
  AND order_delivered_customer_date IS NOT NULL
```

This combination ensures:
- Only completed, revenue-generating orders are counted
- The incomplete final month (Sept 2018) is excluded to avoid distorting trends
- Delivery date calculations don't produce NULL results

---

## Dataset Limitations to Acknowledge in Your Portfolio

| Limitation | Impact |
|---|---|
| Data ends Oct 2018 | Cannot analyse post-2018 trends |
| Review text removed from SQLite version | Sentiment analysis not possible |
| ~600 products have no category | Small revenue gap in category analysis |
| Seller/customer names are hashed | No named-entity analysis |
| Single country (Brazil) | Findings may not generalise globally |
| No returns/refunds data | Can't calculate net revenue accurately |

---

*Schema documented by Muhammad Ariffin Samsu — Olist E-Commerce Sales Intelligence Portfolio Project*  
*Live notebook: [Kaggle →]([https://www.kaggle.com/](https://www.kaggle.com/code/ariffinsamsu/notebook2fec4d9996)) | Repository: [GitHub →]([https://github.com/](https://github.com/ariiffiin/sql-ecommerce-sales-intelligence))*
