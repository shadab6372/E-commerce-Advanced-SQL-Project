SELECT * FROM categories;
SELECT * FROM customers;
SELECT * FROM inventory;
SELECT * FROM order_items;
SELECT * FROM orders;
SELECT * FROM payments;
SELECT * FROM products;
SELECT * FROM sellers;
SELECT * FROM shipping;

SELECT DISTINCT category_name FROM categories;
SELECT DISTINCT product_name FROM products;
SELECT DISTINCT payment_status FROM payments;

SELECT * FROM shipping
WHERE return_date IS NOT NULL

SELECT * FROM orders
WHERE order_id = 'ORD_3003'

SELECT * FROM payments
WHERE order_id = 'ORD_3003'

SELECT * FROM shipping
WHERE return_date IS NULL and delivery_status='Delivered'


---	Business Problem 	---
-- top 10 selling product 
SELECT p.product_name,
COUNT(o.order_id), 
SUM(oi.total_price) as total_sales
FROM orders o
JOIN order_items oi
ON o.order_id = oi.order_id
JOIN products p
ON p.product_id = oi.product_id
GROUP BY 1
ORDER BY 3 DESC
LIMIT 10;

-- revenue by category 
SELECT c.category_name,
SUM(oi.total_price) total_revenue,
round((SUM(oi.total_price)/
(SELECT SUM(total_price) FROM order_items) * 100),2) as contribution
FROM categories c
RIGHT JOIN products p
ON p.category_id = c.category_id
JOIN order_items oi
ON oi.product_id = p.product_id
GROUP BY 1

-- average order value for each customer
SELECT c.name,
COUNT(o.order_id),
AVG(oi.total_price)
FROM customers c
LEFT JOIN orders o
ON c.cust_id = o.customer_id
JOIN order_items oi
ON oi.order_id = o.order_id
GROUP BY 1
HAVING COUNT(o.order_id) > 5


-- monthly sales trend
WITH monthly_sales as (
SELECT 
EXTRACT(YEAR FROM order_date) as year,
EXTRACT(MONTH FROM order_date) as month,
SUM(total_price) as total_sales
FROM orders o 
JOIN order_items oi
ON o.order_id = oi.order_id
WHERE order_date >= current_date - interval '1 year'
GROUP BY 1,2
ORDER BY 1,2
)
SELECT year,
month,
total_sales as current_month_sales,
LAG(total_sales) OVER (ORDER BY 1,2) as last_month_sales
FROM monthly_sales


-- customers with no purchase
SELECT * FROM customers
WHERE cust_id NOT IN (SELECT DISTINCT customer_id FROM orders)

-- best selling category by state
WITH rank_state as(
SELECT
cu.state,
ca.category_name,
SUM(oi.total_price) as total_sales,
RANK() OVER (PARTITION BY ca.category_name ORDER BY SUM(oi.total_price) DESC) as rank
FROM orders o
JOIN order_items oi
ON o.order_id = oi.order_id
JOIN customers cu
ON cu.cust_id = o.customer_id
JOIN products p
ON p.product_id = oi.product_id
JOIN categories ca
ON ca.category_id = p.category_id
GROUP BY 1,2
ORDER BY 1,3
)
SELECT * FROM rank_state
WHERE rank = 1

-- customer lifetime value
SELECT 
c.name,
SUM(oi.total_price) as total_value,
DENSE_RANK() OVER(ORDER BY SUM(oi.total_price) DESC) as cx_ranking
FROM customers c
JOIN orders o
ON c.cust_id = o.customer_id
JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY 1

--inventory stock alert
WITH stock_alert as
(
SELECT 
p.product_name,
i.stock_remaining as stock_left,
i.warehouse_id as warehouse,
i.restock_date as last_restock
FROM inventory i
JOIN products p
ON i.product_id = p.product_id
)
SELECT * FROM stock_alert
WHERE stock_left < 10

-- delivery success rate
SELECT 
s.delivery_status,
COUNT(o.order_id)::numeric / 
			(SELECT COUNT(*) FROM orders)::numeric * 100 as percentage
FROM orders o
JOIN shipping s
ON o.order_id = s.order_id
GROUP BY 1

-- payments success rate 
SELECT 
p.payment_status,
round((COUNT(o.order_id)::numeric/
			(SELECT COUNT(*) FROM orders)::numeric *100),2) as percentage
FROM orders o
JOIN payments p
ON p.order_id = o.order_id
GROUP BY 1
ORDER BY 2 DESC

-- top performing seller
SELECT
s.seller_name,
COUNT(o.*) as total_order,
SUM(oi.total_price) as total_sales
FROM sellers s
JOIN orders o
ON o.seller_id = s.seller_id
JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY 1
ORDER BY total_sales DESC
LIMIT 5

-- payments success rate 
SELECT 
p.payment_status,
round((COUNT(o.order_id)::numeric/
			(SELECT COUNT(*) FROM orders)::numeric *100),2) as percentage
FROM orders o
JOIN payments p
ON p.FROMr_id = o.order_id
GROUP BY 1
ORDER BY 2 DESC

-- top 10 product
WITH top_products as
(
SELECT 
p.product_name as product_name,
COUNT(oi.order_id) as total_orders,
SUM(oi.total_Price) as total_sales
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
GROUP BY 1
)
SELECT
product_name,
total_orders,
total_Sales,
RANK() OVER(ORDER BY total_sales DESC) as rank
FROM top_products
LIMIT 10


-- 15 most returned product
WITH return_product as
(
SELECT 
p.product_name product_name,
s.delivery_status status,
round((COUNT(s.delivery_status)::numeric /
		((SELECT COUNT(*) FROM order_items)::numeric) * 100),2) as return_rate
FROM products p
JOIN order_items oi
ON p.product_id = oi.product_id
JOIN shipping s
ON s.order_id = oi.order_id
GROUP BY 1,2
)
SELECT *
FROM return_product
WHERE status = 'Returned'
ORDER BY return_rate DESC
LIMIT 10

--most returned category
WITH return_cat as
(
SELECT 
c.category_name,
s.delivery_status,
round((COUNT(s.delivery_status)::numeric /
		((SELECT COUNT(*) FROM order_items)::numeric) * 100),2) as return_rate
FROM categories c
JOIN products p
ON c.category_id = p.category_id
JOIN order_items oi
ON oi.product_id = p.product_id
JOIN shipping s
ON s.order_id = oi.order_id
GROUP BY 1,2
)
SELECT * 
FROM return_cat
WHERE delivery_status = 'Returned'
ORDER BY return_rate DESC

--inactive seller from last  1 months
WITH seller as
(
SELECT 
s.seller_id,
s.seller_name,
MAX(o.order_date) as last_order
FROM sellers s
JOIN orders o
ON s.seller_id = o.seller_id
GROUP BY 1,2
)
SELECT *
FROM seller
WHERE last_order IS NULL 
OR
last_order < current_date - interval '1 months'


-- identify customer into returned and new
WITH cust as 
(
SELECT 
c.cust_id,
c.name,
COUNT(o.*) as total_orders,
COUNT(CASE WHEN s.delivery_status = 'Returned' THEN 1 END) as returned_orders
FROM customers c
JOIN orders o
ON c.cust_id = o.customer_id
JOIN shipping s
ON s.order_id = o.order_id
GROUP BY 1,2
)
SELECT *,
CASE WHEN
returned_orders >= 5 
THEN 'returned'
ELSE 'new'
END
FROM cust

-- top 5 customer by orders in each state 
WITH cust as
(
SELECT 
c.state,
c.name,
COUNT(o.order_id) as total_orders,
SUM(oi.total_Price) as total_sales
FROM customers c
JOIN orders o 
ON c.cust_id = o.customer_id
JOIN order_items oi
ON oi.order_id = o.order_id
GROUP BY 1,2
),
ranked_data as
(
SELECT *,
ROW_NUMBER() OVER (PARTITION BY state ORDER BY total_sales DESC) as rn
FROM cust
)
SELECT * 
FROM ranked_data 
WHERE rn<=5

-- top 10 product with highest decresing ration compare to last 6 month and current current
WITH last_6_months as
(
SELECT 
c.category_name,
p.product_name,
SUM(oi.total_price) as total_sales
FROM categories c
JOIN products p 
ON c.category_id = p.category_id
JOIN order_items oi 
ON oi.product_id = p.product_id
JOIN orders o 
ON o.order_id = oi.order_id
WHERE o.order_date >= current_date - INTERVAL '6 months'
GROUP BY 1,2
),

prev_6_months as 
(
SELECT 
c.category_name,
p.product_name,
SUM(oi.total_price) as total_sales
FROM categories c
JOIN products p 
ON c.category_id = p.category_id
JOIN order_items oi 
ON oi.product_id = p.product_id
JOIN orders o 
ON o.order_id = oi.order_id
WHERE o.order_date >= current_date - INTERVAL '12 months'
	AND o.order_date < current_date - INTERVAL '6 months'
GROUP BY 1,2
)

SELECT 
l.category_name,
l.product_name,
l.total_sales as current_6m_sales,
COALESCE(p.total_sales,0) as prev_6m_sales,
(l.total_sales - COALESCE(p.total_sales,0)) as sales_diff
FROM last_6_months l
LEFT JOIN prev_6_months p
ON l.product_name = p.product_name
ORDER BY sales_diff DESC;