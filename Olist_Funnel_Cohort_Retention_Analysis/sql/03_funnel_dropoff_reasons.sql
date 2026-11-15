SELECT order_status,
       COUNT(*) AS orders
FROM olist_orders_dataset
WHERE COALESCE(order_delivered_customer_date,'') = ''
GROUP BY order_status
ORDER BY orders DESC;