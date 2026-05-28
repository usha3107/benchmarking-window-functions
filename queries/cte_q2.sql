WITH user_spend AS (
    SELECT u.cohort_month,
           u.user_id,
           SUM(o.amount) AS total_spend
    FROM users u
    JOIN orders o ON u.user_id = o.user_id
    GROUP BY u.cohort_month, u.user_id
),
ranked_spend AS (
    SELECT us1.cohort_month,
           us1.user_id,
           us1.total_spend,
           (
               SELECT COUNT(*)
               FROM user_spend us2
               WHERE us2.cohort_month = us1.cohort_month
                 AND us2.total_spend > us1.total_spend
           ) + 1 AS rank_in_cohort
    FROM user_spend us1
)
SELECT cohort_month,
       user_id,
       total_spend::numeric AS total_spend,
       rank_in_cohort::int AS rank_in_cohort
FROM ranked_spend
WHERE rank_in_cohort <= 10
ORDER BY cohort_month ASC, rank_in_cohort ASC, user_id ASC;
