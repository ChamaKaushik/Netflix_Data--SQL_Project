-- 15. Business Problems & Solutions


-- 1. Count the number of Movies vs TV Shows

select  type, count(*) as number_of_Movies_vs_TVShows from netflix 
group by type ;

-- 2. Find the most common rating for movies and TV shows

select type, rating from(
select type, rating, cnt, 
max(cnt) over (partition by type) as mx_value
from (
select type, rating, count(rating) as cnt from netflix
group by type, rating) as t1) as t2
where cnt = mx_value ;
    
    --  OR 

select type, rating 
from (
select type, rating, cnt, 
rank() over (partition by type order by cnt desc) as rnk 
from (
select type, rating, count(*) as cnt from netflix
group by type, rating) as t1 ) as t2
where rnk = 1 ;

-- 3. List all movies released in a specific year (e.g., 2020)

select release_year, title from netflix 
where type= 'movie' and release_year = 2020 ;

-- 4. Find the top 5 countries with the most content on Netflix
 
 WITH RECURSIVE split_countries AS (
  SELECT                                                            -- Base case: extract the first country and remaining string
    show_id,
    TRIM(SUBSTRING_INDEX(country, ',', 1)) AS new_country,
    LTRIM(SUBSTRING(country, LENGTH(SUBSTRING_INDEX(country, ',', 1)) + 2)) AS rest
  FROM netflix
  WHERE country IS NOT NULL

  UNION ALL

  SELECT                                                               -- Recursive case: extract the next country from rest
    show_id,
    TRIM(SUBSTRING_INDEX(rest, ',', 1)) AS new_country,
    LTRIM(SUBSTRING(rest, LENGTH(SUBSTRING_INDEX(rest, ',', 1)) + 2)) AS rest
  FROM split_countries
  WHERE rest IS NOT NULL AND rest != ''
)

SELECT new_country, COUNT(*) AS content_count                   -- Final aggregation: count content by country
FROM split_countries
GROUP BY new_country
ORDER BY content_count DESC 
limit 5;           
            
            
-- 5. Identify the longest movie

select title, duration from netflix 
where type = 'movie'  and duration = (select max(duration) from netflix ); 
   
--  OR
select title, duration from netflix 
where type = 'movie'
order by duration desc 
limit 1 ;

-- 6. Find content added in the last 5 years

select date_added from netflix ;

ALTER TABLE netflix ADD COLUMN date_added_parsed DATE;

UPDATE netflix
SET date_added_parsed = STR_TO_DATE(date_added, '%M %d, %Y') ;
rollback ;

SELECT date_added_parsed
FROM netflix ;

select * from netflix 
where date_added_parsed >= curdate()-INTERVAL 5 year ;

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

select type, title from netflix 
where director like '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons

select duration, substring_index(duration, ' ', 1) as new  from netflix ;

select duration, cast(substring_index(duration, ' ', 1) AS UNSIGNED) as new_duration 
from netflix ;

select * from netflix
where type = 'tv show' and duration IS NOT NULL and
cast(substring_index(duration, ' ', 1) AS UNSIGNED) > 5 ;

    -- OR
select title, new_duration from (
select type, title , substring_index(duration, ' ', 1) as new_duration from netflix
where type = 'tv show' ) as t1 
where new_duration > 5;


-- 9. Count the number of content items in each genre

WITH RECURSIVE split_genres AS (
  SELECT                                                       -- Base case: get first genre from listed_in
    show_id,
    TRIM(SUBSTRING_INDEX(listed_in, ',', 1)) AS genre,
    LTRIM(SUBSTRING(listed_in, LENGTH(SUBSTRING_INDEX(listed_in, ',', 1)) + 2)) AS rest
  FROM netflix
  WHERE listed_in IS NOT NULL

  UNION ALL

  SELECT                                                      -- Recursive part: split the rest
    show_id, TRIM(SUBSTRING_INDEX(rest, ',', 1)) AS genre,
    LTRIM(SUBSTRING(rest, LENGTH(SUBSTRING_INDEX(rest, ',', 1)) + 2)) AS rest
  FROM split_genres
  WHERE rest IS NOT NULL AND rest != ''
)
SELECT                                                       -- Final result: count genres
  genre, COUNT(*) AS content_count
FROM split_genres
GROUP BY genre ;


-- 10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!

select year(date_added_parsed) as year_added, 
round(count(show_id) / (select count(show_id) from netflix where country like '%india%') *100,2) as avg_content_relaese_per_year 
from netflix
where country like '%india%'
group by year_added 
order by avg_content_relaese_per_year desc 
limit 5 ;

-- 11. List all movies that are documentaries .

select title, listed_in from netflix 
where type = 'movie' and listed_in like '%documentaries%' ;

-- 12. Find all content without a director

select * from netflix 
where director IS NULL ;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years

select count(show_id)  as no_of_movies from netflix 
where type = 'movie' and casts like '%salman khan%' and 
release_year >= year(curdate()) - 10  ;
   --  OR 
select title, casts from netflix 
where type = 'movie' and casts like '%salman khan%' and 
release_year >= year(curdate()) - 10  ;
   
-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.(who appears mostly in indian movies)

WITH RECURSIVE split_cast AS (

  SELECT show_id,                                                            -- Base case: get first actor from cast
    TRIM(SUBSTRING_INDEX(casts, ',', 1)) AS actor,
    LTRIM(SUBSTRING(casts, LENGTH(SUBSTRING_INDEX(casts, ',', 1)) + 2)) AS rest
  FROM netflix
  WHERE type = 'Movie'
    AND country LIKE '%India%'
    AND casts IS NOT NULL

  UNION ALL

  SELECT show_id,                                                        -- Recursive case: split remaining actors
    TRIM(SUBSTRING_INDEX(rest, ',', 1)) AS actor,
    LTRIM(SUBSTRING(rest, LENGTH(SUBSTRING_INDEX(rest, ',', 1)) + 2)) AS rest
  FROM split_cast
  WHERE rest IS NOT NULL AND rest != ''
)

SELECT actor, COUNT(*) AS movie_count                                     -- Final output: count actor appearances
FROM split_cast
GROUP BY actor
ORDER BY movie_count DESC
LIMIT 10;


-- 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. 
-- Label content containing these keywords as 'Bad' and all other content as 'Good'. 
-- Count how many items fall into each category.

select  category, count(*) as content_count 
from (
SELECT description,
CASE
	WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'bad_content'
	ELSE 'good_content'
END category
FROM netflix ) as t1 
group by category ;

