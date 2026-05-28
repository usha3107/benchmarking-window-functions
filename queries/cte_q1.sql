WITH daily_sales AS (
    SELECT created_at::date AS day,
           SUM(amount) AS daily_revenue
    FROM orders
    GROUP BY 1
)
SELECT ds1.day,
       ds1.daily_revenue::numeric AS daily_revenue,
       ROUND(AVG(ds2.daily_revenue), 2)::numeric AS rolling_7d_avg
FROM daily_sales ds1
JOIN daily_sales ds2 ON ds2.day BETWEEN ds1.day - 6 AND ds1.day
WHERE ds1.day >= (SELECT MAX(created_at::date) FROM orders) - INTERVAL '89 days'
GROUP BY ds1.day, ds1.daily_revenue
ORDER BY ds1.day ASC;
