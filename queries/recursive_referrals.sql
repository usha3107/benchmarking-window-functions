WITH RECURSIVE top_100 AS (
    SELECT user_id, COUNT(*) AS order_count
    FROM orders
    GROUP BY user_id
    ORDER BY order_count DESC
    LIMIT 100
),
referral_tree AS (
    SELECT t.user_id AS root_user_id,
           u.user_id AS current_user_id,
           1 AS depth
    FROM top_100 t
    JOIN users u ON t.user_id = u.user_id

    UNION ALL

    SELECT rt.root_user_id,
           u.user_id AS current_user_id,
           rt.depth + 1 AS depth
    FROM referral_tree rt
    JOIN users u ON u.referred_by = rt.current_user_id
)
SELECT root_user_id AS user_id,
       MAX(depth)::int AS chain_depth
FROM referral_tree
GROUP BY root_user_id
ORDER BY chain_depth DESC, root_user_id ASC;
