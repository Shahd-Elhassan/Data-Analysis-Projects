-- 1) How are scores distributed?
SELECT review_score, COUNT(*) AS reviews,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM olist_order_reviews_dataset
GROUP BY review_score
ORDER BY review_score;