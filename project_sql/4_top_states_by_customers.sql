/*
Question: Which states have the most customers?
- Count distinct customers per state directly from the customers table
  (no join needed, since customer_state already lives there).
- Why? Identifies where Olist's customer base is concentrated
  geographically, useful for understanding market reach.
*/

SELECT  
    COUNT(DISTINCT customer_unique_id) AS customer_count,
    customer_state
FROM
    customers
GROUP BY
    customer_state
ORDER BY
    customer_count DESC
LIMIT 10;