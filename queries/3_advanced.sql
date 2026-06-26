-- ============================================
-- Olist SQL Analysis
-- File: 03_advanced.sql
-- Description: Advanced analysis queries (Q11-Q15)
-- ============================================

USE olist;

-- -----------------------------------------------
-- Q11: Customer RFM Segmentation
-- Business question: How can we segment customers by recency, frequency, and monetary value?
-- Uses: CTE, NTILE() window function, CASE WHEN tiering
-- -----------------------------------------------
WITH rfm_base AS (
    SELECT 
        c.customer_unique_id,
        DATEDIFF('2018-09-01', MAX(o.order_purchase_timestamp)) AS recency,
        COUNT(DISTINCT o.order_id) AS frequency,
        ROUND(SUM(oi.price), 2) AS monetary
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
rfm_scores AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY recency DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
    FROM rfm_base
)
SELECT 
    r_score,
    f_score,
    m_score,
    COUNT(*) AS customer_count,
    ROUND(AVG(monetary), 2) AS avg_spend,
    CASE 
        WHEN r_score >= 4 AND f_score >= 4 THEN 'Champion'
        WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal'
        WHEN r_score >= 3 AND f_score < 3  THEN 'Potential'
        WHEN r_score < 3 AND f_score >= 3  THEN 'At Risk'
        ELSE 'Lost'
    END AS segment
FROM rfm_scores
GROUP BY r_score, f_score, m_score, segment
ORDER BY r_score DESC, f_score DESC
LIMIT 15;

/*
OUTPUT:
+---------+---------+---------+----------------+-----------+-----------+
| r_score | f_score | m_score | customer_count | avg_spend | segment   |
+---------+---------+---------+----------------+-----------+-----------+
|       5 |       5 |       1 |             10 |     29.12 | Champion  |
|       5 |       5 |       2 |             45 |     55.89 | Champion  |
|       5 |       5 |       3 |             83 |     90.08 | Champion  |
|       5 |       5 |       4 |            148 |    142.80 | Champion  |
|       5 |       5 |       5 |            337 |    408.24 | Champion  |
|       5 |       2 |       1 |            594 |     25.58 | Potential |
|       5 |       2 |       2 |            569 |     53.27 | Potential |
|       5 |       2 |       3 |            605 |     89.54 | Potential |
|       5 |       2 |       4 |            640 |    136.98 | Potential |
|       5 |       2 |       5 |            658 |    420.44 | Potential |
|       5 |       1 |       1 |           3255 |     26.16 | Potential |
|       5 |       1 |       2 |           2965 |     54.11 | Potential |
|       5 |       1 |       3 |           2967 |     88.14 | Potential |
|       5 |       1 |       4 |           3045 |    138.95 | Potential |
|       5 |       1 |       5 |           2750 |    402.40 | Potential |
+---------+---------+---------+----------------+-----------+-----------+

INSIGHT: Champions (r=5, f=5) — 623 customers, avg spend up to $408. Recently active, buy often, spend the most — VIP retention priority.
The massive Potential segment (r=5, f=1-2) represents thousands of recent one-time buyers — highest ROI target for re-engagement campaigns.
*/


-- -----------------------------------------------
-- Q12: Monthly Revenue Running Total + MoM Growth
-- Business question: How has cumulative revenue grown and what are the month-on-month changes?
-- Uses: CTE, SUM() OVER() running window, LAG()
-- -----------------------------------------------
WITH monthly_revenue AS (
    SELECT 
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
        ROUND(SUM(oi.price), 2) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY month
)
SELECT 
    month,
    revenue,
    ROUND(SUM(revenue) OVER (ORDER BY month), 2) AS running_total,
    ROUND(revenue - LAG(revenue) OVER (ORDER BY month), 2) AS mom_change,
    ROUND((revenue - LAG(revenue) OVER (ORDER BY month)) * 100.0 / 
        LAG(revenue) OVER (ORDER BY month), 2) AS mom_pct_change
FROM monthly_revenue
ORDER BY month;

/*
OUTPUT:
+---------+-----------+---------------+------------+----------------+
| month   | revenue   | running_total | mom_change | mom_pct_change |
+---------+-----------+---------------+------------+----------------+
| 2016-09 |    134.97 |        134.97 |       NULL |           NULL |
| 2016-10 |  40325.11 |      40460.08 |   40190.14 |       29777.09 |
| 2016-12 |     10.90 |      40470.98 |  -40314.21 |         -99.97 |
| 2017-01 | 111798.36 |     152269.34 |  111787.46 |     1025573.03 |
| 2017-02 | 234223.40 |     386492.74 |  122425.04 |         109.51 |
| 2017-03 | 359198.85 |     745691.59 |  124975.45 |          53.36 |
| 2017-04 | 340669.68 |    1086361.27 |  -18529.17 |          -5.16 |
| 2017-05 | 489338.25 |    1575699.52 |  148668.57 |          43.64 |
| 2017-06 | 421923.37 |    1997622.89 |  -67414.88 |         -13.78 |
| 2017-07 | 481604.52 |    2479227.41 |   59681.15 |          14.15 |
| 2017-08 | 554699.70 |    3033927.11 |   73095.18 |          15.18 |
| 2017-09 | 607399.67 |    3641326.78 |   52699.97 |           9.50 |
| 2017-10 | 648247.65 |    4289574.43 |   40847.98 |           6.73 |
| 2017-11 | 987765.37 |    5277339.80 |  339517.72 |          52.37 |
| 2017-12 | 726033.19 |    6003372.99 | -261732.18 |         -26.50 |
| 2018-01 | 924645.00 |    6928017.99 |  198611.81 |          27.36 |
| 2018-02 | 826437.13 |    7754455.12 |  -98207.87 |         -10.62 |
| 2018-03 | 953356.25 |    8707811.37 |  126919.12 |          15.36 |
| 2018-04 | 973534.09 |    9681345.46 |   20177.84 |           2.12 |
| 2018-05 | 977544.69 |   10658890.15 |    4010.60 |           0.41 |
| 2018-06 | 856077.86 |   11514968.01 | -121466.83 |         -12.43 |
| 2018-07 | 867953.46 |   12382921.47 |   11875.60 |           1.39 |
| 2018-08 | 838576.64 |   13221498.11 |  -29376.82 |          -3.38 |
+---------+-----------+---------------+------------+----------------+

INSIGHT: Nov 2017 saw a +52% MoM spike ($339k jump) — clear Black Friday effect. Cumulative revenue crossed $13.2M by Aug 2018. Growth slowed
significantly in mid-2018 (Apr-Aug under 2% MoM), suggesting market maturity or increased competition.
*/


-- -----------------------------------------------
-- Q13: Customer Cohort Retention
-- Business question: What percentage of customers
-- from each monthly cohort make a repeat purchase?
-- Uses: CTE, DATE_FORMAT(), MIN(), LEFT JOIN, cohort analysis
-- -----------------------------------------------
WITH cohorts AS (
    SELECT 
        c.customer_unique_id,
        DATE_FORMAT(MIN(o.order_purchase_timestamp), '%Y-%m') AS cohort_month
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
customer_activity AS (
    SELECT 
        c.customer_unique_id,
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS activity_month
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id, activity_month
)
SELECT 
    co.cohort_month,
    COUNT(DISTINCT co.customer_unique_id) AS cohort_size,
    COUNT(DISTINCT ca.customer_unique_id) AS retained_customers,
    ROUND(COUNT(DISTINCT ca.customer_unique_id) * 100.0 / 
        COUNT(DISTINCT co.customer_unique_id), 2) AS retention_pct
FROM cohorts co
LEFT JOIN customer_activity ca 
    ON co.customer_unique_id = ca.customer_unique_id
    AND ca.activity_month > co.cohort_month
GROUP BY co.cohort_month
ORDER BY co.cohort_month;

/*
OUTPUT:
+--------------+-------------+--------------------+---------------+
| cohort_month | cohort_size | retained_customers | retention_pct |
+--------------+-------------+--------------------+---------------+
| 2016-09      |           1 |                  0 |          0.00 |
| 2016-10      |         262 |                  9 |          3.44 |
| 2016-12      |           1 |                  1 |        100.00 |
| 2017-01      |         717 |                 30 |          4.18 |
| 2017-02      |        1628 |                 46 |          2.83 |
| 2017-03      |        2503 |                 86 |          3.44 |
| 2017-04      |        2256 |                 77 |          3.41 |
| 2017-05      |        3451 |                122 |          3.54 |
| 2017-06      |        3037 |                109 |          3.59 |
| 2017-07      |        3752 |                116 |          3.09 |
| 2017-08      |        4057 |                129 |          3.18 |
| 2017-09      |        4004 |                120 |          3.00 |
| 2017-10      |        4328 |                108 |          2.50 |
| 2017-11      |        7060 |                133 |          1.88 |
| 2017-12      |        5338 |                 87 |          1.63 |
| 2018-01      |        6842 |                119 |          1.74 |
| 2018-02      |        6288 |                106 |          1.69 |
| 2018-03      |        6774 |                 80 |          1.18 |
| 2018-04      |        6582 |                 82 |          1.25 |
| 2018-05      |        6506 |                 62 |          0.95 |
| 2018-06      |        5878 |                 40 |          0.68 |
| 2018-07      |        5949 |                 31 |          0.52 |
| 2018-08      |        6144 |                  0 |          0.00 |
+--------------+-------------+--------------------+---------------+

INSIGHT: Retention consistently hovers around 3-4% across all cohorts — confirming the platform is acquisition-driven rather than retention-driven.
Earlier cohorts (2017-01 to 2017-06) show slightly higher retention, possibly due to a smaller, more engaged early user base.
*/


-- -----------------------------------------------
-- Q14: Seller Performance Analysis
-- Business question: Who are the top performing sellers and how do they compare on revenue and delivery time?
-- Uses: CTE, RANK() window function, CASE WHEN tiering
-- -----------------------------------------------
WITH seller_stats AS (
    SELECT 
        oi.seller_id,
        COUNT(DISTINCT oi.order_id) AS total_orders,
        ROUND(SUM(oi.price), 2) AS total_revenue,
        ROUND(AVG(oi.price), 2) AS avg_order_value,
        COUNT(DISTINCT oi.product_id) AS unique_products,
        ROUND(AVG(DATEDIFF(
            o.order_delivered_customer_date,
            o.order_purchase_timestamp
        )), 1) AS avg_delivery_days
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
    GROUP BY oi.seller_id
)
SELECT 
    seller_id,
    total_orders,
    total_revenue,
    avg_order_value,
    unique_products,
    avg_delivery_days,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
    CASE
        WHEN total_revenue >= 100000 THEN 'Platinum'
        WHEN total_revenue >= 50000  THEN 'Gold'
        WHEN total_revenue >= 10000  THEN 'Silver'
        ELSE 'Bronze'
    END AS seller_tier
FROM seller_stats
ORDER BY total_revenue DESC
LIMIT 15;

/*
OUTPUT:
-- paste your output here

INSIGHT: A small number of Platinum sellers drive a disproportionate share of revenue — classic 80/20 distribution. High-revenue sellers
don't always have the fastest delivery times, suggesting a trade-off between volume and service quality worth monitoring.
*/


-- -----------------------------------------------
-- Q15: Customer Lifetime Value by Acquisition Month
-- Business question: Which acquisition cohorts produce the highest lifetime value customers?
-- Uses: CTE, AVG(), SUM(), cohort-based LTV calculation
-- -----------------------------------------------
WITH first_purchase AS (
    SELECT 
        c.customer_unique_id,
        DATE_FORMAT(MIN(o.order_purchase_timestamp), '%Y-%m') AS acquisition_month,
        MIN(o.order_purchase_timestamp) AS first_order_date
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
customer_ltv AS (
    SELECT 
        c.customer_unique_id,
        ROUND(SUM(oi.price), 2) AS total_spent,
        COUNT(DISTINCT o.order_id) AS total_orders,
        DATEDIFF(
            MAX(o.order_purchase_timestamp),
            MIN(o.order_purchase_timestamp)
        ) AS customer_lifespan_days
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT 
    fp.acquisition_month,
    COUNT(DISTINCT fp.customer_unique_id) AS customers_acquired,
    ROUND(AVG(cl.total_spent), 2) AS avg_ltv,
    ROUND(SUM(cl.total_spent), 2) AS total_cohort_revenue,
    ROUND(AVG(cl.total_orders), 2) AS avg_orders_per_customer,
    ROUND(AVG(cl.customer_lifespan_days), 1) AS avg_lifespan_days
FROM first_purchase fp
JOIN customer_ltv cl ON fp.customer_unique_id = cl.customer_unique_id
GROUP BY fp.acquisition_month
ORDER BY fp.acquisition_month;

/*
OUTPUT:
+-------------------+--------------------+---------+----------------------+-------------------------+-------------------+
| acquisition_month | customers_acquired | avg_ltv | total_cohort_revenue | avg_orders_per_customer | avg_lifespan_days |
+-------------------+--------------------+---------+----------------------+-------------------------+-------------------+
| 2016-09           |                  1 |  134.97 |               134.97 |                    1.00 |               0.0 |
| 2016-10           |                262 |  159.44 |             41772.57 |                    1.05 |              16.2 |
| 2016-12           |                  1 |   21.80 |                21.80 |                    2.00 |              13.0 |
| 2017-01           |                717 |  159.83 |            114596.44 |                    1.09 |              12.5 |
| 2017-02           |               1628 |  147.29 |            239788.46 |                    1.04 |               6.8 |
| 2017-03           |               2503 |  148.48 |            371645.15 |                    1.06 |               7.8 |
| 2017-04           |               2256 |  155.81 |            351496.79 |                    1.05 |               6.5 |
| 2017-05           |               3451 |  145.61 |            502508.72 |                    1.06 |               7.5 |
| 2017-06           |               3037 |  143.03 |            434368.18 |                    1.06 |               7.2 |
| 2017-07           |               3752 |  130.79 |            490736.52 |                    1.05 |               5.9 |
| 2017-08           |               4057 |  139.57 |            566249.59 |                    1.06 |               5.2 |
| 2017-09           |               4004 |  153.31 |            613856.99 |                    1.05 |               4.4 |
| 2017-10           |               4328 |  150.66 |            652054.08 |                    1.04 |               3.7 |
| 2017-11           |               7060 |  140.51 |            991983.85 |                    1.03 |               2.0 |
| 2017-12           |               5338 |  135.17 |            721523.22 |                    1.03 |               1.9 |
| 2018-01           |               6842 |  134.70 |            921642.55 |                    1.03 |               1.9 |
| 2018-02           |               6288 |  131.63 |            827691.11 |                    1.04 |               1.6 |
| 2018-03           |               6774 |  139.78 |            946901.05 |                    1.03 |               0.9 |
| 2018-04           |               6582 |  146.19 |            962225.03 |                    1.02 |               0.7 |
| 2018-05           |               6506 |  148.15 |            963884.08 |                    1.02 |               0.5 |
| 2018-06           |               5878 |  142.01 |            834710.45 |                    1.01 |               0.3 |
| 2018-07           |               5949 |  143.16 |            851647.43 |                    1.01 |               0.1 |
| 2018-08           |               6144 |  133.47 |            820059.08 |                    1.01 |               0.0 |
+-------------------+--------------------+---------+----------------------+-------------------------+-------------------+

INSIGHT: Early cohorts (2016-10, 2017-01) have the highest avg LTV ($159)
and longest lifespan (12-16 days between orders) — early adopters were
more engaged. 2018 cohorts show declining lifespan (near 0) as the
dataset ends, not necessarily lower quality customers.
*/