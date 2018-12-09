-- Instructions

-- 1a. Display the first and last names of all actors from the table `actor`.
USE [Sakila]
GO
select [first_name],[last_name] from [dbo].[actor]

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
USE [Sakila]
GO
select [first_name]+' ' +[last_name] as 'Actor Name' from [dbo].[actor]

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
USE [Sakila]
GO
select [actor_id],[first_name],[last_name] from [dbo].[actor] where first_name ='Joe'

-- 2b. Find all actors whose last name contain the letters `GEN`:
USE [Sakila]
GO
select [first_name],[last_name] from [dbo].[actor] where last_name like '%GEN%'

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
USE [Sakila]
GO
select [first_name],[last_name] from [dbo].[actor] where last_name like '%LI%' order by [last_name],[first_name]

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
USE [Sakila]
GO
select [country_id],[country] from [dbo].[country] where [country] in('Afghanistan', 'Bangladesh', 'China')

-- 3a. You want to keep a description of each actor. You don't think you will be performing q ueries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
USE [Sakila]
GO
ALTER TABLE actor
  ADD [description] varbinary(MAX);
-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
USE [Sakila]
GO
ALTER TABLE actor
  DROP COLUMN [description];
-- 4a. List the last names of actors, as well as how many actors have that last name.
USE [Sakila]
GO
select [last_name] ,count([last_name] ) as [last_name_count] from [dbo].[actor]  group by [last_name]

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
USE [Sakila]
GO
select [last_name] ,count(last_name ) as last_name_count from [dbo].[actor] group by [last_name] having count(last_name )>=2 

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
USE [Sakila]
GO
update [dbo].[actor] set [first_name] = 'HARPO' where  [first_name]='GROUCHO' and last_name='WILLIAMS'

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
USE [Sakila]
GO
update [dbo].[actor] set [first_name] = 'GROUCHO' where  [first_name]='HARPO' and last_name='WILLIAMS'

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?

USE [sakila]
GO

/****** Object:  Table [dbo].[address]    Script Date: 12/8/2018 1:39:30 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[address](
	[address_id] [int] IDENTITY(1,1) NOT NULL,
	[address] [varchar](50) NOT NULL,
	[address2] [varchar](50) NULL DEFAULT (NULL),
	[district] [varchar](20) NOT NULL,
	[city_id] [int] NOT NULL,
	[postal_code] [varchar](10) NULL DEFAULT (NULL),
	[phone] [varchar](20) NOT NULL,
	[last_update] [datetime] NOT NULL CONSTRAINT [DF_address_last_update]  DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[address_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[address]  WITH CHECK ADD  CONSTRAINT [fk_address_city] FOREIGN KEY([city_id])
REFERENCES [dbo].[city] ([city_id])
ON UPDATE CASCADE
GO

ALTER TABLE [dbo].[address] CHECK CONSTRAINT [fk_address_city]
GO

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
USE [Sakila]
GO
select [first_name],[last_name],[address]
from [dbo].[staff] st
inner join [dbo].[address] ad
on st.address_id = ad.address_id

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
USE [Sakila]
GO
select sum(amount),s.[staff_id] from
[dbo].[payment] p
inner join [dbo].[staff] s
on s.[staff_id] = p.[staff_id]

where [payment_date]>='08/1/2005' and [payment_date]<'9/1/2005'
group by s.[staff_id]

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
USE [Sakila]
GO
select [title],count([actor_id]) as actorcount
from [dbo].[film] f
inner join [dbo].[film_actor] fa
on fa.[film_id] = f.[film_id]
group by [title]

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
USE [Sakila]
GO
select count([inventory_id]) from [dbo].[inventory] 
where [film_id] in(select[film_id] from [film] where title = 'Hunchback Impossible')


-- 6e. Using the tables `payment` and `customer` and the `JOIN` command,list the total paid by each customer. List the customers alphabetically by last name:
--  ![Total amount paid](Images/total_payment.png)
USE [Sakila]
GO
select c.first_name,c.last_name ,sum([amount]) as 'Total Amount Paid'  from [dbo].[payment] p
inner join [dbo].[customer] c
on c.[customer_id] = p.[customer_id]
group by c.customer_id,c.first_name,c.last_name
order by c.last_name



-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
--films starting with the letters `K` and `Q` have also soared in popularity.
-- Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
USE [Sakila]
GO
select [title] from film where (title like 'k%' or title like 'Q%' )and language_id in(select language_id from [dbo].[language] where name='English')

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
USE [Sakila]
GO
select first_name+' '+last_name as Actors from actor where actor_id in(select actor_id from [dbo].[film_actor] where film_id in(
select film_id from film where [title] = 'Alone Trip')) order by last_name 

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
USE [Sakila]
GO
SELECT 
      c.[first_name] +' '+c.[last_name] as [customer name]
	  ,c.[email]
 FROM [customer] c
  inner join [address] a
  on a.[address_id] = c.[address_id]
  inner join [dbo].[city] ci
  on ci.[city_id] = a.[city_id]
  inner join [dbo].[country] co
  on co.[country_id] = ci.[country_id]
    where co.[country]='canada'

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
USE [Sakila]
GO
select title from film where [film_id] in(select film_id from [dbo].[category] where name='Family')

-- 7e. Display the most frequently rented movies in descending order.
USE [Sakila]
GO
select Top(1)(rental), title as most_frequent_rental,title 
from
(SELECT count(rental_date) rental, title
FROM rental AS r
INNER JOIN inventory AS i ON r.inventory_id = i.inventory_id
INNER JOIN film AS f ON f.film_id = i.film_id
GROUP BY  title  ) a
Order By rental desc
-- 7f. Write a query to display how much business, in dollars, each store brought in.
USE [Sakila]
GO
SELECT
  s.store_id
 ,c.city+','+co.country AS store
 ,SUM(p.amount) AS total
FROM payment AS p
INNER JOIN rental AS r ON p.rental_id = r.rental_id
INNER JOIN inventory AS i ON r.inventory_id = i.inventory_id
INNER JOIN store AS s ON i.store_id = s.store_id
INNER JOIN address AS a ON s.address_id = a.address_id
INNER JOIN city AS c ON a.city_id = c.city_id
INNER JOIN country AS co ON c.country_id = co.country_id

GROUP BY   
  s.store_id
, c.city+ ','+co.country 

-- 7g. Write a query to display for each store its store ID, city, and country.
USE [Sakila]
GO
select s.store_id, c.city, co.country
from store s
inner join [address] a
on a.[address_id] =s.[address_id]
inner join city c
on c.[city_id] = a.[city_id]
inner join [dbo].[country] co
on co.[country_id] = c.[country_id]

-- 7h. List the top five genres in gross revenue in descending order. (----Hint--*: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
USE [Sakila]
GO
Select Top(5)Amount,Name from
(select sum(amount) amount , c.name 
from rental r 
inner join [dbo].[payment] p
on p.rental_id = r.rental_id
inner join [dbo].[inventory] i 
on i.[inventory_id] = r.[inventory_id]
inner join [dbo].[film_category] f
on f.[film_id] = i.[film_id]
inner join category c
on c.category_id = f.category_id
group by c.name )a 
Order by amount desc

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
USE [Sakila]
GO

/****** Object:  View [dbo].[uvw_Sakila_TopGeners]    Script Date: 12/8/2018 2:57:27 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[uvw_Top_Five_Genres]
AS

Select Top(5)Amount,Name from
(select sum(amount) amount , c.name 
from rental r 
inner join [dbo].[payment] p
on p.rental_id = r.rental_id
inner join [dbo].[inventory] i 
on i.[inventory_id] = r.[inventory_id]
inner join [dbo].[film_category] f
on f.[film_id] = i.[film_id]
inner join category c
on c.category_id = f.category_id
group by c.name )a 
Order by amount desc

-- 8b. How would you display the view that you created in 8a?
select * from uvw_Top_Five_Genres

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
USE [sakila]
GO

/****** Object:  View [dbo].[uvw_Sakila_TopGeners]    Script Date: 12/8/2018 3:03:45 PM ******/
    DROP VIEW [dbo].[uvw_Top_Five_Genres]
GO


