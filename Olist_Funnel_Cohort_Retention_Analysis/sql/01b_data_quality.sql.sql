SELECT 'duplicate order_ids' AS check_name,
       COUNT(*) - COUNT(DISTINCT order_id) AS issues
FROM olist_orders_dataset
UNION ALL
SELECT 'delivered before purchase', COUNT(*)
FROM olist_orders_dataset
WHERE COALESCE(order_delivered_customer_date,'') <> ''
  AND order_delivered_customer_date < order_purchase_timestamp
UNION ALL
SELECT 'status delivered but no delivery date', COUNT(*)
FROM olist_orders_dataset
WHERE order_status = 'delivered'
  AND COALESCE(order_delivered_customer_date,'') = ''
UNION ALL
SELECT 'orders with no items', COUNT(*)
FROM olist_orders_dataset
WHERE order_id NOT IN (SELECT order_id FROM olist_order_items_dataset)
UNION ALL
SELECT 'products with no category', COUNT(*)
FROM olist_products_dataset
WHERE COALESCE(product_category_name,'') = '';