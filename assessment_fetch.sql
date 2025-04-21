DROP TABLE IF EXISTS users_takehome;

CREATE TABLE users_takehome (
    id VARCHAR PRIMARY KEY,
    created_date DATE,
    birth_date DATE,
    state TEXT,
    language TEXT,
    gender TEXT
);

select * from users_takehome;

DROP TABLE IF EXISTS transaction_items_raw;

CREATE TABLE transaction_items_raw (
    receipt_id TEXT,
    purchase_date TEXT,
    scan_date TEXT,
    store_name TEXT,
    user_id TEXT,
    barcode TEXT,
    final_quantity TEXT,
    final_sale TEXT
);

select * from transaction_items_raw;


DROP TABLE IF EXISTS transaction_items;

CREATE TABLE transaction_items (
    receipt_id VARCHAR,
    purchase_date DATE,
    scan_date TIMESTAMP,
    store_name TEXT,
    user_id VARCHAR,
    barcode NUMERIC,
    final_quantity NUMERIC,
    final_sale NUMERIC
);

INSERT INTO transaction_items
SELECT
    receipt_id,
    TO_DATE(purchase_date, 'MM/DD/YYYY'),     -- Fix for "8/21/2024"
    scan_date::timestamp,
    store_name,
    user_id,
    barcode::NUMERIC,
    final_quantity::NUMERIC,
    NULLIF(TRIM(final_sale), '')::NUMERIC
FROM transaction_items_raw;

select * from transaction_items;

DROP TABLE IF EXISTS products_takehome;

CREATE TABLE products_takehome (
    category_1 TEXT,
    category_2 TEXT,
    category_3 TEXT,
    category_4 TEXT,
    manufacturer TEXT,
    brand TEXT,
    barcode NUMERIC  -- must match the type in `transaction_items`
);

select * from products_takehome;


-- Nulls in each column
SELECT
    COUNT(*) FILTER (WHERE birth_date IS NULL) AS null_birth_date,
    COUNT(*) FILTER (WHERE created_date IS NULL) AS null_created_date,
    COUNT(*) FILTER (WHERE gender IS NULL) AS null_gender,
    COUNT(*) FILTER (WHERE state IS NULL) AS null_state,
    COUNT(*) FILTER (WHERE language IS NULL) AS null_language
FROM users_takehome;

-- Unexpected values in gender
SELECT DISTINCT gender FROM users_takehome;

SELECT 
    *,
    CASE
        WHEN LOWER(gender) = 'male' THEN 'Male'
        WHEN LOWER(gender) = 'female' THEN 'Female'
        WHEN LOWER(gender) IN ('non_binary', 'non-binary') THEN 'Non-Binary'
        WHEN LOWER(gender) = 'transgender' THEN 'Transgender'
        WHEN LOWER(gender) IN (
            'prefer not to say',
            'prefer_not_to_say',
            'not_specified',
            'unknown',
            'not_listed'
        ) THEN 'Prefer Not to Say'
        WHEN LOWER(gender) = 'my gender isn''t listed' THEN 'Other'
        ELSE 'Unknown'
    END AS normalized_gender
FROM users_takehome;

CREATE VIEW users_normalized AS
SELECT 
    *,
    CASE
        WHEN LOWER(gender) = 'male' THEN 'Male'
        WHEN LOWER(gender) = 'female' THEN 'Female'
        WHEN LOWER(gender) IN ('non_binary', 'non-binary') THEN 'Non-Binary'
        WHEN LOWER(gender) = 'transgender' THEN 'Transgender'
        WHEN LOWER(gender) IN (
            'prefer not to say',
            'prefer_not_to_say',
            'not_specified',
            'unknown',
            'not_listed'
        ) THEN 'Prefer Not to Say'
        WHEN LOWER(gender) = 'my gender isn''t listed' THEN 'Other'
        ELSE 'Unknown'
    END AS normalized_gender
FROM users_takehome;


SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (WHERE receipt_id IS NULL) AS null_receipt_id,
    COUNT(*) FILTER (WHERE user_id IS NULL) AS null_user_id,
    COUNT(*) FILTER (WHERE store_name IS NULL) AS null_store_name,
    COUNT(*) FILTER (WHERE purchase_date IS NULL) AS null_purchase_date,
    COUNT(*) FILTER (WHERE scan_date IS NULL) AS null_scan_date,
    MIN(purchase_date) AS earliest_purchase,
    MAX(purchase_date) AS latest_purchase
FROM transaction_items;

SELECT *
FROM transaction_items
WHERE scan_date > CURRENT_DATE;

-- Join Users + Transactions
SELECT 
    t.receipt_id,
    t.purchase_date,
    t.user_id,
    u.birth_date,
    u.state,
    u.gender
FROM transaction_items t
JOIN users_takehome u ON t.user_id = u.id;

-- Join Transactions + Products (by barcode)
SELECT 
    t.receipt_id,
    t.user_id,
    t.barcode,
    p.brand,
    p.category_1,
    p.category_2,
    p.manufacturer
FROM transaction_items t
JOIN products_takehome p ON t.barcode = p.barcode;

-- Full Join: Users + Transactions + Products

SELECT 
    t.receipt_id,
    t.purchase_date,
    t.user_id,
    u.state,
    u.gender,
    u.birth_date,
    t.barcode,
    p.brand,
    p.category_1,
    t.final_quantity,
    t.final_sale
FROM transaction_items t
JOIN users_takehome u ON t.user_id = u.id
JOIN products_takehome p ON t.barcode = p.barcode;


-- SELECT COUNT(*) FROM transaction_items t
-- WHERE t.user_id NOT IN (SELECT id FROM users_takehome);

-- Top 5 Brands by Receipts Scanned Among Users 21 and Over
SELECT 
    p.brand,
    COUNT(DISTINCT t.receipt_id) AS receipt_count
FROM transaction_items t
JOIN users_takehome u 
    ON TRIM(LOWER(t.user_id)) = TRIM(LOWER(u.id))
JOIN products_takehome p 
    ON t.barcode = p.barcode
WHERE 
    EXTRACT(YEAR FROM AGE(u.birth_date)) >= 21
    AND p.brand IS NOT NULL
GROUP BY p.brand
ORDER BY receipt_count DESC
LIMIT 5;

-- What are the top 5 brands by sales among users that have had their account for at least six months?

SELECT 
    p.brand,
    ROUND(SUM(t.final_sale), 2) AS total_sales
FROM transaction_items t
JOIN users_takehome u 
    ON TRIM(LOWER(t.user_id)) = TRIM(LOWER(u.id))
JOIN products_takehome p 
    ON t.barcode = p.barcode
WHERE 
    u.created_date <= CURRENT_DATE - INTERVAL '6 months'
    AND p.brand IS NOT NULL
GROUP BY p.brand
ORDER BY total_sales DESC
LIMIT 5;


-- What is the Percentage of Sales in Health & Wellness by Generation?
WITH sales_by_gen AS (
  SELECT
    CASE 
      WHEN EXTRACT(YEAR FROM birth_date) BETWEEN 1997 AND 2012 THEN 'Gen Z'
      WHEN EXTRACT(YEAR FROM birth_date) BETWEEN 1981 AND 1996 THEN 'Millennials'
      WHEN EXTRACT(YEAR FROM birth_date) BETWEEN 1965 AND 1980 THEN 'Gen X'
      WHEN EXTRACT(YEAR FROM birth_date) < 1965 THEN 'Boomers+'
      ELSE 'Unknown'
    END AS generation,
    SUM(t.final_sale) AS health_sales
  FROM transaction_items t
  JOIN users_takehome u ON TRIM(LOWER(t.user_id)) = TRIM(LOWER(u.id))
  JOIN products_takehome p ON t.barcode = p.barcode
  WHERE p.category_1 = 'Health & Wellness'
  GROUP BY generation
),
total_sales AS (
  SELECT SUM(final_sale) AS total
  FROM transaction_items
)

SELECT 
  generation,
  ROUND(100.0 * health_sales / total, 2) AS percent_health_sales
FROM sales_by_gen, total_sales
ORDER BY percent_health_sales DESC;

-- Who Are Fetch's Power Users?
WITH user_receipts AS (
  SELECT user_id, COUNT(DISTINCT receipt_id) AS receipt_count
  FROM transaction_items
  GROUP BY user_id
),
ranked_users AS (
  SELECT *,
         NTILE(100) OVER (ORDER BY receipt_count DESC) AS percentile
  FROM user_receipts
)

SELECT user_id, receipt_count
FROM ranked_users
WHERE percentile = 1
ORDER BY receipt_count DESC;

-- Which is the leading brand in the Dips & Salsa category?
SELECT 
    p.brand,
    ROUND(SUM(t.final_sale), 2) AS total_sales
FROM transaction_items t
JOIN products_takehome p 
    ON t.barcode = p.barcode
WHERE 
    TRIM(LOWER(p.category_2)) = 'dips & salsa'
    AND p.brand IS NOT NULL
GROUP BY p.brand
ORDER BY total_sales DESC
LIMIT 5;

-- At what percent has Fetch grown year over year?
WITH yearly_sales AS (
  SELECT 
    EXTRACT(YEAR FROM purchase_date) AS year,
    SUM(final_sale) AS total_sales
  FROM transaction_items
  WHERE final_sale IS NOT NULL
  GROUP BY EXTRACT(YEAR FROM purchase_date)
)
SELECT 
    y1.year AS previous_year,
    y2.year AS current_year,
    ROUND(100.0 * (y2.total_sales - y1.total_sales) / y1.total_sales, 2) AS percent_growth
FROM yearly_sales y1
JOIN yearly_sales y2 ON y2.year = y1.year + 1
ORDER BY y1.year DESC
LIMIT 1;

-- Monthly growth

WITH monthly_sales AS (
  SELECT 
    DATE_TRUNC('month', purchase_date) AS month,
    SUM(final_sale) AS total_sales
  FROM transaction_items
  WHERE final_sale IS NOT NULL
  GROUP BY 1
),
growth_calc AS (
  SELECT 
    month,
    total_sales,
    ROUND(
      100.0 * (total_sales - LAG(total_sales) OVER (ORDER BY month)) / 
      NULLIF(LAG(total_sales) OVER (ORDER BY month), 0), 2
    ) AS percent_growth
  FROM monthly_sales
)
SELECT 
  TO_CHAR(month, 'YYYY-MM') AS month,
  total_sales,
  percent_growth
FROM growth_calc
ORDER BY month;
