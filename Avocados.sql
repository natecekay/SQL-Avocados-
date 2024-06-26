/* Avocado Sales Analysis
Author: Nathaniel Cekay
An analysis of avocado sales data from the Hass Avocado Board website.
The analysis was conducted using SQL.

Citation: JOSEPH, VALENTIN (2021). Avocado sales 2015-2021. [Dataset]
https://www.kaggle.com/datasets/valentinjoseph/avocado-sales-20152021-us-centric/data
*/

CREATE TABLE avocados (
	Date date,
	AveragePrice numeric,
	TotalVolume numeric,
	plu4046 numeric,
	plu4225 numeric,
	plu4770 numeric,
	TotalBags numeric,
	SmallBags numeric,
	LargeBags numeric,
	XLargeBags numeric,
	type varchar(100),
	year int,
	region varchar(50)
);

COPY avocados
FROM 'C:\Datasets\avocados.csv'
WITH (FORMAT CSV, HEADER);

ALTER TABLE avocados
RENAME COLUMN plu4046 TO small_avocados;

ALTER TABLE avocados
RENAME COLUMN plu4225 TO medium_avocados;

ALTER TABLE avocados
RENAME COLUMN plu4770 TO large_avocados;

SELECT * FROM avocados;

SELECT count(date)
FROM avocados;

/* This shows us there are 41025 total dates recorded*/

SELECT corr(totalvolume, totalbags)
    AS totalvolume_and_totalbags
FROM avocados;

/* totalvolume sold and totalbags sold had a very strong correlation of 0.959*/

SELECT corr(small_avocados, totalbags)
    AS small_avocados_and_totalbags
FROM avocados;

/* small avocados sold and totalbags sold had a very strong correlation of 0.919*/

SELECT corr(medium_avocados, totalbags)
    AS medium_avocados_and_totalbags
FROM avocados;

/* medium avocados sold and totalbags sold had a very strong correlation of 0.895*/

SELECT corr(large_avocados, totalbags)
    AS large_avocados_and_totalbags
FROM avocados;
/* large avocados sold and totalbags sold had a strong correlation of 0.800*/

SELECT 
    round(
	    regr_slope(totalvolume, totalbags)::numeric,2
		) AS slope,
	round(
	    regr_intercept(totalvolume, totalbags)::numeric,2
		) AS y_intercept
FROM avocados;
/* running a regression analysis confirms a strong positive
correlation between total volume and total bags sold, with a 
slope of 3.98*/

SELECT round(
	    regr_r2(totalvolume, totalbags)::numeric,3
		) AS r_squared
FROM avocados;
/* running an r-squared calculation confirms a strong correlation 
of 0.92, indicating that about 92% of total volume can be 
explained by the number of total bags sold*/

SELECT
    Date,
	totalbags,
	rank() OVER (ORDER BY totalbags DESC),
	dense_rank() OVER (ORDER BY totalbags DESC)
FROM avocados
ORDER BY totalbags DESC;
/* Here we can see the top dates that sold the most total bags of avocados*/

alter table avocados add column
total_sales numeric GENERATED ALWAYS AS (AveragePrice * TotalVolume) STORED;
/* Here I create a total sales column multiplying the average price by total volume*/

SELECT *
FROM avocados
WHERE total_sales >= (
	SELECT percentile_cont(.5) WITHIN GROUP (ORDER BY total_sales)
	FROM avocados
	)
ORDER BY total_sales DESC;
/* Here I use a subquery to view the top 50th percentile cutoff for total_sales*/

SELECT *
FROM avocados
WHERE total_sales >= (
	SELECT percentile_cont(.9) WITHIN GROUP (ORDER BY total_sales)
	FROM avocados
	)
ORDER BY total_sales DESC;
/* Here I use a subquery to view the top 90th percentile cutoff for total_sales*/

