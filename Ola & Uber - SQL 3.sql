CREATE TABLE trip_details(
    tripid INT PRIMARY KEY,
    location_id int,
    searches INT,
    searches_got_estimate INT,
    searches_for_quotes INT,
    searches_got_quotes INT,
    customer_not_cancelled int,
    driver_not_cancelled int,
    otp_entered int,
    end_ride int
);

CREATE TABLE trips (
    tripid INT PRIMARY KEY,
	id int,
    faremethod int,
    fare int,
    loc_from int,
    loc_to int,
    driverid INT,
    custid INT,
    distance int,
    duration_id int
);

CREATE TABLE durations (
    duration_id INT PRIMARY KEY,
    duration varchar (255)
);

CREATE TABLE payment(
    id INT PRIMARY KEY,
    method varchar (255)
);

CREATE TABLE assembly(
    location_id INT PRIMARY KEY,
    Assembly varchar (255)
);


select *
from assembly

--total trips
select count(distinct tripid)
from trip_details


---total drivers
select count (distinct driverid)
from trips

---total earnings
select sum(fare)
from trips

---total completed trips
select count (end_ride)
from trip_details
where end_ride = '1'
	
---total search
select sum(searches),sum(searches_got_estimate),sum(searches_for_quotes)
from trip_details

---total search which got estimate
select count (searches_got_estimate)
from trip_details
where searches_got_estimate = '1'

---total searches for quotes
select sum(searches_got_quotes)
from trip_details

---total searches which got quotes
select count(searches_for_quotes)
from trip_details
where searches_for_quotes ='1'

---total otp entered
select sum(otp_entered)
from trip_details

---total end ride
select sum(end_ride)
from trip_details

---cancelled booking by driver
select count(driver_not_cancelled)
from trip_details
where driver_not_cancelled = '0'

---cancelled booking by customer
select count(customer_not_cancelled)
from trip_details
where customer_not_cancelled = '0'

---average distance per trip
select sum(distance)/count(tripid) as average_distance_per_trip
from trips

---average fare per trip
select sum(fare)/count(tripid) as average_fare_per_trip
from trips

---distance travelled
select sum(distance) as distance_travelled
from trips

---which is the most used payment method 
select method,count(*)
from trips t
join payment p
on t.id = p.id
group by method

-- the highest payment was made through which instrument
select method,count(*)
from trips t
join payment p
on t.id = p.id
group by method
Limit 1

-- which two locations had the most trips
select assembly,count(*)
from assembly a
join trip_details t
on a.location_id = t.location_id
group by assembly
order by count desc
limit 2

--top 5 earning drivers
select driverid,sum(fare) as Earning
from trips
group by driverid
order by Earning desc
limit 5

-- which duration had more trips
select d.duration_id,count(*)
from durations d
join trips t
on d.duration_id = t.duration_id
group by d.duration_id
order by d.duration desc
limit 1
	
-- which area got the highest fares, cancellations,trips,
with trips as (select td.location_id,a.assembly,count(*) as Highest_no_of_trips
from trips t
join trip_details td
on t.tripid = td.tripid
join assembly a
on td.location_id = a.location_id
group by a.assembly,td.location_id
order by Highest_no_of_trips desc
),
cancellations as (select td.location_id,a.assembly,count(*) Highest_no_of_cancellations
from trip_details td
join assembly a
on td.location_id = a.location_id
where td.searches_got_estimate ='0'
group by a.location_id,td.location_id
order by Highest_no_of_cancellations desc
),
fare as (select td.location_id,a.assembly,sum(fare) as Highest_no_of_fare
from trips ts
join trip_details td
on ts.tripid = td.tripid
join assembly a
on td.location_id = a.location_id
group by a.assembly,td.location_id
order by Highest_no_of_fare desc)

select c.assembly,f.Highest_no_of_fare,t.Highest_no_of_trips,c.Highest_no_of_cancellations
from trips t
join cancellations c
on t.location_id = c.location_id
join fare f
on c.location_id = f.location_id
---------
WITH trips AS (
    SELECT 
        td.location_id, 
        a.assembly, 
        COUNT(*) AS highest_no_of_trips
    FROM 
        trips t
    JOIN 
        trip_details td ON t.tripid = td.tripid
    JOIN 
        assembly a ON td.location_id = a.location_id
    GROUP BY 
        a.assembly, 
        td.location_id
    ORDER BY 
        highest_no_of_trips DESC
),
cancellations AS (
    SELECT 
        td.location_id, 
        a.assembly, 
        COUNT(*) AS highest_no_of_cancellations
    FROM 
        trip_details td
    JOIN 
        assembly a ON td.location_id = a.location_id
    WHERE 
        td.searches_got_estimate = '0'
    GROUP BY 
        a.assembly, 
        td.location_id
    ORDER BY 
        highest_no_of_cancellations DESC
),
fare AS (
    SELECT 
        td.location_id, 
        a.assembly, 
        SUM(ts.fare) AS highest_no_of_fare
    FROM 
        trips ts
    JOIN 
        trip_details td ON ts.tripid = td.tripid
    JOIN 
        assembly a ON td.location_id = a.location_id
    GROUP BY 
        a.assembly, 
        td.location_id
    ORDER BY 
        highest_no_of_fare DESC
)

SELECT 
    c.assembly, 
    f.highest_no_of_fare, 
    t.highest_no_of_trips, 
    c.highest_no_of_cancellations
FROM 
    trips t
JOIN 
    cancellations c ON t.location_id = c.location_id
JOIN 
    fare f ON c.location_id = f.location_id;

---------
-- which duration got the highest trips and fares
with hf as(select duration_id,count(*) as number_of_trips,sum(fare) as fares
from trips
group by duration_id
order by number_of_trips desc,fares desc
limit 5)
	
select d.duration,h.number_of_trips,fares
from hf h
join durations d
on h.duration_id = d.duration_id
