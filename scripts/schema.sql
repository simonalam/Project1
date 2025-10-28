CREATE DATABASE IF NOT EXISTS ds2002_retail;
USE ds2002_retail;

CREATE TABLE customer_dim (
    customer_id INT PRIMARY KEY,
    customer_reference_id VARCHAR(50) UNIQUE,
    name VARCHAR(50),
    email VARCHAR(100),
    city VARCHAR(30),
    loyalty_member VARCHAR(10),
    age INT
);

CREATE TABLE product_dim (
    product_id INT PRIMARY KEY,
    item_name VARCHAR(50),
    category VARCHAR(30),
    brand VARCHAR(30),
    material VARCHAR(30),
    season VARCHAR(15),
    gender_target VARCHAR(10),
    base_price DECIMAL(8,2),
    stock_quantity INT,
    supplier_name VARCHAR(30),
    product_introduction_date DATE
);

CREATE TABLE date_dim (
    date_id INT PRIMARY KEY,
    purchase_date DATE,
    year INT,
    month INT,
    day INT
);

CREATE TABLE payment_dim (
    payment_id INT PRIMARY KEY,
    payment_method VARCHAR(20)
);

CREATE TABLE sales_fact (
    sale_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    date_id INT,
    payment_id INT,
    purchase_amount DECIMAL(10,2),
    review_rating DECIMAL(4,2),
    FOREIGN KEY (customer_id) REFERENCES customer_dim(customer_id),
    FOREIGN KEY (product_id) REFERENCES product_dim(product_id),
    FOREIGN KEY (date_id) REFERENCES date_dim(date_id),
    FOREIGN KEY (payment_id) REFERENCES payment_dim(payment_id)
);
