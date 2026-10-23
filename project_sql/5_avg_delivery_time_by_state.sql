/*
Question: How long does delivery take on average, and does it vary by state?
- Calculate delivery time (in days) as the difference between purchase
  and actual delivery date for each delivered order, then average by customer state.
- Also count the orders per state to show how reliable each average is.
- Why? Delivery speed is a key operational metric that directly affects
  customer satisfaction and cost to serve different regions.
*/

SELECT
    customers.customer_state,
    COUNT(*) AS orders_count,
    ROUND(AVG(orders.order_delivered_customer_date::date - orders.order_purchase_timestamp::date), 1) AS avg_delivery_days
FROM
    orders
INNER JOIN customers
    ON orders.customer_id = customers.customer_id
WHERE
    orders.order_delivered_customer_date IS NOT NULL AND
    orders.order_status = 'delivered'
GROUP BY
    customers.customer_state
ORDER BY
    avg_delivery_days;