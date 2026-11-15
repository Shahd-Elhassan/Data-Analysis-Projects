WITH orders_clean AS (
  SELECT c.customer_unique_id, o.order_id, o.order_purchase_timestamp AS ts
  FROM olist_orders_dataset o
  JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
  WHERE o.order_status NOT IN ('canceled', 'unavailable')
),
ranked AS (
  SELECT customer_unique_id, order_id, ts,
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
  SELECT customer_unique_id, order_id FROM ranked WHERE rn = 1
),
item_rank AS (
  SELECT i.order_id,
         COALESCE(t.product_category_name_english,
                  NULLIF(p.product_category_name,''), 'unknown') AS category,
         ROW_NUMBER() OVER (PARTITION BY i.order_id
                            ORDER BY i.price DESC, i.order_item_id) AS rk
  FROM olist_order_items_dataset i
  LEFT JOIN olist_products_dataset p ON i.product_id = p.product_id
  LEFT JOIN product_category_name_translation t
         ON p.product_category_name = t.product_category_name
),
per_customer AS (
  SELECT f.customer_unique_id,
         COALESCE(ir.category, 'no items') AS category,
         fl.repeat24
  FROM first_orders f
  LEFT JOIN item_rank ir ON f.order_id = ir.order_id AND ir.rk = 1
  JOIN flags fl ON f.customer_unique_id = fl.customer_unique_id
),
sized AS (
  SELECT *, COUNT(*) OVER (PARTITION BY category) AS n
  FROM per_customer
)
SELECT CASE WHEN n >= 1000 THEN category ELSE 'other (<1000 customers)' END AS first_category,
       COUNT(*) AS customers,
       SUM(repeat24) AS repeat_customers,
       ROUND(100.0 * SUM(repeat24) / COUNT(*), 2) AS repeat_rate_pct
FROM sized
GROUP BY 1
ORDER BY repeat_rate_pct DESC;