SELECT 'orders'    AS tbl, COUNT(*) AS n FROM olist_orders_dataset
UNION ALL SELECT 'customers', COUNT(*) FROM olist_customers_dataset
UNION ALL SELECT 'items',     COUNT(*) FROM olist_order_items_dataset
UNION ALL SELECT 'payments',  COUNT(*) FROM olist_order_payments_dataset
UNION ALL SELECT 'reviews',   COUNT(*) FROM olist_order_reviews_dataset
UNION ALL SELECT 'products',  COUNT(*) FROM olist_products_dataset
UNION ALL SELECT 'sellers',   COUNT(*) FROM olist_sellers_dataset;