WITH orders_clean AS (
  SELECT c.customer_unique_id,
         o.order_purchase_timestamp AS ts
  FROM olist_orders_dataset o
  JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
  WHERE o.order_status NOT IN ('canceled', 'unavailable')
),
ranked AS (
  SELECT customer_unique_id,
         ts,
         ROW_NUMBER() OVER (PARTITION BY customer_unique_id ORDER BY ts) AS order_num,
         LAG(ts)      OVER (PARTITION BY customer_unique_id ORDER BY ts) AS prev_ts
  FROM orders_clean
)
SELECT CASE WHEN days < 1   THEN '0. same day'
            WHEN days <= 30  THEN '1. within 30 days'
            WHEN days <= 90  THEN '2. 31-90 days'
            WHEN days <= 180 THEN '3. 91-180 days'
            ELSE '4. 180+ days' END AS gap_to_second_order,
       COUNT(*) AS customers,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_repeat_customers
FROM (SELECT julianday(ts) - julianday(prev_ts) AS days
      FROM ranked
      WHERE order_num = 2)
GROUP BY gap_to_second_order
ORDER BY gap_to_second_order;