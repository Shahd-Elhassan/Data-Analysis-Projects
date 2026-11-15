SELECT o.order_status,
       COUNT(*) AS orders,
       SUM(CASE WHEN COALESCE(o.order_approved_at,'') <> '' THEN 1 ELSE 0 END)           AS has_approval,
       SUM(CASE WHEN COALESCE(o.order_delivered_carrier_date,'') <> '' THEN 1 ELSE 0 END) AS has_carrier_date,
       SUM(CASE WHEN o.order_id IN (SELECT order_id FROM olist_order_payments_dataset) THEN 1 ELSE 0 END) AS has_payment,
       SUM(CASE WHEN o.order_id IN (SELECT order_id FROM olist_order_items_dataset) THEN 1 ELSE 0 END)    AS has_items
FROM olist_orders_dataset o
WHERE o.order_status IN ('unavailable', 'canceled', 'delivered')
GROUP BY o.order_status;