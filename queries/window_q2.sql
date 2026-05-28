WITH user_spend AS (
    SELECT u.cohort_month,
           u.user_id,
           SUM(o.amount) AS total_spend
    FROM users u
    JOIN orders o ON u.user_id = o.user_id
    GROUP BY u.cohort_month, u.user_id
),
ranked_spend AS (
    SELECT cohort_month,
           user_id,
           total_spend,
           RANK() OVER (PARTITION BY cohort_month ORDER BY total_spend DESC) AS rank_in_cohort
    FROM user_spend
)
SELECT cohort_month,
       user_id,
       total_spend::numeric AS total_spend,
       rank_in_cohort::int AS rank_in_cohort
FROM ranked_spend
WHERE rank_in_cohort <= 10
ORDER BY cohort_month ASC, rank_in_cohort ASC, user_id ASC;
