WITH purchases AS (
  SELECT c.customer_unique_id,
         strftime('%Y-%m', o.order_purchase_timestamp) AS order_month
  FROM olist_orders_dataset o
  JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
  WHERE o.order_status NOT IN ('canceled', 'unavailable')
),
first_orders AS (
  SELECT customer_unique_id, MIN(order_month) AS cohort_month
  FROM purchases
  GROUP BY customer_unique_id
),
cohort_activity AS (
  SELECT f.cohort_month,
         (CAST(substr(p.order_month,1,4) AS INT) - CAST(substr(f.cohort_month,1,4) AS INT)) * 12
         + CAST(substr(p.order_month,6,2) AS INT) - CAST(substr(f.cohort_month,6,2) AS INT) AS month_number,
         COUNT(DISTINCT p.customer_unique_id) AS users
  FROM first_orders f
  JOIN purchases p USING (customer_unique_id)
  GROUP BY 1, 2
)
SELECT cohort_month,
       month_number,
       users,
       ROUND(100.0 * users /
             FIRST_VALUE(users) OVER (PARTITION BY cohort_month ORDER BY month_number), 2) AS retention_pct
FROM cohort_activity
ORDER BY cohort_month, month_number;