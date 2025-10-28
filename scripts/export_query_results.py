import pandas as pd
from sqlalchemy import create_engine

# MySQL connection
engine = create_engine('mysql+mysqlconnector://root:Oct2703thh@localhost/ds2002_retail')

# Query to export (FIXED - using COUNT(*) instead of sale_id)
query = """
SELECT 
    pd.item_name, 
    pd.category,
    COUNT(*) AS num_sales,
    SUM(sf.purchase_amount) AS total_sales,
    AVG(sf.purchase_amount) AS avg_sale_price,
    AVG(sf.review_rating) AS avg_rating
FROM sales_fact sf
JOIN product_dim pd ON sf.product_id = pd.product_id
JOIN date_dim dd ON sf.date_id = dd.date_id
WHERE dd.year = 2023
GROUP BY pd.item_name, pd.category
ORDER BY total_sales DESC;
"""

# Execute query and save to CSV
df = pd.read_sql(query, engine)
df.to_csv('../output/query_results.csv', index=False)

print(f"Successfully saved {len(df)} rows to query_results.csv")
print(f"Total sales: ${df['total_sales'].sum():,.2f}")
