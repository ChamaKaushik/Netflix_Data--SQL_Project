# Netflix Movies and TV Shows Data Analysis using SQL

![](https://github.com/najirh/netflix_sql_project/blob/main/logo.png)

## Overview
This project is a part of my learning journey as a data analyst fresher, where I performed an analysis of Netflix's movies and TV shows dataset using SQL. The main objective was to gain insights from the data by writing SQL queries to answer real-world business questions and practice hands-on data analysis.

## Objectives

- Understand the distribution between movies and TV shows.
- Find out the most common ratings on Netflix.
- Explore content by release year, duration, and country.
- Filter and categorize content based on specific conditions like keywords or genres.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT 
    type,
    COUNT(*) as number_of_Movies_vs_TVShows
FROM netflix
GROUP BY type;
```

**Objective:** Helps to understand what type of content is more common on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
SELECT 
    type, 
    rating 
FROM (
    SELECT 
        type, 
        rating, 
        rating_count, 
        RANK() OVER (PARTITION BY type ORDER BY cnt DESC) AS rank
    FROM (
        SELECT 
            type, 
            rating, 
            COUNT(*) AS rating_count
        FROM netflix
        GROUP BY type, rating
    ) AS rating_counts
) AS ranked_ratings
WHERE rank = 1;
```

**Objective:** Identifies which ratings are most frequently used for each type.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT 
    release_year, title
FROM
    netflix
WHERE
    type = 'movie' AND release_year = 2020;
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
WITH RECURSIVE split_countries AS (
    -- Base case: extract the first country and the remaining string
    SELECT
        show_id,
        TRIM(SUBSTRING_INDEX(country, ',', 1)) AS new_country,
        LTRIM(SUBSTRING(country, LENGTH(SUBSTRING_INDEX(country, ',', 1)) + 2)) AS rest
    FROM netflix
    WHERE country IS NOT NULL

    UNION ALL

    -- Recursive case: extract the next country from the 'rest' string
    SELECT
        show_id,
        TRIM(SUBSTRING_INDEX(rest, ',', 1)) AS new_country,
        LTRIM(SUBSTRING(rest, LENGTH(SUBSTRING_INDEX(rest, ',', 1)) + 2)) AS rest
    FROM split_countries
    WHERE rest IS NOT NULL AND rest != ''
)

-- Final aggregation: count how many times each country appears
SELECT 
    new_country, 
    COUNT(*) AS content_count
FROM split_countries
GROUP BY new_country
ORDER BY content_count DESC
LIMIT 5;
```

**Objective:** Reveals which countries contribute the most content on the platform.

### 5. Identify the Longest Movie

```sql
SELECT 
    title, duration
FROM
    netflix
WHERE
    type = 'movie'
ORDER BY duration DESC
LIMIT 1;
```

**Objective:** Finds the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
-- Step 1: View the original date_added column
SELECT date_added 
FROM netflix;

-- Step 2: Add a new column to store the parsed date
ALTER TABLE netflix 
ADD COLUMN date_added_parsed DATE;

-- Step 3: Populate the new column by converting text to date format
UPDATE netflix
SET date_added_parsed = STR_TO_DATE(date_added, '%M %d, %Y');

-- Step 4: Verify the parsed date values
SELECT date_added_parsed
FROM netflix;

-- Step 5: Retrieve all content added in the last 5 years
SELECT *
FROM netflix 
WHERE date_added_parsed >= CURDATE() - INTERVAL 5 YEAR;
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT 
    type, title
FROM
    netflix
WHERE
    director LIKE '%Rajiv Chilaka%';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT 
    title, 
    new_duration
FROM (
    SELECT 
        type, 
        title, 
        SUBSTRING_INDEX(duration, ' ', 1) AS new_duration
    FROM netflix
    WHERE type = 'TV Show'
) AS t1
WHERE new_duration > 5;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
WITH RECURSIVE split_genres AS (
    -- Base case: get the first genre from the listed_in column
    SELECT
        show_id,
        TRIM(SUBSTRING_INDEX(listed_in, ',', 1)) AS genre,
        LTRIM(SUBSTRING(listed_in, LENGTH(SUBSTRING_INDEX(listed_in, ',', 1)) + 2)) AS rest
    FROM netflix
    WHERE listed_in IS NOT NULL

    UNION ALL

    -- Recursive step: continue splitting remaining genres
    SELECT
        show_id,
        TRIM(SUBSTRING_INDEX(rest, ',', 1)) AS genre,
        LTRIM(SUBSTRING(rest, LENGTH(SUBSTRING_INDEX(rest, ',', 1)) + 2)) AS rest
    FROM split_genres
    WHERE rest IS NOT NULL AND rest != ''
)

-- Final aggregation: count how many times each genre appears
SELECT 
    genre, 
    COUNT(*) AS content_count
FROM split_genres
GROUP BY genre
ORDER BY content_count DESC;
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
SELECT 
    YEAR(date_added_parsed) AS year_added,
    ROUND(
        COUNT(show_id) / 
        (SELECT COUNT(show_id) FROM netflix WHERE country LIKE '%India%') * 100, 2
    ) AS avg_content_release_per_year
FROM netflix
WHERE country LIKE '%India%'
GROUP BY year_added
ORDER BY avg_content_release_per_year DESC
LIMIT 5;
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
SELECT 
    title, 
    listed_in
FROM netflix 
WHERE type = 'Movie' 
  AND listed_in LIKE '%Documentaries%';

```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT * 
FROM netflix
WHERE director IS NULL;
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT * 
FROM netflix
WHERE casts LIKE '%Salman Khan%'
  AND release_year >= year(curdate()) - 10;
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
WITH RECURSIVE split_cast AS (
    -- Base case: extract the first actor from the casts column
    SELECT 
        show_id,
        TRIM(SUBSTRING_INDEX(casts, ',', 1)) AS actor,
        LTRIM(SUBSTRING(casts, LENGTH(SUBSTRING_INDEX(casts, ',', 1)) + 2)) AS rest
    FROM netflix
    WHERE type = 'Movie'
      AND country LIKE '%India%'
      AND casts IS NOT NULL

    UNION ALL

    -- Recursive case: extract the next actor from the remaining string
    SELECT 
        show_id,
        TRIM(SUBSTRING_INDEX(rest, ',', 1)) AS actor,
        LTRIM(SUBSTRING(rest, LENGTH(SUBSTRING_INDEX(rest, ',', 1)) + 2)) AS rest
    FROM split_cast
    WHERE rest IS NOT NULL AND rest != ''
)

-- Final result: count the number of movies each actor has appeared in
SELECT 
    actor, 
    COUNT(*) AS movie_count
FROM split_cast
GROUP BY actor
ORDER BY movie_count DESC
LIMIT 10;
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;
```

**Objective:** Labels content as "Good" or "Bad" based on keywords in the description. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Common ratings helps to understand content suitability and audience targeting.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This project improved my SQL querying skills and helped me to understand how to analyze real-world datasets through structured queries.

