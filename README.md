# Olist E-Commerce SQL Analysis


End-to-end SQL analysis of a Brazilian e-commerce platform using the Olist public dataset. Covers revenue analysis, customer segmentation, logistics performance, and cohort-based retention — structured to answer real business questions across 15 queries of increasing complexity.

---

## Dataset

**Source:** [Olist Brazilian E-Commerce — Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

99,441 orders placed between 2016 and 2018 across multiple product categories and Brazilian states. The dataset ships as multiple CSVs mapping to a relational schema.

---

## Schema

```
customers
    customer_id (PK)
    customer_unique_id
    customer_zip_code_prefix
    customer_city
    customer_state
         |
         | 1:N
         v
orders
    order_id (PK)
    customer_id (FK)
    order_status
    order_purchase_timestamp
    order_approved_at
    order_delivered_carrier_date
    order_delivered_customer_date
    order_estimated_delivery_date
         |
         | 1:N
         v
order_items
    order_id (FK)
    order_item_id
    product_id (FK)
    seller_id
    shipping_limit_date
    price
    freight_value
         |
         | N:1
         v
products
    product_id (PK)
    product_category_name (FK)
    product_name_length
    product_description_length
    product_photos_qty
    product_weight_g
    product_length_cm
    product_height_cm
    product_width_cm
         |
         | N:1
         v
categories
    product_category_name (PK)
    product_category_name_english
```

---

## Queries

### Basic (Q1-Q5)
| # | Question | Concepts |
|---|----------|----------|
| Q1 | Total revenue by category | JOIN, GROUP BY, ORDER BY, COALESCE |
| Q2 | Monthly revenue trend | DATE_FORMAT, aggregation |
| Q3 | Top 10 customers by spend | Multi-table JOIN, GROUP BY |
| Q4 | Average order value by state | AVG, SUM, GROUP BY |
| Q5 | Order status breakdown | Window function, SUM() OVER() |

### Intermediate (Q6-Q10)
| # | Question | Concepts |
|---|----------|----------|
| Q6 | Avg delivery time by state | DATEDIFF, AVG, IS NOT NULL |
| Q7 | Repeat purchase rate | CTE, CASE WHEN, conditional aggregation |
| Q8 | Top 10 most reordered products | CTE, RANK() window function |
| Q9 | Late deliveries by state | CASE WHEN, percentage calc, HAVING |
| Q10 | Revenue by weekday | DAYNAME, DAYOFWEEK |

### Advanced (Q11-Q15)
| # | Question | Concepts |
|---|----------|----------|
| Q11 | RFM customer segmentation | CTE, NTILE(), multi-score tiering |
| Q12 | Running revenue + MoM growth | SUM() OVER(), LAG() |
| Q13 | Cohort retention analysis | CTE, self-join, cohort logic |
| Q14 | Seller performance ranking | CTE, RANK(), CASE WHEN tiering |
| Q15 | Customer LTV by acquisition month | CTE, cohort-based LTV |

---

## Key Findings

**Revenue**
- Health & beauty leads all categories with $1.26M revenue across 8,836 orders — higher avg order value than bed_bath_table despite fewer orders
- November 2017 saw a 52% MoM revenue spike ($339k jump), a clear Black Friday effect
- Cumulative revenue reached $13.2M by August 2018, with growth plateauing in mid-2018

**Customer Behaviour**
- Only 3% of customers make repeat purchases — the platform is heavily acquisition-driven
- Early cohorts (2016-10, 2017-01) show the highest avg LTV at ~$159, with lifespan of 12-16 days between orders
- RFM analysis reveals a large "Potential" segment: recently active, single-purchase customers — the highest ROI re-engagement target

**Logistics**
- SP and RJ receive orders fastest (8-10 days avg delivery)
- Northern states like AM and RR average 25+ days — a systemic logistics gap
- garden_tools has 4 products in the top 10 most reordered, suggesting high replacement/consumable demand

---

## Project Structure

```
olist-sql-analysis/
    README.md
    schema/
        create_tables.sql
    data/
        seed_data.sql
    queries/
        01_basic.sql
        02_intermediate.sql
        03_advanced.sql
```

---

## Setup

**Requirements:** MySQL 8.0+, DB Browser for SQLite (optional)

1. Clone the repo
2. Download the Olist dataset from Kaggle (link above)
3. Run `schema/create_tables.sql` to create the database and tables
4. Follow instructions in `data/seed_data.sql` to load CSVs
5. Run queries from the `queries/` folder in order

---

## Tools Used

- MySQL 8.0
- MySQL CLI
- VS Code
- Kaggle (Olist Brazilian E-Commerce dataset)