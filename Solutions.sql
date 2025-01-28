DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
	show_id	VARCHAR(5),
	type    VARCHAR(10),
	title	VARCHAR(250),
	director VARCHAR(550),
	casts	VARCHAR(1050),
	country	VARCHAR(550),
	date_added	VARCHAR(55),
	release_year	INT,
	rating	VARCHAR(15),
	duration	VARCHAR(15),
	listed_in	VARCHAR(250),
	description VARCHAR(550)
);

select * from netflix;

--1. Count the number of Movies vs TV Shows
SELECT 
     TYPE,
	 COUNT(*)
FROM netflix
GROUP BY 1;


--2. Find the most common rating for movies and TV shows
SELECT 
   type,
   rating
FROM( 
SELECT 
     type,
	 rating,
	 COUNT(*),
	 RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS rank
FROM netflix	 
GROUP BY 1,2
) AS t1
WHERE rank=1;


--3. List all movies released in a specific year (e.g., 2020)
SELECT
	title,
	release_year
FROM netflix
WHERE release_year='2020'
AND type='Movie';

--4. List all the movies released in a particular year and display order should be recent year.
SELECT 
     release_year,
	 COUNT(*)
FROM netflix
GROUP BY 1
order BY 1 desc;


--5. Find the top 5 countries with the most content on Netflix
SELECT 
	COUNTRY
FROM(
SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(country,','))) AS country,
	COUNT(*)
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
)
LIMIT 5;


--6. Identify the longest movie
SELECT
	title
FROM(
SELECT
	title,
	SPLIT_PART(duration,' ',1)::INT AS duration
FROM netflix
WHERE duration IS NOT NULL
AND type='Movie'
)
ORDER BY duration desc
LIMIT 1;




--7. Find content added in the last 5 years

SELECT 
	title
FROM netflix
WHERE TO_DATE(date_added,'Month DD,year')>=CURRENT_DATE - INTERVAL '5 years';


--8. Find all the movies/TV shows by director 'Rajiv Chilaka'!
--solution 1
SELECT *
FROM
(
SELECT 
	*,
	UNNEST(STRING_TO_ARRAY(director, ',')) as director_name
FROM 
netflix
)
WHERE 
director_name = 'Rajiv Chilaka';

--solution 2
SELECT * FROM netflix WHERE director like '%Rajiv Chilaka%';


--9. List all TV shows with more than 5 seasons
SELECT
	title
FROM(
SELECT
	title,
	SPLIT_PART(duration,' ',1)::INT AS duration
FROM netflix
WHERE duration IS NOT NULL
AND type='TV Show'
);


--10. Count the number of content items in each 
SELECT 
     TRIM(UNNEST(STRING_TO_ARRAY(listed_in,','))) AS genre,
	 COUNT(*)
FROM netflix	
GROUP  BY 1;

/* 11. Find each year and the average numbers of content release by India on netflix. 
 return top 5 year with highest avg content release ! */
SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS date,
	COUNT(*) AS yearly_content,
	ROUND(
	COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country like '%India%') * 100,2) AS avg_content_per_year
FROM netflix
WHERE country like '%India%'
GROUP BY 1
ORDER BY 3 DESC
LIMIT 5;


--12. Find each year and the  numbers of content release by only India on netflix. 

SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS date,
	TRIM(UNNEST(STRING_TO_ARRAY(country,','))) AS country,
	COUNT(*)
FROM netflix
WHERE country='India'
GROUP BY 1,2;


--13. List all movies that are documentaries
SELECT 
	title
from(
SELECT 
     type,
     title,
	TRIM(UNNEST(STRING_TO_ARRAY(listed_in,','))) AS movie_type
FROM netflix
where type='Movie'
)
where movie_type='Documentaries';


--14. Find all content without a director
SELECT
	type,
	title
FROM netflix
WHERE director IS NULL;


--15. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT
	title FROM
(
SELECT
title,
TRIM(UNNEST(STRING_TO_ARRAY(casts,','))) as casts,
release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10
FROM netflix
)
WHERE casts='Salman Khan';


--16. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT 
TRIM(UNNEST(STRING_TO_ARRAY(casts,','))) as casts,
COUNT(*)
FROM netflix
WHERE country ILIKE '%india%' 
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;


/*17.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.*/
WITH cte as (
SELECT 
	*,
    CASE 
        WHEN description ilike '% kill %' OR description ilike '% violence %' THEN 'Bad'
        ELSE 'Good'
END AS Category
FROM netflix
)
SELECT
	category,
	COUNT(*) as total_content
FROM cte
GROUP BY 1;

