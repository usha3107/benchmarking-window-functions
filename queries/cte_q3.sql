WITH target_orders AS (
    SELECT user_id, created_at, amount, 'first'::text AS type
    FROM (
        SELECT DISTINCT ON (user_id) user_id, created_at, amount
        FROM orders
        ORDER BY user_id, created_at ASC
    ) f
    UNION ALL
    SELECT user_id, created_at, amount, 'last'::text AS type
    FROM (
        SELECT DISTINCT ON (user_id) user_id, created_at, amount
        FROM orders
        ORDER BY user_id, created_at DESC
    ) l
)
SELECT user_id,
       MAX(CASE WHEN type = 'first' THEN created_at END) AS first_order_date,
       MAX(CASE WHEN type = 'last' THEN created_at END) AS last_order_date,
       MAX(CASE WHEN type = 'first' THEN amount END)::numeric AS first_order_amount,
       MAX(CASE WHEN type = 'last' THEN amount END)::numeric AS last_order_amount
FROM target_orders
GROUP BY user_id;
