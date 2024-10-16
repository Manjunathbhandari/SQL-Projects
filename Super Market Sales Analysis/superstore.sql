-- CREATE DATABASE FOR SUPER MARKET SALES ANALYSIS
DROP DATABASE IF EXISTS supermarket_db;
CREATE DATABASE supermarket_db;

USE supermarket_db;

-- TOTAL SALES AMOUNT FOR EACH PRODUCT CATEGORY
SELECT category, SUM(sales) AS 'Total Sales'
FROM superstore
GROUP BY category
ORDER BY SUM(sales) DESC;

-- AVERAGE PROFIT MARGIN FOR EACH PRODUCT
SELECT product_name, AVG(profit)
FROM superstore
GROUP BY product_name;

-- PRODUCT WITH HIGHEST SALES QUANTITY
WITH ProductSales AS
(
SELECT product_name,
SUM(quantity) as total_sold
FROM superstore
GROUP BY product_name
)
SELECT product_name, total_sold
FROM ProductSales
ORDER BY total_sold DESC
LIMIT 1;

-- TOTAL SALES AMOUNT FOR THE ENTIRE DATASET
SELECT
SUM(sales * quantity * (1 - discount / 100)) AS total_sales
FROM superstore;

-- TOTAL PROFIT MADE ACROSS ALL SALES
SELECT SUM(profit) total_profit
FROM superstore;

-- AVERAGE DISCOUNT GIVEN ON SALES
SELECT AVG(discount) average_discount
FROM superstore;

-- TOTAL PRODUCT SOLD
SELECT COUNT(product_id)
FROM superstore;

-- SALES TREND OVER TIME
SELECT 
    MONTHNAME(order_date) as Month,
    SUM(sales) as Total_Sales
FROM superstore
GROUP BY Month, MONTH(order_date)
ORDER BY MONTH(order_date);

-- MONTH WITH HIGHEST SALES
SELECT MONTHNAME(order_date) as Month,
SUM(sales) as Total_Sales
FROM superstore
GROUP BY Month, MONTH(order_date)
ORDER BY MONTH(order_date)
LIMIT 1;

-- AVERAGE SHIPPING TIME 
WITH OrderProcessingTime as
(
SELECT order_id, DATEDIFF(ship_date,order_date) as DaysToShip
FROM superstore
)
SELECT ROUND(AVG(DaysToShip),0) as Average_Time
FROM OrderProcessingTime;

-- STATE WITH HIGHEST NUMBER OF SALES
WITH countstate as 
(
SELECT state, 
COUNT(state) as total_states
FROM superstore
GROUP BY state
)
SELECT state, total_states
FROM countstate
ORDER BY total_states DESC
LIMIT 1;

-- PRODUCT CATEGORY WITH HIGHEST SALES
WITH totalSales as
(
SELECT category, 
SUM(sales) as total_sold
FROM superstore
GROUP BY category
)
SELECT category, total_sold
FROM totalSales
ORDER BY total_sold DESC
LIMIT 1;

-- TOP 10 PRODUCTS BY QUANTITY SOLD
WITH totalProductQuantity as
(
SELECT product_name, 
sum(quantity) as total_quantity
FROM superstore
GROUP BY product_name
)
SELECT product_name, total_quantity
FROM totalProductQuantity
ORDER BY total_quantity DESC
LIMIT 10;


-- SALES FIGURE BY PRODUCT SUB CATEGORY
WITH salesFigure as
(
SELECT sub_category, 
SUM(sales) as total_sales
FROM superstore
GROUP BY sub_category
)
SELECT sub_category, total_sales
FROM salesFigure
ORDER BY total_sales DESC;

-- AVERAGE PROFIT MARGIN FOR EACH PRODUCT CATEGORY
WITH averagePRofit as
(
SELECT category, avg(profit) as average_profit
FROM superstore
GROUP BY category
)
SELECT category, ROUND(average_profit) as margin_profit
FROM averageProfit;

-- DISTRIBRUTION SALES ACROSS DIFFERENT DISCOUNT RANGE
SELECT discount, sum(sales) Sales
FROM superstore
GROUP BY discount;

-- PRODUCT WITH HIGHEST SALES WITH DISCOUNT APPLIED
SELECT product_name,category, sales
FROM superstore
WHERE discount > 0
ORDER BY sales DESC
LIMIT 1;

-- TOTAL TRANSACTIONS WITH NO DISCOUNTS
SELECT COUNT(order_id) sales_with_no_discounts
FROM superstore
WHERE discount = 0;

-- SALES PERFORMANCE OF PRODUCTS THAT HAVE BEEN DISCOUNTED VERSUS THOSE THAT HAVEN'T
WITH salesWithNoDiscount as
(
SELECT SUM(sales) sales_with_no_discount
FROM superstore
WHERE discount = 0
),
salesWithDiscount as
(
SELECT SUM(sales) sales_with_discount
FROM superstore 
WHERE discount > 0
)
SELECT sales_with_no_discount, sales_with_discount
FROM salesWithNoDiscount, salesWithDiscount;

-- PRODUCT WITH HIGHEST PROFIT MARGIN VS PRODUCT WITH LOWEST PROFIT MARGIN

(
    SELECT 'Highest' AS margin_type,product_id, 
        product_name, category, sub_category,
        sales, profit,
        (profit / sales) * 100 AS profit_margin
    FROM superstore
    WHERE sales > 0 
    ORDER BY profit_margin DESC
    LIMIT 1
)
UNION ALL
(
    SELECT 'Lowest' AS margin_type, product_id, 
        product_name, category, sub_category,
        sales, profit,
        (profit / sales) * 100 AS profit_margin
    FROM superstore
    WHERE  sales > 0
    ORDER BY profit_margin ASC
    LIMIT 1
);

-- TOTAL ORDERS FROM DIFFERENT CITIES
SELECT city, COUNT(order_id) as 'Total Orders'
FROM superstore
GROUP BY city
ORDER BY city;

-- TOTAL SALES, PROFIT, AND DISCOUNTS BY REGION
SELECT region, SUM(sales) total_sales,
SUM(profit) total_profit, SUM(discount) total_discount
FROM superstore
GROUP BY region;






