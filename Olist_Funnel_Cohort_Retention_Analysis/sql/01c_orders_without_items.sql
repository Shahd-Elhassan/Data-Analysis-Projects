-- 1) What status do the 775 item-less orders have?
SELECT order_status, COUNT(*) AS orders
FROM olist_orders_dataset
WHERE order_id NOT IN (SELECT order_id FROM olist_order_items_dataset)
GROUP BY order_status
ORDER BY orders DESC;