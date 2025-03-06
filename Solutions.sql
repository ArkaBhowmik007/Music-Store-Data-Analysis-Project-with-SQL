/*EASY LEVEL QUESTIONS*/

--Q1: Who is the senior most employee based on job title?

SELECT *
FROM EMPLOYEE 
ORDER BY LEVELS DESC
LIMIT 1;

--Q2: Which countries have the most Invoices?

SELECT MAX(BILLING_COUNTRY) MAX_INVOICE
FROM INVOICE
GROUP BY BILLING_COUNTRY
ORDER BY BILLING_COUNTRY DESC
LIMIT 1;

--Q3: Which countries have the how many Invoices?

SELECT COUNT(BILLING_COUNTRY) TOTAL_INVOICE, BILLING_COUNTRY
FROM INVOICE
GROUP BY BILLING_COUNTRY
ORDER BY BILLING_COUNTRY DESC;

--Q4: What are top 3 values of total invoice? 

SELECT *
FROM INVOICE
ORDER BY TOTAL DESC
LIMIT 3;

/*Q5: Which city has the best customers? We would like to throw a promotional Music 
Festival in the city we made the most money. Write a query that returns one city that 
has the highest sum of invoice totals. Return both the city name & sum of all invoice 
totals*/
SELECT SUM(TOTAL) SUM_INVOICES,BILLING_CITY 
FROM INVOICE
GROUP BY BILLING_CITY
ORDER BY SUM_INVOICES DESC 
LIMIT 1;

/*Q6: Who is the best customer? The customer who has spent the most money will be 
declared the best customer. Write a query that returns the person who has spent the 
most money*/

SELECT C.CUSTOMER_ID,C.FIRST_NAME,C.LAST_NAME,SUM(I.TOTAL) SUM_INVOICES FROM
CUSTOMER C
JOIN INVOICE I
ON C.CUSTOMER_ID=I.CUSTOMER_ID
GROUP BY C.FIRST_NAME,C.LAST_NAME,C.CUSTOMER_ID
ORDER BY SUM_INVOICES DESC
LIMIT 1;

/*MODERATE LEVEL QUESTIONS*/

/*Q1: Write query to return the email, first name, last name, & Genre of all Rock Music 
listeners. Return your list ordered alphabetically by email starting with A*/

--Join Method
SELECT DISTINCT C.FIRST_NAME,C.LAST_NAME,C.EMAIL
FROM CUSTOMER C
JOIN INVOICE I
ON C.CUSTOMER_ID=I.CUSTOMER_ID

JOIN INVOICE_LINE IL
ON I.INVOICE_ID=IL.INVOICE_ID

JOIN TRACK T
ON IL.TRACK_ID=T.TRACK_ID

JOIN GENRE G
ON T.GENRE_ID=G.GENRE_ID

WHERE G.NAME LIKE 'Rock'
ORDER BY C.EMAIL DESC;

--SubQuery Method
SELECT DISTINCT C.FIRST_NAME,C.LAST_NAME,C.EMAIL
FROM CUSTOMER C
JOIN INVOICE I
ON C.CUSTOMER_ID=I.CUSTOMER_ID

JOIN INVOICE_LINE IL
ON I.INVOICE_ID=IL.INVOICE_ID

WHERE TRACK_ID IN (
	SELECT T.TRACK_ID FROM TRACK T
	JOIN GENRE G
	ON T.GENRE_ID=G.GENRE_ID
	WHERE G.NAME LIKE 'Rock'
)
ORDER BY C.EMAIL;

/*Let's invite the artists who have written the most rock music in our dataset. Write a 
query that returns the Artist name and total track count of the top 10 rock bands*/

SELECT A.ARTIST_ID,A.NAME ARTIST_NAME,COUNT(A.ARTIST_ID) NUMBER_OF_SONGS
FROM TRACK T
JOIN ALBUM AL
ON AL.ALBUM_ID=T.ALBUM_ID

JOIN ARTIST A
ON A.ARTIST_ID=AL.ARTIST_ID

JOIN GENRE G
ON G.GENRE_ID=T.GENRE_ID

WHERE G.NAME LIKE 'Rock'
GROUP BY A.ARTIST_ID,A.NAME
ORDER BY NUMBER_OF_SONGS DESC
LIMIT 10;

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT NAME,MILLISECONDS TIME
FROM TRACK
WHERE MILLISECONDS>(
	SELECT AVG(MILLISECONDS)AS AVG_TIME
	FROM TRACK
)
ORDER BY MILLISECONDS DESC;

/*HARD LEVEL QUESTIONS*/
/* Q1: Find how much amount spent by each customer on artists? 
Write a query to return customer name, artist name and total spent */

/* Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price
for each artist. */

WITH BEST_SELLING_ARTIST AS(
SELECT A.ARTIST_ID ARTIST_ID,A.NAME ARTIST_NAME,SUM(IL.QUANTITY*IL.UNIT_PRICE)TOTAL_SALES
FROM INVOICE_LINE IL
JOIN TRACK T
ON T.TRACK_ID=IL.TRACK_ID

JOIN ALBUM AL
ON AL.ALBUM_ID=T.ALBUM_ID

JOIN ARTIST A
ON A.ARTIST_ID=AL.ARTIST_ID

GROUP BY A.ARTIST_ID,A.NAME
ORDER BY TOTAL_SALES DESC
LIMIT 1
)
SELECT C.CUSTOMER_ID,C.FIRST_NAME,C.LAST_NAME,
BSA.ARTIST_NAME, SUM(IL.UNIT_PRICE*IL.QUANTITY) TOTAL_SPENT
FROM INVOICE I
JOIN CUSTOMER C
ON C.CUSTOMER_ID=I.CUSTOMER_ID

JOIN INVOICE_LINE IL
ON IL.INVOICE_ID=I.INVOICE_ID

JOIN TRACK T
ON T.TRACK_ID=IL.TRACK_ID

JOIN ALBUM AL
ON AL.ALBUM_ID=T.ALBUM_ID

JOIN BEST_SELLING_ARTIST BSA
ON BSA.ARTIST_ID=AL.ARTIST_ID

GROUP BY C.CUSTOMER_ID,C.FIRST_NAME,C.LAST_NAME,BSA.ARTIST_NAME
ORDER BY TOTAL_SPENT DESC;

/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

/* Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level. */

WITH POPULAR_GENRE AS(
SELECT COUNT(IL.QUANTITY) PURCHASE,C.COUNTRY,G.NAME,G.GENRE_ID,
ROW_NUMBER()OVER(PARTITION BY C.COUNTRY ORDER BY COUNT(IL.QUANTITY)DESC) ROW_NO
FROM INVOICE_LINE IL
JOIN INVOICE I
ON I.INVOICE_ID=IL.INVOICE_ID

JOIN TRACK T
ON T.TRACK_ID=IL.TRACK_ID

JOIN CUSTOMER C
ON C.CUSTOMER_ID=I.CUSTOMER_ID

JOIN GENRE G
ON G.GENRE_ID=T.GENRE_ID

GROUP BY C.COUNTRY,G.NAME,G.GENRE_ID
ORDER BY C.COUNTRY DESC, PURCHASE ASC
)
SELECT * FROM POPULAR_GENRE WHERE ROW_NO <= 1

/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Steps to Solve:  Similar to the above question. There are two parts in question- 
first find the most spent on music for each country and second filter the data for respective customers.*/

WITH CUSTOMER_COUNTRY AS(
	SELECT C.CUSTOMER_ID,C.FIRST_NAME,C.LAST_NAME,I.BILLING_COUNTRY,SUM(I.TOTAL)TOTAL_SPEND,
	ROW_NUMBER()OVER(PARTITION BY I.BILLING_COUNTRY ORDER BY SUM(I.TOTAL)DESC)ROW_NO 
	FROM INVOICE I
	JOIN CUSTOMER C
	ON C.CUSTOMER_ID=I.CUSTOMER_ID
	GROUP BY C.CUSTOMER_ID,C.FIRST_NAME,C.LAST_NAME,I.BILLING_COUNTRY
	ORDER BY TOTAL_SPEND DESC
)
SELECT * FROM CUSTOMER_COUNTRY WHERE ROW_NO<=1