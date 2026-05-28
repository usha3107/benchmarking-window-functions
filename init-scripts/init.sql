CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    email VARCHAR UNIQUE NOT NULL,
    cohort_month DATE NOT NULL,
    referred_by INT NULL
);

CREATE TABLE orders (
    order_id UUID PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    amount NUMERIC NOT NULL CHECK (amount > 0),
    status VARCHAR NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO users (user_id, email, cohort_month, referred_by)
SELECT
    i AS user_id,
    'user_' || i || '@example.com' AS email,
    DATE '2024-06-01' + (floor(random() * 24) * INTERVAL '1 month') AS cohort_month,
    CASE 
        WHEN i > 1 AND random() < 0.30 THEN floor(random() * (i - 1))::int + 1
        ELSE NULL
    END AS referred_by
FROM generate_series(1, 200000) AS i;

INSERT INTO orders (order_id, user_id, product_id, amount, status, created_at, updated_at)
SELECT
    order_id,
    user_id,
    product_id,
    amount,
    status,
    created_at,
    created_at + (random() * INTERVAL '2 hours') AS updated_at
FROM (
    SELECT
        gen_random_uuid() AS order_id,
        floor(pow(random(), 2.5) * 200000)::int + 1 AS user_id,
        floor(random() * 1000)::int + 1 AS product_id,
        round((random() * 495.00 + 5.00)::numeric, 2) AS amount,
        (ARRAY['completed', 'completed', 'completed', 'pending', 'cancelled'])[floor(random() * 5)::int + 1] AS status,
        NOW() - (random() * 24 * 30 * INTERVAL '1 day') AS created_at
    FROM generate_series(1, 1000000) AS i
) sub;

ALTER TABLE users ADD CONSTRAINT fk_users_referred_by FOREIGN KEY (referred_by) REFERENCES users(user_id);
ALTER TABLE orders ADD CONSTRAINT fk_orders_user FOREIGN KEY (user_id) REFERENCES users(user_id);

SELECT 'Users Count: ' || COUNT(*) FROM users;
SELECT 'Orders Count: ' || COUNT(*) FROM orders;
