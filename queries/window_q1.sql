WITH daily_sales AS (
    SELECT created_at::date AS day,
           SUM(amount) AS daily_revenue
    FROM orders
    GROUP BY 1
),
with_rolling AS (
    SELECT day,
           daily_revenue,
           AVG(daily_revenue) OVER (
               ORDER BY day
               ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
           ) AS rolling_7d_avg
    FROM daily_sales
)
SELECT day,
       daily_revenue::numeric AS daily_revenue,
       ROUND(rolling_7d_avg, 2)::numeric AS rolling_7d_avg
FROM with_rolling
WHERE day >= (SELECT MAX(created_at::date) FROM orders) - INTERVAL '89 days'
ORDER BY day ASC;
