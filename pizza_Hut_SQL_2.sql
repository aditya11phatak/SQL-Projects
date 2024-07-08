-----BASIC-----

-- 1.Retrieve the total number of orders placed.
select count(order_id) as total_orders_placed
from orders


--2.Calculate the total revenue generated from pizza sales.
select sum(p.price * o.quantity) as total_revenue
from pizzas p
join order_details o
on p.pizza_id = o.pizza_id


--3.Identify the highest-priced pizza.
select t.name,p.price
from pizzas p
join pizza_types t
on p.pizza_type_id = t.pizza_type_id
order by price desc
limit 1


--4.Identify the most common pizza size ordered.
select size,count(*) as most_common_pizza_size
from order_details o
join pizzas p
on o.pizza_id = p.pizza_id
group by size
order by most_common_pizza_size desc


--5.List the top 5 most ordered pizza types along with their quantities.
select pizza_type_id,sum(quantity) as quantities
from pizzas p
join order_details o
on p.pizza_id = o.pizza_id
group by pizza_type_id
order by quantities desc
limit 5


-----INTERMEDIATE-----

--1.Join the necessary tables to find the total quantity of each pizza category ordered.
select pt.category,sum(od.quantity) as quantity
from order_details od
join pizzas p
on od.pizza_id = p.pizza_id 
join pizza_types pt
on p.pizza_type_id = pt.pizza_type_id
group by pt.category
order by quantity desc


--2.Determine the distribution of orders by hour of the day.
select o.time,count(order_details_id) as orders
from orders o
join order_details od
on o.order_id = od.order_id
group by o.time
order by o.time

SELECT 
    DATEPART(hour,time) AS hour_of_day,
    COUNT(*) AS number_of_orders
FROM 
    Orders
GROUP BY 
    DATEPART(hour, time)
ORDER BY 
    DATEPART(hour, time);

--3.Join relevant tables to find the category-wise distribution of pizzas.
select category,count(name)
from pizza_types
group by category


--4.Group the orders by date and calculate the average number of pizzas ordered per day.
select round (avg (sum),0)
from(select o.date,sum(od.quantity)
from orders o
join order_details od
on o.order_id = od.order_id
group by o.date) as order_quantity;


--5.Determine the top 3 most ordered pizza types based on revenue.
select p.pizza_type_id,sum(od.quantity * p.price) as revenue
from order_details od
join pizzas p
on od.pizza_id = p.pizza_id
group by p.pizza_type_id
order by revenue desc
limit 3


------ADVANCED------

--1.Calculate the percentage contribution of each pizza type to total revenue.
with total_sales as(
	select sum(od.quantity * p.price) as total_sales
    from order_details od
    join pizzas p
    on od.pizza_id = p.pizza_id)
	
select pt.category,
	(sum(od.quantity * p.price)/ ts.total_sales)*100 as revenue
from pizza_types pt
join pizzas p
on pt.pizza_type_id = p.pizza_type_id
join order_details od
on p.pizza_id = od.pizza_id
cross join total_sales ts
group by pt.category,ts.total_sales
order by revenue desc;


--2.Analyze the cumulative revenue generated over time.
select date,
sum(revenue) over(order by date)as cum_revenue
from
(select o.date,sum(od.quantity * p.price) as revenue
from order_details od
join pizzas p
on od.pizza_id = p.pizza_id
join orders o
on od.order_id = o.order_id
group by o.date) as sales


--3.Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name,revenue,rank
from(select category,name,revenue,
rank () over(partition by category order by revenue desc) as rank
from
(select pt.category,pt.name,sum(od.quantity * p.price) as revenue
from pizza_types pt
join pizzas p
on pt.pizza_type_id = p.pizza_type_id
join order_details od
on p.pizza_id = od.pizza_id
group by pt.category,pt.name) as a) as b
where rank <= 3;
