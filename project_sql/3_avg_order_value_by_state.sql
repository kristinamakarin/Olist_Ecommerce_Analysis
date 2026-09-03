/*
Question: How does average order value vary by customer state?
- First sum order_items.price per order (via a CTE) to get each order's
  total value, then average those totals grouped by customer_state.
- Why? A two-step aggregation is needed because averaging item-level
  prices directly would ignore that orders often contain multiple items,
  understating true order value.
*/


WITH order_totals AS (
    SELECT
        orders.order_id,
        customers.customer_state,
        SUM(order_items.price) AS order_total
    FROM 
        customers
    LEFT JOIN orders
        ON customers.customer_id = orders.customer_id
    LEFT JOIN order_items
        ON orders.order_id = order_items.order_id
    GROUP BY
        orders.order_id,
        customers.customer_state
)

SELECT
    customer_state,
    ROUND(AVG(order_total), 2) AS avg_order_value
FROM
    order_totals
GROUP BY
    customer_state
ORDER BY
    avg_order_value DESC;