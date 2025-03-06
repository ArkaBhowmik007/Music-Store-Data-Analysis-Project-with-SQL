# **Music Store Database Analysis Using SQL**

## **Project Overview**  
This project involves analyzing a music store’s database using SQL to gain insights into sales, customer behavior, and inventory. The database contains information about customers, purchases, artists, albums, genres, and employees. By running SQL queries, we can extract meaningful insights to help the store optimize its operations and boost revenue.

---

## **Objectives**  
1. **Analyze Sales Trends** – Identify best-selling albums, artists, and genres.  
2. **Understand Customer Behavior** – Find the most valuable customers and their purchasing patterns.  
3. **Evaluate Employee Performance** – Determine which sales representatives generate the most revenue.  
4. **Optimize Inventory Management** – Identify slow-moving stock and suggest improvements.  
5. **Revenue Analysis** – Break down revenue by region, customer type, and sales period.  

---

## **Database Schema**  
The music store database consists of the following tables:

### **1. Customers**  
- `customer_id` (Primary Key) – Unique identifier for each customer  
- `first_name`, `last_name` – Customer name  
- `email` – Contact email  
- `phone` – Contact number  
- `country` – Customer’s country  
- `postal_code` – Address details  
- `support_rep_id` – Employee assigned to assist the customer  

### **2. Employees**  
- `employee_id` (Primary Key) – Unique identifier for each employee  
- `first_name`, `last_name` – Employee name  
- `title` – Job title  
- `reports_to` – Manager of the employee  
- `hire_date` – Date of joining  
- `email` – Contact email  

### **3. Invoices**  
- `invoice_id` (Primary Key) – Unique identifier for each invoice  
- `customer_id` (Foreign Key) – Customer who made the purchase  
- `invoice_date` – Date of purchase  
- `total` – Total amount spent  

### **4. Invoice_Items**  
- `invoice_item_id` (Primary Key) – Unique identifier for each purchased item  
- `invoice_id` (Foreign Key) – Associated invoice  
- `track_id` (Foreign Key) – Purchased track  
- `unit_price` – Price per track  
- `quantity` – Number of tracks purchased  

### **5. Tracks**  
- `track_id` (Primary Key) – Unique identifier for each track  
- `name` – Track name  
- `album_id` (Foreign Key) – Associated album  
- `genre_id` (Foreign Key) – Track’s genre  
- `unit_price` – Price per track  

### **6. Albums**  
- `album_id` (Primary Key) – Unique identifier for each album  
- `title` – Album name  
- `artist_id` (Foreign Key) – Artist who created the album  

### **7. Artists**  
- `artist_id` (Primary Key) – Unique identifier for each artist  
- `name` – Artist name  

### **8. Genres**  
- `genre_id` (Primary Key) – Unique identifier for each genre  
- `name` – Genre name  

---

## **SQL Queries and Insights**

### **1. Best-Selling Artists**  
To identify which artists generate the most revenue:

```sql
SELECT a.name AS artist_name, SUM(ii.unit_price * ii.quantity) AS total_sales
FROM invoice_items ii
JOIN tracks t ON ii.track_id = t.track_id
JOIN albums al ON t.album_id = al.album_id
JOIN artists a ON al.artist_id = a.artist_id
GROUP BY a.name
ORDER BY total_sales DESC
LIMIT 10;
```

### **2. Most Popular Genre**  
To determine which genre sells the most:

```sql
SELECT g.name AS genre, SUM(ii.quantity) AS total_sales
FROM invoice_items ii
JOIN tracks t ON ii.track_id = t.track_id
JOIN genres g ON t.genre_id = g.genre_id
GROUP BY g.name
ORDER BY total_sales DESC
LIMIT 5;
```

### **3. Top 5 Customers by Spending**  
To find the most valuable customers:

```sql
SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) AS total_spent
FROM customers c
JOIN invoices i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC
LIMIT 5;
```

### **4. Employee Sales Performance**  
To check which employee has the highest sales:

```sql
SELECT e.employee_id, e.first_name, e.last_name, SUM(i.total) AS total_sales
FROM employees e
JOIN customers c ON e.employee_id = c.support_rep_id
JOIN invoices i ON c.customer_id = i.customer_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY total_sales DESC;
```

### **5. Monthly Revenue Trend**  
To analyze revenue trends over time:

```sql
SELECT strftime('%Y-%m', invoice_date) AS month, SUM(total) AS revenue
FROM invoices
GROUP BY month
ORDER BY month;
```

### **6. Slow-Moving Inventory**  
To find tracks that are selling the least:

```sql
SELECT t.name AS track_name, COUNT(ii.invoice_item_id) AS sales_count
FROM tracks t
LEFT JOIN invoice_items ii ON t.track_id = ii.track_id
GROUP BY t.name
ORDER BY sales_count ASC
LIMIT 10;
```

### **7. Who is the senior most employee based on job title?**

```sql
SELECT *
FROM EMPLOYEE 
ORDER BY LEVELS DESC
LIMIT 1;
```

### **8. Which countries have the most Invoices?**

```sql
SELECT MAX(BILLING_COUNTRY) MAX_INVOICE
FROM INVOICE
GROUP BY BILLING_COUNTRY
ORDER BY BILLING_COUNTRY DESC
LIMIT 1;
```

### **9. Which countries have the how many Invoices?**

```sql
SELECT COUNT(BILLING_COUNTRY) TOTAL_INVOICE, BILLING_COUNTRY
FROM INVOICE
GROUP BY BILLING_COUNTRY
ORDER BY BILLING_COUNTRY DESC;
```

### **10. What are top 3 values of total invoice?**

```sql
SELECT *
FROM INVOICE
ORDER BY TOTAL DESC
LIMIT 3;
```

### **11. Which city has the best customers?**

```sql
SELECT SUM(TOTAL) SUM_INVOICES,BILLING_CITY 
FROM INVOICE
GROUP BY BILLING_CITY
ORDER BY SUM_INVOICES DESC 
LIMIT 1;
```

### **12. Who is the best customer? The customer who has spent the most money will be?**
```sql
SELECT C.CUSTOMER_ID,C.FIRST_NAME,C.LAST_NAME,SUM(I.TOTAL) SUM_INVOICES FROM
CUSTOMER C
JOIN INVOICE I
ON C.CUSTOMER_ID=I.CUSTOMER_ID
GROUP BY C.FIRST_NAME,C.LAST_NAME,C.CUSTOMER_ID
ORDER BY SUM_INVOICES DESC
LIMIT 1;
```

### **13. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A**

Join Method
```sql
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
```

SubQuery Method
```sql
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
```
### **14. Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands**

```sql
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
```


### **15. Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.**

```sql
SELECT NAME,MILLISECONDS TIME
FROM TRACK
WHERE MILLISECONDS>(
	SELECT AVG(MILLISECONDS)AS AVG_TIME
	FROM TRACK
)
ORDER BY MILLISECONDS DESC;
```

### **16. Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent.**

```sql
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
```

### **17. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre.For countries where the maximum number of purchases is shared return all Genres.**

```sql
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
```

### **18. Write a query that determines the customer that has spent the most on music for each country.**

```sql
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
```
---

## **Insights and Recommendations**  

1. **Best-Selling Artists & Genres:**  
   - Focus marketing efforts on the top-selling artists and genres.  
   - Consider bundling top genres into playlists for promotions.  

2. **Customer Behavior Analysis:**  
   - Offer discounts or loyalty rewards to top customers to increase retention.  
   - Target low-spending customers with personalized recommendations.  

3. **Employee Performance:**  
   - Train low-performing employees with sales strategies from top performers.  
   - Reward high-performing employees with incentives.  

4. **Inventory Optimization:**  
   - Discontinue or discount slow-selling tracks to free up storage.  
   - Stock more of the best-selling albums and tracks.  

5. **Revenue Growth Strategies:**  
   - Introduce seasonal sales campaigns based on revenue trends.  
   - Expand into markets where sales are lower to increase reach.  

---

## **Conclusion**  
This SQL-based music store database analysis helps in identifying trends, optimizing sales, and improving overall business performance. By leveraging SQL queries, we can make data-driven decisions that enhance customer satisfaction and maximize revenue.
