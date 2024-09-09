USE pizza_db;

-- -------------EDA--------------

-- Retrieve the total number of orders placed.
SELECT 
    COUNT(*) AS total_no_orders
FROM
    orders;

-- Calculate the total revenue generated from pizza sales.
SELECT 
    SUM(Quantity * Price) AS total_revenue
FROM
    pizzas
        JOIN
    order_details ON pizzas.Pizza_id = order_details.Pizza_id;

-- Identify the highest-priced pizza.
SELECT 
    Name, Category, Size, MAX(Price) AS highest_priced_pizza
FROM
    pizza_type pt
        JOIN
    pizzas p ON pt.Pizza_type_id = p.Pizza_type_id
GROUP BY Name , Category , Size
ORDER BY highest_priced_pizza DESC
LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT 
    Size, COUNT(*) AS most_common_size
FROM
    pizzas p
        JOIN
    order_details od ON p.Pizza_id = od.Pizza_id
GROUP BY Size
ORDER BY most_common_size DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    Name, SUM(Quantity) AS Qty
FROM
    pizza_type pt
        JOIN
    pizzas p ON pt.Pizza_type_id = p.Pizza_type_id
        JOIN
    order_details od ON p.Pizza_id = od.Pizza_id
GROUP BY Name
ORDER BY Qty DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    Category, SUM(Quantity) AS Qty
FROM
    pizza_type pt
        JOIN
    pizzas p ON pt.Pizza_type_id = p.Pizza_type_id
        JOIN
    order_details od ON p.Pizza_id = od.Pizza_id
GROUP BY Category
ORDER BY Qty DESC;

-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(TIME) AS hour, COUNT(*) AS order_count
FROM
    Orders
GROUP BY hour
ORDER BY order_count DESC;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(qty), 0) AS Avg_pizza_order
FROM
    (SELECT 
        Date, SUM(Quantity) AS qty
    FROM
        Orders o
    JOIN order_details od ON o.Order_id = od.Order_id
    GROUP BY Date) AS date_cnt;

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pt.Name, SUM(p.Price * od.Quantity) AS revenue
FROM
    pizza_type pt
        JOIN
    pizzas p ON pt.Pizza_type_id = p.Pizza_type_id
        JOIN
    order_details od ON p.Pizza_id = od.Pizza_id
GROUP BY pt.Name
ORDER BY revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
WITH cte AS (
	SELECT pt.Name, SUM(p.Price*od.Quantity) AS revenue FROM pizza_type pt
	JOIN pizzas p ON pt.Pizza_type_id=p.Pizza_type_id
	JOIN order_details od ON p.Pizza_id=od.Pizza_id
	GROUP BY pt.Name)
SELECT Name, CONCAT(ROUND((revenue*100)/(SELECT SUM(revenue) FROM cte),2),'%') AS perc_cont FROM cte;


-- Analyze the cumulative revenue generated over time.
SELECT Date, revenue, SUM(revenue) OVER(ORDER BY Date) AS Cum_revenue FROM (
SELECT Date, SUM(Quantity*Price) AS revenue FROM order_details od
JOIN orders o ON od.Order_id=o.Order_ID
JOIN pizzas p ON od.Pizza_id=p.Pizza_id
GROUP BY Date) AS rev;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

-- ------------First Approach-------------

WITH cte AS (
SELECT Category, Name, SUM(Quantity*Price) AS revenue FROM pizza_type pt
JOIN pizzas p ON pt.Pizza_type_id=p.Pizza_type_id
JOIN order_details od ON p.Pizza_id=od.Pizza_id
GROUP BY Category, Name),
cte2 AS(
SELECT Category, Name, revenue, DENSE_RANK() OVER(PARTITION BY Category ORDER BY revenue DESC) AS rnk FROM cte)

SELECT Category, Name, revenue, rnk FROM cte2
WHERE rnk <=3;

-- -----------Second Approach-------------- 

SELECT Category, Name, revenue, rnk FROM 
(SELECT Category, Name, revenue, DENSE_RANK() OVER(PARTITION BY Category ORDER BY revenue DESC) AS rnk FROM 
(SELECT Category, Name, SUM(Quantity*Price) AS revenue FROM pizza_type pt
JOIN pizzas p ON pt.Pizza_type_id=p.Pizza_type_id
JOIN order_details od ON p.Pizza_id=od.Pizza_id
GROUP BY Category, Name) AS RNK2_) AS RNK_
WHERE rnk <=3;


