# Rori Cooper - 8: SQL Homework
## Instructions/Code

USE sakila;

#1a. Display the first and last names of all actors from the table `actor`.
SELECT first_name, last_name
FROM actor;
    
#1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT UPPER(CONCAT(first_name, ' ', last_name)) AS 'Actor Name'
FROM actor;

#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor 
WHERE first_name = 'Joe';

#2b. Find all actors whose last name contain the letters `GEN`:
SELECT first_name, last_name
FROM actor
WHERE last_name like '%GEN%';

#2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT last_name, first_name
FROM actor
WHERE last_name like '%LI%';

#2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

#3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
#BLOB = "A Binary Large OBject (BLOB) is a collection of binary data stored as a single entity in a database management system. Blobs are typically images, audio or other multimedia objects, though sometimes binary executable code is stored as a blob." https://en.wikipedia.org/wiki/Binary_large_object
ALTER TABLE actor
ADD COLUMN description BLOB;

#3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor
DROP COLUMN description;

#4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*) AS 'Same Last Name Count#'
FROM actor GROUP BY last_name;

#4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(*) AS 'Same Last Name Count#>=2'
FROM actor GROUP BY last_name
HAVING count(*) >=2;
	
#4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

#4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS';

#5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
# Hint: <https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html>
SHOW CREATE TABLE address;

#6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT first_name, last_name, address
FROM staff st
JOIN address ad
ON st.address_id = ad.address_id;

#6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT payment.staff_id, staff.first_name, staff.last_name, 
payment.amount, payment.payment_date
FROM staff 
JOIN payment ON
staff.staff_id = payment.staff_id 
AND payment_date LIKE '2005-08%';

#6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT film.title AS 'Film Title', COUNT(act.actor_id) 
AS 'Actors Total'
FROM film_actor act
INNER JOIN film film
ON act.film_id = film.film_id
GROUP BY film.title;

#6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT film.title, count(*)
FROM inventory inv  JOIN film film ON inv.film_id = film.film_id
WHERE film.title = "Hunchback Impossible";

#6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT cust.last_name AS 'last_name',sum(pay.amount) AS '$ Total Paid'
FROM customer cust
JOIN payment pay ON (cust.customer_id = pay.customer_id)
GROUP BY cust.last_name;

#7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT * FROM(SELECT film.title, lang.name FROM film film JOIN language lang ON film.language_id = lang.language_id) 
AS title WHERE title.name = "English" AND (LEFT(title.title,1) = 'K' OR LEFT(title.title,1) = 'Q');

#7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN(Select actor_id FROM film_actor WHERE film_id IN (SELECT film_id FROM film WHERE title = 'Alone Trip'));
  
#7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT cust.first_name, cust.last_name, cust.email 
FROM customer cust
JOIN address addr ON (cust.address_id = addr.address_id)
JOIN city ct ON (ct.city_id = addr.city_id)
JOIN country ON (country.country_id = ct.country_id)
WHERE country.country= 'Canada';

#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT title, description FROM film 
WHERE film_id IN (SELECT film_id FROM film_category WHERE category_id IN(SELECT category_id FROM category WHERE name = "Family"));

#7e. Display the most frequently rented movies in descending order.
SELECT film.title, COUNT(rental_id) AS 'Top Rentals'
FROM rental rent
JOIN inventory inv ON (rent.inventory_id = inv.inventory_id)
JOIN film film ON (inv.film_id = film.film_id)
GROUP BY film.title
ORDER BY `Top Rentals` DESC;

#7f. Write a query to display how much business, in dollars, each store brought in.
SELECT id.store_id, SUM(amount) AS '$ Sales'
FROM payment pay
JOIN rental rent ON (pay.rental_id = rent.rental_id)
JOIN inventory inv ON (inv.inventory_id = rent.inventory_id)
JOIN store id ON (id.store_id = inv.store_id)
GROUP BY id.store_id; 

#7g. Write a query to display for each store its store ID, city, and country.
SELECT id.store_id, ct.city, cy.country 
FROM store id
JOIN address addr ON id.address_id = addr.address_id
JOIN city ct ON addr.city_id = ct.city_id
JOIN country cy ON ct.country_id = cy.country_id;

#7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT top.name AS 'Top 5 Genres', SUM(pay.amount) AS 'Sales' 
FROM category top
JOIN film_category cat ON top.category_id=cat.category_id
JOIN inventory inv ON cat.film_id=inv.film_id
JOIN rental rent ON inv.inventory_id=rent.inventory_id
JOIN payment pay ON rent.rental_id=pay.rental_id
GROUP BY top.name ORDER BY Sales DESC LIMIT 5;

#8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW Top_5_Genres_Sales AS
SELECT top.name AS 'Top 5 Genres', SUM(pay.amount) AS 'Sales' 
FROM category top
JOIN film_category cat ON top.category_id=cat.category_id
JOIN inventory inv ON cat.film_id=inv.film_id
JOIN rental rent ON inv.inventory_id=rent.inventory_id
JOIN payment pay ON rent.rental_id=pay.rental_id
GROUP BY top.name ORDER BY Sales DESC LIMIT 5;

#8b. How would you display the view that you created in 8a?
SELECT * FROM sakila.Top_5_Genres_Sales;

#8c. You find that you no longer need the view `Top_5_Genres_Sales`. Write a query to delete it.
DROP VIEW Top_5_Genres_Sales;