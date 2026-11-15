SELECT 'total items (check: 112650)' AS metric, COUNT(*) AS value
FROM olist_order_items_dataset
UNION ALL
SELECT 'items with no category (% of items)',
       ROUND(100.0 * SUM(CASE WHEN COALESCE(p.product_category_name,'') = '' THEN 1 ELSE 0 END) / COUNT(*), 2)
FROM olist_order_items_dataset i
LEFT JOIN olist_products_dataset p ON i.product_id = p.product_id
UNION ALL
SELECT 'revenue with no category (% of item price)',
       ROUND(100.0 * SUM(CASE WHEN COALESCE(p.product_category_name,'') = '' THEN i.price ELSE 0 END) / SUM(i.price), 2)
FROM olist_order_items_dataset i
LEFT JOIN olist_products_dataset p ON i.product_id = p.product_id
UNION ALL
SELECT 'orders with 2+ categories (% of orders with items)',
       ROUND(100.0 * SUM(CASE WHEN n > 1 THEN 1 ELSE 0 END) / COUNT(*), 2)
FROM (SELECT i.order_id,
             COUNT(DISTINCT COALESCE(NULLIF(p.product_category_name,''), 'unknown')) AS n
      FROM olist_order_items_dataset i
      LEFT JOIN olist_products_dataset p ON i.product_id = p.product_id
      GROUP BY i.order_id);