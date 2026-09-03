/*
Question: What percentage of orders are delivered later than the
estimated delivery date, and does this vary by state?
- For each order, compare actual delivery date to estimated delivery
  date using CASE to flag it as "late" or "on time", then calculate
  the percentage of late orders per state.
- Why? Late deliveries are a key driver of customer dissatisfaction;
  identifying where they're concentrated helps prioritize logistics
  improvements.
*/

WITH delivery_status AS (
    SELECT
        orders.order_id,
        customers.customer_state,
        CASE
            WHEN orders.order_delivered_customer_date::date > orders.order_estimated_delivery_date::date 
                THEN 1
            ELSE 0
        END AS is_late
    FROM
        orders
    LEFT JOIN customers
        ON orders.customer_id = customers.customer_id
    WHERE
        orders.order_delivered_customer_date IS NOT NULL
)

SELECT
    customer_state,
    COUNT(*) AS total_orders,
    SUM(is_late) AS late_orders,
    ROUND(100.0 * SUM(is_late) / COUNT(*), 1) AS pct_late
FROM
    delivery_status
GROUP BY
    customer_state
ORDER BY
    pct_late DESC;