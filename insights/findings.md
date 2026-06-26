# Key Findings — Olist E-Commerce Analysis

Analysis of 99,441 orders placed on the Olist platform between September 2016 and August 2018, across 5 relational tables and 15 SQL queries.

---

## Revenue

**Top categories by revenue**

Health & beauty leads all categories with $1.26M in revenue across 8,836 orders. Despite bed_bath_table having more orders (9,417), health & beauty generates higher revenue — indicating a significantly higher average order value. watches_gifts ranks second at $1.2M with far fewer orders (5,624), the highest revenue-per-order ratio in the top 10.

| Category | Revenue | Orders |
|----------|---------|--------|
| health_beauty | $1,258,681 | 8,836 |
| watches_gifts | $1,205,005 | 5,624 |
| bed_bath_table | $1,036,988 | 9,417 |
| sports_leisure | $988,048 | 7,720 |
| computers_accessories | $911,954 | 6,689 |

**Monthly growth**

Revenue grew consistently from near zero in late 2016 to ~$1M/month by early 2018. November 2017 stands out with a 52% MoM spike (+$339k) — a Black Friday effect. Post-spike, revenue stabilized rather than dropping sharply, suggesting the platform retained a portion of new customers acquired during the sale period. Growth plateaued in mid-2018, with April–August 2018 all under 2% MoM change.

**Cumulative revenue reached $13.2M by August 2018.**

---

## Customer Behaviour

**Repeat purchase rate**

Only 3% of customers make more than one purchase. This is the most significant finding in the dataset — Olist operates almost entirely on new customer acquisition rather than retention. The platform's CAC (customer acquisition cost) likely far exceeds its LTV unless average order values are high enough to justify single-purchase customers.

**RFM segmentation**

Using recency, frequency, and monetary scoring (NTILE 1-5):

- Champions (r=5, f=5): 623 customers, avg spend up to $408. Recently active, high frequency, high spend. Top priority for retention and upsell.
- Potential (r=5, f=1-2): Tens of thousands of recently active, single-purchase customers. Largest segment by volume. Highest ROI target for re-engagement — they bought recently and haven't been lost yet.
- At Risk / Lost: Customers with low recency scores who haven't returned. Winback campaigns would be lower priority given the low baseline retention rate.

**Customer LTV by acquisition cohort**

Early cohorts (Oct 2016, Jan 2017) show the highest avg LTV at ~$159 with customer lifespans of 12-16 days between first and last order. As the platform scaled through 2018, avg LTV declined slightly to ~$133-$148, likely due to a broader, less targeted customer base. Note: 2018 cohorts show near-zero lifespan because the dataset ends in August 2018 — not necessarily a sign of lower quality customers.

---

## Logistics

**Delivery time by state**

SP and RJ, Brazil's largest cities and likely closest to distribution centers, receive orders in 8-10 days on average. Northern and northeastern states (AM, RR, PA) average 25+ days. This is a 3x difference in delivery experience for customers depending on location.

**Late delivery rate**

States with the longest avg delivery times also show the highest late delivery rates (20-30% in northern states). This confirms a systemic logistics gap in those regions — not just slower delivery, but consistently missing estimated delivery dates. This would directly impact customer satisfaction and repeat purchase likelihood in those regions.

**On-time performance overall**

97% of orders reach delivered status, indicating strong operational reliability at a platform level. The logistics issues are regional rather than systemic.

---

## Products and Sellers

**Most reordered products**

garden_tools has 4 products in the top 10 most reordered list, despite moderate average prices ($54-$55). This suggests consumable or replacement-driven buying behavior in that category. bed_bath_table's top product leads in both order frequency (467 orders) and total revenue ($43k).

**Seller performance**

Seller revenue follows a classic long-tail distribution — a small number of Platinum-tier sellers ($100k+) drive a disproportionate share of total revenue. High-revenue sellers do not always have the fastest delivery times, suggesting a volume-vs-service quality trade-off that the platform could address through seller incentives.

---

## Summary

The core business challenge Olist faces is retention. Revenue is growing, operational delivery is reliable, and product-market fit exists in several categories — but a 3% repeat purchase rate means the platform is on a treadmill of acquisition. Converting even a fraction of the large "Potential" RFM segment (recently active, one-time buyers) into repeat customers would have an outsized impact on LTV and overall platform economics.