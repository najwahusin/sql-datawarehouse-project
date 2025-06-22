USE DataWarehouse;

--===============================================================
-- DATABASE EXPLORATION
--===============================================================

-- Get informations of all tables in DB
SELECT * FROM INFORMATION_SCHEMA.TABLES

-- Get informations of all columns in specific table in DB
-- Get all columns' info from gold.dim_customers
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers'

--===============================================================
-- DIMENSIONS EXPLORATION
--===============================================================

-- Explore countries of origin of customers
SELECT DISTINCT country FROM gold.dim_customers

-- Get data on products including its categories, subcategories and names
SELECT DISTINCT 
	category,
	subcategory,
	product_name
FROM gold.dim_products
ORDER BY 1, 2, 3

--===============================================================
-- DATE EXPLORATION
--===============================================================

-- Range of Date of First and Latest Orders
SELECT
	MIN(order_date) first_order_date,
	MAX(order_date) last_order_date,
	DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) order_range_year
FROM gold.fact_sales


-- Data of Youngest and Oldest Customers
SELECT
	MIN(birthdate) oldest_customer,
	DATEDIFF(YEAR, MIN(birthdate), GETDATE()) age_oldest_customer,
	MAX(birthdate) youngest_customer,
	DATEDIFF(YEAR, MAX(birthdate), GETDATE()) age_youngest_customer
FROM gold.dim_customers


-- Total Sales
SELECT SUM(sales_amount) total_sales
FROM gold.fact_sales


--Items sold
SELECT SUM(quantity) total_quantity
FROM gold.fact_sales


--Average Selling Price
SELECT AVG(price) avg_price
FROM gold.fact_sales


--Total Orders made by Customers
SELECT COUNT(order_number) total_orders
FROM gold.fact_sales


SELECT COUNT(DISTINCT order_number) total_orders
FROM gold.fact_sales


--Total Products Sold
SELECT COUNT(product_key) total_products
FROM gold.dim_products


--Total customers
SELECT COUNT(DISTINCT customer_key) total_customers
FROM gold.dim_customers


--Total customers with Order Placed
SELECT COUNT(DISTINCT customer_key) total_customers
FROM gold.fact_sales


--===============================================================
-- Generating Reports 
--===============================================================

SELECT 'Total Sales' AS measure_name, SUM(sales_amount) measure_values FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity' AS measure_name, SUM(quantity) measure_values FROM gold.fact_sales
UNION ALL
SELECT 'Average Price' AS measure_name, AVG(price) measure_values FROM gold.fact_sales
UNION ALL
SELECT 'Total No. Orders' AS measure_name, COUNT(DISTINCT order_number) measure_values FROM gold.fact_sales
UNION ALL
SELECT 'Total No. Products' AS measure_name,  COUNT(product_key) measure_values FROM gold.dim_products
UNION ALL
SELECT 'Total No.Customers' AS measure_name, COUNT(customer_key) measure_values FROM gold.dim_customers
UNION ALL
SELECT 'Total Order Placed by Customer' AS measure_name, COUNT(DISTINCT customer_key) measure_values FROM gold.fact_sales

--===============================================================
-- Magnitude Analysis
-- Measuring values by categories
--===============================================================

-- Total Customers by Countries
SELECT
	country,
	COUNT(customer_key) total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC


-- Total Customers by Gender
SELECT
	gender,
	COUNT(customer_key) total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC


-- Total Products by Categories
SELECT
	category,
	COUNT(product_key) total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC


-- Average Cost for each Categories
SELECT
	category,
	AVG(cost) avg_costs
FROM gold.dim_products
GROUP BY category
ORDER BY avg_costs DESC


-- Total Revenue by Categories
SELECT
	p.category,
	SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products	p
ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY total_revenue DESC


-- Total Revenue by Customers
SELECT
	c.customer_key,
	c.first_name,
	c.last_name,
	SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY c.customer_key,
	c.first_name,
	c.last_name
ORDER BY total_revenue DESC


-- Distribution of Items Sold by Country
SELECT 
	c.country,
	SUM(quantity) total_sold_items
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.country
ORDER BY total_sold_items DESC


--===============================================================
-- Ranking Analysis
--===============================================================

-- Top 5 Best Performing Products
SELECT TOP 5
	p.product_name,
	SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC

-- Top 5 Worst Performing Products
SELECT TOP 5
	p.product_name,
	SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue ASC

-- Top 5 Best Performing Subcategory
SELECT TOP 5
	p.subcategory,
	SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.subcategory
ORDER BY total_revenue DESC

-- Top 5 Best Performing Products
SELECT * FROM (
	SELECT 
		p.product_name,
		SUM(f.sales_amount) total_revenue,
		ROW_NUMBER() OVER (ORDER BY SUM(f.sales_amount) DESC) rank_products
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON p.product_key = f.product_key
	GROUP BY p.product_name
)t
WHERE rank_products <= 5

-- Top 10 Customers with Highest Revenue
SELECT TOP 10
	c.customer_key,
	c.first_name,
	c.last_name,
	SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY c.customer_key,
	c.first_name,
	c.last_name
ORDER BY total_revenue DESC

-- Top 3 Customers with Fewest Orders
SELECT TOP 3
	c.customer_key,
	c.first_name,
	c.last_name,
	COUNT(DISTINCT f.order_number) total_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY c.customer_key,
	c.first_name,
	c.last_name
ORDER BY total_orders ASC

-- Changes Over Time Analysis (Dec 2010-Jan 2014)

-- Sales, Total Customers and Quantity of Products Sold per Month and Year (Dec 2010-Jan 2014)
SELECT 
YEAR(order_date) order_year,
MONTH(order_date) order_month, 
SUM(sales_amount) total_sales,
COUNT(DISTINCT customer_key) total_customers,
SUM(quantity) total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date) 


-- Sales, Total Customers and Quantity of Products Sold per Month
SELECT
DATETRUNC(month, order_date) order_date, 
SUM(sales_amount) total_sales,
COUNT(DISTINCT customer_key) total_customers,
SUM(quantity) total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
ORDER BY DATETRUNC(month, order_date)

SELECT 
FORMAT(order_date, 'yyyy-MMM') order_date,
SUM(sales_amount) total_sales,
COUNT(DISTINCT customer_key) total_customers,
SUM(quantity) total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date, 'yyyy-MMM')
ORDER BY FORMAT(order_date, 'yyyy-MMM')

-- Cumulative Analysis
-- Total Sales by Year
-- Running Total of Sales over Time

SELECT 
order_date,
total_sales,
SUM(total_sales) OVER (PARTITION BY order_date ORDER BY order_date) running_total_sales,
AVG(avg_price) OVER (ORDER BY order_date) moving_avg_price
FROM (
SELECT
DATETRUNC(YEAR, order_date) order_date,
SUM(sales_amount) total_sales,
AVG(price) avg_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(YEAR, order_date)
)t

-- Performance Analysis
-- Analyzing yearly performance of products by comparing sales to both avg sales of products and prev year's sales

WITH annual_product_sales AS (
SELECT
YEAR(f.order_date) order_year,
p.product_name,
SUM(f.sales_amount) current_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE order_date IS NOT NULL
GROUP BY YEAR(f.order_date), p.product_name)
SELECT
order_year,
product_name,
current_sales,
AVG(current_sales) OVER (PARTITION BY product_name) avg_sales,
current_sales - AVG(current_sales) OVER (PARTITION BY product_name) diff_avg,
CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Average'
	 WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Average'
	 ELSE 'Average'
END avg_change,
LAG(current_sales)  OVER (PARTITION BY product_name ORDER BY order_year) py_sales,
current_sales - LAG(current_sales)  OVER (PARTITION BY product_name ORDER BY order_year) diff_py,
CASE WHEN current_sales - LAG(current_sales)  OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
	 WHEN current_sales - LAG(current_sales)  OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
	 ELSE 'No Change'
END py_change
FROM annual_product_sales
ORDER BY product_name, order_year

-- Part-to-Whole Analysis
-- Percentage of Sales by Categories

WITH category_sales AS (
SELECT 
category,
SUM(sales_amount) total_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
GROUP BY category)
SELECT
category,
total_sales,
SUM(total_sales) OVER () overall_sales,
CONCAT(ROUND((CAST (total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2), '%') percentage_of_total
FROM category_sales
ORDER BY total_sales DESC

-- Data Segmentation
-- Segment products by cost range
-- Total products per segment

WITH product_segment AS (
SELECT
product_key,
product_name,
cost,
CASE WHEN cost < 100 THEN 'Below 100'
	 WHEN cost BETWEEN 100 AND 500 THEN '100-500'
	 WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
	 ELSE 'Above 1000'
END cost_range
FROM gold.dim_products)

SELECT 
cost_range,
COUNT(product_key) total_products
FROM product_segment
GROUP BY cost_range
ORDER BY total_products DESC

-- Customers' group based on spending behaviour
	-- VIP: >12 mths + >5k spending
	-- Regular: >12 mths + <5k
	-- New: <12 mths
-- Total customers per group

WITH customer_spending AS (
SELECT 
c.customer_key,
SUM(f.sales_amount) total_spending,
MAX(order_date) first_order,
MAX(order_date) last_order,
DATEDIFF(MONTH ,MIN(order_date), MAX(order_date)) lifespan
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY c.customer_key
)

SELECT 
customer_segment,
COUNT(customer_key) total_customers
FROM (
	SELECT 
	customer_key,
	CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
		 WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
		 ELSE 'New'
	END customer_segment
	FROM customer_spending
)t
GROUP BY customer_segment
ORDER BY total_customers DESC
