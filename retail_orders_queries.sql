-- Create and select database
CREATE DATABASE data_analysis;
SHOW DATABASES;
USE data_analysis;

-- Check existing tables
SHOW TABLES;

-- Drop table if it already exists
DROP TABLE df_orders;

-- Create orders table
CREATE TABLE df_orders (
    order_id INT PRIMARY KEY,
    order_date DATE,
    ship_mode VARCHAR(20),
    segment VARCHAR(20),
    country VARCHAR(20),
    city VARCHAR(20),
    state VARCHAR(20),
    postal_code VARCHAR(20),
    region VARCHAR(20),
    category VARCHAR(20),
    sub_category VARCHAR(20),
    product_id VARCHAR(50),
    quantity INT,
    discount DECIMAL(7,2),
    sale_price DECIMAL(7,2),
    profit DECIMAL(7,2)
);

-- View complete dataset
SELECT * FROM df_orders;


-- =====================================================
-- Question 1: Find Top 10 Highest Revenue Generating Products
-- =====================================================

SELECT
    product_id,
    SUM(sale_price) AS sales
FROM df_orders
GROUP BY product_id
ORDER BY sales DESC
LIMIT 10;


-- =====================================================
-- Question 2: Find Top 5 Highest Selling Products in Each Region
-- =====================================================

WITH cte AS (
    SELECT
        region,
        product_id,
        SUM(sale_price) AS total_sales
    FROM df_orders
    GROUP BY region, product_id
)

SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER(
               PARTITION BY region
               ORDER BY total_sales DESC
           ) AS rn
    FROM cte
) AS r
WHERE rn <= 5;


-- =====================================================
-- Question 3: Compare Monthly Sales Between 2022 and 2023
-- =====================================================

WITH cte AS (
    SELECT
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY YEAR(order_date), MONTH(order_date)
)

SELECT
    order_month,
    SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
    SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY order_month
ORDER BY order_month;


-- =====================================================
-- Question 4: Find the Highest Selling Month for Each Category
-- =====================================================

WITH cte AS (
    SELECT
        category,
        DATE_FORMAT(order_date, '%Y %m') AS order_year_month,
        SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY category, order_year_month
)

SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER(
               PARTITION BY category
               ORDER BY sales DESC
           ) AS rn
    FROM cte
) AS r
WHERE rn = 1;


-- =====================================================
-- Question 5: Find the Sub-Category with Highest Sales Growth
-- Between 2022 and 2023
-- =====================================================

WITH cte AS (
    SELECT
        sub_category,
        YEAR(order_date) AS order_year,
        SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY sub_category, YEAR(order_date)
),

cte2 AS (
    SELECT
        sub_category,
        SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
        SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
    FROM cte
    GROUP BY sub_category
)

SELECT *,
       (sales_2023 - sales_2022) * 100 / sales_2022 AS sales_percent
FROM cte2
ORDER BY sales_percent DESC
LIMIT 1;