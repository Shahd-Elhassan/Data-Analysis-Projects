SELECT
  COUNT(*) AS purchased,
  SUM(CASE WHEN COALESCE(order_approved_at,'') <> '' THEN 1 ELSE 0 END) AS approved,
  SUM(CASE WHEN COALESCE(order_delivered_carrier_date,'') <> '' THEN 1 ELSE 0 END) AS shipped,
  SUM(CASE WHEN COALESCE(order_delivered_customer_date,'') <> '' THEN 1 ELSE 0 END) AS delivered,
  SUM(CASE WHEN COALESCE(order_delivered_customer_date,'') <> ''
            AND order_id IN (SELECT order_id FROM olist_order_reviews_dataset)
           THEN 1 ELSE 0 END) AS delivered_and_reviewed
FROM olist_orders_dataset;