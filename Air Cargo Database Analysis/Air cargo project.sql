/*1. 
Create a database named AirCargo and import ticket_details.csv, routes.csv, passengers_on_flights.csv, and customer.csv from the given
resources into it.
*/
create database aircargo;
use aircargo;

/*2. 
Create an ER diagram for the given airlines' database. - Completed
*/

/*
3.	Write a query to display all the passengers who have traveled 
on routes 01 to 25 from the passengers_on_flights table.
*/
select customer_id,
	   route_id
from passengers_on_flights
where route_id between 1 and 25
order by customer_id ;

/*
4.	Write a query to identify the number of passengers and 
total revenue in business class from the ticket_details table.
*/
select class_id, 
	   count(class_id) as 'number of passengers',
       SUM(no_of_tickets * Price_per_ticket) AS 'total revenue'
from ticket_details
WHERE class_id = 'Business' ;

/*
5.	Write a query to display the full name of the customer 
by extracting the first name and last name from the customer table.
*/
select customer_id, 
	   concat(trim(first_name), 
			  ' ' , 
			  trim(last_name)) as 'Name'
from customer ;

/*
6.	Write a query to extract the customers who have registered and booked a ticket
from the customer and ticket_details tables.
*/
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    t.p_date,
    t.aircraft_id,
    t.no_of_tickets
FROM
    customer c
        INNER JOIN
    ticket_details t 
      ON c.customer_id = t.customer_id;

/*
7.	Write a query to identify the customer’s first name and last name 
based on their customer ID and brand (Emirates) from the ticket_details table.
*/
SELECT 
    c.customer_id,
    CONCAT(TRIM(c.first_name),
            ' ',
            TRIM(c.last_name)) AS CustomerName,
    t.brand
FROM
    customer c
        INNER JOIN
    ticket_details t 
		ON c.customer_id = t.customer_id
WHERE
    t.brand = 'Emirates';
    
/* 
8. Write a query to identify the customers who have traveled by Economy Plus class 
using the sub-query on the passengers_on_flights table.
*/
select customer_id, 
	   class_id 
from passengers_on_flights 
where customer_id in 
					(
                     select distinct customer_id 
                     from passengers_on_flights 
                     where class_id = 'Economy Plus'
					) 
     and class_id = 'Economy Plus'
group by customer_id;

/*
9.	Write a query to identify whether the revenue has crossed 10000 
using the IF clause on the ticket_details table.
*/
SELECT 
    IF(
		SUM(no_of_tickets * Price_per_ticket) > 10000,
        'Revenue is greater than 10k',
        'Revenue is less than 10k'
	  ) AS 'Revenue Status'
FROM
    ticket_details;
    
    
/*
10. Write a query to create and grant access to a new user to perform database operations.
*/
-- Step 1: Create a new user
DROP USER IF EXISTS 'junior'@'localhost';
CREATE USER 'junior'@'localhost'
identified by 'junior123';

-- Step 2: Grant all privileges on the database to the new user
GRANT ALL privileges ON air_cargo.* TO 'junior'@'localhost' ;
SELECT USER, host FROM mysql.user ;

/* 
11.	Write a query to find the maximum ticket price for each class 
using window functions on the ticket_details table. 
*/
select  class_id, 
		Price_per_ticket, 
        brand,
		MAX(Price_per_ticket) over (partition by class_id) as 'Max_ticketprice_by_ClassID'
from ticket_details
order by Price_per_ticket desc ;

/*
12. Write a query to extract the passengers whose route ID is 4 
by improving the speed and performance of the passengers_on_flights
table using the index.
*/
select customer_id, 
	   aircraft_id, 
       route_id
from passengers_on_flights 
where route_id = 4 ;

create index idx_route_id ON passengers_on_flights(route_id) ;
select customer_id, 
       aircraft_id, 
       route_id
from passengers_on_flights 
where route_id = 4 ;

/*
13.	 For the route ID 4, write a query to
view the execution plan of the passengers_on_flights table.
*/
explain select customer_id, 
			   aircraft_id, 
               route_id
from passengers_on_flights 
where route_id = 4 ;


/*
14.	Write a query to calculate the total price of all tickets 
booked by a customer across different aircraft IDs using the rollup function. 
*/
select customer_id, 
       aircraft_id, 
       SUM(no_of_tickets * Price_per_ticket) AS 'total price'
from ticket_details
group by 1,2 WITH ROLLUP ;

/*
15. Write a query to create a view with only business class customers and the airline brand.
*/
CREATE VIEW 
			Business_Class_View AS
select customer_id, 
       class_id, 
       brand
from ticket_details 
where class_id = 'Business' ;

select *
from business_class_view;


/*
16. Write a query to create a stored procedure that extracts all the details 
from the routes table where the traveled distance is more than 2000 miles.
*/
USE `aircargo`;
DROP procedure IF EXISTS `Distance_Miles_More_Than_2K`;

DELIMITER $$
USE `aircargo`$$
CREATE PROCEDURE Distance_Miles_More_Than_2K ()
BEGIN
select * 
from routes 
where distance_miles > 2000;
END$$

DELIMITER ;
call aircargo.Distance_Miles_More_Than_2K();


/*17. 
Using GROUP BY, determine the total number of tickets purchased by each customer
and the total price paid.
*/
select customer_id,
       count(no_of_tickets) as Total_tickets,
       sum(Price_per_ticket) as Total_Price 
from ticket_details
group by customer_id;


/*18. 
Calculate the average distance and average number of passengers per aircraft, 
considering only those routes with more than one departure date.
*/
select r.aircraft_id,
       round(avg(r.distance_miles),2)as average_distance,
       round(avg(p.total_passengers),2) as average_passengers 
from routes r
			join 
               (
                select route_id,
					   count(distinct customer_id) as total_passengers,
                       count(distinct travel_date) as total_departures 
                from passengers_on_flights p
				group by route_id
				having count(distinct travel_date)>1
			   )as p
        on r.route_id=p.route_id
group by r.aircraft_id;

/*Calculate the average number of passengers per flight route.*/
select route_id, 
       round(avg(total_passengers),2) as avg_passengers
from (
		select route_id,
			   count(distinct customer_id) as total_passengers
		from passengers_on_flights 
		group by route_id
	 ) as p
group by route_id;
                

