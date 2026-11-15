SELECT order_estimated_delivery_date, order_delivered_customer_date
FROM olist_orders_dataset
WHERE order_status = 'delivered'
LIMIT 5;