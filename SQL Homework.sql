USE sakila;

#1A Display the first and last names of all actors from the table actor
SELECT first_name, last_name FROM actor;

#1B Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name
SELECT CONCAT(first_name, " ", last_name) AS "Actor Name"
FROM actor;

#2A You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name FROM actor
WHERE first_name="Joe";

#2B Find all actors whose last name contain the letters GEN:
SELECT * FROM actor
WHERE last_name LIKE "%GEN%";

#2C Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT * FROM actor
WHERE last_name LIKE "%LI%"
ORDER BY last_name, first_name;

#2D Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ("Afghanistan", "Bangladesh", "China");

#3A You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor
ADD description BLOB;

#3B Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
DROP COLUMN description;

#4A List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(last_name)
FROM actor
GROUP BY last_name;

#4B List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors.
SELECT last_name, count(last_name)
FROM actor
GROUP BY last_name
HAVING count(last_name)>2;

#4C The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
SET first_name ="HARPO"
WHERE first_name = "GROUCHO" AND last_name="WILLIAMS";

#4D Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name ="GROUCHO"
WHERE first_name = "HARPO" AND last_name="WILLIAMS";

#5A You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

#6A Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address
SELECT first_name, last_name, address
FROM staff s
LEFT OUTER JOIN address a
ON s.address_id = a.address_id;

#6B Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment
SELECT first_name, last_name, SUM(amount)
FROM staff s
INNER JOIN payment p
ON s.staff_id = p.staff_id
WHERE YEAR(p.payment_date)="2005" AND MONTH(p.payment_date)=08
GROUP BY last_name;

#6C List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT title, SUM(actor_id)
FROM film f
LEFT OUTER JOIN film_actor a
ON f.film_id = a.film_id
GROUP BY title;

#6D How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(inventory_id) 
FROM film f
LEFT OUTER JOIN inventory i
ON f.film_id = i.film_id
GROUP BY title
HAVING title="Hunchback Impossible";

#6E Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name
SELECT first_name, last_name, SUM(amount)
FROM customer c
LEFT OUTER JOIN payment p
ON c.customer_id = p.customer_id
GROUP BY last_name,first_name
ORDER BY last_name;

#7A The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title 
FROM film
WHERE language_id in
	(
    SELECT language_id
    FROM language
    WHERE name="English"
    )
HAVING title LIKE "Q%" OR title LIKE "K%";

#7B Use subqueries to display all actors who appear in the film Alone Trip
SELECT first_name, last_name 
FROM actor
WHERE actor_id IN
	(
    SELECT actor_id
    FROM film_actor
    WHERE film_id IN
		(
        SELECT film_id
        FROM film
        WHERE title="Alone Trip"
        )
    );

#7C You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT first_name, last_name, email, country
FROM customer c
LEFT OUTER JOIN address a ON c.address_id = a.address_id
LEFT OUTER JOIN city cy ON a.city_id = cy.city_id
LEFT OUTER JOIN country ctry ON cy.country_id = ctry.country_id
WHERE country = "Canada"

#7DSales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT title, name
FROM film f
LEFT OUTER JOIN film_category fc ON f.film_id = fc.film_id
LEFT OUTER JOIN category c ON fc.category_id = c.category_id
WHERE name="family";

#7E Display the most frequently rented movies in descending order
SELECT title, COUNT(rental_id) AS Rentals
FROM rental r
LEFT OUTER JOIN inventory i ON r.inventory_id = i.inventory_id
LEFT OUTER JOIN film f ON i.film_id = f.film_id
GROUP BY title
ORDER BY Rentals DESC;

#7F Write a query to display how much business, in dollars, each store brought in
SELECT store_id, SUM(amount)
FROM payment p
LEFT OUTER JOIN staff sf ON p.staff_id = sf.staff_id
GROUP BY store_id; 

#7G Write a query to display for each store its store ID, city, and country
SELECT store_id, city, country
FROM store s
LEFT OUTER JOIN address a ON s.address_id = a.address_id
LEFT OUTER JOIN city cy ON a.city_id = cy.city_id
LEFT OUTER JOIN country cty ON cy.country_id = cty.country_id;

#7H List the top five genres in gross revenue in descending order
SELECT c.name, SUM(p.amount)
FROM category c, film_category fc, inventory i, rental r, payment p
WHERE c.category_id = fc.category_id AND fc.film_id = i.film_id AND i.inventory_id = r.inventory_id AND r.rental_id = p.rental_id
GROUP BY c.name
ORDER BY SUM(p.amount) DESC LIMIT 5;

#8A In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW TopGenres AS
SELECT c.name, SUM(p.amount)
FROM category c, film_category fc, inventory i, rental r, payment p
WHERE c.category_id = fc.category_id AND fc.film_id = i.film_id AND i.inventory_id = r.inventory_id AND r.rental_id = p.rental_id
GROUP BY c.name
ORDER BY SUM(p.amount) DESC LIMIT 5;

#8B How would you display the view that you created in 8a?
SELECT * FROM TopGenres;

#8C You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW TopGenres;

