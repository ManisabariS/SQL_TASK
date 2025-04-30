-- Create Database
CREATE DATABASE ecommerce;
USE ecommerce;

-- Create Tables
CREATE TABLE customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    address TEXT
);

CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    price DECIMAL(10,2),
    description TEXT
);

CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

-- Insert Sample Data
INSERT INTO customers (name, email, address) VALUES
('Alice', 'alice@example.com', '123 Main St'),
('Bob', 'bob@example.com', '456 Elm St'),
('Charlie', 'charlie@example.com', '789 Maple St');

INSERT INTO products (name, price, description) VALUES
('Apple iPhone 14', 799.00, '128GB, Midnight, 5G smartphone'),
('Samsung Galaxy S22', 699.00, '128GB, Phantom Black, 5G smartphone'),
('Sony WH-1000XM5 Headphones', 399.00, 'Wireless Noise Cancelling Headphones'),
('Dell XPS 13 Laptop', 999.00, '13.4” FHD+ Touch Laptop, 16GB RAM, 512GB SSD'),
('Amazon Echo Dot (5th Gen)', 49.99, 'Smart speaker with Alexa');

INSERT INTO orders (customer_id, order_date, total_amount) VALUES
(1, CURDATE(), 848.99),
(2, CURDATE() - INTERVAL 10 DAY, 798.00),
(1, CURDATE() - INTERVAL 40 DAY, 999.00),
(3, CURDATE() - INTERVAL 5 DAY, 539.98);

-- Customers who placed orders in last 30 days
SELECT DISTINCT c.*
FROM customers c
JOIN orders o ON c.id = o.customer_id
WHERE o.order_date >= CURDATE() - INTERVAL 30 DAY;

-- Total order amount by customer
SELECT c.name, SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o ON c.id = o.customer_id
GROUP BY c.id;

-- Update price of Sony Headphones to 379.00 (Safe mode compatible)
UPDATE products
SET price = 379.00
WHERE id = (
    SELECT id FROM (SELECT id FROM products WHERE name = 'Sony WH-1000XM5 Headphones' LIMIT 1) AS temp
);

-- Add discount column
ALTER TABLE products
ADD COLUMN discount DECIMAL(5,2) DEFAULT 0.00;

-- Top 3 expensive products
SELECT * FROM products
ORDER BY price DESC
LIMIT 3;

-- Normalize: create order_items
CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Sample data for order_items
INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
(1, 1, 1, 799.00), -- iPhone 14
(1, 5, 1, 49.99), -- Echo Dot
(2, 2, 1, 699.00), -- Galaxy S22
(2, 5, 2, 49.50), -- Echo Dot
(3, 4, 1, 999.00), -- Dell XPS 13
(4, 3, 1, 399.00), -- Sony Headphones
(4, 5, 1, 49.99); -- Echo Dot

-- Customers who ordered 'Apple iPhone 14'
SELECT DISTINCT c.name
FROM customers c
JOIN orders o ON c.id = o.customer_id
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id
WHERE p.name = 'Apple iPhone 14';

-- Customer name and order date
SELECT c.name, o.order_date
FROM orders o
JOIN customers c ON o.customer_id = c.id;

-- Orders with total amount > 150
SELECT * FROM orders
WHERE total_amount > 150.00;

-- Average order total
SELECT AVG(total_amount) AS average_order_total
FROM orders;
