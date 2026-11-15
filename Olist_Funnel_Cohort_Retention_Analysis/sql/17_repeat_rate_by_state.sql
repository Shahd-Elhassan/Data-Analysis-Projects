WITH orders_clean AS (
  SELECT c.customer_unique_id, o.order_id,
         o.order_purchase_timestamp AS ts,
         c.customer_state AS state
  FROM olist_orders_dataset o
  JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
  WHERE o.order_status NOT IN ('canceled', 'unavailable')
),
ranked AS (
  SELECT customer_unique_id, order_id, ts, state,
         ROW_NUMBER() OVER (PARTITION BY customer_unique_id ORDER BY ts, order_id) AS rn,
         MIN(ts)      OVER (PARTITION BY customer_unique_id)                       AS first_ts
  FROM orders_clean
),
flags AS (
  SELECT customer_unique_id,
         MAX(CASE WHEN julianday(ts) - julianday(first_ts) >= 1 THEN 1 ELSE 0 END) AS repeat24
  FROM ranked
  GROUP BY customer_unique_id
),
first_orders AS (
  SELECT customer_unique_id, state FROM ranked WHERE rn = 1
),
per_customer AS (
  SELECT f.state, fl.repeat24
  FROM first_orders f
  JOIN flags fl ON f.customer_unique_id = fl.customer_unique_id
),
sized AS (
  SELECT *, COUNT(*) OVER (PARTITION BY state) AS n
  FROM per_customer
)
SELECT CASE WHEN n >= 1000 THEN state ELSE 'other (<1000 customers)' END AS first_state,
       COUNT(*) AS customers,
       SUM(repeat24) AS repeat_customers,
       ROUND(100.0 * SUM(repeat24) / COUNT(*), 2) AS repeat_rate_pct
FROM sized
GROUP BY 1
ORDER BY customers DESC;