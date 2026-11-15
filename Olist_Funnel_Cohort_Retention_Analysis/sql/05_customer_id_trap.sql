WITH by_customer_id AS (
  SELECT customer_id, COUNT(*) AS orders
  FROM olist_orders_dataset
  WHERE order_status NOT IN ('canceled', 'unavailable')
  GROUP BY customer_id
)
SELECT COUNT(*) AS ids,
       SUM(CASE WHEN orders >= 2 THEN 1 ELSE 0 END) AS repeat_ids,
       ROUND(100.0 * SUM(CASE WHEN orders >= 2 THEN 1 ELSE 0 END) / COUNT(*), 2) AS wrong_repeat_rate_pct
FROM by_customer_id;