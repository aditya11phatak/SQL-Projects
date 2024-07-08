--QUESTION SET 1

--1. Who is the senior most employee based on job title?
select *
from employee
order by levels desc
limit  1

	
--2. Which countries have the most Invoices?
select billing_country,count(*)
from invoice
group by billing_country
order by count desc

	
--3. What are top 3 values of total invoice?
select total
from invoice
order by total desc
limit 3

	
--4. Which city has the best customers? We would like to throw a promotional Music 
-----Festival in the city we made the most money. Write a query that returns one city that 
-----has the highest sum of invoice totals. Return both the city name & sum of all invoice 
-----totals
select sum(total) as invoice_total,billing_city
from invoice
group by billing_city
order by invoice_total desc


--5. Who is the best customer? The customer who has spent the most money will be 
--declared the best customer. Write a query that returns the person who has spent the 
--most money
select c.customer_id,c.first_name,c.last_name,sum(i.total) as total_spent
from customer c
join invoice i
on c.customer_id = i.customer_id
group by c.customer_id
order by total_spent desc
limit 1

--------------------------------------------------------------------------------------------------------------------------------------------------------------

--QUESTION SET 2 
	
--1. Write query to return the email, first name, last name, & Genre of all Rock Music 
--listeners. Return your list ordered alphabetically by email starting with A
select distinct c.email,c.first_name,c.last_name,ii.track_id
from customer c
join invoice i
on c.customer_id=i.customer_id
join invoice_line ii
on i.invoice_id=ii.invoice_id
where track_id in(
     select track_id
     from track t
     join genre g
     on t.genre_id=g.genre_id
     where g.name='Rock'
     order by t.track_id)
order by email;


--2. Let's invite the artists who have written the most rock music in our dataset. Write a 
--query that returns the Artist name and total track count of the top 10 rock bands
select aa.artist_id,aa.name,count(aa.artist_id)as number_of_songs
 from track t
 join genre g
 on t.genre_id=g.genre_id
 join album a
 on t.album_id=a.album_id
 join artist aa
 on a.artist_id=aa.artist_id
where g.name='Rock'
group by aa.artist_id
order by number_of_songs desc
limit 10;


--3. Return all the track names that have a song length longer than the average song length. 
--Return the Name and Milliseconds for each track. Order by the song length with the 
--longest songs listed first
select name,milliseconds
from track
where milliseconds > (select avg(milliseconds)as avg_len
from track)
order by milliseconds desc


------------------------------------------------------------------------------------------------------------------------------------------------------------------
--QUESTION SET 3

--1. Find how much amount spent by each customer on artists? Write a query to return
--customer name, artist name and total spent
with best_selling_artist as(select a.artist_id,a.name,
sum(il.unit_price * il.quantity) as total_sales
from artist a
 join album aa
 on a.artist_id = aa.artist_id
   join track t
   on aa.album_id = t.album_id
     join invoice_line il
     on t.track_id = il.track_id
group by a.artist_id
order by 3 desc
limit 5)

select c.customer_id,c.first_name,c.last_name,bsa.name,
sum (ii.unit_price * ii.quantity) as amount_spent
from customer c
 join invoice i
 on c.customer_id = i.customer_id
   join invoice_line ii
   on i.invoice_id = ii.invoice_id
     join track t
     on t.track_id = ii.track_id
 join album a
 on t.album_id = a.album_id
 join best_selling_artist bsa 
 on a.artist_id = bsa.artist_id
 group by 1,2,3,4
 order by 5 desc;


--2. We want to find out the most popular music Genre for each country. We determine the 
--most popular genre as the genre with the highest amount of purchases. Write a query 
--that returns each country along with the top Genre. For countries where the maximum 
--number of purchases is shared return all Genres
with popular_genre as(select count(il.quantity) as purchase,c.country,g.name,g.genre_id,
row_number() over(partition by c.country order by count (il.quantity )desc) as rowno
from genre g
join track t
on g.genre_id = t.genre_id
join invoice_line il
on t.track_id = il.track_id
join invoice i
on il.invoice_id = i.invoice_id
join customer c
on i.customer_id = c.customer_id
group by 2,3,4
order by 2 asc , 1 desc)

select *
from popular_genre
where rowno <=1
order by purchase desc


--3. Write a query that determines the customer that has spent the most on music for each 
--country. Write a query that returns the country along with the top customer and how
--much they spent. For countries where the top amount spent is shared, provide all 
--customers who spent this amount
with recursive
	customer_with_country as(
select c.customer_id,first_name,last_name,billing_country,
sum(i.total) as total_spending
from customer c
join invoice i
on c.customer_id = i.customer_id
group by 1,2,3,4
order by 1,5 desc),

customer_max_spending as (
select billing_country,max(total_spending) as max_spending
from customer_with_country
group by billing_country)

select cc.billing_country,cc.total_spending,cc.first_name,cc.last_name
from customer_with_country cc
join customer_max_spending ms
on cc.billing_country = ms.billing_country
where cc.total_spending = ms.max_spending
order by 1 ;


