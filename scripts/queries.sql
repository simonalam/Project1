-- Fashion Retail Sales Analysis Queries
-- DS-2002 Project 1
-- All queries demonstrate JOINs across 3+ tables with aggregations

USE ds2002_retail;

-- ============================================================================
-- Query 1: Total Sales by Product (3 tables: sales_fact, product_dim, date_dim)
-- Demonstrates: JOIN, SUM, COUNT, AVG, GROUP BY
-- ============================================================================
SELECT 
    pd.item_name, 
    pd.category,
    COUNT(sf.sale_id) AS num_sales,
    SUM(sf.purchase_amount) AS total_sales,
    AVG(sf.purchase_amount) AS avg_sale_price,
    AVG(sf.review_rating) AS avg_rating
FROM sales_fact sf
JOIN product_dim pd ON sf.product_id = pd.product_id
JOIN date_dim dd ON sf.date_id = dd.date_id
WHERE dd.year = 2023
GROUP BY pd.item_name, pd.category
ORDER BY total_sales DESC
LIMIT 15;


-- ============================================================================
-- Query 2: Customer Spending Analysis (3 tables: sales_fact, customer_dim, payment_dim)
-- Demonstrates: JOIN, SUM, COUNT, AVG, GROUP BY
-- ============================================================================
SELECT 
    cd.name, 
    cd.city,
    pm.payment_method,
    COUNT(sf.sale_id) AS num_purchases,
    SUM(sf.purchase_amount) AS total_spent,
    AVG(sf.purchase_amount) AS avg_purchase,
    MAX(sf.purchase_amount) AS largest_purchase
FROM sales_fact sf
JOIN customer_dim cd ON sf.customer_id = cd.customer_id
JOIN payment_dim pm ON sf.payment_id = pm.payment_id
GROUP BY cd.name, cd.city, pm.payment_method
HAVING num_purchases >= 10
ORDER BY total_spent DESC
LIMIT 20;


-- ============================================================================
-- Query 3: Product Performance by Category (4 tables: all dimensions + fact)
-- Demonstrates: JOIN, AVG, COUNT, SUM, GROUP BY
-- ============================================================================
SELECT 
    pd.category,
    pd.brand,
    pm.payment_method,
    COUNT(DISTINCT cd.customer_id) AS unique_customers,
    COUNT(sf.sale_id) AS total_sales,
    SUM(sf.purchase_amount) AS revenue,
    AVG(sf.review_rating) AS avg_rating
FROM sales_fact sf
JOIN product_dim pd ON sf.product_id = pd.product_id
JOIN customer_dim cd ON sf.customer_id = cd.customer_id
JOIN payment_dim pm ON sf.payment_id = pm.payment_id
WHERE sf.review_rating IS NOT NULL
GROUP BY pd.category, pd.brand, pm.payment_method
ORDER BY revenue DESC;


-- ============================================================================
-- Query 4: Monthly Sales Trends (3 tables: sales_fact, date_dim, product_dim)
-- Demonstrates: JOIN, SUM, COUNT, AVG, GROUP BY, DATE functions
-- ============================================================================
SELECT 
    dd.year,
    dd.month,
    pd.category,
    COUNT(sf.sale_id) AS num_transactions,
    SUM(sf.purchase_amount) AS monthly_revenue,
    AVG(sf.purchase_amount) AS avg_transaction,
    COUNT(DISTINCT pd.product_id) AS unique_products_sold
FROM sales_fact sf
JOIN date_dim dd ON sf.date_id = dd.date_id
JOIN product_dim pd ON sf.product_id = pd.product_id
GROUP BY dd.year, dd.month, pd.category
ORDER BY dd.year, dd.month, monthly_revenue DESC;


-- ============================================================================
-- Query 5: Customer Loyalty Analysis (4 tables: all dimensions)
-- Demonstrates: JOIN, SUM, COUNT, AVG, GROUP BY, derived metrics
-- ============================================================================
SELECT 
    cd.loyalty_member,
    cd.city,
    pd.category,
    COUNT(DISTINCT cd.customer_id) AS num_customers,
    COUNT(sf.sale_id) AS total_purchases,
    SUM(sf.purchase_amount) AS total_revenue,
    AVG(sf.purchase_amount) AS avg_purchase_value,
    ROUND(SUM(sf.purchase_amount) / COUNT(DISTINCT cd.customer_id), 2) AS revenue_per_customer,
    AVG(sf.review_rating) AS avg_satisfaction
FROM sales_fact sf
JOIN customer_dim cd ON sf.customer_id = cd.customer_id
JOIN product_dim pd ON sf.product_id = pd.product_id
JOIN date_dim dd ON sf.date_id = dd.date_id
WHERE sf.review_rating IS NOT NULL AND dd.year = 2023
GROUP BY cd.loyalty_member, cd.city, pd.category
HAVING total_purchases >= 5
ORDER BY revenue_per_customer DESC
LIMIT 25;


-- ============================================================================
-- Query 6: Geographic Sales Distribution (3 tables: sales_fact, customer_dim, product_dim)
-- Demonstrates: JOIN, SUM, COUNT, AVG, GROUP BY
-- ============================================================================
SELECT 
    cd.city,
    cd.loyalty_member,
    COUNT(DISTINCT cd.customer_id) AS num_customers,
    COUNT(sf.sale_id) AS num_sales,
    SUM(sf.purchase_amount) AS total_revenue,
    AVG(sf.purchase_amount) AS avg_sale,
    MAX(sf.purchase_amount) AS largest_sale
FROM sales_fact sf
JOIN customer_dim cd ON sf.customer_id = cd.customer_id
JOIN product_dim pd ON sf.product_id = pd.product_id
GROUP BY cd.city, cd.loyalty_member
ORDER BY total_revenue DESC
LIMIT 15;


-- ============================================================================
-- Query 7: Payment Method Preference by Category (4 tables)
-- Demonstrates: JOIN, COUNT, SUM, GROUP BY
-- ============================================================================
SELECT 
    pm.payment_method,
    pd.category,
    dd.year,
    COUNT(sf.sale_id) AS num_transactions,
    SUM(sf.purchase_amount) AS total_amount,
    AVG(sf.purchase_amount) AS avg_amount
FROM sales_fact sf
JOIN payment_dim pm ON sf.payment_id = pm.payment_id
JOIN product_dim pd ON sf.product_id = pd.product_id
JOIN date_dim dd ON sf.date_id = dd.date_id
GROUP BY pm.payment_method, pd.category, dd.year
ORDER BY total_amount DESC;


-- ============================================================================
-- BONUS: Data Quality & Summary Statistics
-- ============================================================================

-- Table row counts
SELECT 
    'customer_dim' AS table_name,
    COUNT(*) AS row_count
FROM customer_dim
UNION ALL
SELECT 'product_dim', COUNT(*) FROM product_dim
UNION ALL
SELECT 'date_dim', COUNT(*) FROM date_dim
UNION ALL
SELECT 'payment_dim', COUNT(*) FROM payment_dim
UNION ALL
SELECT 'sales_fact', COUNT(*) FROM sales_fact;


-- Overall statistics
SELECT 
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(DISTINCT product_id) AS total_products,
    COUNT(*) AS total_transactions,
    SUM(purchase_amount) AS total_revenue,
    AVG(purchase_amount) AS avg_transaction_value,
    MIN(purchase_amount) AS min_transaction,
    MAX(purchase_amount) AS max_transaction,
    AVG(review_rating) AS avg_rating
FROM sales_fact;


-- Top 5 customers
SELECT 
    cd.name,
    cd.city,
    cd.loyalty_member,
    COUNT(sf.sale_id) AS purchases,
    SUM(sf.purchase_amount) AS total_spent
FROM sales_fact sf
JOIN customer_dim cd ON sf.customer_id = cd.customer_id
GROUP BY cd.name, cd.city, cd.loyalty_member
ORDER BY total_spent DESC
LIMIT 5;
