SELECT * FROM customers


---Removing Duplicates from the customer table
WITH Duplicated AS (
	SELECT DISTINCT ON (customer_id) *
	FROM customers
	ORDER BY customer_id)
	

DELETE FROM customers c
WHERE c.customer_id NOT IN (SELECT customer_id FROM Duplicated)


---Checking for null rows
SELECT *
FROM customers
WHERE region IS NULL


---Set Null values to be unknown
SELECT customer_id, contact_name, COALESCE(region,'unknown') AS region
FROM customers


---Analyze the impact of nulls
SELECT country, COUNT(*) AS totalcustomers, COUNT(region) AS customers_with_region, COUNT(*)-COUNT(region) AS customer_with_no_region
FROM customers
GROUP BY country;

-------------------------------------------------------------------------------------------------------------------------------------------------
----Exploratory data analyst
---product by category
SELECT product_name, category_name
FROM products p
JOIN categories
USING(category_id)


---get the most expensive and least expensive product
(SELECT product_name, MAX(unit_price) unit_price
FROM products
GROUP BY product_name
ORDER BY unit_price DESC
LIMIT 1)
UNION
(SELECT product_name, unit_price
FROM products
ORDER BY unit_price
LIMIT 1)


---Get current and discontinued products
SELECT
		SUM(CASE WHEN discontinued = 0 THEN 1 ELSE 0 END) AS current_products,
		SUM(CASE WHEN discontinued = 1 THEN 1 ELSE 0 END) AS discontinued_products
FROM products


---show sales data by categories in the year 1997
SELECT category_name, ROUND(SUM(od.quantity*od.unit_price*(1-od.discount))::NUMERIC, 2) total_sales
FROM order_details od
JOIN products p 
USING(product_id)
JOIN categories c 
USING(category_id)
JOIN orders o 
USING(order_id)
WHERE EXTRACT(YEAR FROM o.order_date) = 1997
GROUP BY category_name


---EMPLOYEE AND THEIR SALES AMOUNT
SELECT CONCAT(first_name,' ',last_name) full_name, SUM(unit_price) unit_price
FROM employees e
JOIN orders o 
USING(employee_id)
JOIN order_details od 
USING(order_id)
GROUP BY full_name
ORDER BY unit_price DESC


---Product name by quantity and total unit
SELECT product_name, quantity_per_unit, SUM(units_in_stock) total_unit
FROM products
GROUP BY product_name, quantity_per_unit
ORDER BY total_unit DESC
LIMIT 20


---Current Product list
SELECT product_id, product_name
FROM products
WHERE discontinued = 0


---Discontinued price list
SELECT product_id, product_name
FROM products
WHERE discontinued = 1


---Product List where current price is < 20
SELECT product_id, product_name, unit_price
FROM products
WHERE discontinued = 0 
	AND unit_price < 20


---Product List where price is between 15 and 25
SELECT product_id, product_name, unit_price
FROM products
WHERE unit_price BETWEEN 15 AND 25
ORDER BY unit_price ASC


---Product List of average price
SELECT product_name, ROUND(AVG(unit_price)::NUMERIC,2) AS avg_price
FROM products
GROUP BY product_name
ORDER by avg_price DESC


---Top 10 most expensive Products
SELECT product_name, MAX(unit_price) unit_price
FROM products
GROUP BY product_name
ORDER BY unit_price DESC
LIMIT 10


---Products on order and in stock where the products in stock is lesser than what was ordered
SELECT product_name, units_on_order, units_in_stock
FROM products
WHERE units_in_stock < units_on_order


---Sales amount of employees
SELECT CONCAT(first_name,' ',last_name) full_name, ROUND(SUM(od.quantity*od.unit_price*(1-od.discount))::NUMERIC, 2) total_sales
FROM employees e
JOIN orders o 
ON e.employee_id = o.employee_id
JOIN order_details od 
ON o.order_id = od.order_id
GROUP BY full_name
ORDER BY total_sales DESC


---Retrieve order details and calculate the final sales price after discount
SELECT order_id, product_name, od.unit_price, quantity, discount, ROUND(SUM(quantity*od.unit_price*(1-discount))::NUMERIC, 2) total_sales
FROM order_details od
JOIN products p
USING(product_id)
GROUP BY order_id, product_name, od.unit_price, quantity, discount
ORDER BY total_sales DESC


---Products sold and their total sales amount per category
SELECT category_name, product_name, ROUND(SUM(quantity*od.unit_price*(1-discount))::NUMERIC, 2) total_sales
FROM categories
JOIN products
USING(category_id)
JOIN order_details od
USING(product_id)
GROUP BY category_name, product_name
ORDER BY category_name, total_sales DESC


