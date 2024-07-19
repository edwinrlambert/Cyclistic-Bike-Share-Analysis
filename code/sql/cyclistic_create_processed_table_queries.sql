-- DROP THE TABLE, IF EXISTING
DROP TABLE IF EXISTS `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_processed`;

-- CREATE PROCESSED TABLE WITH 'RIDE_ID' BEING PRIMARY KEY.
CREATE TABLE         `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_processed` (
                      ride_id STRING,
                      rideable_type STRING,
                      started_at TIMESTAMP,
                      ended_at TIMESTAMP,
                      day_of_week INT64,
                      is_peak_hour STRING,
                      is_weekend STRING,
                      day_part STRING,
                      season STRING,
                      ride_length STRING,
                      ride_type STRING,
                      start_station_name STRING,
                      start_station_id STRING,
                      end_station_name STRING,
                      end_station_id STRING,
                      start_lat STRING,
                      start_lng STRING,
                      end_lat STRING,
                      end_lng STRING,
                      trip_distance FLOAT64,
                      member_casual STRING
);

-- INSERT THE INFORMATION FROM THE CLEANED TABLE.
INSERT INTO           `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_processed` (
                      ride_id, rideable_type, started_at, ended_at, day_of_week, 
                      is_peak_hour, is_weekend, day_part, season, ride_length, ride_type, 
                      start_station_name, start_station_id, end_station_name, end_station_id, 
                      start_lat, start_lng, end_lat, end_lng, trip_distance, member_casual
)
SELECT                ride_id, rideable_type, started_at, ended_at, day_of_week, 
                      is_peak_hour, is_weekend, day_part, season, ride_length, ride_type, 
                      start_station_name, start_station_id, end_station_name, end_station_id, 
                      start_lat, start_lng, end_lat, end_lng, trip_distance, member_casual
FROM                  `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_cleaned`;

-- 
SELECT    * 
FROM      `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_processed`