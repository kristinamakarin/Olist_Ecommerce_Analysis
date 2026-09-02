/*
Question: What are the top-selling product categories by revenue?
- Join order items with products and the category translation table to
  get readable category names, then sum revenue (price) and freight
  separately for each category.
- Why? Identifies which product categories drive the most sales revenue,
  a foundational metric for understanding what the business sells best.

Note: "Revenue" here refers to product price only, excluding freight/
shipping charges, which are shown separately as they represent a
pass-through logistics cost rather than earned revenue.
*/

SELECT 
    SUM(price) AS total_revenue,
    SUM(freight_value) AS total_freight,
    SUM(price) + SUM(freight_value) AS total_revenue_with_freight,
    product_category_name_translation.product_category_name_english AS product_name_english
FROM 
    order_items
LEFT JOIN products
    ON order_items.product_id = products.product_id
LEFT JOIN product_category_name_translation
    ON products.product_category_name = product_category_name_translation.product_category_name
GROUP BY
    product_name_english
ORDER BY
    total_revenue DESC
LIMIT 10;

