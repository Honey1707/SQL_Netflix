# SQL_Netflix

![Netflix Logo](https://github.com/Honey1707/SQL_Netflix/blob/main/netflix_logo.png)

## Overview
This project provides a data-driven analysis of Netflix's movies and TV shows using SQL. The objective is to gain insights into content distribution, ratings, genres, and trends over time, helping to understand Netflix's offerings more comprehensively.

## Objectives

- Analyze the distribution of content types (movies vs. TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Categorize content based on specific criteria and keywords for deeper insights.

## Dataset

The dataset used in this project is sourced from Kaggle:

- **Dataset Link:** [Netflix Movies and TV Shows](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
DROP TABLE IF EXISTS netflix_data;
CREATE TABLE netflix_data
(
	id             VARCHAR(6),
	category       VARCHAR(15),
	name           VARCHAR(255),
	filmmaker      VARCHAR(600),
	actors         VARCHAR(1100),
	origin_country VARCHAR(600),
	added_date     VARCHAR(60),
	year_released  INT,
	content_rating VARCHAR(20),
	run_time       VARCHAR(20),
	genres         VARCHAR(255),
	summary        VARCHAR(600)
);
```
## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT 
    type,
    COUNT(*) AS total_count
FROM netflix_data
GROUP BY type;
```
**Objective:** Understand the distribution of movies and TV shows on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
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
```

**Objective:** Identify the most common ratings for each content type.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT * 
FROM netflix_data
WHERE release_year = 2020;
```

**Objective:** Retrieve movies released in a specified year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT country, COUNT(*) AS content_count
FROM (
    SELECT UNNEST(STRING_TO_ARRAY(country, ',')) AS country
    FROM netflix_data
) AS country_data
WHERE country IS NOT NULL
GROUP BY country
ORDER BY content_count DESC
LIMIT 5;
```

**Objective:** Identify the top 5 countries with the most content on Netflix.

### 5. Identify the Longest Movie

```sql
SELECT * 
FROM netflix_data
WHERE type = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC
LIMIT 1;
```

**Objective:** Find the longest movie by duration.

### 6. Find Content Added in the Last 5 Years

```sql
SELECT *
FROM netflix_data
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';
```

**Objective:** Retrieve content added to Netflix within the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT *
FROM (
    SELECT *, UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
    FROM netflix_data
) AS director_data
WHERE director_name = 'Rajiv Chilaka';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT *
FROM netflix_data
WHERE type = 'TV Show' 
AND SPLIT_PART(duration, ' ', 1)::INT > 5;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(*) AS genre_count
FROM netflix_data
GROUP BY genre;
```

**Objective:**Count content items by genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
SELECT 
    release_year,
    COUNT(show_id) AS total_releases,
    ROUND((COUNT(show_id)::numeric / (SELECT COUNT(show_id) FROM netflix_data WHERE country = 'India') * 100), 2) AS avg_release_percent
FROM netflix_data
WHERE country = 'India'
GROUP BY release_year
ORDER BY avg_release_percent DESC 
LIMIT 5;
```

**Objective:** Rank the top 5 years by average content releases for India.

### 11. List All Movies that are Documentaries

```sql
SELECT * 
FROM netflix_data
WHERE listed_in LIKE '%Documentaries';
```

**Objective:** Retrieve movies categorized as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT * 
FROM netflix_data
WHERE director IS NULL;
```

**Objective:**  List content with no director assigned.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT *
FROM netflix_data
WHERE casts LIKE '%Salman Khan%'
AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
```

**Objective:** Count movies featuring Salman Khan over the last decade.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*) AS appearance_count
FROM netflix_data
WHERE country = 'India'
GROUP BY actor
ORDER BY appearance_count DESC
LIMIT 10;
```

**Objective:** Identify actors with the most frequent appearances in Indian movies.


### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
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
```

**Objective:** Classify content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise.


## Findings and Conclusion

- **Content Diversity:** Netflix offers a wide range of movies and TV shows across multiple genres and countries.
- **Rating Insights:** Identifying common ratings for each content type helps in understanding audience demographics.
- **Regional Trends:** Insights on top content-producing countries and Indian content trends over the years.
- **Content Categorization:** Classification based on keywords helps identify potentially sensitive content.

This analysis offers a comprehensive understanding of Netflix’s catalog and can be useful in content strategy planning.
