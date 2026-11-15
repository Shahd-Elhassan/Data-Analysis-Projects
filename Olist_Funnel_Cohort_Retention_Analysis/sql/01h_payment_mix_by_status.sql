SELECT o.order_status,
       p.payment_type,
       COUNT(*) AS orders,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY o.order_status), 2) AS pct_within_status
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p ON o.order_id = p.order_id
WHERE o.order_status IN ('unavailable', 'canceled', 'delivered')
  AND CAST(p.payment_sequential AS INTEGER) = 1
GROUP BY o.order_status, p.payment_type
ORDER BY o.order_status, orders DESC;