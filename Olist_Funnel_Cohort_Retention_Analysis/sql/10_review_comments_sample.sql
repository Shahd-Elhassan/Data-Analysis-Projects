-- 2) What do the comments of 1-star reviews look like?
SELECT review_score, review_comment_message
FROM olist_order_reviews_dataset
WHERE review_score = 1
  AND COALESCE(review_comment_message,'') <> ''
LIMIT 15;