/* 🎵 SQL Music Store Analysis by Sneha Belure */
/* ------------------------------------------- */
/* Data exploration and insights from a fictional music store database */

/* ----------------------------- */
/*   Question Set 1 - Easy */
/* ----------------------------- */

/* Q1: Who is the senior most employee based on job title? */
SELECT title, last_name, first_name 
FROM employee
ORDER BY levels DESC
LIMIT 1;

/* Q2: Which countries have the most invoices? */
SELECT COUNT(*) AS total_invoices, billing_country 
FROM invoice
GROUP BY billing_country
ORDER BY total_invoices DESC;

/* Q3: What are the top 3 highest invoice totals? */
SELECT total 
FROM invoice
ORDER BY total DESC
LIMIT 3;

/* Q4: In which city do our best customers live? */
SELECT billing_city, SUM(total) AS total_revenue
FROM invoice
GROUP BY billing_city
ORDER BY total_revenue DESC
LIMIT 1;

/* Q5: Who is the highest spending customer? */
SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) AS total_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 1;

/* ----------------------------- */
/*   Question Set 2 - Moderate */
/* ----------------------------- */

/* Q1: Emails of all Rock music listeners */
SELECT DISTINCT c.email, c.first_name, c.last_name
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoiceline il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
ORDER BY c.email;

/* Q2: Top 10 artists with the most Rock songs */
SELECT a.artist_id, a.name AS artist_name, COUNT(t.track_id) AS rock_songs
FROM track t
JOIN genre g ON t.genre_id = g.genre_id
JOIN album al ON t.album_id = al.album_id
JOIN artist a ON al.artist_id = a.artist_id
WHERE g.name = 'Rock'
GROUP BY a.artist_id
ORDER BY rock_songs DESC
LIMIT 10;

/* Q3: Tracks longer than average duration */
SELECT name, miliseconds
FROM track
WHERE miliseconds > (
	SELECT AVG(miliseconds) FROM track
)
ORDER BY miliseconds DESC;

/* ----------------------------- */
/*   Question Set 3 - Advanced */
/* ----------------------------- */

/* Q1: Customer spending on best-selling artist */
WITH best_artist AS (
	SELECT a.artist_id, a.name AS artist_name, 
	       SUM(il.unit_price * il.quantity) AS total_sales
	FROM invoice_line il
	JOIN track t ON il.track_id = t.track_id
	JOIN album al ON t.album_id = al.album_id
	JOIN artist a ON al.artist_id = a.artist_id
	GROUP BY a.artist_id
	ORDER BY total_sales DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, ba.artist_name,
       SUM(il.unit_price * il.quantity) AS amount_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN album al ON t.album_id = al.album_id
JOIN best_artist ba ON al.artist_id = ba.artist_id
GROUP BY c.customer_id, ba.artist_name
ORDER BY amount_spent DESC;

/* Q2: Most popular genre per country */
WITH genre_country AS (
	SELECT c.country, g.name AS genre, COUNT(il.quantity) AS purchase_count,
	       ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC) AS rn
	FROM customer c
	JOIN invoice i ON c.customer_id = i.customer_id
	JOIN invoice_line il ON i.invoice_id = il.invoice_id
	JOIN track t ON il.track_id = t.track_id
	JOIN genre g ON t.genre_id = g.genre_id
	GROUP BY c.country, g.name
)
SELECT country, genre, purchase_count
FROM genre_country
WHERE rn = 1;

/* Q3: Highest spending customer per country */
WITH customer_spending AS (
	SELECT c.customer_id, c.first_name, c.last_name, c.country, SUM(i.total) AS total_spent,
	       ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY SUM(i.total) DESC) AS rn
	FROM customer c
	JOIN invoice i ON c.customer_id = i.customer_id
	GROUP BY c.customer_id, c.first_name, c.last_name, c.country
)
SELECT customer_id, first_name, last_name, country, total_spent
FROM customer_spending
WHERE rn = 1;

/* 🔍 Customized & Reformatted by Sneha Belure */
/* 📌 GitHub: github.com/Snehabelure419 */
/* 🙏 Thank you for exploring this project! */
