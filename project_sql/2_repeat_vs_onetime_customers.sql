/*
Question: How many customers are repeat buyers vs. one-time buyers?
- Count orders per unique customer (customer_unique_id, not customer_id,
  since customer_id is generated per order in this dataset) using a CTE,
  then classify each as "one-time" or "repeat" with a CASE statement.
- Why? Customer retention is a key health metric for any e-commerce
  business — low repeat purchase rates signal reliance on constant new
  customer acquisition, which is typically costlier than retention.
*/

WITH customer_order_counts AS (
    SELECT
        customers.customer_unique_id,
        COUNT(order_id) AS number_of_orders
    FROM
        customers
    LEFT JOIN orders
        ON customers.customer_id = orders.customer_id
    GROUP BY
        customer_unique_id
)

SELECT
    CASE
        WHEN number_of_orders = 1 THEN 'One-time customer'
        ELSE 'Repeat customer'
    END AS customer_type,
    COUNT(*) AS number_of_customers
FROM 
    customer_order_counts
GROUP BY 
    customer_type;