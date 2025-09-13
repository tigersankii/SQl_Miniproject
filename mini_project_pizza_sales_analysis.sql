/*
**************************************************** Mini Project: Pizza Sales Analysis with SQL **********************************************************************

Problem Statement: This SQL project involves analyzing a pizza sales dataset to gain insights about sales patterns, order distributions, and revenue. The dataset contains details about customer orders, pizzas, their categories, and prices. Students will be required to write SQL queries to extract and analyze data based on a series of progressively challenging questions.

Dataset Link: Pizza Sales Dataset

Guidelines for Students:
1. Data Understanding:
○ Understand the structure of the dataset by inspecting the tables and their relationships.
○ Familiarize yourself with the schema, particularly the pizza categories, order details, and sales records.

2. Data Exploration:
○ Analyze the dataset by writing queries to retrieve basic information such as the total number of orders, revenue, and frequently ordered items.

3. Advanced Analysis:
○ Perform more complex queries involving joins and groupings to calculate metrics like revenue distribution, pizza category sales, and cumulative sales over time.

4. Optimization and Interpretation:
○ Ensure that your queries are optimized for performance (e.g., using GROUP BY, JOIN operations, and HAVING clauses).
○ Interpret the results of each query to understand trends and patterns.

*/

use pizza;

select * from orders;
select * from order_details;
select * from pizza_types;
select * from pizzas;

# 1. Retrieve the total number of orders placed.
select count(*) "Total no of order placed" from orders;

 # 2. Calculate the total revenue generated from pizza sales.
 select round(sum(order_details.quantity* pizzas.price),2) "total revanue" 
 from order_details 
 join pizzas 
 on pizzas.pizza_id = order_details.pizza_id;
 
# 3. Identify the highest-priced pizza.
select pizzas.price, pizza_types.name 
from pizzas  
join pizza_types  
on pizza_types.pizza_type_id = pizzas.pizza_type_id 
order by pizzas.price desc limit 1 ;
 
 # 4. Identify the most common pizza size ordered.
SELECT order_details.pizza_id as most_common_pizza_size_ordered, COUNT(*) as order_count
FROM order_details
GROUP BY order_details.pizza_id 
ORDER BY order_count DESC
limit 1;

# 5. List the top 5 most ordered pizza types along with their quantities.
SELECT order_details.pizza_id as "5 most pizza size ordered", COUNT(*) as quantities
FROM order_details 
GROUP BY order_details.pizza_id 
ORDER BY quantities DESC
limit 5;

# 6. Join the necessary tables to find the total quantity of each pizza category ordered.
select category ,sum(quantity)  as "Total quantity of each pizza" 
from pizzas 
join pizza_types 
on pizza_types.pizza_type_id =  pizzas.pizza_type_id 
join order_details on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category;

# 7. Determine the distribution of orders by hour of the day.
select hour(time), count(order_details.order_id) from orders
join order_details
on orders.order_id= order_details.order_id
group by hour(time)
order by hour(time);

# 8. Join relevant tables to find the category-wise distribution of pizzas.
SELECT category , count(order_details.order_id) as pizzas
FROM pizzas p
JOIN pizza_types pt 
ON p.pizza_type_id = pt.pizza_type_id
join order_details
on order_details.pizza_id = p.pizza_id
GROUP BY pt.category;

# 9. Group the orders by date and calculate the average number of pizzas ordered per day.
select orders.date ,  count(distinct orders.order_id) "orders" , sum(quantity) "total quantity" , sum(quantity)/count(distinct order_details.order_id) "average number of pizzas ordered per day."
from orders
join order_details 
on  order_details.order_id = orders.order_id 
group by orders.date;

# 10. Determine the top 3 most ordered pizza types based on revenue.
SELECT pt.name AS pizza_type, SUM(od.quantity * p.price) AS total_revenue
FROM order_details od
JOIN pizzas p 
ON od.pizza_id = p.pizza_id
JOIN pizza_types pt 
ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_revenue DESC
LIMIT 3;

# 11. Calculate the percentage contribution of each pizza type to total revenue.
select round(count(*)*100 / sum(quantity*pizzas.price),2) percentage, pizza_types.name 
from pizza_types
join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details 
on  order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name;

# 12. Analyze the cumulative revenue generated over time.
select hour(time) over_time,sum(quantity*price) revenue from orders
join order_details
on order_details.order_id = orders.order_id
join pizzas 
on pizzas.pizza_id = order_details.pizza_id
group by over_time
having over_time > 20;

# 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT category, name, pizza_revenue FROM (SELECT pt.category, pt.name, 
COALESCE(SUM(od.quantity * p.price), 0) AS pizza_revenue,
ROW_NUMBER() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity * p.price) DESC) AS rn
FROM pizza_types pt
JOIN pizzas p USING (pizza_type_id)
LEFT JOIN order_details od USING (pizza_id)
GROUP BY pt.category, pt.name) AS ranked_pizzas
WHERE rn <= 3
ORDER BY category, pizza_revenue DESC;

