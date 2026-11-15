WITH orders_clean AS (
  SELECT c.customer_unique_id,
         o.order_id,
         o.order_purchase_timestamp AS ts
  FROM olist_orders_dataset o
  JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
  WHERE o.order_status NOT IN ('canceled', 'unavailable')
),
ranked AS (
  SELECT customer_unique_id, order_id, ts,
         ROW_NUMBER() OVER (PARTITION BY customer_unique_id ORDER BY ts) AS order_num,
         LAG(ts)       OVER (PARTITION BY customer_unique_id ORDER BY ts) AS prev_ts,
         LAG(order_id) OVER (PARTITION BY customer_unique_id ORDER BY ts) AS prev_order_id
  FROM orders_clean
),
within_24h AS (
  SELECT order_id, prev_order_id,
         (julianday(ts) - julianday(prev_ts)) * 24 * 60 AS gap_min
  FROM ranked
  WHERE order_num = 2
    AND julianday(ts) - julianday(prev_ts) < 1
)
SELECT CASE WHEN gap_min < 5  THEN '1. under 5 min'
            WHEN gap_min < 60 THEN '2. 5-60 min'
            ELSE '3. 1-24 hours' END AS gap,
       CASE WHEN EXISTS (
              SELECT 1
              FROM olist_order_items_dataset a
              JOIN olist_order_items_dataset b ON a.product_id = b.product_id
              WHERE a.order_id = w.prev_order_id AND b.order_id = w.order_id)
            THEN 'same product' ELSE 'different products' END AS product_match,
       COUNT(*) AS customers
FROM within_24h w
GROUP BY 1, 2
ORDER BY 1, 2;