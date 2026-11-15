-- 2) Are uncategorized products actually sold, and do all categories have a translation?
SELECT 'sold products with no category' AS check_name,
       COUNT(DISTINCT i.product_id) AS n
FROM olist_order_items_dataset i
JOIN olist_products_dataset p ON i.product_id = p.product_id
WHERE COALESCE(p.product_category_name,'') = ''
UNION ALL
SELECT 'categories with no english translation', COUNT(DISTINCT p.product_category_name)
FROM olist_products_dataset p
LEFT JOIN product_category_name_translation t
       ON p.product_category_name = t.product_category_name
WHERE COALESCE(p.product_category_name,'') <> ''
  AND t.product_category_name IS NULL;