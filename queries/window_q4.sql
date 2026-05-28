WITH periods AS (
    SELECT 1 AS period UNION ALL SELECT 2 AS period
),
user_periods AS (
    SELECT u.user_id, p.period
    FROM users u
    CROSS JOIN periods p
),
order_counts AS (
    SELECT user_id,
           CASE
               WHEN created_at >= (SELECT MAX(created_at) FROM orders) - INTERVAL '30 days' THEN 2
               WHEN created_at >= (SELECT MAX(created_at) FROM orders) - INTERVAL '60 days' AND created_at < (SELECT MAX(created_at) FROM orders) - INTERVAL '30 days' THEN 1
           END AS period,
           COUNT(*) AS cnt
    FROM orders
    WHERE created_at >= (SELECT MAX(created_at) FROM orders) - INTERVAL '60 days'
    GROUP BY user_id, period
),
full_grid AS (
    SELECT up.user_id,
           up.period,
           COALESCE(oc.cnt, 0) AS cnt
    FROM user_periods up
    LEFT JOIN order_counts oc ON up.user_id = oc.user_id AND up.period = oc.period
),
lagged AS (
    SELECT user_id,
           period,
           cnt,
           LAG(cnt) OVER (PARTITION BY user_id ORDER BY period) AS prev_cnt
    FROM full_grid
)
SELECT user_id,
       cnt::int AS orders_last_30d,
       prev_cnt::int AS orders_prev_30d
FROM lagged
WHERE period = 2 AND cnt < prev_cnt
ORDER BY user_id ASC;
