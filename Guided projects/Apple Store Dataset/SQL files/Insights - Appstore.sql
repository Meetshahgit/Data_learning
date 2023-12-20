Create table Applestore_description_combined AS

Select * From applestore_description
Union All
Select * From applestore_description2
Union All
Select * From applestore_description3
Union All
Select * From applestore_description4;

-- check the number of unique apps in both tables

select count(Distinct id) As UniqueAppIDs
from appstore_data;

select count(distinct id ) AS UniqueAppIDs
from applestore_description_combined;

-- check for any missing values in key fields

select count(*) As MissingValues
From Appstore_data
Where track_name IS NULL OR user_rating is NULL or prime_genre is NULL;

select count(*) As MissingValues
From applestore_description_combined
Where app_desc Is Null;

-- find out the number of apps per genre

select prime_genre, count(*) AS NumApps
from appstore_data
group by prime_genre
Order by NumApps DESC;

-- get an over view of the apps user rating

select min(user_rating) As MinRating, Max(user_rating) As MaxRating, Avg(user_rating) AS AvgRating
From appstore_data;

-- determine whether paid apps have ratings than free apps

SELECT 
    CASE
        WHEN price > 0 THEN 'Paid'
        ELSE 'free'
    END AS App_type,
    AVG(user_rating) AS Avg_rating
From appstore_data
Group by App_type;
    
-- Check if apps with more supported languages have higher ratings

Select
case 
	when lang_num < 10 then '<10 languages'
    when Lang_num between 10 and 30 then '10 -30 lanaguages'
    else '>30 langauges'
    end AS language_bucket, 
    Avg(user_rating) as Avg_rating
From Appstore_data
Group by language_bucket
Order by Avg_rating Desc;

-- check Generes with low ratings
Select prime_genre,
Avg(user_rating) as Avg_rating
From appstore_data
group by prime_genre
Order by Avg_rating ASC
limit 10;

-- Check if there is a correlation between the length of the app description and the user rating

SELECT 
    CASE
        WHEN LENGTH(b.app_desc) < 500 THEN 'Short'
        WHEN LENGTH(b.app_desc) BETWEEN 500 AND 1000 THEN 'Medium'
        ELSE 'Long'
    END AS description_length_bucket,
    AVG(a.user_rating) AS Average_rating
FROM
    Appstore_data a
        JOIN
    Applestore_description_combined b ON a.id = b.id
GROUP BY description_length_bucket
ORDER BY average_rating DESC;

-- check the top-rate apps for each genre

Select prime_genre, track_name,user_rating
From 
(select 
prime_genre, track_name, user_rating, RANk()OVER(partition by prime_genre Order by user_rating DESC, rating_count_tot DESC) As App_rank
From Appstore_Data ) AS A
where
a.App_rank = 1;