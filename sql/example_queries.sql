-- Total sales by product
SELECT 
    pd.item_purchased, 
    SUM(sf.purchase_amount) AS total_sales
FROM sales_fact sf
JOIN product_dim pd ON sf.product_id = pd.product_id
GROUP BY pd.item_purchased
ORDER BY total_sales DESC;


-- Total spent by customer
SELECT 
    cd.customer_reference_id, 
    SUM(sf.purchase_amount) AS total_spent
FROM sales_fact sf
JOIN customer_dim cd ON sf.customer_id = cd.customer_id
GROUP BY cd.customer_reference_id
ORDER BY total_spent DESC;


-- Average review rating per item
SELECT 
    pd.item_purchased, 
    AVG(sf.review_rating) AS avg_rating,
    COUNT(*) AS rating_count
FROM sales_fact sf
JOIN product_dim pd ON sf.product_id = pd.product_id
GROUP BY pd.item_purchased
ORDER BY avg_rating DESC;


-- Sales count by payment method
SELECT 
    pm.payment_method, 
    COUNT(*) AS num_sales
FROM sales_fact sf
JOIN payment_dim pm ON sf.payment_id = pm.payment_id
GROUP BY pm.payment_method
ORDER BY num_sales DESC;
