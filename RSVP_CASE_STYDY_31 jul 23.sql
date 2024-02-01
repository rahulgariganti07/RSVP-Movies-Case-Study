USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/



-- Segment 1:




-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:
        
select table_name,table_rows
from information_schema.tables
where table_schema = 'imdb';

/* observation */
-- director_mapping 		3867
-- genre					14662
-- income_table				3
-- movie					8698
-- names					23440
-- ratings					8230
-- role_mapping				16453


-- Q2. Which columns in the movie table have null values?
-- Type your code below: 
SELECT
SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS ID_NULL,
SUM(CASE WHEN title IS NULL THEN 1 ELSE 0 END) AS Title_NULL,
SUM(CASE WHEN year IS NULL THEN 1 ELSE 0 END) AS Year_NULL,
SUM(CASE WHEN date_published IS NULL THEN 1 ELSE 0 END) AS DatePublished_NULL,
SUM(CASE WHEN duration IS NULL THEN 1 ELSE 0 END) AS Duration_NULL,
SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS Country_NULL,
SUM(CASE WHEN worlwide_gross_income IS NULL THEN 1 ELSE 0 END) AS WorldWide_NULL,
SUM(CASE WHEN languages IS NULL THEN 1 ELSE 0 END) AS Language_NULL,
SUM(CASE WHEN production_company IS NULL THEN 1 ELSE 0 END) AS production_company_NULL
FROM movie;

-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

-- total numbers of movies released each year.
SELECT year,
       Count(id) AS number_of_movies
FROM   movie
GROUP  BY year; -- grouping by year

-- total number of movies released each month.
SELECT Month(date_published) AS 'Month',
       Count(id)             AS number_of_movies
FROM   movie
GROUP  BY Month(date_published)    -- grouping by month
ORDER  BY Month(date_published); 

/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

SELECT Count(DISTINCT id) AS number_of_movies
FROM   movie
WHERE  ( Upper(country) LIKE '%INDIA%'
          OR Upper(country) LIKE '%USA%')
       AND year = 2019; 
       

/* observation */
-- 1059 movies were produced in usa and india in 2019

/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:
SELECT DISTINCT genre
FROM   genre; 

/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:
SELECT g.genre,
       Count(m.id) AS num_of_movie
FROM   genre g
       INNER JOIN movie m
               ON g.movie_id = m.id
GROUP  BY genre
ORDER  BY Count(id) DESC  -- sorting in descreasing order
LIMIT  1; 				  -- only limiting to first row

/* observation */
-- Drama genre have the highest number of movies i.e 4285 

/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:
-- we can solve this question with the use of sub-query and cte we will use cte because it is more optimized than sub-query
                    
WITH genre_summary AS
(
SELECT
movie_id, COUNT(genre) AS number_of_movies
FROM genre
GROUP BY movie_id
HAVING number_of_movies=1
)
SELECT COUNT(movie_id) AS number_of_movies
FROM genre_summary;
/* observation */
-- 3289 movies belong to only one genre

/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)
/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
SELECT genre,
       Round(Avg(duration), 2) AS avg_duration
FROM   movie mov
       INNER JOIN genre gen
               ON mov.id = gen.movie_id
GROUP  BY genre
ORDER  BY Avg(mov.duration) DESC; 


/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

 WITH genre_summary AS
 (SELECT genre,
                Count(movie_id)                    AS movie_count,
                Rank()
                  OVER(
                    ORDER BY Count(movie_id) DESC) AS genre_rank
         FROM   genre
         GROUP  BY genre)
SELECT *
FROM   genre_summary
WHERE  genre = 'thriller'; 

/*observation*/
-- 'thriller’ genre has ‘thriller’ genre has 3rd rank among all the genres in terms of number of movies produced

/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/




-- Segment 2:




-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:
SELECT MIN(avg_rating) AS min_avg_rating, 
		MAX(avg_rating) AS max_avg_rating,
		MIN(total_votes) AS min_total_votes, 
        MAX(total_votes) AS max_total_votes,
		MIN(median_rating) AS min_median_rating, 
        MAX(median_rating) AS max_median_rating
From ratings;

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too

WITH avg_rating_summary
     -- we are using cte instead of limit because cte's are more optimized than limit
     AS (SELECT mov.title                         AS title,
                rat.avg_rating                    AS avg_rating,
                Dense_rank()
                  OVER(
                    ORDER BY rat.avg_rating DESC) movie_rank
         FROM   movie mov
                INNER JOIN ratings rat
                        ON mov.id = rat.movie_id)
SELECT *
FROM   avg_rating_summary
WHERE  movie_rank <= 10; 

/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have

SELECT median_rating, COUNT(movie_id) AS movie_count
FROM ratings
GROUP BY median_rating
ORDER BY movie_count desc;

/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:

SELECT production_company,
       Count(id)                    AS movie_count,
       Dense_rank()
         OVER(
           ORDER BY Count(id) DESC) AS prod_company_rank
FROM   movie AS mov
       INNER JOIN ratings AS rat
               ON mov.id = rat.movie_id
WHERE  avg_rating > 8         -- filtering the data
       AND production_company IS NOT NULL
-- another filter not null is used because most of the rows have null in place of production_company and we need to avoid then.
GROUP  BY production_company
ORDER  BY movie_count DESC;

-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
SELECT gen.genre,
       Count(gen.movie_id) AS movie_count
FROM   genre AS gen
       INNER JOIN ratings AS rat
               ON gen.movie_id = rat.movie_id
       INNER JOIN movie AS mov
               ON mov.id = gen.movie_id
WHERE  mov.country  LIKE '%USA%' 
       AND rat.total_votes > 1000
       AND Month(date_published) = 3
       AND year = 2017
GROUP  BY gen.genre
ORDER  BY movie_count DESC;


-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
SELECT title,
       avg_rating,
       genre
FROM   genre AS gen
       INNER JOIN ratings AS rat
               ON gen.movie_id = rat.movie_id
       INNER JOIN movie AS mov
               ON mov.id = gen.movie_id
WHERE  title LIKE 'THE%'
       AND avg_rating > 8
ORDER  BY avg_rating DESC; 


-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:
SELECT median_rating,
       Count(movie_id) AS movie_count
FROM   movie AS mov
       INNER JOIN ratings AS rat
               ON mov.id = rat.movie_id
WHERE  median_rating = 8
       AND date_published BETWEEN '2018-04-01' AND '2019-04-01'
GROUP  BY median_rating; 

-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:

SELECT country,
       Sum(total_votes) AS votes_count
FROM   movie AS m
       INNER JOIN ratings AS r
               ON r.movie_id = m.id
WHERE  country = 'germany'
        OR country = 'italy'
GROUP  BY country; 

-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/




-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:
/* QUERY to count null  */

-- NULL counts for individual columns of the names table

SELECT 
    SUM(CASE
        WHEN name IS NULL THEN 1
        ELSE 0
    END) AS name_nulls,
    SUM(CASE
        WHEN height IS NULL THEN 1
        ELSE 0
    END) AS height_nulls,
    SUM(CASE
        WHEN date_of_birth IS NULL THEN 1
        ELSE 0
    END) AS date_of_birth_nulls,
    SUM(CASE
        WHEN known_for_movies IS NULL THEN 1
        ELSE 0
    END) AS known_for_movies_nulls
FROM
    names;
-- date_of_birth, known_for_movies, height columns contains NULLS

/* columns containing NULLS are Height, date_of_birth, known_for_movies.

/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- CTE- Computes the top 3 genres using average rating > 8 condition and highest movie counts
-- Using the top genres derived from CTE, the directors are found whose movies have an average rating > 8 and are sorted based on no. of movies made.
WITH top_3_genres AS
(
SELECT	genre,
	Count(m.id) AS movie_count,
	Rank() OVER(ORDER BY Count(m.id) DESC) AS genre_rank
FROM	movie AS m
INNER JOIN genre AS g
ON g.movie_id = m.id
INNER JOIN ratings AS r
ON r.movie_id = m.id
WHERE avg_rating > 8
GROUP BY genre limit 3
)
SELECT 
    n.NAME AS director_name, COUNT(d.movie_id) AS movie_count
FROM
    director_mapping AS d
        INNER JOIN
    genre AS G USING (movie_id)
        INNER JOIN
    names AS n ON n.id = d.name_id
        INNER JOIN
    top_3_genres USING (genre)
        INNER JOIN
    ratings USING (movie_id)
WHERE
    avg_rating > 8
GROUP BY NAME
ORDER BY movie_count DESC
LIMIT 3;


-- Soubin Shahir, James Mangold and Anthony Russo are top three directors in the top 3 genres whose, movies have an average ratings > 8 
/* Top 3 directors in the top 3 genre are james mongld, joe russo and anthony russo. */

/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
SELECT 
    N.name AS actor_name, COUNT(movie_id) AS movie_count
FROM
    role_mapping AS RM
        INNER JOIN
    movie AS M ON M.id = RM.movie_id
        INNER JOIN
    ratings AS R USING (movie_id)
        INNER JOIN
    names AS N ON N.id = RM.name_id
WHERE
    R.median_rating >= 8
        AND category = 'ACTOR'
GROUP BY actor_name
ORDER BY movie_count DESC
LIMIT 2;

/* Mammootty and Mohanlal are 2 top actors */


/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

WITH ranking
     AS (SELECT production_company,
                Sum(total_votes)                    AS vote_count,
                Rank()
                  OVER(
                    ORDER BY Sum(total_votes) DESC) AS prod_comp_rank
         FROM   movie AS m
                INNER JOIN ratings AS r
                        ON r.movie_id = m.id
         GROUP  BY production_company)
SELECT production_company,
       vote_count,
       prod_comp_rank
FROM   ranking
WHERE  prod_comp_rank < 4; 
-- Top 3 production houses based on the no. of votes received by the movies are like Marvel Studios, Worner Bros and Twentieth Century Fox

/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
SELECT     n.NAME                                                                          AS actor_name,
           Any_value(r.total_votes)                                                        AS total_votes,
           Count(r.movie_id)                                                               AS movie_count,
           Round(Sum(avg_rating*total_votes)/Sum(total_votes),2)                           AS actor_avg_rating,
           Rank() OVER(ORDER BY Round(Sum(avg_rating*total_votes)/Sum(total_votes),2)DESC) AS actor_rank
FROM       names n
INNER JOIN role_mapping rm
ON         n.id = rm.name_id
INNER JOIN ratings r
ON         rm.movie_id = r.movie_id
INNER JOIN movie m
ON         m.id = r.movie_id
WHERE      rm.category = "actor"
AND        m.country = "India"
GROUP BY   n.NAME
HAVING     Count(r.movie_id) >=5;




-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
SELECT     n.NAME                                                                          AS actress_name,
           Any_value(total_votes)                                                          AS total_votes,
           Count(m.id)                                                                     AS movie_count,
           Round(Sum(avg_rating*total_votes)/Sum(total_votes),2)                           AS actress_avg_rating,
           Rank() OVER(ORDER BY Round(Sum(avg_rating*total_votes)/Sum(total_votes),2)DESC) AS actress_rank
FROM       names n
INNER JOIN role_mapping rm
ON         n.id = rm.name_id
INNER JOIN movie m
ON         rm.movie_id = m.id
INNER JOIN ratings r
ON         m.id = r.movie_id
WHERE      rm.category = "ACTRESS"
AND        m.languages LIKE "%HINDI%"
AND        m.country = "India"
GROUP BY   n.NAME
HAVING     Count(m.id) >=3 limit 5;

-- Top 5 actress in Hindi movies released in India based on their average ratings are Taapsee Pannu, Divya Dutta, Kriti Sanon, Kriti Kharabandh, Shraddha Kapoor







/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:
SELECT 
    title,
    avg_rating,
    CASE
        WHEN avg_rating > 8 THEN 'Superhit movies'
        WHEN avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
        WHEN avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
        ELSE 'Flop movies'
    END AS avg_rating_category
FROM
    movie m
        INNER JOIN
    genre g ON m.id = g.movie_id
        INNER JOIN
    ratings r ON r.movie_id = m.id
WHERE
    genre = 'thriller';
    


/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

SELECT genre,
       Round(Avg(duration), 2) AS avg_duration,
       Sum(Round(Avg(duration), 1))					-- calculating running total
         OVER(
           ORDER BY genre)  AS running_total_duration,
       Avg(Avg(duration))							-- calculating moving average
         OVER(
           ORDER BY genre)  AS moving_avg_duration
FROM   movie AS mov
       INNER JOIN genre AS gen
               ON mov.id = gen.movie_id
GROUP  BY genre; 									-- grouping by genre

-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies
WITH top3_genre AS
(
         -- cte of top 3 genres
         SELECT   genre,
                  Count(movie_id) AS movie_count
         FROM     genre
         GROUP BY genre
         ORDER BY movie_count DESC limit 3 ), top5_movie AS
(
           SELECT     genre,
                      year,
                      title AS movie_name,
                      CASE                                                                                                                                         
                      -- using case statments to convert the worlwide_gross_income from string to integer while ranking
                                 WHEN worlwide_gross_income LIKE '$%' THEN worlwide_gross_income                                                                   
                                 WHEN worlwide_gross_income LIKE 'inr%' THEN Concat('$',Cast(Cast(Substring(worlwide_gross_income, 4) AS SIGNED)/82.25AS CHAR(50)))
                                 -- here converting the worlwide_gross_income to int then converting from inr to dollor
                      END AS worlwide_gross_income ,
                      Dense_rank() OVER (partition BY year ORDER BY
                      CASE                                                                                                            
                      -- using case statments to convert the worlwide_gross_income from string to integer while ranking
                                 WHEN worlwide_gross_income LIKE '$%' THEN Cast(Substring(worlwide_gross_income, 2) AS SIGNED)         
                                 -- here converting the worlwide_gross_income which is in $  to int for orderding
                                 WHEN worlwide_gross_income LIKE 'inr%' THEN Cast(Substring(worlwide_gross_income, 4) AS SIGNED)/82.25 
                                 -- here converting the worlwide_gross_income to int then converting from inr to dollor for ordering which in dollor
                      END DESC ) AS movie_rank
           FROM       movie m
           INNER JOIN genre g
           ON         m.id = g.movie_id
           WHERE      genre IN
                      (
                             SELECT genre
                             FROM   top3_genre) )
SELECT *
FROM   top5_movie
WHERE  movie_rank <= 5;




-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:
SELECT     production_company,
           Count(id)                                  AS movie_count,
           Dense_rank() OVER(ORDER BY Count(id) DESC) AS prod_comp_rank
FROM       movie mov
INNER JOIN ratings rat
ON         mov.id = rat.movie_id
WHERE      median_rating>=8
AND        production_company IS NOT NULL
AND        position(',' IN languages)>0			-- using posisition to find if a movie is Multilingual or not
GROUP BY   production_company limit 2;		

-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

SELECT     NAME                                                  AS actress_name,
           Sum(total_votes)                                      AS total_votes,
           Count(rm.movie_id)                                    AS movie_count,
           Round(Sum(avg_rating*total_votes)/Sum(total_votes),2) AS actress_avg_rating,
           Rank() OVER(ORDER BY Count(rm.movie_id) DESC)         AS actress_rank
FROM       names n
INNER JOIN role_mapping rm
ON         n.id = rm.name_id
INNER JOIN ratings rat
ON         rat.movie_id = rm.movie_id
INNER JOIN genre gen
ON         gen.movie_id = rat.movie_id
WHERE      category="actress"
AND        avg_rating>8
AND        gen.genre="Drama"
GROUP BY   NAME limit 3;

/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:

WITH director_details AS
(
SELECT DM.name_id,
NAME,
DM.movie_id,
duration,
rat.avg_rating,
total_votes,
mov.date_published,
Lead(date_published,1) OVER(PARTITION BY DM.name_id ORDER BY date_published,movie_id ) AS next_date_published
-- calculating the lead of date published for finding the difference of days in each movie
FROM director_mapping AS DM
INNER JOIN names AS n ON n.id = DM.name_id
INNER JOIN movie AS mov ON mov.id = DM.movie_id
INNER JOIN ratings AS rat ON rat.movie_id = mov.id ),
director_summary AS
(
SELECT *,
Datediff(next_date_published, date_published) AS days_difference
-- calculating the days difference between movies of a perticular director
FROM director_details
)
SELECT name_id AS director_id,
NAME AS director_name,
COUNT(movie_id) AS number_of_movies,
ROUND(AVG(days_difference),2) AS avg_inter_movie_days,
ROUND(AVG(avg_rating),2) AS avg_rating,
SUM(total_votes) AS total_votes,
MIN(avg_rating) AS min_rating,
MAX(avg_rating) AS max_rating,
SUM(duration) AS total_duration
FROM director_summary
GROUP BY director_id
ORDER BY COUNT(movie_id) DESC
limit 9;












