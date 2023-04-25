Q1. Who is the senior most employee based on job title?

select * from employee
order by levels desc

Q2. Which countries have the most invoices?

select COUNT(*) as c, billing_country from invoice
group by billing_country
order by c desc

Q3. What are top 3 values of total invoice?

select total from invoice
order by total desc
limit 3

Q4. Which city has the best customers?

Select Sum(total)as invoice_total, billing_city from invoice
group by billing_city
order by invoice_total desc

Q5. Who is the best customer?

select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as total from customer
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total desc

Q6. Return the email, first name, last name, & genre of all rock music listners in alphabetic order

Select distinct email,first_name,last_name
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
where track_id in(
select track_id from track
join genre on track.genre_id = genre.genre_id
where genre.name like 'Rock'
)
order by email;

Q7. Invite artist who have written most rock music. return top 10 artist name and track count

select artist.artist_id, artist.name, count(artist.artist_id) as number_of_songs
from track
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id=track.genre_id
where genre.name like 'rock'
group by artist.artist_id
order by number_of_songs desc
limit 10;

Q7. Return all track names that have a song length longer than average song length. Return name of songs and milliseconds for each track

SELECT name, milliseconds 
FROM track 
WHERE milliseconds > (SELECT AVG(milliseconds) as avg_track_length FROM track) 
GROUP BY name, milliseconds 
ORDER BY milliseconds DESC;

Q8. Find how much amount spent by each customer on artists?

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

Q9. Find out the most popular music genre in each country with highest amount of purchases

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1