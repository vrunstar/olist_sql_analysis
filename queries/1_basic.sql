-- ============================================
-- Olist E-Commerce SQL Analysis
-- File: 01_basic.sql
-- Description: Basic analysis queries (Q1-Q5)
-- ============================================

USE olist;

-- -----------------------------------------------
-- Q1: Total Revenue by Category (Top 10)
-- Business question: Which product categories generate the most revenue?
-- -----------------------------------------------
SELECT 
    COALESCE(c.product_category_name_english, p.product_category_name, 'Uncategorized') AS category,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    COUNT(DISTINCT oi.order_id) AS total_orders
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN categories c ON p.product_category_name = c.product_category_name
GROUP BY category
ORDER BY total_revenue DESC
LIMIT 10;

/*
OUTPUT:
category                | total_revenue | total_orders
------------------------|---------------|-------------
health_beauty           | 1258681.34    | 8836
watches_gifts           | 1205005.68    | 5624
bed_bath_table          | 1036988.68    | 9417
sports_leisure          | 988048.97     | 7720
computers_accessories   | 911954.32     | 6689
furniture_decor         | 729762.49     | 6449
cool_stuff              | 635290.85     | 3632
housewares              | 632248.66     | 5884
auto                    | 592720.11     | 3897
garden_tools            | 485256.46     | 3518

INSIGHT: Health & beauty leads with $1.25M revenue despite not having the highest order count — suggesting higher average order values.
*/


-- -----------------------------------------------
-- Q2: Monthly Revenue Trend
-- Business question: How has revenue grown month over month?
-- -----------------------------------------------
SELECT 
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
    ROUND(SUM(oi.price), 2) AS revenue,
    COUNT(DISTINCT o.order_id) AS orders
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY month
ORDER BY month;

/*
+---------+-----------+--------+
| month   | revenue   | orders |
+---------+-----------+--------+
| 2016-09 |    134.97 |      1 |
| 2016-10 |  40325.11 |    265 |
| 2016-12 |     10.90 |      1 |
| 2017-01 | 111798.36 |    750 |
| 2017-02 | 234223.40 |   1653 |
| 2017-03 | 359198.85 |   2546 |
| 2017-04 | 340669.68 |   2303 |
| 2017-05 | 489338.25 |   3546 |
| 2017-06 | 421923.37 |   3135 |
| 2017-07 | 481604.52 |   3872 |
| 2017-08 | 554699.70 |   4193 |
| 2017-09 | 607399.67 |   4150 |
| 2017-10 | 648247.65 |   4478 |
| 2017-11 | 987765.37 |   7289 |
| 2017-12 | 726033.19 |   5513 |
| 2018-01 | 924645.00 |   7069 |
| 2018-02 | 826437.13 |   6555 |
| 2018-03 | 953356.25 |   7003 |
| 2018-04 | 973534.09 |   6798 |
| 2018-05 | 977544.69 |   6749 |
| 2018-06 | 856077.86 |   6099 |
| 2018-07 | 867953.46 |   6159 |
| 2018-08 | 838576.64 |   6351 |
+---------+-----------+--------+


INSIGHT: Revenue shows consistent growth from 2017 to mid-2018, with a notable spike in November 2017 (Black Friday effect).
*/


-- -----------------------------------------------
-- Q3: Top 10 Customers by Total Spend
-- Business question: Who are our highest value customers?
-- -----------------------------------------------
SELECT 
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_unique_id, c.customer_city, c.customer_state
ORDER BY total_spent DESC
LIMIT 10;

/*
+----------------------------------+----------------+----------------+--------------+-------------+
| customer_unique_id               | customer_city  | customer_state | total_orders | total_spent |
+----------------------------------+----------------+----------------+--------------+-------------+
| 0a0a92112bd4c708ca5fde585afaa872 | rio de janeiro | RJ             |            1 |    13440.00 |
| da122df9eeddfedc1dc1f5349a1a690c | araruama       | RJ             |            2 |     7388.00 |
| 763c8b1c9c68a0229c42c9fc6f662b93 | vila velha     | ES             |            1 |     7160.00 |
| dc4802a71eae9be1dd28f5d788ceb526 | campo grande   | MS             |            1 |     6735.00 |
| 459bef486812aa25204be022145caa62 | vitoria        | ES             |            1 |     6729.00 |
| ff4159b92c40ebe40454e3e6a7c35ed6 | marilia        | SP             |            1 |     6499.00 |
| 4007669dec559734d6f53e029e360987 | divinopolis    | MG             |            1 |     5934.60 |
| eebb5dda148d3893cdaf5b5ca3040ccb | maua           | SP             |            1 |     4690.00 |
| 48e1ac109decbb87765a3eade6854098 | joao pessoa    | PB             |            1 |     4590.00 |
| a229eba70ec1c2abef51f04987deb7a5 | niteroi        | RJ             |            1 |     4400.00 |
+----------------------------------+----------------+----------------+--------------+-------------+

INSIGHT: Top customers are mostly from SP (São Paulo), Brazil's largest city, confirming it as the primary market.
*/


-- -----------------------------------------------
-- Q4: Average Order Value by State
-- Business question: Which states have the highest spending customers?
-- -----------------------------------------------
SELECT 
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(AVG(oi.price), 2) AS avg_order_value,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY total_revenue DESC;

/*
+----------------+--------------+-----------------+---------------+
| customer_state | total_orders | avg_order_value | total_revenue |
+----------------+--------------+-----------------+---------------+
| SP             |        40501 |          109.10 |    5067633.16 |
| RJ             |        12350 |          124.42 |    1759651.13 |
| MG             |        11354 |          120.20 |    1552481.83 |
| RS             |         5345 |          118.83 |     728897.47 |
| PR             |         4923 |          117.91 |     666063.51 |
| SC             |         3546 |          123.75 |     507012.13 |
| BA             |         3256 |          134.02 |     493584.14 |
| DF             |         2080 |          125.90 |     296498.41 |
| GO             |         1957 |          124.21 |     282836.70 |
| ES             |         1995 |          120.74 |     268643.45 |
| PE             |         1593 |          144.27 |     251889.49 |
| CE             |         1279 |          154.11 |     219757.38 |
| PA             |          946 |          165.53 |     174470.59 |
| MT             |          886 |          146.76 |     152191.62 |
| MA             |          717 |          146.26 |     117009.38 |
| MS             |          701 |          142.33 |     115429.97 |
| PB             |          517 |          192.13 |     112586.82 |
| PI             |          476 |          161.99 |      84721.00 |
| RN             |          474 |          157.59 |      82105.66 |
| AL             |          397 |          184.67 |      78855.72 |
| SE             |          335 |          150.86 |      56574.19 |
| TO             |          274 |          156.14 |      48402.51 |
| RO             |          243 |          167.34 |      45682.76 |
| AM             |          145 |          135.93 |      22155.84 |
| AC             |           80 |          175.07 |      15930.97 |
| AP             |           67 |          165.12 |      13374.81 |
| RR             |           41 |          153.42 |       7057.47 |
+----------------+--------------+-----------------+---------------+

INSIGHT: SP dominates in volume but some smaller states show higher avg order values — potential premium markets.
*/


-- -----------------------------------------------
-- Q5: Order Status Breakdown
-- Business question: What percentage of orders are successfully delivered?
-- -----------------------------------------------
SELECT 
    order_status,
    COUNT(*) AS total_orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

/*
+--------------+--------------+------------+
| order_status | total_orders | percentage |
+--------------+--------------+------------+
| delivered    |        96478 |      97.02 |
| shipped      |         1107 |       1.11 |
| canceled     |          625 |       0.63 |
| unavailable  |          609 |       0.61 |
| invoiced     |          314 |       0.32 |
| processing   |          301 |       0.30 |
| created      |            5 |       0.01 |
| approved     |            2 |       0.00 |
+--------------+--------------+------------+

INSIGHT: ~97% of orders are delivered successfully, showing strong operational reliability.
*/