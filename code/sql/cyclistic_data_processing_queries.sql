-- DROP THE COLUMNS, IF EXISTING..
ALTER TABLE             `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_cleaned`
DROP COLUMN IF EXISTS   ride_length,
DROP COLUMN IF EXISTS   day_of_week,
DROP COLUMN IF EXISTS   trip_distance,
DROP COLUMN IF EXISTS   is_weekend,
DROP COLUMN IF EXISTS   is_peak_hour,
DROP COLUMN IF EXISTS   ride_type,
DROP COLUMN IF EXISTS   season,
DROP COLUMN IF EXISTS   day_part;

-- CREATE NEW COLUMNS.
ALTER TABLE   `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_cleaned`
ADD COLUMN    ride_length STRING,
ADD COLUMN    day_of_week INT64,
ADD COLUMN    trip_distance FLOAT64,
ADD COLUMN    is_weekend STRING,
ADD COLUMN    is_peak_hour STRING,
ADD COLUMN    ride_type STRING,
ADD COLUMN    season STRING,
ADD COLUMN    day_part STRING;

-- UPDATE NEW COLUMNS FOR PROCESSING.
UPDATE        `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_cleaned`

-- Update the 'ride_length' column.
SET ride_length = CONCAT(
    LPAD(CAST(FLOOR(TIMESTAMP_DIFF(ended_at, started_at, SECOND) / 3600) AS STRING), 2, '0'), ':',
    LPAD(CAST(FLOOR((TIMESTAMP_DIFF(ended_at, started_at, SECOND) - (FLOOR(TIMESTAMP_DIFF(ended_at, started_at, SECOND) / 3600) * 3600)) / 60) AS STRING), 2, '0'), ':',
    LPAD(CAST(TIMESTAMP_DIFF(ended_at, started_at, SECOND) - (FLOOR(TIMESTAMP_DIFF(ended_at, started_at, SECOND) / 60) * 60) AS STRING), 2, '0')
),

-- Update the 'day_of_week' column.
day_of_week = EXTRACT(DAYOFWEEK FROM started_at),

-- Update the 'trip_distance' column.
trip_distance = ROUND(
  6371 * 2 * ASIN(SQRT(
    POW(SIN((CAST(end_lat AS FLOAT64) - CAST(start_lat AS FLOAT64)) * 3.141592653589793 / 180 / 2), 2) +
    COS(CAST(start_lat AS FLOAT64) * 3.141592653589793 / 180) * COS(CAST(end_lat AS FLOAT64) * 3.141592653589793 / 180) *
    POW(SIN((CAST(end_lng AS FLOAT64) - CAST(start_lng AS FLOAT64)) * 3.141592653589793 / 180 / 2), 2)
  )), 2
),

-- Update the 'is_weekend' column.
is_weekend = IF(FORMAT_TIMESTAMP('%A', started_at) IN ('Saturday', 'Sunday'), 'Yes', 'No'),

-- Update the 'is_peak_hour'  column.
is_peak_hour = IF(EXTRACT(HOUR FROM started_at) IN (7, 8, 9, 16, 17, 18), 'Yes', 'No'),

-- Update the 'ride_type' column.
ride_type = CASE
    WHEN TIMESTAMP_DIFF(ended_at, started_at, MINUTE) < 10 THEN 'Short'
    WHEN TIMESTAMP_DIFF(ended_at, started_at, MINUTE) BETWEEN 10 AND 30 THEN 'Medium'
    ELSE 'Long'
END,

-- Update the 'season' column.
season = CASE
  WHEN EXTRACT(MONTH FROM started_at) IN (12, 1, 2) THEN 'Winter'
  WHEN EXTRACT(MONTH FROM started_at) IN (3, 4, 5) THEN 'Spring'
  WHEN EXTRACT(MONTH FROM started_at) IN (6, 7, 8) THEN 'Summer'
  WHEN EXTRACT(MONTH FROM started_at) IN (9, 10, 11) THEN 'Fall'
END,

-- Update the 'day_part' column.
day_part = CASE
  WHEN EXTRACT(HOUR FROM started_at) BETWEEN 5 AND 11 THEN 'Morning'
  WHEN EXTRACT(HOUR FROM started_at) BETWEEN 12 AND 16 THEN 'Afternoon'
  WHEN EXTRACT(HOUR FROM started_at) BETWEEN 17 AND 20 THEN 'Evening'
  ELSE 'Night'
END

WHERE     ride_id IS NOT NULL;

--

SELECT   *
FROM     `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_cleaned`;
