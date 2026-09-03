/*
Question: Which month has the highest rate of late deliveries?
- Flag each order as "late" or "on time" (same logic as Query 6),
  then group by the month the order was placed instead of by state.
- Why? Identifies whether certain months (e.g. holiday/peak season)
  see worse delivery performance, useful for anticipating seasonal strain.
*/

WITH delivery_status AS (
    SELECT
        EXTRACT(MONTH FROM order_purchase_timestamp) AS month,
        orders.order_id,
        CASE
            WHEN orders.order_delivered_customer_date::date > orders.order_estimated_delivery_date::date 
                THEN 1
            ELSE 0
        END AS is_late
    FROM
        orders
    WHERE
        orders.order_delivered_customer_date IS NOT NULL
)

SELECT
    delivery_status.month,
    COUNT(*) AS total_orders,
    SUM(is_late) AS late_orders,
    ROUND(100.0 * SUM(is_late) / COUNT(*), 1) AS pct_late
FROM
    delivery_status
GROUP BY
    month
ORDER BY
    pct_late DESC;