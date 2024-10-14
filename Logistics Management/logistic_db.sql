-- CREATE DATABASE FOR LOGISTIC AND SUPPLY CHAIN MANAGEMENT APP
DROP DATABASE IF EXISTS logistic_db;
CREATE DATABASE logistic_db;

USE logistic_db;

-- CREATE TABLE FOR SUPPLIER DATA
DROP TABLE IF EXISTS supplier;
CREATE TABLE supplier (
    supplier_id INT PRIMARY KEY AUTO_INCREMENT,
    supplier_name VARCHAR(100) NOT NULL,
    contact_info VARCHAR(255),
    rating DECIMAL(3, 2),  -- Rating out of 5. Example: 4.75
    address VARCHAR(255),
    city VARCHAR(100),
    country VARCHAR(100)
);

-- CREATE TABLE FOR WAREHOUSE INFO
DROP TABLE IF EXISTS warehouse;
CREATE TABLE warehouse (
    warehouse_id INT PRIMARY KEY AUTO_INCREMENT,
    warehouse_name VARCHAR(100) NOT NULL,
    location VARCHAR(255),
    capacity INT,  -- Maximum storage capacity
    current_stock INT  -- Current stock level in the warehouse
);

-- CREATE TABLE FOR INVENTORY DATA
DROP TABLE IF EXISTS inventory;
CREATE TABLE inventory (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    warehouse_id INT,
    stock_level INT,  -- Current stock level
    minimum_stock INT,  -- Minimum stock level before restocking
    unit_price DECIMAL(10, 2),
    FOREIGN KEY (warehouse_id) REFERENCES warehouse(warehouse_id)
);

-- CREATE TABLE FOR DELIVERY ROUTE DATA
DROP TABLE IF EXISTS delivery_route;
CREATE TABLE delivery_route (
    route_id INT PRIMARY KEY AUTO_INCREMENT,
    start_location VARCHAR(255),
    end_location VARCHAR(255),
    distance DECIMAL(5, 2),  -- Distance in kilometers
    estimated_time DECIMAL(5, 2), -- Estimated time in hours
    transport_cost DECIMAL(10, 2)  
);

-- CREATE TABLE FOR SHIPMENT DATA
DROP TABLE IF EXISTS shipment;
CREATE TABLE shipment (
    shipment_id INT PRIMARY KEY AUTO_INCREMENT,
    supplier_id INT,
    shipment_date DATE,
    arrival_date DATE,
    product_id INT,
    quantity INT,
    cost DECIMAL(9, 2),
    shipment_status VARCHAR(50), -- Example: In-transit, Delivered, Canceled, Returned
    FOREIGN KEY (supplier_id) REFERENCES supplier(supplier_id),
    FOREIGN KEY (product_id) REFERENCES inventory(product_id)
);

-- INSERT DATA FOR SUPPLIERS
INSERT INTO supplier (supplier_name, contact_info, rating, address, city, country) 
VALUES
('Global Supplies Co.', 'global@supplies.com', 4.75, '123 Industrial Park', 'Bangalore', 'India'),
('QuickShip Ltd.', 'contact@quickship.com', 4.50, '45 Warehouse Street', 'Mumbai', 'India'),
('Mega Logistics', 'info@megalogistics.com', 4.20, '89 Distribution Road', 'Delhi', 'India'),
('FastTrack Supply', 'support@fasttrack.com', 4.90, '67 Speedy Ave', 'Hyderabad', 'India');

-- INSERT DATA FOR WAREHOUSE INFO
INSERT INTO warehouse (warehouse_name, location, capacity, current_stock)
VALUES
('Bangalore Central Warehouse', 'Bangalore', 50000, 30000),
('Mumbai North Warehouse', 'Mumbai', 40000, 25000),
('Delhi East Warehouse', 'Delhi', 60000, 40000),
('Hyderabad South Warehouse', 'Hyderabad', 45000, 32000);

-- INSERT DATA FOR INVENTORY
INSERT INTO inventory (product_name, warehouse_id, stock_level, minimum_stock, unit_price)
VALUES
('Mobile Phones', 1, 5000, 1000, 15000.00),
('Laptops', 2, 3000, 500, 60000.00),
('Televisions', 3, 1000, 200, 40000.00),
('Air Conditioners', 4, 2000, 300, 30000.00),
('Refrigerators', 1, 1200, 150, 25000.00),
('Washing Machines', 2, 1500, 200, 20000.00);

-- INSERT DATA FOR DELIVERY ROUTE
INSERT INTO delivery_route (start_location, end_location, distance, estimated_time, transport_cost)
VALUES
('Bangalore Central Warehouse', 'Hyderabad South Warehouse', 500.00, 8.00, 2000.00),
('Mumbai North Warehouse', 'Delhi East Warehouse', 150.00, 18.00, 5000.00),
('Hyderabad South Warehouse', 'Mumbai North Warehouse', 900.00, 12.00, 3000.00),
('Delhi East Warehouse', 'Bangalore Central Warehouse', 200.00, 22.00, 6000.00);

-- INSERT DATA FOR SHIPMENT
INSERT INTO shipment (supplier_id, shipment_date, arrival_date, product_id, quantity, cost, shipment_status) 
VALUES
(1, '2024-10-01', '2024-10-05', 1, 500, 750000.00, 'Delivered'),
(2, '2024-10-03', '2024-10-07', 2, 300, 1800000.00, 'In Transit'),
(3, '2024-09-28', '2024-10-02', 3, 200, 800000.00, 'Cancelled'),
(4, '2024-10-02', '2024-10-06', 4, 400, 1200000.00, 'In Transit'),
(1, '2024-11-05', '2024-11-11', 5, 600, 1900000.00, 'Returned'),  
(2, '2024-11-08', '2024-11-16', 6, 300, 6000000.00, 'Delivered'),
(2, '2024-11-14', '2024-11-21', 1, 450, 6750000.00, 'In Transist'),
(2, '2024-11-15', '2024-11-21', 2, 250, 1250000.00, 'In Transist');

-- LIST BEST SELLER
SELECT RANK() OVER(ORDER BY rating DESC) ranks, supplier_name, contact_info, rating, address, city, country 
FROM supplier
LIMIT 1;

-- WAREHOUSE WITH HIGHEST CAPACITY
WITH MaxCapacity AS (
    SELECT MAX(capacity) AS max_capacity
    FROM warehouse
)
SELECT warehouse_name, capacity, location
FROM warehouse,MaxCapacity
WHERE capacity = max_capacity;

-- TOTAL STOCKS AVAILABLE
SELECT SUM(current_stock) 'Total Stocks'
FROM warehouse;

-- PRODUCTS WITH MINIMUM STOCK LEVEL
SELECT product_id, product_name
FROM inventory
WHERE stock_level < minimum_stock;

-- SHIPMENTS IN 'IN-TRANSIST'
SELECT p.product_id, p.product_name, s.shipment_status
FROM inventory p
JOIN shipment s
ON p.product_id = s.product_id
WHERE shipment_status = 'In Transit';

-- MOST EXPENSIVE TRANSPORT ROUTE
SELECT route_id
FROM delivery_route
ORDER BY transport_cost DESC
LIMIT 1;

-- TOTAL VALUES OF SHIPMENTS THAT WERE CANCELLED
SELECT s.quantity*i.unit_price AS Total 
FROM shipment s
JOIN inventory i
ON s.product_id = i.product_id
WHERE s.shipment_status = 'Cancelled';

-- PRODUCT NAME AND QUANTITY OF THE RETURNED SHIPMENT
SELECT p.product_name, s.quantity
FROM inventory p
JOIN shipment s
ON p.product_id = s.product_id
WHERE s.shipment_status = 'Returned';

-- PRODUCT LIST BY WAREHOUSE
SELECT i.product_name, w.warehouse_name
FROM inventory i
JOIN warehouse w
ON i.warehouse_id = w.warehouse_id;


-- SHIPMENT DETAILS BY SUPPLIER AND PRODUCT
SELECT i.product_name, s.supplier_name, sp.shipment_date, sp.arrival_date, sp.quantity, sp.cost, sp.shipment_status
FROM shipment sp
JOIN supplier s 
ON sp.supplier_id = s.supplier_id
JOIN inventory i 
ON i.product_id = sp.product_id;

-- TOTAL QUANTITY OF PRODUCTS SHIPPED BY EACH SUPPLIER
SELECT s.supplier_name, sp.quantity 
FROM supplier s 
JOIN shipment sp 
ON s.supplier_id = sp.supplier_id;

-- TOP SUPPLIER WITH ON TIME DELIVERY
WITH DeliveryTimes AS (
    SELECT 
        s.supplier_name,
        DATEDIFF(sp.arrival_date, sp.shipment_date) AS delivery_time
    FROM supplier s
    JOIN shipment sp ON sp.supplier_id = s.supplier_id
),
BestDeliveryTime AS (
    SELECT MIN(delivery_time) AS best_time
    FROM DeliveryTimes
)
SELECT supplier_name, delivery_time
FROM DeliveryTimes
WHERE delivery_time = (SELECT best_time FROM BestDeliveryTime);

 -- PRODUCT WITH LOW STOCK LEVELS AND POTENTIAL SUPPLIER
 SELECT i.product_name, s.supplier_name
 FROM inventory i 
 JOIN shipment sp
 ON i.product_id = sp.product_id
 JOIN supplier s 
 ON s.supplier_id = sp.supplier_id
 WHERE i.stock_level < i.minimum_stock;

-- ANLYZE WAREHOUSE CAPACITY UTILIZATION
SELECT warehouse_name, capacity AS total_capacity, current_stock, 
CASE  
WHEN ROUND((current_stock/capacity) * 100) > 65 
THEN ' Under Utilized'
ELSE 'Utilized'
END AS 'Utilization'
FROM warehouse;

-- ANALYZE DELIVERY ROUTE COST EFFICIENCY
SELECT route_id, start_location, end_location, 
CASE
WHEN ROUND(transport_cost/distance) > 10
THEN 'Cost Efficient'
ELSE 'Most Expensive'
END AS 'Efficiency'
FROM delivery_route;

-- ANALYZE PRODUCT TURNOVER TIME
SELECT i.product_name, 
AVG(DATEDIFF(s2.shipment_date, s1.arrival_date)) AS avg_turnover_time
FROM shipment s1
JOIN shipment s2 
ON s1.product_id = s2.product_id 
AND s2.shipment_date > s1.arrival_date
JOIN inventory i 
ON s1.product_id = i.product_id
GROUP BY i.product_name
ORDER BY avg_turnover_time ASC;

-- COST ANALYSIS OF SHIPMENTS PER SUPPLIER
WITH SupplierCosts AS (
SELECT s.supplier_name as supplier_name,
SUM(sp.cost) total_cost, 
sum(sp.quantity) total_quantity
FROM shipment sp
JOIN supplier s
ON s.supplier_id = sp.supplier_id
GROUP BY s.supplier_name
)
SELECT supplier_name, Round(total_cost/total_quantity,2) AS cost_per_unit
FROM SupplierCosts
ORDER BY cost_per_unit;


-- Product Profitability Analysis

SELECT 
    i.product_id,
    i.product_name,
    SUM(s.quantity * i.unit_price) AS total_revenue_generated,
    SUM(s.cost) AS total_shipment_cost,
    (SUM(s.quantity * i.unit_price) - SUM(s.cost)) AS total_profit
FROM inventory i
JOIN shipment s 
ON i.product_id = s.product_id
GROUP BY i.product_id, i.product_name
HAVING total_profit > 0  -- to show only profitable products
ORDER BY total_profit DESC;


-- Supplier-Product Dependency
SELECT 
    sup.supplier_id,
    sup.supplier_name,
    s.shipment_status,
    COUNT(s.shipment_id) AS total_shipments,
    SUM(s.quantity) AS total_quantity_shipped
FROM supplier sup
JOIN shipment s 
ON sup.supplier_id = s.supplier_id
GROUP BY sup.supplier_id, sup.supplier_name, s.shipment_status
ORDER BY sup.supplier_name, s.shipment_status;




