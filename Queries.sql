-- 1. Total Orders
Select Count(*) As total_orders
From orders;

--2. Total Revenue
Select SUM(cost) As total_revenue
From orders;

--3. Average Order value 
Select AVG(cost) As avg_order_value
From orders;

--4. Total Customers
Select COUNT(DISTINCT customer_id) As total_customers
From orders;

--5. Average delivery time 
Select AVG(delivery_time) As avg_delivery_time
From orders;

--6. Orders by Day of week
SELECT order_day,
COUNT(*) AS total_orders
FROM orders
GROUP BY order_day
ORDER BY total_orders DESC;

--7. Top 10 restaurants by orders
SELECT r.restaurant_name,
COUNT(*) AS total_orders
FROM orders o
JOIN restaurants r
ON o.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_name
ORDER BY total_orders DESC
LIMIT 10;

--8. Revenue by Cuisine Type
SELECT cuisine_type,
SUM(o.cost) As revenue
FROM orders o
JOIN restaurants r
ON o.restaurant_id = r.restaurant_id
GROUP BY r.cuisine_type
ORDER BY revenue DESC;

--9. Average Rating per Restaurant
SELECT r.restaurant_name,
AVG(o.rating) AS avg_rating
FROM orders o
JOIN restaurants r
ON o.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_name
ORDER BY avg_rating DESC;

--10. Customers with Most orders
SELECT customer_id,
COUNT(*) AS total_orders
FROM orders
GROUP BY customer_id
ORDER BY total_orders DESC
LIMIT 10;

--11. Top Restaurants by Revenue
SELECT r.restaurant_name,
SUM(o.cost) AS total_revenue
FROM orders o 
JOIN restaurants r
ON o.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_name
ORDER BY total_revenue DESC
LIMIT 10;

--12. Delivery performance by Cuisine
SELECT r.cuisine_type,
AVG(o.delivery_time) AS avg_delivery_time
FROM orders o
JOIN restaurants r 
ON o.restaurant_id = r.restaurant_id
GROUP BY r.cuisine_type
ORDER BY avg_delivery_time;

--13. Restaurants with Highest Average Order Value
SELECT r.restaurant_name,
AVG(o.cost) AS avg_order_value
FROM orders o
JOIN restaurants r 
ON o.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_name
ORDER BY avg_order_value DESC
LIMIT 10;

--14. Orders with long delivery time (>40 Minutes)
SELECT * 
FROM orders
WHERE delivery_time > 40;

--15. Ranking Restaurants by Revenue
SELECT r.restaurant_name,
SUM(o.cost) As revenue,
RANK() OVER(ORDER BY SUM(o.cost)DESC) AS revenue_rank
FROM orders o
JOIN restaurants r 
ON o.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_name;

--16. Customer Lifetime Value
SELECT customer_id,
SUM(cost) AS lifetime_value
FROM orders
GROUP BY customer_id
ORDER BY lifetime_value DESC;

--17. Revenue Contribution  % 
SELECT
r.restaurant_name,
SUM(o.cost) AS revenue,
ROUND(100 * SUM(o.cost) /
SUM(SUM(o.cost)) OVER(),2) AS revenue_percentage
FROM orders o
JOIN restaurants r
ON o.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_name
ORDER BY revenue DESC;

--18. Most popular cuisine each day	
SELECT *
FROM (
SELECT
o.order_day,
r.cuisine_type,
COUNT(*) AS orders,
RANK() OVER(PARTITION BY o.order_day ORDER BY COUNT(*) DESC) AS rank
FROM orders o
JOIN restaurants r
ON o.restaurant_id = r.restaurant_id
GROUP BY o.order_day, r.cuisine_type
) t
WHERE rank = 1;

--19. TOP 10% REVENUE RESTAURANTS (PARETO ANALYSIS)
WITH revenue_table AS (
SELECT r.restaurant_name,
SUM(o.cost) AS revenue
FROM orders o 
JOIN restaurants r
ON o.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_name
)
SELECT * FROM (SELECT *,
NTILE(10) OVER(ORDER BY revenue DESC) AS revenue_bucket
FROM revenue_table
) t 
WHERE revenue_bucket = 1;

--20. Customer Segmentation (High / Medium / Low Spend)
WITH customer_spend AS (
SELECT
customer_id,
SUM(cost) AS total_spend
FROM orders
GROUP BY customer_id
)
SELECT
customer_id,
total_spend,
CASE
WHEN total_spend > 100 THEN 'High Value'
WHEN total_spend BETWEEN 50 AND 100 THEN 'Medium Value'
ELSE 'Low Value'
END AS customer_segment
FROM customer_spend
ORDER BY total_spend DESC;

--21. Fastest Restaurants (Best Delivery Performance)
SELECT
r.restaurant_name,
AVG(o.delivery_time) AS avg_delivery_time,
RANK() OVER(ORDER BY AVG(o.delivery_time)) AS speed_rank
FROM orders o
JOIN restaurants r
ON o.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_name
LIMIT 10;

--22. Customer Retention (Repeat Orders)
SELECT
customer_id,
COUNT(order_id) AS total_orders
FROM orders
GROUP BY customer_id
HAVING COUNT(order_id) > 1
ORDER BY total_orders DESC;

--23. Average Preparation Time by Cuisine
SELECT
r.cuisine_type,
AVG(o.food_preparation_time) AS avg_prep_time
FROM orders o
JOIN restaurants r
ON o.restaurant_id = r.restaurant_id
GROUP BY r.cuisine_type
ORDER BY avg_prep_time;

--24. Orders Above Average Cost
SELECT *
FROM orders
WHERE cost >
(
SELECT AVG(cost)
FROM orders
);

--25. Revenue Contribution by Cuisine
SELECT
r.cuisine_type,
SUM(o.cost) AS revenue,
ROUND(100 * SUM(o.cost) /
SUM(SUM(o.cost)) OVER(),2) AS revenue_percentage
FROM orders o
JOIN restaurants r
ON o.restaurant_id = r.restaurant_id
GROUP BY r.cuisine_type
ORDER BY revenue DESC;

--26. Top Customer per Restaurant
SELECT *
FROM (
SELECT
r.restaurant_name,
o.customer_id,
COUNT(*) AS orders,
RANK() OVER(PARTITION BY r.restaurant_name ORDER BY COUNT(*) DESC) AS rank
FROM orders o
JOIN restaurants r
ON o.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_name, o.customer_id
) t
WHERE rank = 1;

--27.Busiest Restaurants on Weekends
SELECT
r.restaurant_name,
COUNT(*) AS weekend_orders
FROM orders o
JOIN restaurants r
ON o.restaurant_id = r.restaurant_id
WHERE order_day = 'Weekend'
GROUP BY r.restaurant_name
ORDER BY weekend_orders DESC
LIMIT 10;