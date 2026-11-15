WITH orders_clean AS (
  SELECT c.customer_unique_id,
         o.order_status,
         o.order_purchase_timestamp AS ts,
         o.order_delivered_customer_date AS delivered,
         o.order_estimated_delivery_date AS estimated
  FROM olist_orders_dataset o
  JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
  WHERE o.order_status NOT IN ('canceled', 'unavailable')
),
ranked AS (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY customer_unique_id ORDER BY ts) AS rn,
         MIN(ts)      OVER (PARTITION BY customer_unique_id)             AS first_ts
  FROM orders_clean
),
flags AS (
  SELECT customer_unique_id,
         MAX(CASE WHEN julianday(ts) - julianday(first_ts) >= 1 THEN 1 ELSE 0 END) AS repeat24
  FROM ranked
  GROUP BY customer_unique_id
),
first_orders AS (
  SELECT customer_unique_id, order_status, delivered, estimated
  FROM ranked
  WHERE rn = 1
),
banded AS (
  SELECT f.customer_unique_id, fl.repeat24,
         CASE WHEN f.order_status <> 'delivered'
                OR COALESCE(f.delivered,'') = ''
                OR COALESCE(f.estimated,'') = ''           THEN '7. not delivered / no date'
              ELSE
                CASE WHEN CAST(julianday(date(f.delivered)) - julianday(date(f.estimated)) AS INTEGER) <= -7 THEN '1. 7+ days early'
                     WHEN CAST(julianday(date(f.delivered)) - julianday(date(f.estimated)) AS INTEGER) <   0 THEN '2. 1-6 days early'
                     WHEN CAST(julianday(date(f.delivered)) - julianday(date(f.estimated)) AS INTEGER) =   0 THEN '3. promised day'
                     WHEN CAST(julianday(date(f.delivered)) - julianday(date(f.estimated)) AS INTEGER) <=  2 THEN '4. 1-2 days late'
                     WHEN CAST(julianday(date(f.delivered)) - julianday(date(f.estimated)) AS INTEGER) <=  5 THEN '5. 3-5 days late'
                     ELSE '6. 6+ days late' END
         END AS first_delivery_band
  FROM first_orders f
  JOIN flags fl ON f.customer_unique_id = fl.customer_unique_id
)
SELECT first_delivery_band,
       COUNT(*) AS customers,
       SUM(repeat24) AS repeat_customers,
       ROUND(100.0 * SUM(repeat24) / COUNT(*), 2) AS repeat_rate_pct
FROM banded
GROUP BY first_delivery_band
ORDER BY first_delivery_band;