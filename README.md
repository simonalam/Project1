# Fashion Retail Sales Data Mart - ETL Pipeline

**DS-2002 Project 1: Midterm**  
**Author**: Simon Alam  
**University of Virginia**

A dimensional data mart ETL pipeline that extracts data from CSV files, MongoDB Atlas, and programmatic sources, transforms it, and loads into a MySQL star schema for retail sales analytics.

---

## Project Overview

This ETL pipeline demonstrates:
- **Extract** from 3 source types: CSV files (file system), MongoDB Atlas (NoSQL), and Python-generated date dimension
- **Transform** data through surrogate key generation, column modifications, and referential integrity validation
- **Load** into MySQL star schema (4 dimensions + 1 fact table)
- **Analyze** with SQL queries demonstrating JOINs and aggregations

**Business Process**: Fashion retail sales transactions analyzing revenue, customer behavior, product performance, and payment preferences.

---

## Requirements Met ✅

**Data Sources (3 types)**:
- CSV files: Fashion_Retail_Sales.csv, customers.csv, products.csv
- MongoDB Atlas: suppliers collection in retail_db
- Programmatic: Date dimension with time hierarchy

**Star Schema**:
- 1 Fact table: sales_fact (purchase_amount, review_rating)
- 4 Dimensions: date, customer, product, payment

**Transformations**:
- Generate surrogate keys for all dimensions
- Combine first_name + last_name into single name field
- Derive loyalty_member status from loyalty_tier
- Normalize MongoDB documents to flat structure
- Validate referential integrity (0 NULL foreign keys)

**Queries** (all with JOINs + aggregations):
1. Total sales by product category (SUM, COUNT, AVG)
2. Customer spending by segment (SUM, COUNT, AVG)
3. Product performance by category (SUM, COUNT, AVG)
4. Monthly sales trends (SUM, COUNT, AVG)
5. Customer loyalty analysis (SUM, COUNT, AVG, derived metrics)
6. Geographic sales distribution (SUM, COUNT, AVG, MAX)
7. Payment method preferences (SUM, COUNT, AVG)

---

## Quick Start

### Prerequisites
- Python 3.8+
- MySQL 8.0+
- MongoDB Atlas account (free tier)

### Setup

1. **Clone and install dependencies**:
```bash
git clone <your-repo-url>
cd PROJECT1
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

2. **Configure environment variables**:
```bash
cp .env.example .env
# Edit .env with your credentials
```

`.env` format:
```
MYSQL_HOST=localhost
MYSQL_USER=root
MYSQL_PASSWORD=your_password
MYSQL_DATABASE=ds2002_retail
MONGODB_URI=mongodb+srv://user:password@cluster.mongodb.net/
```

3. **Setup MongoDB Atlas**:
- Create free account at https://www.mongodb.com/cloud/atlas
- Create M0 cluster
- Database Access: Add user with read/write permissions
- Network Access: Allow 0.0.0.0/0
- Get connection string and add to `.env`

4. **Create MySQL database**:
```sql
CREATE DATABASE ds2002_retail;
```

5. **Run the pipeline**:
```bash
python scripts/setup_mongodb.py    # Populate MongoDB source
jupyter notebook scripts/etl_pipeline.ipynb     # Run ETL
```

6. **Verify with queries**:
```bash
mysql -u root -p ds2002_retail < scripts/queries.sql
```

7. **Export query results**:
```bash
python scripts/export_query_results.py
```

---

## Project Structure

```
PROJECT1/
├── scripts/
│   ├── etl_pipeline.ipynb           # Main ETL notebook
│   ├── setup_mongodb.py             # MongoDB initialization
│   ├── schema.sql                   # Table definitions
│   ├── queries.sql                  # Analytical queries
│   ├── usedb.sql                    # Database selection
│   └── export_query_results.py      # CSV export script
├── data/
│   ├── Fashion_Retail_Sales.csv     # 3,400 sales records
│   ├── customers.csv                # 166 customer profiles
│   ├── products.csv                 # 61 product catalog
│   └── mongo_source.json            # 4 supplier records
├── output/
│   └── query_results.csv            # Query output
├── .env                             # Credentials (not in Git)
├── .env.example                     # Template
├── requirements.txt                 # Dependencies
├── .gitignore                       # Git exclusions
└── README.md
```

---

## Data Flow

```
SOURCES → TRANSFORM → LOAD

CSV Files (sales)      ┐
CSV Files (customers)  ├→ ETL Pipeline → MySQL Star Schema
CSV Files (products)   │
MongoDB (suppliers)    │
Date Generation        ┘
```

**Extract**: 3,400 sales, 166 customers, 61 products (CSV) + 4 suppliers (MongoDB) + 365 dates (Python)  
**Transform**: Create dimensions, generate surrogate keys, validate foreign keys, combine name fields  
**Load**: 5 tables in MySQL (date_dim, customer_dim, product_dim, payment_dim, sales_fact)

---

## Star Schema

```
         date_dim
            │
       ┌────┼────┐
customer_dim─sales_fact─product_dim
            │
       payment_dim
```

**Fact Table**: `sales_fact` (sale_id, customer_id, product_id, date_id, payment_id, purchase_amount, review_rating)

**Dimensions**:
- `date_dim`: date_id, purchase_date, year, month, day
- `customer_dim`: customer_id, customer_reference_id, name, email, city, loyalty_member, age
- `product_dim`: product_id, item_name, category, brand, material, season, gender_target, base_price, stock_quantity, supplier_name, product_introduction_date
- `payment_dim`: payment_id, payment_method

---

## Sample Queries

**Query 1: Total Sales by Product Category**
```sql
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
```

**Query 2: Customer Spending Analysis**
```sql
SELECT 
    cd.name, 
    cd.city,
    pm.payment_method,
    COUNT(*) AS num_purchases,
    SUM(sf.purchase_amount) AS total_spent,
    AVG(sf.purchase_amount) AS avg_purchase
FROM sales_fact sf
JOIN customer_dim cd ON sf.customer_id = cd.customer_id
JOIN payment_dim pm ON sf.payment_id = pm.payment_id
GROUP BY cd.name, cd.city, pm.payment_method
ORDER BY total_spent DESC;
```

**Query 3: Monthly Sales Trends**
```sql
SELECT 
    dd.year,
    dd.month,
    pd.category,
    COUNT(*) AS num_transactions,
    SUM(sf.purchase_amount) AS monthly_revenue,
    AVG(sf.purchase_amount) AS avg_transaction
FROM sales_fact sf
JOIN date_dim dd ON sf.date_id = dd.date_id
JOIN product_dim pd ON sf.product_id = pd.product_id
GROUP BY dd.year, dd.month, pd.category
ORDER BY dd.year, dd.month, monthly_revenue DESC;
```

---

## Technology Stack

- **Python 3.8+**: ETL pipeline orchestration
- **MySQL 8.0+**: Data warehouse
- **MongoDB Atlas**: NoSQL source (cloud)
- **Jupyter Notebook**: Interactive ETL development
- **Libraries**: pandas, pymongo, mysql-connector-python, SQLAlchemy

---

## Key Features

### Data Quality
- Duplicate removal in customer and product dimensions
- NULL foreign key validation (0 NULLs in final fact table)
- Referential integrity checks between dimensions and fact table
- Data consistency validation between sales and dimension tables

### Transformations
- Surrogate key generation for all dimensions
- Name field combination (first_name + last_name → name)
- Loyalty status derivation (loyalty_tier → loyalty_member Yes/No)
- Date dimension with year, month, day components
- Payment method extraction as separate dimension

### Query Capabilities
- 7 comprehensive analytical queries
- All queries join 3-4 tables
- Multiple aggregation functions (SUM, COUNT, AVG, MAX)
- Geographic, temporal, and categorical analysis
- Customer segmentation and loyalty analysis

---

## Expected Results

After running the ETL pipeline:
- `date_dim`: 365 rows
- `customer_dim`: 166 rows
- `product_dim`: 61 rows
- `payment_dim`: 2 rows
- `sales_fact`: 3,400 rows

**Data Integrity**:
- 0 NULL foreign keys in sales_fact
- All sales transactions have matching customers, products, dates, and payment methods
- Total revenue: $318,160.00 (2023)

---

## Troubleshooting

**MongoDB connection error**: 
- Verify MONGODB_URI in `.env`
- Replace `<password>` with actual password
- Check Network Access in Atlas allows 0.0.0.0/0
- Verify cluster name format: `cluster.xxxxx.mongodb.net`

**MySQL connection refused**:
- Ensure MySQL is running: `brew services start mysql` (Mac)
- Verify credentials in `.env`
- Check database exists: `CREATE DATABASE ds2002_retail;`

**Module not found**:
```bash
pip install -r requirements.txt
```

**Empty MongoDB**:
```bash
python scripts/setup_mongodb.py
```

**NULL foreign keys in sales_fact**:
- Verify all CSV files are present in `data/` folder
- Run `setup_mongodb.py` before ETL notebook
- Check that products.csv has 61 products (not 50)

---

## Validation Steps

1. **Check table row counts**:
```sql
SELECT TABLE_NAME, TABLE_ROWS 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'ds2002_retail';
```

2. **Verify foreign key integrity**:
```sql
SELECT COUNT(*) FROM sales_fact 
WHERE customer_id IS NULL OR product_id IS NULL;
-- Should return 0
```

3. **Test sample query**:
```sql
SELECT pd.category, COUNT(*), SUM(sf.purchase_amount)
FROM sales_fact sf
JOIN product_dim pd ON sf.product_id = pd.product_id
GROUP BY pd.category;
```

---

## Deployment

**Current**: Local MySQL + Cloud MongoDB Atlas + Local Python/Jupyter

**Components**:
- MySQL database: ds2002_retail (local)
- MongoDB Atlas: retail_db.suppliers (cloud)
- ETL execution: Jupyter Notebook (local)
- Query output: CSV export (local)

---

## Data Sources

### CSV Files
- **Fashion_Retail_Sales.csv**: Transaction-level sales data with customer references, items, amounts, dates, ratings, and payment methods
- **customers.csv**: Customer profiles with demographics, contact info, loyalty status, and registration dates
- **products.csv**: Product catalog with categories, brands, materials, pricing, inventory, and supplier information

### MongoDB Atlas
- **suppliers collection**: Supplier data with inventory levels and country information
- Demonstrates NoSQL data extraction and integration into relational warehouse

### Programmatic Generation
- **Date dimension**: Generated in Python with year, month, day components for time-series analysis

---

## Project Highlights

✅ **Complete ETL Pipeline**: Extract, transform, load with validation  
✅ **Multi-Source Integration**: CSV + MongoDB + Python generation  
✅ **Star Schema Design**: Optimized for analytical queries  
✅ **Data Quality**: 0 NULL foreign keys, duplicate removal, integrity checks  
✅ **Comprehensive Analysis**: 7 queries covering sales, customers, products, time, geography  
✅ **Professional Documentation**: Clear setup instructions, troubleshooting, validation steps  

---

## Author

**Simon Alam**  
University of Virginia  
DS-2002 - Data Science Systems

---

## Acknowledgments

- Dataset: Fashion retail sales data with customer demographics and product catalog
- Star schema design based on Kimball dimensional modeling methodology
- MongoDB Atlas for cloud NoSQL data source
- Project structure inspired by industry ETL best practices
