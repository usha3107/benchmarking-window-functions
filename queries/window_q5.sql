SELECT order_id,
       user_id,
       amount::numeric AS amount,
       ROUND((amount / SUM(amount) OVER (PARTITION BY user_id)) * 100, 4)::numeric AS lifetime_share_pct
FROM orders
ORDER BY user_id ASC, order_id ASC;
