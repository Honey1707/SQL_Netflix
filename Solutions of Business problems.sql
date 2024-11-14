-- Netflix Data Analysis Solutions

-- 1. Count the number of Movies vs TV Shows

SELECT 
    type,
    COUNT(*) AS total_count
FROM netflix_data
GROUP BY type;

-- 2. Find the most common rating for movies and TV shows

WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix_data
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rating_rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_common_rating
FROM RankedRatings
WHERE rating_rank = 1;

-- 3. List all movies released in a specific year (e.g., 2020)

SELECT * 
FROM netflix_data
WHERE release_year = 2020;

-- 4. Find the top 5 countries with the most content on Netflix

SELECT country, COUNT(*) AS content_count
FROM (
    SELECT UNNEST(STRING_TO_ARRAY(country, ',')) AS country
    FROM netflix_data
) AS country_data
WHERE country IS NOT NULL
GROUP BY country
ORDER BY content_count DESC
LIMIT 5;

-- 5. Identify the longest movie

SELECT * 
FROM netflix_data
WHERE type = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC
LIMIT 1;

-- 6. Find content added in the last 5 years

SELECT *
FROM netflix_data
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

-- 7. Find all the movies/TV shows directed by 'Rajiv Chilaka'

SELECT *
FROM (
    SELECT *, UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
    FROM netflix_data
) AS director_data
WHERE director_name = 'Rajiv Chilaka';

-- 8. List all TV shows with more than 5 seasons

SELECT *
FROM netflix_data
WHERE type = 'TV Show' 
AND SPLIT_PART(duration, ' ', 1)::INT > 5;

-- 9. Count the number of content items in each genre

SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(*) AS genre_count
FROM netflix_data
GROUP BY genre;

-- 10. Find each year and the average number of content releases by India on Netflix.
-- Return the top 5 years with the highest average content releases.

SELECT 
    release_year,
    COUNT(show_id) AS total_releases,
    ROUND((COUNT(show_id)::numeric / (SELECT COUNT(show_id) FROM netflix WHERE country = 'India') * 100), 2) AS avg_release_percent
FROM netflix_data
WHERE country = 'India'
GROUP BY release_year
ORDER BY avg_release_percent DESC 
LIMIT 5;

-- 11. List all movies that are documentaries

SELECT * 
FROM netflix_data
WHERE listed_in LIKE '%Documentaries';

-- 12. Find all content without a director

SELECT * 
FROM netflix_data
WHERE director IS NULL;

-- 13. Find how many movies actor 'Salman Khan' appeared in over the last 10 years

SELECT *
FROM netflix_data
WHERE casts LIKE '%Salman Khan%'
AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India

SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*) AS appearance_count
FROM netflix_data
WHERE country = 'India'
GROUP BY actor
ORDER BY appearance_count DESC
LIMIT 10;

-- 15. Categorize content based on keywords 'kill' and 'violence' in the description field.
-- Label content with these keywords as 'Sensitive' and others as 'General' and count each category.

SELECT 
    content_label,
    type,
    COUNT(*) AS content_count
FROM (
    SELECT 
        *,
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Sensitive'
            ELSE 'General'
        END AS content_label
    FROM netflix_data
) AS labeled_content
GROUP BY content_label, type
ORDER BY content_label, type;

-- End of analysis
