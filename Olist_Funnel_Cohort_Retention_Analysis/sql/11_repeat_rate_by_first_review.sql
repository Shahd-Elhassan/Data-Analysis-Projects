WITH orders_clean AS (
  SELECT c.customer_unique_id,
         o.order_id,
         o.order_purchase_timestamp AS ts
  FROM olist_orders_dataset o
  JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
  WHERE o.order_status NOT IN ('canceled', 'unavailable')
),
ranked AS (
  SELECT customer_unique_id,
         order_id,
         ROW_NUMBER() OVER (PARTITION BY customer_unique_id ORDER BY ts) AS order_num,
         COUNT(*)     OVER (PARTITION BY customer_unique_id)             AS total_orders
  FROM orders_clean
),
first_orders AS (
  SELECT * FROM ranked WHERE order_num = 1
),
review_per_order AS (
  SELECT order_id, AVG(review_score) AS score
  FROM olist_order_reviews_dataset
  GROUP BY order_id
)
SELECT ROUND(r.score) AS first_order_review_score,
       COUNT(*) AS customers,
       SUM(CASE WHEN f.total_orders >= 2 THEN 1 ELSE 0 END) AS repeat_customers,
       ROUND(100.0 * SUM(CASE WHEN f.total_orders >= 2 THEN 1 ELSE 0 END) / COUNT(*), 2) AS repeat_rate_pct
FROM first_orders f
LEFT JOIN review_per_order r ON f.order_id = r.order_id
GROUP BY 1
ORDER BY 1;