WITH single_seller AS (
  SELECT order_id, MAX(shipping_limit_date) AS limit_ts
  FROM olist_order_items_dataset
  GROUP BY order_id
  HAVING COUNT(DISTINCT seller_id) = 1
),
base AS (
  SELECT o.order_id,
         julianday(o.order_delivered_carrier_date) - julianday(s.limit_ts) AS handoff_days_late,
         CAST(julianday(date(o.order_delivered_customer_date))
            - julianday(date(o.order_estimated_delivery_date)) AS INTEGER) AS days_vs_promise
  FROM olist_orders_dataset o
  JOIN single_seller s ON o.order_id = s.order_id
  WHERE o.order_status = 'delivered'
    AND COALESCE(o.order_delivered_carrier_date,'') <> ''
    AND COALESCE(o.order_delivered_customer_date,'') <> ''
    AND COALESCE(o.order_estimated_delivery_date,'') <> ''
    AND julianday(s.limit_ts) IS NOT NULL
),
review_per_order AS (
  SELECT order_id, AVG(review_score) AS score
  FROM olist_order_reviews_dataset
  GROUP BY order_id
)
SELECT CASE WHEN handoff_days_late <= 0 THEN '1. on time'
            WHEN handoff_days_late <= 1 THEN '2. up to 1 day late'
            WHEN handoff_days_late <= 3 THEN '3. 1-3 days late'
            ELSE '4. 3+ days late' END AS seller_handoff,
       COUNT(*) AS orders,
       ROUND(100.0 * SUM(CASE WHEN days_vs_promise > 0 THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_delivered_late,
       ROUND(AVG(r.score), 2) AS avg_review
FROM base b
LEFT JOIN review_per_order r ON b.order_id = r.order_id
GROUP BY 1
ORDER BY 1;