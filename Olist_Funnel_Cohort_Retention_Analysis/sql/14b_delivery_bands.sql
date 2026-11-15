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
)
SELECT CASE WHEN days_diff <= -7 THEN '1. 7+ days early'
            WHEN days_diff <   0 THEN '2. 1-6 days early'
            WHEN days_diff =   0 THEN '3. promised day'
            WHEN days_diff <=  2 THEN '4. 1-2 days late'
            WHEN days_diff <=  5 THEN '5. 3-5 days late'
            ELSE '6. 6+ days late' END AS delivery_vs_promise,
       COUNT(*) AS orders,
       COUNT(r.score) AS reviewed,
       ROUND(AVG(r.score), 2) AS avg_review,
       ROUND(100.0 * SUM(CASE WHEN ROUND(r.score) = 1 THEN 1 ELSE 0 END) / COUNT(r.score), 1) AS pct_1_star
FROM delivery d
LEFT JOIN review_per_order r ON d.order_id = r.order_id
GROUP BY 1
ORDER BY 1;