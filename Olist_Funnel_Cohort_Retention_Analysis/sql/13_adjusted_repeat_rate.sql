WITH orders_clean AS (
  SELECT c.customer_unique_id,
         o.order_purchase_timestamp AS ts
  FROM olist_orders_dataset o
  JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
  WHERE o.order_status NOT IN ('canceled', 'unavailable')
),
first_order AS (
  SELECT customer_unique_id, MIN(ts) AS first_ts
  FROM orders_clean
  GROUP BY customer_unique_id
),
late_repeaters AS (
  SELECT DISTINCT f.customer_unique_id
  FROM first_order f
  JOIN orders_clean oc ON oc.customer_unique_id = f.customer_unique_id
  WHERE julianday(oc.ts) - julianday(f.first_ts) >= 1
)
SELECT (SELECT COUNT(*) FROM first_order) AS customers,
       COUNT(*) AS repeat_after_24h,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM first_order), 2) AS adjusted_repeat_pct
FROM late_repeaters;