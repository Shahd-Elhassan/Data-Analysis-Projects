SELECT strftime('%Y-%m', order_purchase_timestamp) AS month,
       COUNT(*) AS orders,
       SUM(CASE WHEN order_status = 'unavailable' THEN 1 ELSE 0 END) AS unavailable,
       SUM(CASE WHEN order_status = 'canceled'    THEN 1 ELSE 0 END) AS canceled,
       ROUND(100.0 * SUM(CASE WHEN order_status = 'unavailable' THEN 1 ELSE 0 END) / COUNT(*), 2) AS unavailable_pct,
       ROUND(100.0 * SUM(CASE WHEN order_status = 'canceled'    THEN 1 ELSE 0 END) / COUNT(*), 2) AS canceled_pct,
       ROUND(100.0 * SUM(CASE WHEN order_status IN ('unavailable','canceled') THEN 1 ELSE 0 END) / COUNT(*), 2) AS combined_pct
FROM olist_orders_dataset
GROUP BY 1
ORDER BY 1;