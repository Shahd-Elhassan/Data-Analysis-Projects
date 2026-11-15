SELECT COALESCE(t.product_category_name_english,
                NULLIF(p.product_category_name,''),
                'unknown')                          AS category,
       COUNT(DISTINCT i.order_id)                   AS orders,
       ROUND(SUM(i.price), 0)                       AS revenue,
       ROUND(100.0 * SUM(i.price) / SUM(SUM(i.price)) OVER (), 2) AS pct_revenue,
       ROUND(AVG(i.price), 1)                       AS avg_item_price
FROM olist_order_items_dataset i
JOIN olist_orders_dataset o            ON i.order_id = o.order_id
LEFT JOIN olist_products_dataset p     ON i.product_id = p.product_id
LEFT JOIN product_category_name_translation t
       ON p.product_category_name = t.product_category_name
WHERE o.order_status NOT IN ('canceled', 'unavailable')
GROUP BY 1
ORDER BY revenue DESC
LIMIT 15;