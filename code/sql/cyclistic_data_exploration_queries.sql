-- 1. FIND THE COUNT OF TOTAL ROWS IN THE TABLE.
SELECT  COUNT(*) AS row_count
FROM    `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_raw`;

-- 2. FIND THE COUNT OF NULL VALUES IN EACH COLUMN.
SELECT  COUNT(*) - COUNT(ride_id) AS null_ride_id,
        COUNT(*) - COUNT(rideable_type) AS null_rideable_type,
        COUNT(*) - COUNT(started_at) AS null_started_at,
        COUNT(*) - COUNT(ended_at) AS null_ended_at,
        COUNT(*) - COUNT(start_station_name) AS null_start_station_name,
        COUNT(*) - COUNT(start_station_id) AS null_start_station_id,
        COUNT(*) - COUNT(end_station_name) AS null_end_station_name,
        COUNT(*) - COUNT(end_station_id) AS null_end_station_id,
        COUNT(*) - COUNT(start_lat) AS null_start_lat,
        COUNT(*) - COUNT(start_lng) AS null_start_lng,
        COUNT(*) - COUNT(end_lat) AS null_end_lat,
        COUNT(*) - COUNT(end_lng) AS null_end_lng,
        COUNT(*) - COUNT(member_casual) AS null_member_casual
FROM    `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_raw`;

-- 3.1. FIND THE ROWS WITH MISSING VALUE ON START STATIONS, BUT WITH A END STATION.
SELECT  *
FROM    `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_raw`
WHERE   (start_station_name IS NULL OR start_station_id IS NULL)
AND     (end_station_name IS NOT NULL OR end_station_id IS NOT NULL);

-- 3.2. FIND THE ROWS WITH MISSING VALUE ON END STATIONS, BUT WITH A START STATION.
SELECT  *
FROM    `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_raw`
WHERE   (end_station_name IS NULL OR end_station_id IS NULL)
AND     (start_station_name IS NOT NULL OR start_station_id IS NOT NULL);

-- 3.3. FIND THE ROWS WITH MISSING VALUE FOR BOTH START AND END STATIONS.
SELECT  *
FROM    `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_raw`
WHERE   (start_station_name IS NULL OR start_station_id IS NULL)
AND     (end_station_name IS NULL OR end_station_id IS NULL);

-- 4. FIND IF RIDE_ID IS CONSISTENT.
SELECT  DISTINCT LENGTH(ride_id)
FROM    `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_raw`;

-- 5.1. FIND THE TYPE OF RIDEABLES AVAILABLE.
SELECT  DISTINCT rideable_type
FROM    `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_raw`;

-- 5.2. FIND THE NUMBER OF TIMES PEOPLE HAVE TAKEN EACH RIDEABLE THROUGHOUT THIS YEAR.
SELECT    rideable_type, COUNT(*) AS num_of_rides_this_year
FROM      `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_raw`
GROUP BY  rideable_type;

-- 6.1. FIND SHORTER RIDES (LESS THAN A MINUTE)
SELECT  *
FROM    `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_raw`
WHERE   TIMESTAMP_DIFF(ended_at, started_at, MINUTE) <= 1;

-- 6.2. FIND SHORTER RIDES (LESS THAN A MINUTE) WITHOUT A START NOR AN END STATION.
SELECT  *
FROM    `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_raw`
WHERE   TIMESTAMP_DIFF(ended_at, started_at, MINUTE) <= 1
AND     (start_station_name IS NULL OR end_station_name IS NULL);

-- 6.3. FIND LONGER RIDES (LONGER THAN A DAY)
SELECT  *
FROM    `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_raw`
WHERE   TIMESTAMP_DIFF(ended_at, started_at, MINUTE) >= 1440;

-- 6.4 FIND LONGER RIDES (LONGER THAN A DAY) WITHOUT A START NOR AN END STATION.
SELECT  *
FROM    `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_raw`
WHERE   TIMESTAMP_DIFF(ended_at, started_at, MINUTE) >= 1440
AND     (start_station_name IS NULL OR end_station_name IS NULL);

-- 7. FIND ALL THE UNIQUE STATION_NAMES AND HOW MANY RIDES ORIGINATED AND FINISHED AT THOSE STATIONS.
WITH  station_names AS (

      SELECT  DISTINCT station_name
      FROM    (
              SELECT  start_station_name AS station_name 
              FROM    `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_raw` 
              WHERE   start_station_name IS NOT NULL
              UNION ALL
              SELECT  end_station_name AS station_name 
              FROM    `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_raw` 
              WHERE   end_station_name IS NOT NULL
              ) AS combined_station_names
)

SELECT    stations.station_name,
          COALESCE(SUM(CASE WHEN trips.start_station_name = stations.station_name THEN 1 ELSE 0 END), 0) AS bikes_started,
          COALESCE(SUM(CASE WHEN trips.end_station_name = stations.station_name THEN 1 ELSE 0 END), 0) AS bikes_ended
FROM      station_names AS stations
LEFT JOIN `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_raw` AS trips
ON        trips.start_station_name = stations.station_name
OR        trips.end_station_name = stations.station_name
GROUP BY  stations.station_name
ORDER BY  stations.station_name;

-- 8.1. FINDING IF ALL UNIQUE STATION NAMES HAVE UNIQUE STATION ID.
WITH station_names_ids AS (
    SELECT    DISTINCT start_station_name AS station_name,
              start_station_id AS station_id
    FROM      `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_raw`
    WHERE     start_station_name IS NOT NULL
    AND       start_station_id IS NOT NULL

    UNION DISTINCT

    SELECT    DISTINCT end_station_name AS station_name,
              end_station_id AS station_id
    FROM      `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_raw`
    WHERE     end_station_name IS NOT NULL
    AND       end_station_id IS NOT NULL
), 

station_id_details AS (
    SELECT    station_name, 
              COUNT(DISTINCT station_id) AS distinct_id_count,
              STRING_AGG(DISTINCT station_id, ', ') AS station_ids
    FROM      station_names_ids
    GROUP BY  station_name
)

-- Select stations with more than one distinct station IDs and list them out.
SELECT    station_name, 
          distinct_id_count,
          station_ids
FROM      station_id_details
WHERE     distinct_id_count > 1
ORDER BY  station_name;

-- 8.2. FIND IF THE DUPLICATE IDS ARE STILL UNIQUE AND THEY DON'T HAVE ANY OTHER STATION_NAME ASSOCIATED WITH IT.
WITH station_names_ids AS (
    SELECT    DISTINCT start_station_name AS station_name,
              start_station_id AS station_id
    FROM      `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_raw`
    WHERE     start_station_id IN ("390", "21390", "396", "21396", "374", "21374", 
                                  "321", "23321", "357", "21357", "462", "21462", 
                                  "312", "21312", "354", "21354")

    UNION DISTINCT

    SELECT    DISTINCT end_station_name AS station_name,
              end_station_id AS station_id
    FROM      `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_raw`
    WHERE     end_station_id IN ("390", "21390", "396", "21396", "374", "21374", 
                                "321", "23321", "357", "21357", "462", "21462", 
                                "312", "21312", "354", "21354")
)

SELECT      DISTINCT station_name,
            station_id
FROM        station_names_ids
ORDER BY    station_name, station_id;

-- 9. FIND THE STATION NAME AND THEIR RESPECTIVE LATITUDE AND LONGITUDE VALUES (estimated).
-- Find if there are end_station_names without end_lat and end_lng.
SELECT      DISTINCT end_station_name, 
            end_lat, 
            end_lng
FROM        `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_raw`
WHERE       end_station_name IS NOT NULL
AND         (end_lat IS NULL OR end_lng IS NULL)
ORDER BY    end_station_name;

-- Find the end_lat and end_lng for these station names.
SELECT      DISTINCT end_station_name,
            end_lat,
            end_lng
FROM        `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_raw`
WHERE       end_station_name IN ("Drexel Ave & 60th St", "Elizabeth St & Randolph St", "Halsted St & Fulton St", 
                                "Lincoln Ave & Byron St", "Stony Island Ave & 63rd St")
ORDER BY    end_station_name, end_lat, end_lng;

-- Searching start_lat, start_lng for values with 0.0
SELECT      DISTINCT start_station_name,
            start_lat,
            start_lng
FROM        `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_raw`
WHERE       (start_lat = 0.0 OR start_lng = 0.0)
ORDER BY    start_station_name, start_lat, start_lng;

-- Searching end_lat, end_lng for values with 0.0
SELECT      DISTINCT end_station_name,
            end_lat,
            end_lng
FROM        `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_raw`
WHERE       (end_lat = 0.0 OR end_lng = 0.0)
ORDER BY    end_station_name, end_lat, end_lng;

-- Find if there are values without start or end stations, latitude and longitude.
SELECT      start_station_name,
            end_station_name, 
            start_lat,
            start_lng,
            end_lat, 
            end_lng
FROM        `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_raw`
WHERE       start_station_name IS NULL AND end_station_name IS NULL
AND         (start_lat IS NULL OR start_lng IS NULL)
AND         (end_lat IS NULL OR end_lng IS NULL)
ORDER BY    end_lat, end_lng;

-- Find the station names for the empty end latitude and longitude combinations.
SELECT      DISTINCT a.end_station_name,
            a.end_lat,
            a.end_lng
FROM        `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_raw` AS a
JOIN        (SELECT DISTINCT b.end_lat, 
                    b.end_lng
            FROM    `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_raw` AS b
            WHERE   b.end_station_name IS NULL
            AND     b.end_lat IS NOT NULL 
            AND     b.end_lng IS NOT NULL) AS b
ON          a.end_lat = b.end_lat AND a.end_lng = b.end_lng
WHERE       a.end_station_name IS NOT NULL
ORDER BY    a.end_lat, a.end_lng;

-- 10.1. FIND THE DISTINCT MEMBERS TYPE.
SELECT  DISTINCT member_casual
FROM    `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_raw`;

-- 10.2. FIND THE COUNT OF RIDES TAKEN BY EACH MEMBER TYPES.
SELECT      member_casual, COUNT(*) AS count_of_rides
FROM        `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_raw`
GROUP BY    member_casual;

-- 10.3.FIND THE COUNT OF RIDES TAKEN IN EACH RIDEABLE BY EACH MEMBER TYPES.
SELECT      member_casual, rideable_type, COUNT(*) AS count_of_rides
FROM        `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_raw`
GROUP BY    member_casual, rideable_type;
