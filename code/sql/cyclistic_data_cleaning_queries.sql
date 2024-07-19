-- DROP THE TABLE, IF EXISTING.
DROP TABLE IF EXISTS `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_cleaned`;

-- CREATE A NEW TABLE WITH CLEANED DATA FOR ANALYSIS.
CREATE TABLE         `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_cleaned` AS

-- Remove shorter than a minute and longer than a day trips from the table.
    WITH    table_with_removed_shorter_longer_rides AS (
            SELECT    *
            FROM      `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_raw`
            WHERE     TIMESTAMP_DIFF(ended_at, started_at, MINUTE) > 1
            AND       TIMESTAMP_DIFF(ended_at, started_at, MINUTE) < 1440
    ),

-- Replace duplicate IDs with one with 21/23
    table_with_fixed_duplicate_ids AS (
        SELECT  ride_id,
                rideable_type,
                started_at,
                ended_at,
                start_station_name,
                CASE 
                    WHEN start_station_id = '390' THEN '21390'
                    WHEN start_station_id = '396' THEN '21396'
                    WHEN start_station_id = '374' THEN '21374'
                    WHEN start_station_id = '321' THEN '23321'
                    WHEN start_station_id = '357' THEN '21357'
                    WHEN start_station_id = '462' THEN '21462'
                    WHEN start_station_id = '312' THEN '21312'
                    WHEN start_station_id = '354' THEN '21354'
                    ELSE start_station_id
                END AS start_station_id,
                end_station_name,
                CASE 
                    WHEN end_station_id = '390' THEN '21390'
                    WHEN end_station_id = '396' THEN '21396'
                    WHEN end_station_id = '374' THEN '21374'
                    WHEN end_station_id = '321' THEN '23321'
                    WHEN end_station_id = '357' THEN '21357'
                    WHEN end_station_id = '462' THEN '21462'
                    WHEN end_station_id = '312' THEN '21312'
                    WHEN end_station_id = '354' THEN '21354'
                    ELSE end_station_id
                END AS end_station_id,
                start_lat,
                start_lng,
                end_lat,
                end_lng,
                member_casual
        FROM    table_with_removed_shorter_longer_rides
    ),

-- Find one coordinate for each station.
    station_minimum_coordinates AS (
        SELECT      end_station_name,
                    MIN(TRUNC(end_lat, 5)) AS min_end_lat,
                    MIN(TRUNC(end_lng, 5)) AS min_end_lng
        FROM        table_with_fixed_duplicate_ids
        WHERE       end_lat IS NOT NULL AND end_lng IS NOT NULL
        GROUP BY    end_station_name
    ),

-- Update the null values for end_lat and end_lng
    table_with_filled_end_lat_lng AS (
        SELECT      a.ride_id,
                    a.rideable_type,
                    a.started_at,
                    a.ended_at,
                    a.start_station_name,
                    a.start_station_id,
                    a.end_station_name,
                    a.end_station_id,
                    a.start_lat,
                    a.start_lng,
                    COALESCE(a.end_lat, b.min_end_lat) AS end_lat,
                    COALESCE(a.end_lng, b.min_end_lng) AS end_lng,
                    a.member_casual
        FROM        table_with_fixed_duplicate_ids a
        LEFT JOIN   station_minimum_coordinates b 
        ON          a.end_station_name = b.end_station_name
    ),

-- Update null station names with "Unknown" and null station ids with '0'.
    table_with_updated_null_station_names_ids AS (
        SELECT  ride_id,
                rideable_type,
                started_at,
                ended_at,
                COALESCE(start_station_name, 'Unknown') AS start_station_name,
                COALESCE(start_station_id, '0') AS start_station_id,
                COALESCE(end_station_name, 'Unknown') AS end_station_name,
                COALESCE(end_station_id, '0') AS end_station_id,
                FORMAT('%.5f', start_lat) AS start_lat,
                FORMAT('%.5f', start_lng) AS start_lng,
                FORMAT('%.5f', end_lat) AS end_lat,
                FORMAT('%.5f', end_lng) AS end_lng,
                member_casual
        FROM    table_with_filled_end_lat_lng
    ),

-- Remove the rows without an end destination (no end_station_name, end_station_id, end_lat, end_lng)
    table_with_removed_null_end_destination AS (
        SELECT  *
        FROM    table_with_updated_null_station_names_ids
        WHERE   NOT (
                end_station_name = 'Unknown'
                AND     end_station_id = '0'
                AND     end_lat IS NULL
                AND     end_lng IS NULL
        )
    )

-- Select and list all cleaned rows.
    SELECT  *
    FROM    table_with_removed_null_end_destination;
