use music;

---- /*	Question Set 1 - Easy */


-- Q1. Who is the senior most employee based on job title?
SELECT title, last_name, first_name 
FROM employee
ORDER BY levels DESC
LIMIT 1;
--  Q2: Which countries have the most Invoices? 
SELECT count(*) AS Total_invoice , billing_country
FROM invoice
GROUP BY billing_country
ORDER BY Total_invoice DESC;

-- /* Q3: What are top 3 values of total invoice? */
SELECT total
FROM invoice
ORDER BY total DESC;

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city
we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

SELECT billing_city , SUM(total) AS invoice_total
FROM invoice
GROUP BY billing_city
ORDER BY invoice_total DESC
LIMIT 1;



/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) AS money_spent 
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY money_spent DESC 
LIMIT 1;

-----              /* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

SELECT DISTINCT email,first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoiceline ON invoice.invoice_id = invoiceline.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email;


/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and top 10 total track count of the of the rock bands. */

SELECT artist.name AS artist_name, count(*) AS total_track_count
FROM artist
JOIN album ON album.artist_id =  artist.artist_id
JOIN track ON track.album_id = album.album_id
JOIN genre ON genre.genre_id = track.genre_id
GROUP BY genre.name
ORDER BY total_track_count DESC
LIMIT 10;

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */
  
SELECT name , milliseconds, (SELECT AVG(milliseconds)
							FROM track) AS average_length
FROM track
WHERE milliseconds >= (SELECT AVG(milliseconds)
					   FROM track)
ORDER BY milliseconds DESC;

SET SESSION sql_mode = '';


-----                /* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists?
 Write a query to return customer name, artist name and total spent */

SELECT
    a.name AS artist_name,
    c.first_name AS customer_name,
    SUM(il.unit_price * il.quantity) AS amount_spent
FROM
    artist a
    JOIN album al ON al.artist_id = a.artist_id
    JOIN track t ON t.album_id = al.album_id
    JOIN invoice_line il ON il.track_id = t.track_id
    JOIN invoice i ON i.invoice_id = il.invoice_id
    JOIN customer c ON c.customer_id = i.customer_id
GROUP BY artist_name
ORDER BY amount_spent DESC;


/* Q2: We want to find out the most popular music Genre for each country. 
We determine the most popular genre as the genre with the highest amount of purchases. 
Write a query that returns each country along with the top Genre.*/

SELECT *
FROM (SELECT g.name AS top_genre, i.billing_country AS Country, SUM(i.total) AS amount_of_purchases
FROM genre g
JOIN track t ON t.genre_id = g.genre_id
JOIN invoice_line il ON il.track_id = t.track_id
JOIN invoice i ON i.invoice_id = il.invoice_id
JOIN customer c ON c.customer_id = i.customer_id
GROUP BY  g.name, i.billing_country
ORDER BY amount_of_purchases  DESC) j
GROUP BY j.Country;

/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Steps to Solve:  Similar to the above question. There are two parts in question- 
first find the most spent on music for each country and second filter the data for respective customers. */

WITH Customer_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY customer.customer_id, first_name, last_name, billing_country
		ORDER BY billing_country ASC, total_spending DESC)
        
SELECT * FROM Customer_with_country WHERE RowNo <= 1























