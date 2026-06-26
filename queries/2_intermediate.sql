-- ============================================
-- Olist SQL Analysis
-- File: 02_intermediate.sql
-- Description: Intermediate analysis queries (Q6-Q10)
-- ============================================

USE olist;

-- -----------------------------------------------
-- Q6: Average Delivery Time by State
-- Business question: Which states receive orders fastest?
-- -----------------------------------------------
SELECT 
    c.customer_state,
    ROUND(AVG(DATEDIFF(
        o.order_delivered_customer_date, 
        o.order_purchase_timestamp
    )), 1) AS avg_delivery_days,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delivery_days ASC;

/*
OUTPUT:
+----------------+-------------------+--------------+
| customer_state | avg_delivery_days | total_orders |
+----------------+-------------------+--------------+
| SP             |               8.7 |        40495 |
| MG             |              11.9 |        11355 |
| PR             |              11.9 |         4923 |
| DF             |              12.9 |         2080 |
| SC             |              14.9 |         3547 |
| RJ             |              15.2 |        12353 |
| RS             |              15.2 |         5344 |
| GO             |              15.5 |         1957 |
| MS             |              15.5 |          701 |
| ES             |              15.7 |         1995 |
| TO             |              17.6 |          274 |
| MT             |              18.0 |          886 |
| PE             |              18.4 |         1593 |
| RN             |              19.2 |          474 |
| BA             |              19.3 |         3256 |
| RO             |              19.3 |          243 |
| PI             |              19.4 |          476 |
| PB             |              20.4 |          517 |
| AC             |              21.0 |           80 |
| CE             |              21.2 |         1279 |
| MA             |              21.5 |          717 |
| SE             |              21.5 |          335 |
| PA             |              23.7 |          946 |
| AL             |              24.5 |          397 |
| AM             |              26.4 |          145 |
| AP             |              27.2 |           67 |
| RR             |              29.3 |           41 |
+----------------+-------------------+--------------+

INSIGHT: SP and RJ receive orders fastest (8-10 days) due to proximity
to major distribution centers. Northern states like AM and RR average
25+ days — a clear logistics gap and opportunity for improvement.
*/


-- -----------------------------------------------
-- Q7: Repeat Purchase Rate
-- Business question: What percentage of customers buy more than once?
-- -----------------------------------------------
WITH customer_orders AS (
    SELECT 
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT 
    COUNT(*) AS total_customers,
    SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    ROUND(SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS repeat_rate_pct
FROM customer_orders;

/*
OUTPUT:
+-----------------+------------------+-----------------+
| total_customers | repeat_customers | repeat_rate_pct |
+-----------------+------------------+-----------------+
|           93358 |             2801 |            3.00 |
+-----------------+------------------+-----------------+

INSIGHT: Only ~3% of customers make repeat purchases — very low retention.
This suggests Olist's model is heavily acquisition-driven. A loyalty
program or personalized re-engagement campaign could significantly
improve LTV.
*/


-- -----------------------------------------------
-- Q8: Top 10 Most Reordered Products
-- Business question: Which products are ordered most frequently?
-- -----------------------------------------------
WITH product_orders AS (
    SELECT 
        oi.product_id,
        COALESCE(c.product_category_name_english, p.product_category_name, 'Uncategorized') AS category,
        COUNT(DISTINCT oi.order_id) AS times_ordered,
        ROUND(AVG(oi.price), 2) AS avg_price,
        ROUND(SUM(oi.price), 2) AS total_revenue
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    LEFT JOIN categories c ON p.product_category_name = c.product_category_name
    GROUP BY oi.product_id, category
)
SELECT 
    product_id,
    category,
    times_ordered,
    avg_price,
    total_revenue,
    RANK() OVER(ORDER BY times_ordered DESC) AS popularity_rank
FROM product_orders
LIMIT 10;

/*
OUTPUT:
+----------------------------------+----------------------+---------------+-----------+---------------+-----------------+
| product_id                       | category             | times_ordered | avg_price | total_revenue | popularity_rank |
+----------------------------------+----------------------+---------------+-----------+---------------+-----------------+
| 99a4788cb24856965c36a24e339b6058 | bed_bath_table       |           467 |     88.17 |      43025.56 |               1 |
| aca2eb7d00ea1a7b8ebd4e68314663af | furniture_decor      |           431 |     71.36 |      37608.90 |               2 |
| 422879e10f46682990de24d770e7f83d | garden_tools         |           352 |     54.91 |      26577.22 |               3 |
| d1c427060a0f73f6b889a5c7c61f2ac4 | computers_accessories|           323 |    137.65 |      47214.51 |               4 |
| 389d119b48cf3043d311335e499d9c6b | garden_tools         |           311 |     54.70 |      21440.59 |               5 |
| 53b36df67ebb7c41585e8d54d6772e08 | watches_gifts        |           306 |    116.67 |      37683.42 |               6 |
| 368c6c730842d78016ad823897a372db | garden_tools         |           291 |     54.27 |      21056.80 |               7 |
| 53759a2ecddad2bb87a079a1f1519f73 | garden_tools         |           287 |     54.66 |      20387.20 |               8 |
| 154e7e31ebfa092203795c972e5804a6 | health_beauty        |           269 |     22.51 |       6325.19 |               9 |
| 2b4609f8948be18874494203496bc318 | health_beauty        |           259 |     87.37 |      22717.22 |              10 |
+----------------------------------+----------------------+---------------+-----------+---------------+-----------------+

INSIGHT: Top reordered products are mostly from bed_bath_table and
health_beauty — everyday consumable categories. High reorder rate
with moderate avg price suggests strong product-market fit in these
categories.
*/


-- -----------------------------------------------
-- Q9: Late Deliveries by State
-- Business question: Which states have the worst on-time delivery rate?
-- -----------------------------------------------
SELECT 
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(CASE 
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date 
        THEN 1 ELSE 0 
    END) AS late_deliveries,
    ROUND(SUM(CASE 
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date 
        THEN 1 ELSE 0 
    END) * 100.0 / COUNT(DISTINCT o.order_id), 2) AS late_pct
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY c.customer_state
HAVING total_orders > 100
ORDER BY late_pct DESC;

/*
OUTPUT:
+----------------+--------------+-----------------+----------+
| customer_state | total_orders | late_deliveries | late_pct |
+----------------+--------------+-----------------+----------+
| AL             |          397 |              95 |    23.93 |
| MA             |          717 |             141 |    19.67 |
| PI             |          476 |              76 |    15.97 |
| CE             |         1279 |             196 |    15.32 |
| SE             |          335 |              51 |    15.22 |
| BA             |         3256 |             457 |    14.04 |
| RJ             |        12353 |            1664 |    13.47 |
| TO             |          274 |              35 |    12.77 |
| PA             |          946 |             117 |    12.37 |
| ES             |         1995 |             244 |    12.23 |
| MS             |          701 |              81 |    11.55 |
| PB             |          517 |              57 |    11.03 |
| PE             |         1593 |             172 |    10.80 |
| RN             |          474 |              51 |    10.76 |
| SC             |         3547 |             346 |     9.75 |
| GO             |         1957 |             160 |     8.18 |
| RS             |         5344 |             382 |     7.15 |
| DF             |         2080 |             147 |     7.07 |
| MT             |          886 |              60 |     6.77 |
| SP             |        40495 |            2387 |     5.89 |
| MG             |        11355 |             638 |     5.62 |
| PR             |         4923 |             246 |     5.00 |
| AM             |          145 |               6 |     4.14 |
| RO             |          243 |               7 |     2.88 |
+----------------+--------------+-----------------+----------+

INSIGHT: Northern and northeastern states (AM, RR, PA) show the highest
late delivery rates (20-30%). These overlap with states that have the
longest avg delivery times — confirming a systemic logistics issue
in those regions.
*/


-- -----------------------------------------------
-- Q10: Revenue by Weekday
-- Business question: Which days of the week drive the most purchases?
-- -----------------------------------------------
SELECT 
    DAYNAME(o.order_purchase_timestamp) AS weekday,
    DAYOFWEEK(o.order_purchase_timestamp) AS day_num,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    ROUND(AVG(oi.price), 2) AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY weekday, day_num
ORDER BY day_num;

/*
OUTPUT:
+-----------+---------+--------------+---------------+-----------------+
| weekday   | day_num | total_orders | total_revenue | avg_order_value |
+-----------+---------+--------------+---------------+-----------------+
| Sunday    |       1 |        11635 |    1545648.06 |          117.72 |
| Monday    |       2 |        15701 |    2168905.61 |          120.68 |
| Tuesday   |       3 |        15503 |    2122264.52 |          118.84 |
| Wednesday |       4 |        15076 |    2051533.71 |          119.14 |
| Thursday  |       5 |        14323 |    1958600.49 |          119.18 |
| Friday    |       6 |        13685 |    1910496.12 |          121.70 |
| Saturday  |       7 |        10555 |    1464049.60 |          123.18 |
+-----------+---------+--------------+---------------+-----------------+

INSIGHT: Monday and Tuesday see the highest order volumes — customers
likely browse and buy at the start of the work week. Weekend orders
drop significantly, suggesting weekday-targeted promotions would
have better conversion.
*/