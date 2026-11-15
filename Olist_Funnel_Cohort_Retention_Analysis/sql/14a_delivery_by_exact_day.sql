WITH review_per_order AS (
  SELECT order_id, AVG(review_score) AS score
  FROM olist_order_reviews_dataset
  GROUP BY order_id
),
delivery AS (
  SELECT order_id,
         CAST(julianday(date(order_delivered_customer_date))
            - julianday(date(order_estimated_delivery_date)) AS INTEGER) AS days_diff
  FROM olist_orders_dataset
  WHERE order_status = 'delivered'
    AND COALESCE(order_delivered_customer_date,'') <> ''
    AND COALESCE(order_estimated_delivery_date,'') <> ''
),
capped AS (
  SELECT order_id,
         CASE WHEN days_diff <= -30 THEN -30
              WHEN days_diff >=  30 THEN  30
              ELSE days_diff END AS d
  FROM delivery
)
SELECT c.d AS days_vs_promise,
       COUNT(*) AS orders,
       COUNT(r.score) AS reviewed,
       ROUND(AVG(r.score), 2) AS avg_review,
       ROUND(100.0 * SUM(CASE WHEN ROUND(r.score) = 1 THEN 1 ELSE 0 END) / COUNT(r.score), 1) AS pct_1_star
FROM capped c
LEFT JOIN review_per_order r ON c.order_id = r.order_id
GROUP BY c.d
ORDER BY c.d;