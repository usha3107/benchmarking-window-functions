WITH last_30d AS (
    SELECT user_id, COUNT(*) AS cnt
    FROM orders
    WHERE created_at >= (SELECT MAX(created_at) FROM orders) - INTERVAL '30 days'
    GROUP BY user_id
),
prev_30d AS (
    SELECT user_id, COUNT(*) AS cnt
    FROM orders
    WHERE created_at >= (SELECT MAX(created_at) FROM orders) - INTERVAL '60 days'
      AND created_at < (SELECT MAX(created_at) FROM orders) - INTERVAL '30 days'
    GROUP BY user_id
)
SELECT u.user_id,
       COALESCE(l.cnt, 0)::int AS orders_last_30d,
       COALESCE(p.cnt, 0)::int AS orders_prev_30d
FROM users u
LEFT JOIN last_30d l ON u.user_id = l.user_id
LEFT JOIN prev_30d p ON u.user_id = p.user_id
WHERE COALESCE(l.cnt, 0) < COALESCE(p.cnt, 0)
ORDER BY u.user_id ASC;
