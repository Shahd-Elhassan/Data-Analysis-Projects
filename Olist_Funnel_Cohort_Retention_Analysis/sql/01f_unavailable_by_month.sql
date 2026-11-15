SELECT strftime('%Y-%m', order_purchase_timestamp) AS month,
       COUNT(*) AS orders,
       SUM(CASE WHEN order_status = 'unavailable' THEN 1 ELSE 0 END) AS unavailable,
       ROUND(100.0 * SUM(CASE WHEN order_status = 'unavailable' THEN 1 ELSE 0 END) / COUNT(*), 2) AS unavailable_pct
FROM olist_orders_dataset
GROUP BY 1
ORDER BY 1;