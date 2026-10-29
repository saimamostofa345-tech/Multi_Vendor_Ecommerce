-- ==============================================================================
-- Project: Multi-Vendor SaaS E-Commerce Database Management System
-- Description: Complete SQL script containing Schema Creation (DDL),
--              Data Manipulation (DML), and Analytical Queries (DQL).
-- Dialect: MySQL / MariaDB (Standard ANSI SQL compatible)
-- ==============================================================================

-- Create Database if not exists and use it
CREATE DATABASE IF NOT EXISTS ecommerce_saas;
USE ecommerce_saas;

-- Drop tables if they already exist (in reverse order of foreign key dependencies)
DROP TABLE IF EXISTS payment;
DROP TABLE IF EXISTS order_item;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS product_category;
DROP TABLE IF EXISTS product;
DROP TABLE IF EXISTS category;
DROP TABLE IF EXISTS vendor;
DROP TABLE IF EXISTS subscription_plan;


-- ==============================================================================
-- PART B: SQL DDL (Table Creation)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- Table 1: SubscriptionPlan
-- Stores vendor subscription tier details (name, pricing, duration, features).
-- ------------------------------------------------------------------------------
CREATE TABLE subscription_plan (
    plan_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    price DECIMAL(10, 2) NOT NULL,
    duration VARCHAR(50) NOT NULL,              -- e.g., '1 Month', '1 Year'
    features TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------------------------------------
-- [Question 3]: Table 2: Vendor
-- Primary Key: vendor_id
-- Foreign Key: plan_id referencing subscription_plan(plan_id)
-- ------------------------------------------------------------------------------
CREATE TABLE vendor (
    vendor_id INT AUTO_INCREMENT PRIMARY KEY,
    business_name VARCHAR(150) NOT NULL,
    contact_person VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(25) NOT NULL,
    address TEXT NOT NULL,
    plan_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_vendor_subscription_plan 
        FOREIGN KEY (plan_id) REFERENCES subscription_plan(plan_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- ------------------------------------------------------------------------------
-- Table 3: Category
-- Stores product categories (e.g., Electronics, Fashion, Home & Living).
-- ------------------------------------------------------------------------------
CREATE TABLE category (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------------------------------------
-- Table 4: Product
-- Stores products listed by vendors. Belongs to a single vendor.
-- ------------------------------------------------------------------------------
CREATE TABLE product (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    vendor_id INT NOT NULL,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_product_status CHECK (status IN ('active', 'inactive')),
    CONSTRAINT fk_product_vendor 
        FOREIGN KEY (vendor_id) REFERENCES vendor(vendor_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- ------------------------------------------------------------------------------
-- [Question 4]: Table 5: ProductCategory
-- Junction table handling the M:N (many-to-many) relationship between Product and Category.
-- Composite Primary Key: (product_id, category_id)
-- Foreign Keys: product_id -> product, category_id -> category
-- ------------------------------------------------------------------------------
CREATE TABLE product_category (
    product_id INT NOT NULL,
    category_id INT NOT NULL,
    PRIMARY KEY (product_id, category_id),
    CONSTRAINT fk_pc_product 
        FOREIGN KEY (product_id) REFERENCES product(product_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_pc_category 
        FOREIGN KEY (category_id) REFERENCES category(category_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- ------------------------------------------------------------------------------
-- Table 6: Customer
-- Stores customer registration details.
-- ------------------------------------------------------------------------------
CREATE TABLE customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(25) NOT NULL,
    address TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------------------------------------
-- Table 7: Orders
-- Stores orders placed by customers.
-- Note: 'orders' is used instead of reserved keyword 'order'.
-- ------------------------------------------------------------------------------
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    order_status VARCHAR(50) NOT NULL DEFAULT 'Pending',
    CONSTRAINT fk_orders_customer 
        FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- ------------------------------------------------------------------------------
-- Table 8: OrderItem
-- Tracks each product in an order along with quantity, unit price, and subtotal.
-- ------------------------------------------------------------------------------
CREATE TABLE order_item (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    CONSTRAINT fk_orderitem_order 
        FOREIGN KEY (order_id) REFERENCES orders(order_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_orderitem_product 
        FOREIGN KEY (product_id) REFERENCES product(product_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- ------------------------------------------------------------------------------
-- Table 9: Payment
-- Stores payment transaction details for every order.
-- ------------------------------------------------------------------------------
CREATE TABLE payment (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL UNIQUE,
    method VARCHAR(50) NOT NULL,                -- e.g., 'Card', 'Bkash', 'PayPal', 'Cash on Delivery'
    amount DECIMAL(10, 2) NOT NULL,
    payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_status VARCHAR(50) NOT NULL DEFAULT 'Completed',
    CONSTRAINT fk_payment_order 
        FOREIGN KEY (order_id) REFERENCES orders(order_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);


-- ==============================================================================
-- INITIAL / SEED DATA SETUP
-- (Required so that foreign keys and query tests function cleanly)
-- ==============================================================================

-- Insert Subscription Plans
INSERT INTO subscription_plan (name, price, duration, features) VALUES
('Basic', 999.00, '1 Month', 'Up to 50 product listings, standard support, 5% transaction fee'),
('Pro', 2499.00, '1 Month', 'Up to 250 product listings, priority support, 3% transaction fee'),
('Enterprise', 5999.00, '1 Year', 'Unlimited listings, dedicated account manager, 1.5% transaction fee');

-- Insert Initial Categories
INSERT INTO category (name, description) VALUES
('Electronics', 'Electronic devices, gadgets, computers, and accessories'),
('Fashion', 'Apparel, clothing, footwear, and accessories'),
('Home & Kitchen', 'Home appliances, decor, furniture, and kitchenware');

-- Insert Sample Customers
INSERT INTO customer (name, email, phone, address) VALUES
('Karim Uddin', 'karim.uddin@example.com', '01811112233', 'House 12, Road 5, Dhanmondi, Dhaka'),
('oldcustomer@gmail.com_user', 'oldcustomer@gmail.com', '01922223344', 'Chittagong, Bangladesh'),
('Sarah Ahmed', 'sarah.ahmed@example.com', '01733334455', 'Gulshan 2, Dhaka, Bangladesh');

-- Insert Sample Vendor for query demonstration
INSERT INTO vendor (business_name, contact_person, email, phone, address, plan_id) VALUES
('Apex Gadgets', 'Tanvir Hasan', 'tanvir@apexgadgets.com', '01987654321', 'Motijheel, Dhaka', 2);


-- ==============================================================================
-- PART C: SQL DML (Insert / Update / Delete)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- [Question 5]:
-- Insert a new vendor named "SmartTech Ltd.", with contact person Rahim Khan,
-- email rahim@smarttech.com, phone 017XXXXXXXX, address Dhaka, Bangladesh,
-- under the Basic plan.
-- ------------------------------------------------------------------------------
INSERT INTO vendor (business_name, contact_person, email, phone, address, plan_id)
SELECT 
    'SmartTech Ltd.', 
    'Rahim Khan', 
    'rahim@smarttech.com', 
    '01712345678', 
    'Dhaka, Bangladesh', 
    plan_id
FROM subscription_plan 
WHERE name = 'Basic';


-- ------------------------------------------------------------------------------
-- [Question 6]:
-- Insert a product called "Laptop" under the Electronics category, price 75,000,
-- stock 10, status active, belonging to SmartTech Ltd.
-- ------------------------------------------------------------------------------
-- Step 6a: Insert product into the product table
INSERT INTO product (vendor_id, name, description, price, stock_quantity, status)
SELECT 
    v.vendor_id,
    'Laptop',
    'High-performance Core i7 Laptop with 16GB RAM and 512GB SSD',
    75000.00,
    10,
    'active'
FROM vendor v
WHERE v.business_name = 'SmartTech Ltd.';

-- Step 6b: Associate the Laptop product with the 'Electronics' category in product_category
INSERT INTO product_category (product_id, category_id)
SELECT 
    p.product_id,
    c.category_id
FROM product p
CROSS JOIN category c
WHERE p.name = 'Laptop' AND c.name = 'Electronics';


-- ------------------------------------------------------------------------------
-- [Question 7]:
-- Update the stock quantity of "Laptop" product to 15.
-- ------------------------------------------------------------------------------
UPDATE product
SET stock_quantity = 15
WHERE name = 'Laptop';


-- ------------------------------------------------------------------------------
-- [Question 8]:
-- Delete a customer whose email is "oldcustomer@gmail.com".
-- ------------------------------------------------------------------------------
DELETE FROM customer
WHERE email = 'oldcustomer@gmail.com';


-- ==============================================================================
-- ADDITIONAL SAMPLE DATA FOR TESTING DQL QUERIES
-- ==============================================================================

-- Additional products for testing bestsellers & category listings
INSERT INTO product (vendor_id, name, description, price, stock_quantity, status) VALUES
((SELECT vendor_id FROM vendor WHERE business_name = 'SmartTech Ltd.'), 'Wireless Mouse', 'Ergonomic optical mouse', 1500.00, 50, 'active'),
((SELECT vendor_id FROM vendor WHERE business_name = 'SmartTech Ltd.'), 'Mechanical Keyboard', 'RGB Backlit mechanical keyboard', 4500.00, 30, 'active'),
((SELECT vendor_id FROM vendor WHERE business_name = 'Apex Gadgets'), 'Smartphone', '5G Flagship smartphone', 55000.00, 20, 'active'),
((SELECT vendor_id FROM vendor WHERE business_name = 'Apex Gadgets'), 'Bluetooth Earbuds', 'Noise-cancelling wireless earbuds', 3500.00, 40, 'active'),
((SELECT vendor_id FROM vendor WHERE business_name = 'Apex Gadgets'), 'Smart Watch', 'Fitness tracker with AMOLED display', 6000.00, 25, 'active');

-- Link additional products to Electronics category
INSERT INTO product_category (product_id, category_id)
SELECT p.product_id, c.category_id
FROM product p
CROSS JOIN category c
WHERE c.name = 'Electronics' 
  AND p.name IN ('Wireless Mouse', 'Mechanical Keyboard', 'Smartphone', 'Bluetooth Earbuds', 'Smart Watch');

-- Insert Orders for Karim Uddin (Customer ID lookup)
INSERT INTO orders (customer_id, order_date, total_amount, order_status)
VALUES 
((SELECT customer_id FROM customer WHERE name = 'Karim Uddin'), '2026-10-15 10:30:00', 76500.00, 'Processing'),
((SELECT customer_id FROM customer WHERE name = 'Karim Uddin'), '2026-10-20 14:15:00', 7000.00, 'Delivered');

-- Insert Order Items for Order 1 (Laptop x 1, Wireless Mouse x 1)
INSERT INTO order_item (order_id, product_id, quantity, unit_price, subtotal) VALUES
(1, (SELECT product_id FROM product WHERE name = 'Laptop'), 1, 75000.00, 75000.00),
(1, (SELECT product_id FROM product WHERE name = 'Wireless Mouse'), 1, 1500.00, 1500.00);

-- Insert Order Items for Order 2 (Bluetooth Earbuds x 2)
INSERT INTO order_item (order_id, product_id, quantity, unit_price, subtotal) VALUES
(2, (SELECT product_id FROM product WHERE name = 'Bluetooth Earbuds'), 2, 3500.00, 7000.00);

-- Insert More Order Items to demonstrate Question 13 (Top 5 Best-Selling Products)
-- Create a 3rd order for Sarah Ahmed
INSERT INTO orders (customer_id, order_date, total_amount, order_status)
VALUES ((SELECT customer_id FROM customer WHERE name = 'Sarah Ahmed'), '2026-10-25 16:45:00', 32000.00, 'Completed');

INSERT INTO order_item (order_id, product_id, quantity, unit_price, subtotal) VALUES
(3, (SELECT product_id FROM product WHERE name = 'Wireless Mouse'), 10, 1500.00, 15000.00),
(3, (SELECT product_id FROM product WHERE name = 'Mechanical Keyboard'), 5, 4500.00, 22500.00),
(3, (SELECT product_id FROM product WHERE name = 'Bluetooth Earbuds'), 8, 3500.00, 28000.00),
(3, (SELECT product_id FROM product WHERE name = 'Smart Watch'), 4, 6000.00, 24000.00);

-- Insert Payments
INSERT INTO payment (order_id, method, amount, payment_date, payment_status) VALUES
(1, 'Bkash', 76500.00, '2026-10-15 10:35:00', 'Completed'),
(2, 'Card', 7000.00, '2026-10-20 14:20:00', 'Completed'),
(3, 'PayPal', 32000.00, '2026-10-25 16:50:00', 'Completed');


-- ==============================================================================
-- PART D: SQL Queries (DQL)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- [Question 9]:
-- Write a query to display all vendors along with their subscription plan name and price.
-- ------------------------------------------------------------------------------
SELECT 
    v.vendor_id,
    v.business_name,
    v.contact_person,
    v.email,
    v.phone,
    sp.name AS subscription_plan_name,
    sp.price AS subscription_plan_price,
    sp.duration AS plan_duration
FROM vendor v
INNER JOIN subscription_plan sp ON v.plan_id = sp.plan_id
ORDER BY v.vendor_id ASC;


-- ------------------------------------------------------------------------------
-- [Question 10]:
-- Find all products under the category "Electronics" with their name, price, and stock quantity.
-- ------------------------------------------------------------------------------
SELECT 
    p.product_id,
    p.name AS product_name,
    p.price,
    p.stock_quantity,
    p.status
FROM product p
INNER JOIN product_category pc ON p.product_id = pc.product_id
INNER JOIN category c ON pc.category_id = c.category_id
WHERE c.name = 'Electronics'
ORDER BY p.price DESC;


-- ------------------------------------------------------------------------------
-- [Question 11]:
-- List all orders placed by customer "Karim Uddin", showing order_id, date, total_amount, and status.
-- ------------------------------------------------------------------------------
SELECT 
    o.order_id,
    o.order_date,
    o.total_amount,
    o.order_status
FROM orders o
INNER JOIN customer c ON o.customer_id = c.customer_id
WHERE c.name = 'Karim Uddin'
ORDER BY o.order_date DESC;


-- ------------------------------------------------------------------------------
-- [Question 12]:
-- Show the payment details (method, amount, status) for order_id = 1.
-- ------------------------------------------------------------------------------
SELECT 
    p.payment_id,
    p.order_id,
    p.method,
    p.amount,
    p.payment_status,
    p.payment_date
FROM payment p
WHERE p.order_id = 1;


-- ------------------------------------------------------------------------------
-- [Question 13]:
-- Find the top 5 best-selling products based on total quantity sold.
-- ------------------------------------------------------------------------------
SELECT 
    p.product_id,
    p.name AS product_name,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.subtotal) AS total_revenue_generated
FROM product p
INNER JOIN order_item oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.name
ORDER BY total_quantity_sold DESC
LIMIT 5;

-- ==============================================================================
-- END OF SCRIPT
-- ==============================================================================
