
-- To avoid any errors, check missing value / null value
-- Q1. Write a code to check NULL values
SELECT COUNT(*)-COUNT("Province") AS Province_nulls,
		COUNT(*)-COUNT("Country/Region") AS Country_Region_nulls,
		COUNT(*)-COUNT("Latitude") AS Latitude_nulls,
		COUNT(*)-COUNT("Longitude") AS Longitude_nulls,
		COUNT(*)-COUNT("Date") AS Date_nulls,
		COUNT(*)-COUNT("Confirmed") AS Confirmed_nulls,
		COUNT(*)-COUNT("Deaths") AS Deaths_nulls,
		COUNT(*)-COUNT("Recovered") AS Recovered_nulls
FROM public.coronavirus_data

--Explanation:
-- COUNT(*) counts all rows in the table, regardless of the values in any columns.
-- COUNT("Province") counts all rows where Province is not null.
-- COUNT(*)-COUNT("Province"): This gives the count of null values by subtracting
--  the count of non-null values from the total count.
-- The same logic aapllies to all the other columns.

--Q2. If NULL values are present, update them with zeros for all columns.
--There are no null values.

-- Q3. check total number of rows
SELECT COUNT(*) AS total_no_of_rows
FROM public.coronavirus_data

--There are 78386 rows.

-- Q4. Check what is start_date and end_date
--I discovered that the Date Column is text type. So i decided to convert it:
--Converting the string-formatted date column to DATE type
-- Step 1: Add a new DATE column
ALTER TABLE public.coronavirus_data
ADD COLUMN new_date Date;

-- Step 2: Convert and update the new column with the correct date format
UPDATE public.coronavirus_data
SET new_date = TO_DATE("Date", 'DD-MM-YYYY');

--Step 3:Drop the old string-formatted date column
ALTER TABLE public.coronavirus_data
DROP COLUMN "Date";

--sTEP 4: Rename the new DATE column to the original column name
ALTER TABLE public.coronavirus_data
RENAME COLUMN new_date TO Date;

SELECT MIN(date) AS start_date,
	   MAX(date) AS end_date
FROM public.coronavirus_data

--The Start_Date: 2020-01-22 and the End_Date: 2021-06-13

-- Q5. Number of month present in dataset
SELECT COUNT(DISTINCT DATE_TRUNC('month', date)) AS number_of_months
FROM public.coronavirus_data

--There are 18 months.
-- Q6. Find monthly average for confirmed, deaths, recovered
--At this point, I changed the column_names to lowercase and also replace the '/'
--in Country/Region column.

SELECT TO_CHAR(DATE_TRUNC('month', date), 'Month YYYY') AS month_year,
        ROUND(AVG(confirmed), 2) avg_confirmed,
		ROUND(AVG(deaths), 2) avg_deaths,
		ROUND(AVG(recovered), 2) avg_recovered
FROM public.coronavirus_data
GROUP BY 1
ORDER BY MIN(DATE_TRUNC('month', date))

-- Q7. Find most frequent value for confirmed, deaths, recovered each month
WITH monthly_modes AS (SELECT DATE_TRUNC('month', date) AS month,
					  MODE() WITHIN GROUP (ORDER BY confirmed) AS confirmed_mode,
					  MODE() WITHIN GROUP (ORDER BY deaths) AS deaths_mode,
					  MODE() WITHIN GROUP (ORDER BY recovered) AS recovered_mode
					   FROM public.coronavirus_data
					   GROUP BY 1)

SELECT TO_CHAR(month, 'Month YYYY') AS month_year,
        confirmed_mode, deaths_mode, recovered_mode
FROM monthly_modes
ORDER BY month;

--They are all zeros

-- Q8. Find minimum values for confirmed, deaths, recovered per year
SELECT TO_CHAR(DATE_TRUNC('year', date), 'YYYY') AS Year,
        MIN(confirmed) min_confirmed,
		MIN(deaths) min_deaths,
		MIN(recovered) min_recovered
FROM public.coronavirus_data
GROUP BY 1

-- Q9. Find maximum values of confirmed, deaths, recovered per year
SELECT TO_CHAR(DATE_TRUNC('year', date), 'YYYY') AS Year,
        MAX(confirmed) max_confirmed,
		MAX(deaths) max_deaths,
		MAX(recovered) max_recovered
FROM public.coronavirus_data
GROUP BY 1

-- Q10. The total number of case of confirmed, deaths, recovered each month
SELECT TO_CHAR(DATE_TRUNC('month', date), 'Month YYYY') AS month,
        SUM(confirmed) total_confirmed,
		SUM(deaths) total_deaths,
		SUM(recovered) total_recovered
FROM public.coronavirus_data
GROUP BY 1
ORDER BY MIN(DATE_TRUNC('month', date))
-- Q11. Check how corona virus spread out with respect to confirmed case
--      (Eg.: total confirmed cases, their average, variance & STDEV )
--1. DAILY DATA SHOWING HOW CORONA VIRUS SPREAD OUT WRT CONFIRMED CASES

WITH daily_data AS (SELECT DATE_TRUNC('day', date) AS date,
        			SUM(confirmed) AS confirmed
					FROM public.coronavirus_data
					GROUP BY 1)

SELECT TO_CHAR(date, 'YYYY-MM'), SUM(confirmed) OVER (ORDER BY date) AS cumulative_confirmed
FROM daily_data
ORDER BY date

--2. MONTHLY Confirmed Cases Analysis (MAIN)
SELECT TO_CHAR(DATE_TRUNC('month', date), 'Month YYYY') AS month_year,
			SUM(confirmed) AS monthly_confirmed,
			ROUND(AVG(confirmed), 2) AS avg_confirmed,
			ROUND(VAR_SAMP(confirmed), 2) AS variance_confirmed,
			ROUND(STDDEV_SAMP(confirmed), 2) AS stddev_confirmed
FROM public.coronavirus_data
GROUP BY DATE_TRUNC('month', date)
ORDER BY DATE_TRUNC('month', date)

-- Q12. Check how corona virus spread out with respect to death case per month
--      (Eg.: total confirmed cases, their average, variance & STDEV )
SELECT TO_CHAR(DATE_TRUNC('month', date), 'Month YYYY') AS month_year,
			SUM(deaths) AS monthly_deaths,
			ROUND(AVG(deaths), 2) AS avg_deaths,
			ROUND(VAR_SAMP(deaths), 2) AS variance_deaths,
			ROUND(STDDEV_SAMP(deaths), 2) AS stddev_deaths
FROM public.coronavirus_data
GROUP BY DATE_TRUNC('month', date)
ORDER BY DATE_TRUNC('month', date)
-- Q13. Check how corona virus spread out with respect to recovered case
--      (Eg.: total confirmed cases, their average, variance & STDEV )
SELECT TO_CHAR(DATE_TRUNC('month', date), 'Month YYYY') AS month_year,
			SUM(recovered) AS monthly_recovered,
			ROUND(AVG(recovered), 2) AS avg_recovered,
			ROUND(VAR_SAMP(recovered), 2) AS variance_recovered,
			ROUND(STDDEV_SAMP(recovered), 2) AS stddev_recovered
FROM public.coronavirus_data
GROUP BY DATE_TRUNC('month', date)
ORDER BY DATE_TRUNC('month', date)
-- Q14. Find Country having highest number of the Confirmed case
SELECT country_or_region AS "Country/Region",
		SUM(confirmed) AS total_confirmed
FROM public.coronavirus_data
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1

--THE UNITED STATES HAD THE HIGHEST NUMBER
-- Q15. Find Country having lowest number of the death case
SELECT country_or_region AS "Country/Region",
		SUM(deaths) AS total_deaths
FROM public.coronavirus_data
GROUP BY 1
ORDER BY 2
LIMIT 4 --There were 4 countries without any record of deaths.

-- Q16. Find top 5 countries having highest recovered case
SELECT country_or_region AS "Country/Region",
		SUM(recovered) AS total_recovered
FROM public.coronavirus_data
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

-- Q17. When did each country experience its peak in confirmed cases, deaths,
--and recoverd cases?
SELECT country_or_region AS "Country/Region", date, confirmed
FROM public.coronavirus_data
WHERE (country_or_region, confirmed) IN (
				SELECT country_or_region, MAX(confirmed)
				FROM public.coronavirus_data
				GROUP BY country_or_region)
ORDER BY confirmed DESC
