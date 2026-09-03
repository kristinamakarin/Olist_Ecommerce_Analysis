/*
Question: How does customer satisfaction (review score) vary by product category?
- Join order reviews with order items and products, translating category
  names to English, then average review scores per category.
- Why? Identifies which product categories consistently satisfy or
  disappoint customers, useful for prioritizing quality improvements.
*/

SELECT 
    product_category_name_translation.product_category_name_english,
    COUNT(order_reviews.review_score) AS number_of_reviews,
    ROUND(AVG(review_score), 2) AS avg_review_score
FROM 
    products
LEFT JOIN order_items
    ON products.product_id = order_items.product_id
LEFT JOIN order_reviews
    ON order_items.order_id = order_reviews.order_id
LEFT JOIN product_category_name_translation
    ON products.product_category_name = product_category_name_translation.product_category_name
GROUP BY 
    product_category_name_english
ORDER BY
    avg_review_score DESC;
    --avg_review_score ASC;


