USE imdb;

/* Now that we have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/



-- Segment 1:




-- 1. Finding the total number of rows in each table of the schema?

SELECT COUNT(*) FROM director_mapping;
SELECT COUNT(*) FROM genre;
SELECT COUNT(*) FROM movie;
SELECT COUNT(*) FROM names;
SELECT COUNT(*) FROM ratings;
SELECT COUNT(*) FROM role_mapping;





-- 2. Finding columns in the movie table having null values-

SELECT
(SELECT COUNT(*) FROM movie WHERE id is NULL) AS id,
(SELECT COUNT(*) FROM movie WHERE title is NULL) AS title,
(SELECT COUNT(*) FROM movie WHERE year is NULL) AS year,
(SELECT COUNT(*) FROM movie WHERE date_published is NULL) AS date_published,
(SELECT COUNT(*) FROM movie WHERE duration is NULL) AS duration,
(SELECT COUNT(*) FROM movie WHERE country is NULL) AS country,
(SELECT COUNT(*) FROM movie WHERE worlwide_gross_income is NULL) AS worldwide_gross_income,
(SELECT COUNT(*) FROM movie WHERE languages is NULL) AS languages,
(SELECT COUNT(*) FROM movie WHERE production_company is NULL) AS production_company
;





-- Now as we can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- 3. Finding the total number of movies released each year? How does the trend look month wise? (Output expected)


-- Number of movies released each year
SELECT year, COUNT(title) AS number_of_movies FROM movie
GROUP BY year 
ORDER BY year;

-- Number of movies released each month
SELECT MONTH(date_published) AS month_num,
	   COUNT(title) AS number_of_movies
       FROM movie
GROUP BY month_num 
ORDER BY month_num;




/*The highest number of movies is produced in the month of March.
So, now that we have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- 4. Finding how many movies were produced in the USA or India in the year 2019??

SELECT year, COUNT(DISTINCT id) AS number_of_movies
FROM movie
WHERE (upper(country) LIKE '%USA%'
	  OR upper(country) LIKE '%India%')
      AND year = 2019;
      




/* USA and India produced more than a thousand movies in the year 2019. 
Let’s find out the different genres in the dataset.*/

-- 5. Finding the unique list of the genres present in the data set-

SELECT DISTINCT genre FROM genre;







/* So, RSVP Movies plans to make a movie of one of these genres.
Now, we want to know which genre had the highest number of movies produced in the last year
Combining both the movie and genres table can give more interesting insights. */

-- 6.Finding which genre had the highest number of movies produced overall-

SELECT genre, COUNT(id) AS number_of_movies
	FROM movie AS movie
	INNER JOIN genre AS genre
	ON genre.movie_id = movie.id
	GROUP BY genre
	ORDER BY number_of_movies DESC
LIMIT 1;







/* So, based on the insight that we just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- 7. Finding how many movies belong to only one genre-


SELECT genre_count , COUNT(movie_id) AS movies_count
FROM
	(SELECT movie_id, COUNT(genre) AS genre_count
	FROM genre
	GROUP BY movie_id
	ORDER BY genre_count DESC) AS genre_counts
WHERE genre_count = 1
GROUP BY genre_count;







/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- 8.Finding what is the average duration of movies in each genre-


SELECT genre, ROUND(AVG(duration),2) AS avg_duration
FROM movie AS mov
INNER JOIN genre as gen
ON gen.movie_id = mov.id
GROUP BY genre
ORDER BY avg_duration DESC;






/* Now we know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- 9.Finding what is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced-


WITH genre_summary AS 
( 
	SELECT genre , COUNT(movie_id) AS movie_count,
	RANK() OVER(ORDER BY COUNT(movie_id) DESC) AS genre_rank
    FROM genre
    GROUP BY genre
)

SELECT *
FROM genre_summary
WHERE genre= 'Thriller';





/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/




-- Segment 2:




-- 10.  Finding the minimum and maximum values in  each column of the ratings table except the movie_id column-


SELECT 
	MAX(avg_rating) AS max_avg_rating,
	MIN(avg_rating) AS min_avg_rating, 
	MAX(total_votes) AS max_total_votes,
	MIN(total_votes) AS min_total_votes,
	MAX(median_rating) AS max_median_rating,
	MIN(median_rating) AS min_median_rating
FROM ratings;


    

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- 11. Finding which are the top 10 movies based on average rating?

-- Finding the rank of movies according to avg_rating
-- Displaying top 10 movies using LIMIT clause
SELECT title, avg_rating,
	RANK() OVER(ORDER BY avg_rating DESC) AS movie_rank
FROM ratings AS rat
INNER JOIN movie AS mov
ON rat.movie_id = mov.id
LIMIT 10;






/* So, now that we know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- 12. Summarise the ratings table based on the movie counts by median ratings.


SELECT median_rating, COUNT(movie_id) AS movie_count 
FROM ratings 
GROUP BY median_rating
ORDER BY median_rating;






/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- 13. Finding which production house has produced the most number of hit movies (average rating > 8)-

SELECT production_company, 
	COUNT(movie_id) AS movie_count,
    RANK() OVER(ORDER BY COUNT(movie_id) DESC) AS prod_compony_rank
FROM ratings AS rat
INNER JOIN movie as mov
ON rat.movie_id = mov.id
WHERE avg_rating > 8
	AND production_company IS NOT NULL
GROUP BY production_company;







-- 14. Finding how many movies released in each genre during March 2017 in the USA had more than 1,000 votes-


SELECT genre, COUNT(mov.id) AS movie_count 
FROM movie AS mov
	INNER JOIN genre AS gen
    ON mov.id = gen.movie_id
    INNER JOIN ratings as rat
    ON mov.id = rat.movie_id
WHERE year = 2017
	  AND MONTH(date_published) = 3
      AND country LIKE '%USA%'
      AND total_votes > 1000
GROUP BY genre
ORDER BY movie_count DESC;
	  
      





-- Lets try to analyse with a unique problem statement.
-- 15. Finding movies of each genre that start with the word ‘The’ and which have an average rating > 8?

SELECT title, avg_rating, genre
FROM movie AS mov 
      INNER JOIN genre AS gen
      ON mov.id = gen.movie_id
	  INNER JOIN ratings as rat
      ON mov.id = rat.movie_id
WHERE title LIKE 'The%'
	  AND avg_rating > 8
ORDER BY avg_rating DESC;






-- We should also try our hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- 16. Of the movies released between 1 April 2018 and 1 April 2019, finding how many were given a median rating of 8-

SELECT median_rating, COUNT(mov.id) AS movie_count
FROM movie AS mov
	  INNER JOIN ratings AS rat
      ON mov.id = rat.movie_id
WHERE median_rating = 8
	  AND date_published BETWEEN '2018-04-01' AND '2019-04-01' 
GROUP BY median_rating;







-- 17. Finding if German movies get more votes than Italian movies-

SELECT country, SUM(total_votes) AS total_votes
FROM movie AS mov
	  INNER JOIN ratings AS rat
      ON mov.id = rat.movie_id
WHERE lower(country) = 'germany'
	  OR lower(country) LIKE 'italy'
GROUP BY country;






-- Answer is Yes

/* Now that we have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/




-- Segment 3:



-- 18. Finding which columns in the names table have null values??

SELECT 
(SELECT COUNT(*) FROM names WHERE name IS NULL) AS name_nulls,
(SELECT COUNT(*) FROM names WHERE height IS NULL) AS height_nulls,
(SELECT COUNT(*) FROM names WHERE date_of_birth IS NULL) AS date_of_birth_nulls,
(SELECT COUNT(*) FROM names WHERE known_for_movies IS NULL) AS known_for_movies_nulls;






/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- 19. Finding who are the top three directors in the top three genres whose movies have an average rating > 8?

WITH top_3_genres
AS
	(SELECT genre , COUNT(mov.id) AS movie_count,
	RANK() OVER(ORDER BY COUNT(mov.id) DESC) AS genre_rank
	FROM movie AS mov
		 INNER JOIN genre AS gen
		 ON mov.id = gen.movie_id
		 INNER JOIN ratings AS rat
		 ON mov.id = rat.movie_id
	WHERE avg_rating > 8
	GROUP BY genre 
	LIMIT 3
    )
    
    SELECT nam.name AS director_name,
		COUNT(dm.movie_id) AS movie_count
	FROM director_mapping as dm
		  INNER JOIN genre gen using (movie_id)
          INNER JOIN names as nam
          ON nam.id = dm.name_id
          INNER JOIN top_3_genres using (genre)
          INNER JOIN ratings using (movie_id)
	WHERE avg_rating >8
    GROUP BY name
    ORDER BY movie_count DESC LIMIT 3;




/* James Mangold can be hired as the director for RSVP's next project. 
Now, let’s find out the top two actors.*/

-- 20. Find who are the top two actors whose movies have a median rating >= 8-


SELECT nam.name as actor_name, COUNT(movie_id) AS movie_count
FROM role_mapping as rm
	INNER JOIN movie as mov
    ON mov.id = rm.movie_id
	INNER JOIN ratings AS rat USING (movie_id)
    INNER JOIN names AS nam
    ON rm.name_id = nam.id
WHERE rat.median_rating >= 8
	  AND category = 'actor'
GROUP BY actor_name
ORDER BY movie_count DESC LIMIT 2;






/* RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- 21. Finding which are the top three production houses based on the number of votes received by their movies-


SELECT production_company, SUM(total_votes) AS vote_count,
	RANK() OVER(ORDER BY SUM(total_votes) DESC) AS prod_comp_rank
FROM movie as mov
	INNER JOIN ratings as rat
    ON mov.id = rat.movie_id
GROUP BY production_company LIMIT 3;








/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- 22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 


WITH actor_ratings AS
(
SELECT 
	n.name as actor_name,
    SUM(r.total_votes) AS total_votes,
    COUNT(m.id) as movie_count,
	ROUND(
		SUM(r.avg_rating*r.total_votes)
        /
		SUM(r.total_votes)
			,2) AS actor_avg_rating
FROM
	names AS n
		INNER JOIN
	role_mapping AS a
		ON n.id=a.name_id
			INNER JOIN
        movie AS m
			ON a.movie_id = m.id
				INNER JOIN
            ratings AS r
				ON m.id=r.movie_id
WHERE category = 'actor' AND LOWER(country) like '%india%'
GROUP BY actor_name
)
SELECT *,
	RANK() OVER (ORDER BY actor_avg_rating DESC, total_votes DESC) AS actor_rank
FROM
	actor_ratings
WHERE movie_count>=5;

-- The top actor is Vijay Sethupathi. 





-- 23.Find out the top five actresses in Hindi movies released in India based on their average ratings-
-- Note: The actresses should have acted in at least three Indian movies. 


WITH actress_ratings AS
(
SELECT 
	n.name as actress_name,
    SUM(r.total_votes) AS total_votes,
    COUNT(m.id) as movie_count,
	ROUND(
		SUM(r.avg_rating*r.total_votes)
        /
		SUM(r.total_votes)
			,2) AS actress_avg_rating
FROM
	names AS n
		INNER JOIN
	role_mapping AS a
		ON n.id=a.name_id
			INNER JOIN
        movie AS m
			ON a.movie_id = m.id
				INNER JOIN
            ratings AS r
				ON m.id=r.movie_id
WHERE category = 'actress' AND LOWER(languages) like '%hindi%'
GROUP BY actress_name
)
SELECT *,
	ROW_NUMBER() OVER (ORDER BY actress_avg_rating DESC, total_votes DESC) AS actress_rank
FROM
	actress_ratings
WHERE movie_count>=3
LIMIT 5;





/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* 24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/

WITH thriller_movies
     AS (SELECT DISTINCT title,
                         avg_rating
         FROM   movie AS M
                INNER JOIN ratings AS R
                        ON R.movie_id = M.id
                INNER JOIN genre AS G using(movie_id)
         WHERE  genre LIKE 'THRILLER')
SELECT *,
       CASE
         WHEN avg_rating > 8 THEN 'Superhit movies'
         WHEN avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
         WHEN avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
         ELSE 'Flop movies'
       END AS avg_rating_category
FROM   thriller_movies; 







/* Until now, we have analysed various tables of the data set. 
Now, we will perform some tasks that will give us a broader understanding of the data in this segment.*/

-- Segment 4:

-- 25. Finding what is the genre-wise running total and moving average of the average movie duration- 


SELECT genre,
		ROUND(AVG(duration),2) AS avg_duration,
        SUM(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS UNBOUNDED PRECEDING) AS running_total_duration,
        AVG(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS 10 PRECEDING) AS moving_avg_duration
FROM movie AS m 
INNER JOIN genre AS g 
ON m.id= g.movie_id
GROUP BY genre
ORDER BY genre;





-- Let us find top 5 movies of each year with top 3 genres.

-- 26. Finding which are the five highest-grossing movies of each year that belong to the top three genres-
-- (Note: The top 3 genres would have the most number of movies.)


-- Top 3 Genres based on most number of movies

WITH top_genres AS
(
SELECT 
    genre,
    COUNT(m.id) AS movie_count,
	RANK () OVER (ORDER BY COUNT(m.id) DESC) AS genre_rank
FROM
    genre AS g
        LEFT JOIN
    movie AS m 
		ON g.movie_id = m.id
GROUP BY genre
)
,
top_grossing AS
(
SELECT 
    g.genre,
	year,
	m.title as movie_name,
    worlwide_gross_income,
    RANK() OVER (PARTITION BY g.genre, year
					ORDER BY CONVERT(REPLACE(TRIM(worlwide_gross_income), "$ ",""), UNSIGNED INT) DESC) AS movie_rank
FROM
movie AS m
	INNER JOIN
genre AS g
	ON g.movie_id = m.id
WHERE g.genre IN (SELECT DISTINCT genre FROM top_genres WHERE genre_rank<=3)
)
SELECT * 
FROM
	top_grossing
WHERE movie_rank<=5;






-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- 27.  Finding which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies-


WITH production_company_summary
     AS (SELECT production_company,
                Count(*) AS movie_count
         FROM   movie AS m
                inner join ratings AS r
                        ON r.movie_id = m.id
         WHERE  median_rating >= 8
                AND production_company IS NOT NULL
                AND Position(',' IN languages) > 0
         GROUP  BY production_company
         ORDER  BY movie_count DESC)
SELECT *,
       Rank() over(ORDER BY movie_count DESC) AS prod_comp_rank
FROM   production_company_summary
LIMIT 2; 






-- 28. Finding who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre-


WITH actress_summary AS
(
           SELECT     n.NAME AS actress_name,
                      SUM(total_votes) AS total_votes,
                      Count(r.movie_id)                                     AS movie_count,
                      Round(Sum(avg_rating*total_votes)/Sum(total_votes),2) AS actress_avg_rating
           FROM       movie                                                 AS m
           INNER JOIN ratings                                               AS r
           ON         m.id=r.movie_id
           INNER JOIN role_mapping AS rm
           ON         m.id = rm.movie_id
           INNER JOIN names AS n
           ON         rm.name_id = n.id
           INNER JOIN GENRE AS g
           ON g.movie_id = m.id
           WHERE      category = 'ACTRESS'
           AND        avg_rating>8
           AND genre = "Drama"
           GROUP BY   NAME )
SELECT   *,
         Rank() OVER(ORDER BY movie_count DESC) AS actress_rank
FROM     actress_summary LIMIT 3;






/* 29. Let's get the following details for top 9 directors (based on number of movies)
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


WITH next_date_published_summary AS
(
           SELECT     d.name_id,
                      NAME,
                      d.movie_id,
                      duration,
                      r.avg_rating,
                      total_votes,
                      m.date_published,
                      Lead(date_published,1) OVER(partition BY d.name_id ORDER BY date_published,movie_id ) AS next_date_published
           FROM       director_mapping                                                                      AS d
           INNER JOIN names                                                                                 AS n
           ON         n.id = d.name_id
           INNER JOIN movie AS m
           ON         m.id = d.movie_id
           INNER JOIN ratings AS r
           ON         r.movie_id = m.id ), top_director_summary AS
(
       SELECT *,
              Datediff(next_date_published, date_published) AS date_difference
       FROM   next_date_published_summary )
SELECT   name_id                       AS director_id,
         NAME                          AS director_name,
         Count(movie_id)               AS number_of_movies,
         Round(Avg(date_difference),2) AS avg_inter_movie_days,
         Round(Avg(avg_rating),2)               AS avg_rating,
         Sum(total_votes)              AS total_votes,
         Min(avg_rating)               AS min_rating,
         Max(avg_rating)               AS max_rating,
         Sum(duration)                 AS total_duration
FROM     top_director_summary
GROUP BY director_id
ORDER BY Count(movie_id) DESC limit 9;




