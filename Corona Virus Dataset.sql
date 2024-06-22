-- creation of database if not exist
create database corona_analysis;
-- use the database created
use corona_analysis;

## due to the different data type format(text) in the date column we need to alter the table and create a new column with the right datatype
alter table `corona virus dataset` add column new_date datetime;

-- updating our dataset to fill in our new date(created) with the data of our older column(date)
set sql_safe_updates =0;-- to turn of safe mode
UPDATE `corona virus dataset` 
SET 
    new_date = STR_TO_DATE(`Date`, '%d/%m/%Y');
    
    -- we need to drop our older date column
ALTER TABLE `corona virus dataset` DROP COLUMN `Date`;
set sql_safe_updates =1;-- turn on back the safe update mode

SELECT 
    *
FROM
    `corona virus dataset`;
    
    -- Q1. Write a code to check NULL values
SELECT 
    SUM(CASE
        WHEN Confirmed IS NULL THEN 1
        ELSE 0
    END) AS confirmed_null,
    SUM(CASE
        WHEN Deaths IS NULL THEN 1
        ELSE 0
    END) AS deaths_null,
    SUM(CASE
        WHEN Recovered IS NULL THEN 1
        ELSE 0
    END) AS recovered_null,
    SUM(CASE
        WHEN Province IS NULL THEN 1
        ELSE 0
    END) AS province_null,
    SUM(CASE
        WHEN `Country/Region` IS NULL THEN 1
        ELSE 0
    END) AS country_null,
    SUM(CASE
        WHEN Latitude IS NULL THEN 1
        ELSE 0
    END) AS latitude_null,
    SUM(CASE
        WHEN Longitude IS NULL THEN 1
        ELSE 0
    END) AS longitude_null,
    SUM(CASE
        WHEN new_date IS NULL THEN 1
        ELSE 0
    END) AS new_date_null
FROM
    `corona virus dataset`;

-- Q2. If NULL values are present, update them with zeros for all columns.
set sql_safe_updates =0;
UPDATE `corona virus dataset` 
SET 
    Province = COALESCE(Province, 0),
    `Country/Region` = COALESCE(`Country/Region`, 0),
    Longitude = COALESCE(Longitude, 0),
    Confirmed = COALESCE(Confirmed, 0),
    Deaths = COALESCE(Deaths, 0),
    Recovered = COALESCE(Recovered, 0),
    new_date = COALESCE(new_date, 0),
    Latitude = COALESCE(Latitude, 0);
    set sql_safe_updates =1;
    
    -- Q3. check total number of rows
SELECT 
    COUNT(*) AS total_rows
FROM
    `corona virus dataset`;

-- Q4. Check what is start_date and end_date
SELECT 
    MIN(new_date) AS start_date, MAX(new_date) AS end_date
FROM
    `corona virus dataset`;

-- Q5. Number of month present in dataset
SELECT 
    COUNT(DISTINCT MONTH(new_date)) AS num_months
FROM
    `corona virus dataset`;

-- Q6. Find monthly average for confirmed, deaths, recovered
SELECT 
    MONTH(new_date) AS month,
    AVG(Confirmed) AS avg_confirmed,
    AVG(Deaths) AS avg_deaths,
    AVG(Recovered) AS avg_recovered
FROM
    `corona virus dataset`
GROUP BY MONTH(new_date);

-- Q7. Find most frequent value for confirmed, deaths, recovered each month
SELECT month, Confirmed, Deaths, Recovered
FROM (
    SELECT date_format('month', new_date) AS month,
           confirmed, deaths, recovered,
           ROW_NUMBER() OVER (PARTITION BY date_format('month', new_date) ORDER BY COUNT(*) DESC) AS ranks
    FROM `corona virus dataset`
    GROUP BY month, Confirmed, Deaths,Recovered
) ranked
WHERE ranks = 1;

-- Q8. Find minimum values for confirmed, deaths, recovered per year
SELECT 
    YEAR(new_date) AS year,
    MIN(Confirmed) AS min_confirmed,
    MIN(Deaths) AS min_deaths,
    MIN(Recovered) AS min_recovered
FROM
    `corona virus dataset`
GROUP BY YEAR(new_date);

-- Q9. Find maximum values of confirmed, deaths, recovered per year
SELECT 
    YEAR(new_date) AS year,
    MAX(Confirmed) AS min_confirmed,
    MAX(Deaths) AS min_deaths,
    MAX(Recovered) AS min_recovered
FROM
    `corona virus dataset`
GROUP BY YEAR(new_date);

-- Q10. The total number of case of confirmed, deaths, recovered each month
SELECT 
    MONTH(new_date) AS month,
    SUM(Confirmed) AS total_confirmed,
    SUM(Deaths) AS total_deaths,
    SUM(Recovered) AS total_recovered
FROM
    `corona virus dataset`
GROUP BY MONTH(new_date);

-- Q11. Check how corona virus spread out with respect to confirmed case
--      (Eg.: total confirmed cases, their average, variance & STDEV )
SELECT 
    MONTH(new_date) AS month,
    AVG(Confirmed) AS avg_confirmed,
    VARIANCE(Confirmed) AS var_confirmed,
    SQRT(VARIANCE(Confirmed)) AS stdev_confirmed
FROM
    `corona virus dataset`
GROUP BY MONTH(new_date);

-- Q12. Check how corona virus spread out with respect to death case per month
--      (Eg.: total confirmed cases, their average, variance & STDEV )
SELECT 
    MONTH(new_date) AS month,
    AVG(Deaths) AS avg_deaths,
    VARIANCE(Deaths) AS var_deaths,
    SQRT(VARIANCE(Deaths)) AS stdev_deaths
FROM
    `corona virus dataset`
GROUP BY MONTH(new_date);

-- Q13. Check how corona virus spread out with respect to recovered case
--      (Eg.: total confirmed cases, their average, variance & STDEV )
SELECT 
    MONTH(new_date) AS month,
    AVG(Recovered) AS avg_recovered,
    VARIANCE(Recovered) AS var_recovered,
    SQRT(VARIANCE(Recovered)) AS stdev_recovered
FROM
    `corona virus dataset`
GROUP BY MONTH(new_date);

-- Q14. Find Country having highest number of the Confirmed case
SELECT 
    `Country/Region`, sum(Confirmed) AS total_confirmed
FROM
    `corona virus dataset`
GROUP BY `Country/Region`
ORDER BY total_confirmed DESC
LIMIT 5;

-- Q15. Find Country having lowest number of the death case
SELECT 
    `Country/Region`, MIN(Deaths) AS min_deaths
FROM
    `corona virus dataset`
GROUP BY `Country/Region`
ORDER BY min_deaths ASC;

-- Q16. Find top 5 countries having highest recovered case
SELECT 
    `Country/Region`, sum(Recovered) AS highest_recovered
FROM
    `corona virus dataset`
GROUP BY `Country/Region`
ORDER BY highest_recovered DESC
LIMIT 5;

-- to find the total confirmed, deaths, recovered cases
SELECT 
    SUM(Confirmed) AS total_confirmed,
    SUM(Deaths) AS total_deaths,
    SUM(Recovered) AS total_recovered
FROM
    `corona virus dataset`;
    
    -- total nunber of country/region
SELECT 
    COUNT(DISTINCT (`Country/Region`)) AS num_of_country
FROM
    `corona virus dataset`;
    
-- the end
