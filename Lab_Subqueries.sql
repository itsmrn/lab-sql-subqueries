-- LAB sql subqueries

-- DONE: How many copies of the film Hunchback Impossible exist in the inventory system?
select  COUNT(inventory_id) copies from inventory where film_id IN (select  film_id from
(select  film_id from film where title = "Hunchback Impossible") s1);

-- DONE: List all films whose length is longer than the average of all the films.
select title, length from film
where length > (select avg(length) from film);

-- DONE: Use subqueries to display all actors who appear in the film Alone Trip.

select first_name, last_name from actor
where actor_id in (select actor_id from film_actor
where film_id in (select  film_id from film where title = "Alone Trip"));

-- DONE: Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

select * from category;
select * from film;
select * from film_category;

select  title, category_id category from film
join film_category using (film_id)
where category_id IN (select category_id  from (select category_id from category where name = "family") s1);    

-- DONE: Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.
select * from customer;
select * from address;
select * from city;
select * from country;

select concat(first_name, " ", last_name) as customer, email 
from customer where address_id in (
select address_id  from address where city_id in (
select city_id from city where country_id in (
select country_id from country where country = "Canada")
)
);

-- DONE: Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.

#Step 1 -  Most prolific actor
select  actor_id,  count(*) films from film_actor 
group by actor_id 
order by films desc 
limit 1;

#Step 2: 
select fa.film_id,  f.title, fa.actor_id, a.first_name, a.last_name from film_actor fa 
left join film f on f.film_id = fa.film_id 
left join  actor a on a.actor_id = fa.actor_id 
inner join
 (
select actor_id,  count(*) films from film_actor 
group by actor_id 
order by films desc 
limit 1 
 ) pa on pa.actor_id = fa.actor_id
 order by f.title asc
 limit 1; 

-- DONE: Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments
#Step 1: Most profitable customer
select c.customer_id, sum(amount) as total from customer c 
left join payment as p on c.customer_id = p.customer_id 
group by c.customer_id
order by total desc 
limit 1;

#Step 2:Films rented by most profitable customer
select p.customer_id, f.title  from rental as r 
left join inventory as i on i.inventory_ID = r.inventory_id
left join film f on i.film_id = f.film_id 
inner join (
select c.customer_id, sum(p.amount) total FROM customer c 
left join payment as p ON c.customer_id = p.customer_id 
group by c.customer_id
order by total desc 
limit 1) p on r.customer_id = p.customer_id
group by p.customer_id, f.film_id, f.title 
order by f.title asc ;

-- DONE: Get the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client.

# Step 1: total amount spent by customer
select c.customer_id, sum(p.amount) total from customer c 
left join payment as p on c.customer_id = p.customer_id 
group by c.customer_id
order by total desc ;

#Step 2: average of the sum per customer
select avg(total) average from (
select c.customer_id, sum(p.amount) total from customer c 
left join payment as p on c.customer_id = p.customer_id 
group by c.customer_id) as s1 ;

#Step 3: customer that spent more than the avg of the total amount
select c.customer_id, sum(p.amount) total from customer c 
left join payment as p on c.customer_id = p.customer_id 
group by c.customer_id
having total > (select avg(total) avg_total from (
select c.customer_id, sum(p.amount) total from customer c 
left join payment as p on c.customer_id = p.customer_id 
group by c.customer_id) as s1 );
