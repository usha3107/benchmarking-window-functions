SELECT DISTINCT
    user_id,
    FIRST_VALUE(created_at) OVER (
        PARTITION BY user_id
        ORDER BY created_at ASC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS first_order_date,
    LAST_VALUE(created_at) OVER (
        PARTITION BY user_id
        ORDER BY created_at ASC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS last_order_date,
    FIRST_VALUE(amount) OVER (
        PARTITION BY user_id
        ORDER BY created_at ASC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS first_order_amount,
    LAST_VALUE(amount) OVER (
        PARTITION BY user_id
        ORDER BY created_at ASC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS last_order_amount
FROM orders;
