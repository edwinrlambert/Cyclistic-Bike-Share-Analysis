-- CREATE A COMBINED TABLE FOR ALL THE DATA FOR ANALYSIS, PARTITIONED BY MONTH.
CREATE TABLE  `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_raw`
PARTITION BY  DATE_TRUNC(started_at, MONTH)
OPTIONS       (
              partition_expiration_days = 365,
              description = "Partitioned Table of Cyclistic Bike Rides by Month"
              ) AS 
SELECT        *
FROM          (
              SELECT * FROM `data-certifications-erl.divvy_tripdata.202301-tripdata`  
              UNION ALL
              SELECT * FROM `data-certifications-erl.divvy_tripdata.202302-tripdata`  
              UNION ALL
              SELECT * FROM `data-certifications-erl.divvy_tripdata.202303-tripdata`  
              UNION ALL
              SELECT * FROM `data-certifications-erl.divvy_tripdata.202304-tripdata`  
              UNION ALL
              SELECT * FROM `data-certifications-erl.divvy_tripdata.202305-tripdata`  
              UNION ALL
              SELECT * FROM `data-certifications-erl.divvy_tripdata.202306-tripdata`  
              UNION ALL
              SELECT * FROM `data-certifications-erl.divvy_tripdata.202307-tripdata`  
              UNION ALL
              SELECT * FROM `data-certifications-erl.divvy_tripdata.202308-tripdata`  
              UNION ALL
              SELECT * FROM `data-certifications-erl.divvy_tripdata.202309-tripdata`  
              UNION ALL
              SELECT * FROM `data-certifications-erl.divvy_tripdata.202310-tripdata`  
              UNION ALL
              SELECT * FROM `data-certifications-erl.divvy_tripdata.202311-tripdata`  
              UNION ALL
              SELECT * FROM `data-certifications-erl.divvy_tripdata.202312-tripdata`    
);