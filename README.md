# Fashion Retail Sales Data Mart - ETL Pipeline

**DS-2002 Project 1: Midterm**  
**Author**: Simon Alam  
**Institution**: University of Virginia  
**Course**: DS-2002 - Data Science Systems

A dimensional data mart ETL pipeline that extracts data from multiple heterogeneous sources (CSV files, MongoDB Atlas, programmatic generation), transforms it through data quality operations and surrogate key generation, and loads into a MySQL star schema optimized for analytical queries on fashion retail sales.

---

## Business Process

This project models **fashion retail sales transactions** as a dimensional data mart. The business process captures customer purchases of fashion products, tracking:
- What products were purchased (item, category, brand)
- Who purchased them (customer demographics, loyalty status)
- When purchases occurred (date, time hierarchy)
- How payment was made (payment method)
- Transaction details (purchase amount, customer satisfaction ratings)

This enables post-hoc analysis of sales performance, customer behavior, product trends, and revenue patterns over time.

---

## Project Requirements Compliance

### Dimensional Data Mart Design
✅ **Date Dimension**: Programmatically generated with time hierarchy (year, month, day) for temporal analysis  
✅ **Additional Dimensions**: Customer, Product, and Payment dimensions model business entities  
✅ **Fact Table**: sales_fact captures transaction-level measures (purchase_amount, review_rating)  
✅ **Star Schema**: Optimized for OLAP queries with denormalized dimensions surrounding fact table

### Data Source Requirements (3 of 4 sources)
✅ **File System**: CSV files (Fashion_Retail_Sales.csv, customers.csv, products.csv) - 3,400+ records  
✅ **NoSQL Database**: MongoDB Atlas cloud instance with suppliers collection  
✅ **Programmatic Generation**: Python-generated date dimension with complete time hierarchy

### ETL Transformations
✅ **Column Modifications**: 
- Combine first_name + last_name → name (reducing columns)
- Derive loyalty_member from loyalty_tier (data enrichment)
- Extract payment methods into separate dimension
- Generate surrogate keys for all dimensions

✅ **Data Quality**: Duplicate removal, NULL validation, referential integrity checks

### SQL Query Requirements
✅ **Multi-table JOINs**: All 7 queries join 3-4 tables (fact + multiple dimensions)  
✅ **Aggregations**: Extensive use of SUM, COUNT, AVG, MAX across queries  
✅ **Grouping Operations**: GROUP BY on customer segments, product categories, time periods, geography

---

## Architecture Overview

### ETL Pipeline Flow

```
┌─────────────────────┐
│   DATA SOURCES      │
├─────────────────────┤
│ CSV Files (Local)   │─┐
│ - Sales (3,400)     │ │
│ - Customers (166)   │ │
│ - Products (61)     │ ├──→ EXTRACT
│                     │ │
│ MongoDB Atlas       │ │
│ - Suppliers (4)     │─┘
│                     │
│ Python Generation   │─┐
│ - Date Dim (365)    │ │
└─────────────────────┘ │
                        ├──→ TRANSFORM
┌─────────────────────┐ │   - Generate surrogate keys
│  TRANSFORMATIONS    │←┘   - Combine name fields
├─────────────────────┤     - Derive loyalty status
│ - Data cleaning     │     - Validate integrity
│ - Key generation    │     - Join operations
│ - Field derivation  │
│ - Integrity checks  │
└─────────────────────┘
        │
        ├──→ LOAD
        ↓
┌─────────────────────┐
│  MySQL Data Mart    │
│  (Star Schema)      │
├─────────────────────┤
│ ┌─────────────────┐ │
│ │   date_dim      │ │
│ │      (365)      │ │
│ └────────┬────────┘ │
│          │          │
│   ┌──────┼──────┐   │
│   │      │      │   │
│ ┌─▼──┐ ┌─▼──┐ ┌─▼─┐│
│ │cust││fact││prod││
│ │dim ││tbl ││dim ││
│ │(166)││3400││(61)││
│ └────┘ └─┬──┘ └───┘│
│          │          │
│      ┌───▼───┐      │
│      │payment│      │
│      │  (2)  │      │
│      └───────┘      │
└─────────────────────┘
```

---

## Star Schema Design

### Fact Table: `sales_fact`
**Grain**: One row per sales transaction

| Column | Type | Description |
|--------|------|-------------|
| sale_id | INT | Auto-increment primary key |
| customer_id | INT | FK to customer_dim |
| product_id | INT | FK to product_dim |
| date_id | INT | FK to date_dim |
| payment_id | INT | FK to payment_dim |
| purchase_amount | DECIMAL(10,2) | Transaction amount (measure) |
| review_rating | DECIMAL(4,2) | Customer satisfaction rating (measure) |

**Record Count**: 3,400 transactions

### Dimension: `date_dim`
**Purpose**: Enable temporal analysis across multiple time hierarchies

| Column | Type | Description |
|--------|------|-------------|
| date_id | INT | Surrogate key |
| purchase_date | DATE | Actual transaction date |
| year | INT | Extracted year |
| month | INT | Extracted month |
| day | INT | Extracted day |

**Record Count**: 365 dates (covering sales period)

### Dimension: `customer_dim`
**Purpose**: Customer demographics and loyalty information

| Column | Type | Description |
|--------|------|-------------|
| customer_id | INT | Surrogate key |
| customer_reference_id | VARCHAR(50) | Natural business key |
| name | VARCHAR(100) | Combined first + last name |
| email | VARCHAR(100) | Contact information |
| city | VARCHAR(30) | Geographic location |
| loyalty_member | VARCHAR(10) | Derived from tier (Yes/No) |
| age | INT | Customer age |

**Record Count**: 166 customers

### Dimension: `product_dim`
**Purpose**: Product catalog with supplier information

| Column | Type | Description |
|--------|------|-------------|
| product_id | INT | Surrogate key |
| item_name | VARCHAR(50) | Product name |
| category | VARCHAR(30) | Product category |
| brand | VARCHAR(30) | Brand name |
| material | VARCHAR(30) | Fabric/material type |
| season | VARCHAR(15) | Seasonal collection |
| gender_target | VARCHAR(10) | Target demographic |
| base_price | DECIMAL(8,2) | List price |
| stock_quantity | INT | Inventory level |
| supplier_name | VARCHAR(30) | Supplier reference |
| product_introduction_date | DATE | Launch date |

**Record Count**: 61 products

### Dimension: `payment_dim`
**Purpose**: Payment method classification

| Column | Type | Description |
|--------|------|-------------|
| payment_id | INT | Surrogate key |
| payment_method | VARCHAR(20) | Payment type |

**Record Count**: 2 payment methods (Credit Card, PayPal)

---

## Technology Stack

**ETL & Processing**:
- Python 3.8+ (pandas, pymongo, mysql-connector-python, sqlalchemy)
- Jupyter Notebook (interactive development)

**Data Warehouse**:
- MySQL 8.0+ (local OLAP database)

**Source Systems**:
- CSV files (local file system)
- MongoDB Atlas (cloud NoSQL database)

**Development Environment**:
- VS Code (code editor)
- Git/GitHub (version control)

---

## Installation & Setup

### Prerequisites
- Python 3.8 or higher
- MySQL 8.0 or higher
- MongoDB Atlas account (free M0 tier)
- Git (for cloning repository)

### Step 1: Clone Repository
```bash
git clone https://github.com/yourusername/PROJECT1.git
cd PROJECT1
```

### Step 2: Create Virtual Environment
```bash
python3 -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
```

### Step 3: Install Dependencies
```bash
pip install -r requirements.txt
```

**Required packages**:
```
pandas==2.1.0
pymongo==4.5.0
mysql-connector-python==8.0.33
sqlalchemy==2.0.21
jupyter==1.0.0
```

### Step 4: Configure Environment Variables
```bash
cp .env.example .env
```

Edit `.env` with your credentials:
```env
MYSQL_HOST=localhost
MYSQL_USER=root
MYSQL_PASSWORD=your_mysql_password
MYSQL_DATABASE=ds2002_retail

MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/
```

### Step 5: Setup MongoDB Atlas
1. Create account at https://www.mongodb.com/cloud/atlas
2. Create free M0 cluster
3. Navigate to Database Access → Add Database User
4. Navigate to Network Access → Add IP Address (allow 0.0.0.0/0 for development)
5. Get connection string from Connect → Connect your application
6. Update `MONGODB_URI` in `.env`

### Step 6: Initialize MongoDB Source Data
```bash
python scripts/setup_mongodb.py
```

**Expected output**:
```
============================================================
MongoDB Atlas Setup
============================================================

1. Connecting to MongoDB Atlas...
   ✓ Connected successfully

2. Loading supplier data from JSON file...
   ✓ Loaded 4 suppliers from JSON

3. Inserting supplier data...
   ✓ Inserted 4 supplier records

✅ MongoDB supplier collection initialized successfully!
```

### Step 7: Create MySQL Database
```bash
mysql -u root -p
```

In MySQL prompt:
```sql
CREATE DATABASE ds2002_retail;
USE ds2002_retail;
SOURCE scripts/schema.sql;
EXIT;
```

### Step 8: Run ETL Pipeline
```bash
jupyter notebook scripts/etl_pipeline.ipynb
```

Execute all cells in the notebook. Expected results:
- ✓ 3,400 sales records extracted
- ✓ 166 customers processed
- ✓ 61 products loaded
- ✓ 4 suppliers retrieved from MongoDB
- ✓ 365 date records generated
- ✓ All dimensions loaded to MySQL
- ✓ 3,400 fact records inserted with 0 NULL foreign keys

### Step 9: Execute Analytical Queries
```bash
mysql -u root -p ds2002_retail < scripts/queries.sql
```

### Step 10: Export Query Results
```bash
python scripts/export_query_results.py
```

Results saved to: `output/query_results.csv`

---

## Project Structure

```
PROJECT1/
├── data/                               # Source data files
│   ├── Fashion_Retail_Sales.csv        # 3,400 transaction records
│   ├── customers.csv                   # 166 customer profiles
│   ├── products.csv                    # 61 product catalog entries
│   └── mongo_source.json               # 4 supplier records for MongoDB
│
├── scripts/                            # ETL code and SQL
│   ├── etl_pipeline.ipynb              # Main ETL notebook (Extract/Transform/Load)
│   ├── setup_mongodb.py                # MongoDB Atlas initialization script
│   ├── schema.sql                      # DDL for star schema creation
│   ├── queries.sql                     # 7 analytical queries
│   ├── usedb.sql                       # Database selection helper
│   └── export_query_results.py         # Query result export to CSV
│
├── output/                             # Generated artifacts
│   └── query_results.csv               # Query output for analysis
│
├── .env                                # Environment variables (not in repo)
├── .env.example                        # Template for .env
├── .gitignore                          # Git exclusion rules
├── requirements.txt                    # Python dependencies
└── README.md                           # This file
```

---

## ETL Implementation Details

### Extract Phase

**CSV File Extraction**:
```python
# Load sales transactions
df_sales = pd.read_csv('../data/Fashion_Retail_Sales.csv')  # 3,400 rows

# Load customer profiles
df_customers = pd.read_csv('../data/customers.csv')  # 166 rows

# Load product catalog
df_products = pd.read_csv('../data/products.csv')  # 61 rows
```

**MongoDB Extraction**:
```python
# Connect to MongoDB Atlas
atlas_url = "mongodb+srv://user:pass@cluster.mongodb.net/retail_db"
client = pymongo.MongoClient(atlas_url)
db = client["retail_db"]

# Extract suppliers collection
df_suppliers = pd.DataFrame(list(db["suppliers"].find()))  # 4 documents
```

**Programmatic Date Generation**:
```python
# Generate date dimension
dates = df_sales[['Date Purchase']].drop_duplicates()
dates['date_id'] = range(1, len(dates) + 1)
dates['purchase_date'] = pd.to_datetime(dates['Date Purchase'])
dates['year'] = dates['purchase_date'].dt.year
dates['month'] = dates['purchase_date'].dt.month
dates['day'] = dates['purchase_date'].dt.day
```

### Transform Phase

**Data Quality Operations**:
- Remove duplicate customers: `df_customers.drop_duplicates(subset=['customer_reference_id'])`
- Remove duplicate products: `df_products.drop_duplicates(subset=['item_name'])`
- Handle NULL review ratings: Retain NULLs for analytical flexibility

**Surrogate Key Generation**:
```python
# Generate customer surrogate keys
dim_customer['customer_id'] = range(1, len(dim_customer) + 1)

# Generate date surrogate keys
dim_date['date_id'] = range(1, len(dim_date) + 1)

# Payment dimension surrogate keys
dim_payment['payment_id'] = range(1, len(dim_payment) + 1)
```

**Column Modifications**:
```python
# Combine name fields (reducing columns)
dim_customer['name'] = dim_customer['first_name'] + ' ' + dim_customer['last_name']

# Derive loyalty status
dim_customer['loyalty_member'] = dim_customer['loyalty_tier'].apply(
    lambda x: 'Yes' if x in ['Gold', 'Platinum'] else 'No'
)
```

**Foreign Key Lookup**:
```python
# Join to get customer_id
fact_sales = fact_sales.merge(
    dim_customer[['customer_id', 'customer_reference_id']],
    left_on='Customer Reference ID',
    right_on='customer_reference_id',
    how='left'
)

# Join to get product_id
fact_sales = fact_sales.merge(
    dim_product[['product_id', 'item_name']],
    left_on='Item Purchased',
    right_on='item_name',
    how='left'
)

# Validate: 0 NULL foreign keys
assert fact_sales['customer_id'].isna().sum() == 0
assert fact_sales['product_id'].isna().sum() == 0
```

### Load Phase

**Dimension Loading** (order matters for FK constraints):
```python
# Load dimensions first
dim_date.to_sql('date_dim', engine, if_exists='replace', index=False)
dim_customer.to_sql('customer_dim', engine, if_exists='replace', index=False)
dim_product.to_sql('product_dim', engine, if_exists='replace', index=False)
dim_payment.to_sql('payment_dim', engine, if_exists='replace', index=False)

# Load fact table last
fact_sales.to_sql('sales_fact', engine, if_exists='replace', index=False)
```

---

## Analytical Queries

All queries demonstrate multi-table JOINs (3-4 tables) with aggregation functions required by project specifications.

### Query 1: Product Category Performance Analysis
**Tables**: sales_fact, product_dim, date_dim (3 tables)  
**Aggregations**: COUNT, SUM, AVG

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

### Query 2: Customer Spending by Segment & Payment Method
**Tables**: sales_fact, customer_dim, payment_dim (3 tables)  
**Aggregations**: COUNT, SUM, AVG, MAX

```sql
SELECT 
    cd.name, 
    cd.city,
    pm.payment_method,
    COUNT(*) AS num_purchases,
    SUM(sf.purchase_amount) AS total_spent,
    AVG(sf.purchase_amount) AS avg_purchase,
    MAX(sf.purchase_amount) AS largest_purchase
FROM sales_fact sf
JOIN customer_dim cd ON sf.customer_id = cd.customer_id
JOIN payment_dim pm ON sf.payment_id = pm.payment_id
GROUP BY cd.name, cd.city, pm.payment_method
HAVING num_purchases >= 10
ORDER BY total_spent DESC;
```

### Query 3: Product Category Sales Across Payment Methods
**Tables**: sales_fact, product_dim, customer_dim, payment_dim (4 tables)  
**Aggregations**: COUNT, SUM, AVG

```sql
SELECT 
    pd.category,
    pd.brand,
    pm.payment_method,
    COUNT(DISTINCT cd.customer_id) AS unique_customers,
    COUNT(*) AS total_sales,
    SUM(sf.purchase_amount) AS revenue,
    AVG(sf.review_rating) AS avg_rating
FROM sales_fact sf
JOIN product_dim pd ON sf.product_id = pd.product_id
JOIN customer_dim cd ON sf.customer_id = cd.customer_id
JOIN payment_dim pm ON sf.payment_id = pm.payment_id
WHERE sf.review_rating IS NOT NULL
GROUP BY pd.category, pd.brand, pm.payment_method
ORDER BY revenue DESC;
```

### Query 4: Monthly Sales Trends by Category
**Tables**: sales_fact, date_dim, product_dim (3 tables)  
**Aggregations**: COUNT, SUM, AVG

```sql
SELECT 
    dd.year,
    dd.month,
    pd.category,
    COUNT(*) AS num_transactions,
    SUM(sf.purchase_amount) AS monthly_revenue,
    AVG(sf.purchase_amount) AS avg_transaction,
    COUNT(DISTINCT pd.product_id) AS unique_products_sold
FROM sales_fact sf
JOIN date_dim dd ON sf.date_id = dd.date_id
JOIN product_dim pd ON sf.product_id = pd.product_id
GROUP BY dd.year, dd.month, pd.category
ORDER BY dd.year, dd.month, monthly_revenue DESC;
```

### Query 5: Customer Loyalty & Geographic Analysis
**Tables**: sales_fact, customer_dim, product_dim, date_dim (4 tables)  
**Aggregations**: COUNT, SUM, AVG, derived metric

```sql
SELECT 
    cd.loyalty_member,
    cd.city,
    pd.category,
    COUNT(DISTINCT cd.customer_id) AS num_customers,
    COUNT(*) AS total_purchases,
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
```

### Query 6: Geographic Sales Distribution
**Tables**: sales_fact, customer_dim, product_dim (3 tables)  
**Aggregations**: COUNT, SUM, AVG, MAX

```sql
SELECT 
    cd.city,
    cd.loyalty_member,
    COUNT(DISTINCT cd.customer_id) AS num_customers,
    COUNT(*) AS num_sales,
    SUM(sf.purchase_amount) AS total_revenue,
    AVG(sf.purchase_amount) AS avg_sale,
    MAX(sf.purchase_amount) AS largest_sale
FROM sales_fact sf
JOIN customer_dim cd ON sf.customer_id = cd.customer_id
JOIN product_dim pd ON sf.product_id = pd.product_id
GROUP BY cd.city, cd.loyalty_member
ORDER BY total_revenue DESC
LIMIT 15;
```

### Query 7: Payment Preference by Category & Time
**Tables**: sales_fact, payment_dim, product_dim, date_dim (4 tables)  
**Aggregations**: COUNT, SUM, AVG

```sql
SELECT 
    pm.payment_method,
    pd.category,
    dd.year,
    COUNT(*) AS num_transactions,
    SUM(sf.purchase_amount) AS total_amount,
    AVG(sf.purchase_amount) AS avg_amount
FROM sales_fact sf
JOIN payment_dim pm ON sf.payment_id = pm.payment_id
JOIN product_dim pd ON sf.product_id = pd.product_id
JOIN date_dim dd ON sf.date_id = dd.date_id
GROUP BY pm.payment_method, pd.category, dd.year
ORDER BY total_amount DESC;
```

---

## Data Integrity & Validation

### Foreign Key Integrity Check
```sql
-- Verify no NULL foreign keys (requirement for data quality)
SELECT COUNT(*) FROM sales_fact 
WHERE customer_id IS NULL 
   OR product_id IS NULL 
   OR date_id IS NULL 
   OR payment_id IS NULL;
-- Expected: 0
```

### Row Count Validation
```sql
SELECT TABLE_NAME, TABLE_ROWS 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'ds2002_retail'
ORDER BY TABLE_NAME;
```

**Expected Results**:
| Table | Rows |
|-------|------|
| customer_dim | 166 |
| date_dim | 365 |
| payment_dim | 2 |
| product_dim | 61 |
| sales_fact | 3,400 |

### Data Quality Metrics
- **Duplicate Removal**: 0 duplicate customers or products in dimensions
- **NULL Foreign Keys**: 0 NULL foreign keys in fact table
- **Referential Integrity**: 100% of fact records join to all dimensions
- **Total Revenue**: $318,160.00 (2023 transactions)
- **Average Transaction**: $93.58
- **Customer Coverage**: All 166 customers have transaction history

---

## Troubleshooting

### MongoDB Connection Issues

**Error**: `ServerSelectionTimeoutError`

**Solution**:
1. Verify MongoDB Atlas cluster is running (not paused)
2. Check Network Access in Atlas allows your IP or 0.0.0.0/0
3. Verify connection string format:
   ```
   mongodb+srv://username:password@cluster.subnet.mongodb.net/dbname
   ```
4. Test connection: `python scripts/setup_mongodb.py`

### MySQL Connection Refused

**Error**: `Can't connect to MySQL server`

**Solution**:
```bash
# Mac - Start MySQL
brew services start mysql

# Linux - Start MySQL
sudo systemctl start mysql

# Verify MySQL is running
mysql -u root -p -e "SELECT VERSION();"
```

### Missing Python Packages

**Error**: `ModuleNotFoundError: No module named 'pandas'`

**Solution**:
```bash
# Ensure virtual environment is activated
source .venv/bin/activate  # or .venv\Scripts\activate on Windows

# Reinstall dependencies
pip install -r requirements.txt
```

### NULL Foreign Keys in Fact Table

**Error**: Sales fact table has NULL customer_id or product_id

**Solution**:
1. Verify products.csv has 61 products (not 50) - use fixed version
2. Ensure all CSV files are in `data/` directory
3. Run `python scripts/setup_mongodb.py` before ETL notebook
4. Re-run ETL pipeline from beginning

### Query Results Empty

**Error**: Queries return no rows

**Solution**:
```sql
-- Check if fact table has data
SELECT COUNT(*) FROM sales_fact;

-- Verify date range
SELECT MIN(purchase_date), MAX(purchase_date) FROM date_dim;

-- If dates don't include 2023, modify query WHERE clause
WHERE dd.year IN (2022, 2023)
```

---

## Deployment & Execution

### Current Architecture
- **Data Warehouse**: MySQL 8.0 (local installation)
- **NoSQL Source**: MongoDB Atlas M0 cluster (cloud)
- **ETL Execution**: Jupyter Notebook (local)
- **Code Repository**: GitHub (version control)

### Execution Order
1. `setup_mongodb.py` - Initialize MongoDB source (one-time)
2. `schema.sql` - Create database tables (one-time)
3. `etl_pipeline.ipynb` - Extract, transform, load data (repeatable)
4. `queries.sql` - Execute analytical queries (repeatable)
5. `export_query_results.py` - Export results to CSV (optional)

### Performance Considerations
- **ETL Runtime**: ~2-3 minutes for full pipeline
- **Query Performance**: All queries execute in <1 second with proper indexing
- **Database Size**: ~5MB for complete data mart
- **Scalability**: Star schema supports millions of fact records with appropriate indexing

---

## Project Deliverables Checklist

✅ **Dimensional Data Mart**: Star schema with 1 fact + 4 dimensions  
✅ **Date Dimension**: Programmatically generated with time hierarchy  
✅ **2+ Dimensions**: Customer, Product, Payment dimensions  
✅ **Business Process**: Fashion retail sales transaction modeling  
✅ **3 Data Sources**: CSV files + MongoDB Atlas + Python generation  
✅ **ETL Pipeline**: Complete extract, transform, load implementation  
✅ **Column Modifications**: Name combination, loyalty derivation, dimension extraction  
✅ **SQL Queries**: 7 queries joining 3-4 tables with aggregations  
✅ **Data Submission**: All source CSV files and mongo_source.json included  
✅ **Code Submission**: All Python scripts and SQL files in GitHub repository  
✅ **Documentation**: Comprehensive README with setup and deployment instructions

---

## Future Enhancements

**Potential Improvements**:
1. Implement slowly changing dimensions (SCD Type 2) for customer loyalty tier history
2. Add real-time streaming ingestion from e-commerce transaction logs
3. Integrate product review sentiment analysis from external APIs
4. Implement incremental ETL loads instead of full refresh
5. Add data quality monitoring and alerting
6. Create Tableau/Power BI dashboards for business users
7. Deploy to cloud (AWS RDS for MySQL, MongoDB Atlas already cloud-based)
8. Implement data lineage tracking and metadata management

---

## Learning Outcomes

This project demonstrates:
- **OLTP vs OLAP**: Understanding transactional vs analytical database design
- **Dimensional Modeling**: Star schema design following Kimball methodology
- **ETL Development**: Practical implementation of data integration pipelines
- **Multi-Source Integration**: Combining relational, NoSQL, and file-based data
- **Data Quality**: Implementing validation, deduplication, and integrity checks
- **SQL Proficiency**: Complex analytical queries with multi-table joins
- **Cloud Services**: MongoDB Atlas integration
- **Version Control**: Git/GitHub for collaborative development
- **Documentation**: Professional technical writing and process documentation

---

## References & Resources

**Datasets**:
- Fashion retail sales data (Kaggle-sourced, anonymized)
- Customer demographic profiles (synthetically generated)
- Product catalog (curated for fashion retail domain)

**Technologies**:
- [MySQL Documentation](https://dev.mysql.com/doc/)
- [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
- [Pandas Documentation](https://pandas.pydata.org/docs/)
- [SQLAlchemy Documentation](https://docs.sqlalchemy.org/)

**Methodologies**:
- Kimball Dimensional Modeling (The Data Warehouse Toolkit)
- ETL Best Practices (Ralph Kimball)
- Star Schema Design Patterns

---

## Author & Contact

**Simon Alam**  
University of Virginia  
DS-2002 - Data Science Systems  
Fall 2024

**Repository**: [github.com/yourusername/PROJECT1](https://github.com/simonalam/Project1)

---

## License & Acknowledgments

This project was created for academic purposes as part of DS-2002 coursework at the University of Virginia. 

**Acknowledgments**:
- Professor and teaching staff for project guidance
- Kaggle community for public datasets
- MongoDB Atlas for free cloud database hosting
- Open-source Python data science community

---

*Last Updated: October 2025*