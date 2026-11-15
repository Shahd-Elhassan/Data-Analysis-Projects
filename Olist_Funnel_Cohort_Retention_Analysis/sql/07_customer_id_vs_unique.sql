SELECT COUNT(*)                           AS orders,
       COUNT(DISTINCT customer_id)        AS customer_ids,
       COUNT(DISTINCT customer_unique_id) AS real_customers
FROM olist_customers_dataset;