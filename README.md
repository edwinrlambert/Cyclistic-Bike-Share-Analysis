# **Cyclistic Bike Share Analysis**

This repository contains the analysis done for the Google Data Analytics Capstone Project. This project is to showcase my skills and analysis, based on what I know and what I learned from this professional certification.

**Cyclistic** is a bike-sharing program l in 2016, that features more than 5,824 bicycles and 692 docking stations. The company also offer reclining bikes, hand tricycles, and cargo bikes, making bike-share more inclusive.

Cyclistic is successful in its business and appealing to the broad consumer segment. Customers who purchase single-ride or full-day passes are referred to as casual riders and customers who purchase annual memberships are Cyclistic members.

## **Business Task**

The primary goal of this analysis is to understand how casual riders (who purchase single-ride or full-day passes) and annual members use Cyclistic bikes differently. Insights from this analysis will inform targeted marketing strategies to convert casual riders into annual members.

## **I. ASK**

The analysis centers around three refined questions to guide the marketing program:

1. **How do annual members and casual riders use Cyclistic bikes differently?**
2. **Why would casual riders buy Cyclistic annual memberships?**
3. **How can Cyclistic use digital media to influence casual riders to become members?**

### **Guiding Questions in this Phase**

#### 1. What are the problems that we are trying to solve?

For this problem, what we trying to understand is how casual riders and annual riders use the bike-sharing service differently. What are the factors that are different between the two types of population and all insights can be used to convert casual riders to annual riders.

#### 2. How can the insights drive business decisions?

The insight from this analysis can be used to design marketing strategies that aims in a better conversion to memberships. Having annual memberships can contribute to the company's revenue and good-will long term compared to single-ride/full day riders.

#### 3. Who are the key stakeholders for this project?

The key stakeholders are:

- **Cyclistic Marketing Analytics Team**: Analyzes data to guide marketing strategy.
- **Lily Moreno (Director of Marketing)**: Develops campaigns to promote the bike-share program based on analytical insights.
- **Cyclistic Executive Team**: Makes final decisions on implementing marketing strategies based on data-driven recommendations.

#### 4. What will be the success criteria of this project?

The project will be deemed successful if it results in a measurable increase in annual memberships, specifically aiming for at least a 10% increase within six months after implementing the new marketing strategies. The success will also be evaluated based on the approval and satisfaction of the marketing strategies by the Cyclistic executive team.

## **II. PREPARE**

Now we gather, assess, and prepare the necessary data that will allow us to answer the business questions asked in the "Ask" phase.

### **Data Collection**

We're using the Cyclistic's historical trip data for the past 12 months. The data is organized in a structured format, as CSV files, with each file representing trip data for a particular month.

**Data Source**: [divvy-tripdata](https://divvy-tripdata.s3.amazonaws.com/index.html)

**Note**: This data has been made available by Motivate International Inc. under this [license](https://www.divvybikes.com/data-license-agreement)

### **Data Import**

For this project, we're going to combine 12 datasets from January 2023 to December 2023 together into a single table. We're going to use BigQuery for the setup due to the vast amount of data in this project.

#### **1. Setting Up BigQuery**

Here are the steps I did to setup BigQuery.

1. Ensured that I have a [**Google Cloud**](https://cloud.google.com/) account. If you don't, you'll need to create one.
2. Created a new project in Google Cloud Console, specifically made for my analysis and to keep my work organized and manageable.
3. Confirmed that **BigQuery API** is enabled. If not, enable it.
4. Ensured that the billing details are set up correctly. (_You do get credits for the first time, use that for learning._)

#### **2. Upload the CSV documents to Cloud Storage**

For large datasets or for better management and scalability, it's a good practice to upload the files to Google Cloud Storage (GCS).

1. Go to Google Cloud Storage, navigate to "**Storage**" and create a new bucket. Choose a region that will be close to your BigQuery dataset to reduce latency and cost.
2. Upload the CSV files to the newly created bucket.

#### **3. Create a Dataset in BigQuery**

Before you can upload the files as tables, you need a dataset to hold the tables.

1. In the Google Cloud Console, go to **BigQuery**.
2. Click on your project name, then click "**Create dataset**". Enter a Dataset ID, choose a data location that matches your GCS bucket's location, and set other configurations as needed.

#### **4. Create a Table and Import Data**

Now you can create a table and import data from your CSV files or via Google Cloud Storage.

1. Go to your dataset and click "**+**" and **Create Table**.
2. Set the "**Create table from**" option to "**Upload**" if you're uploading directly from your computer, or choose "**Google Cloud Storage**" if you've uploaded the files to GCS.
3. For "**Select file**" or "**Select GCS file**", navigate to your file in your local computer or the GCS URI.
4. Set "**File Format** to the appropriate file type.
5. Specify the **table name** and **table type**.
6. Define your schema manually, or check "**Auto detect**" to let Bigquery infer the schema from the data.
7. After setting up your table and schema, click "**Create Table**". This process will start the import job, which will execute and load your data into BigQuery.

### **Data Exploration**

First, I am going to combine all 12 months of data as a single table as that would enable us to work with a single table instead of joining 12 tables for each query.

I am also partitioning the table by month, as it allows to manage the data efficiently, reducing query costs and improving performance by scanning only relevant partitions.

**Note**: When you query a partitioned table in BigQuery, it scans only the partitions relevant to the query. For instance, if you’re analyzing data from March, BigQuery will only scan the March partition instead of the entire dataset. This reduces the amount of data scanned during queries, leading to faster performance and lower costs.

```sql
-- Create a combined table for all the data combined for analysis partitioned by month.
CREATE TABLE  `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_raw`
PARTITION BY  DATE_TRUNC(started_at, MONTH)
OPTIONS       (
              partition_expiration_days = 730,
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
```

Here is the schema of the table.

| No. | Variable           | Type      | Description                                |
| --- | ------------------ | --------- | ------------------------------------------ |
| 1   | ride_id            | STRING    | Unique ID assigned to each ride            |
| 2   | rideable_type      | STRING    | Type of bike (classic, docked, electric)   |
| 3   | started_at         | TIMESTAMP | Date and time at the start of trip         |
| 4   | ended_at           | TIMESTAMP | Date and time at the end of trip           |
| 5   | start_station_name | STRING    | Name of the station where the ride started |
| 6   | start_station_id   | STRING    | ID of the station where the ride started   |
| 7   | end_station_name   | STRING    | Name of the station where the ride ended   |
| 8   | end_station_id     | STRING    | ID of the station where the ride ended     |
| 9   | start_lat          | FLOAT     | Latitude of starting station               |
| 10  | start_lng          | FLOAT     | Longitude of starting station              |
| 11  | end_lat            | FLOAT     | Latitude of ending station                 |
| 12  | end_lng            | FLOAT     | Longitude of ending station                |
| 13  | member_casual      | STRING    | Type of membership of each rider           |

Now let's check how much rows are there in the whole table.

```sql
-- Find the count of rows in this table.
SELECT  COUNT(*) AS row_count
FROM    `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_raw`;
```

There are **5,719,877** rows of bike ride data in this dataset.

#### **Finding Missing in each columns**

After writing a SQL query to find missing value for each columns, here is what are the columns with missing values:

- **start_station_name**: Have 875,716 null values
- **start_station_id**: Have 875,848 null values
- **end_station_name**: Have 929,202 null values
- **end_station_id**: Have 929,343 null values
- **end_lat**: Have 6,990 null values
- **end_lng**: Have 6,990 null values

**Observations**:

- There are **458,726** rows without a start station, but with an end station.
  - This have the possibility that these bikes were started from a non-designated location and returned to a designated location.
  - If these bikes were reported stolen, then this can also mean that these bikes were found and returned to their respective designated locations.
  - Some data are spanning over a short period of time and short period of geographical distance that suggests that workers might be taking the bikes kept near the docking station and parking it correctly.
  - It can also suggest that customers were unsatisfied with the bikes they got and returned it back to the station.
- There are **512,222** rows with a start station, but without an end station.
  - This have the possibility that the data was recorded when the trip is ongoing.
  - It can also mean that these trips were one-way trips where the bikes were left at non-designated location, or can be stolen.
  - Some data are spanning over a short period of time and short period of geographical distance that suggests that customer took the bike from the station, was unsatisfied with the bike due to some mechanical or other issues and parked the vehicle near the station.
- There are **417,137** rows without both start and end stations.
  - This have the possibility that these bikes were started and ended at places that are not the designated station for these bikes.
  - Some data are spanning over a short period of time and short period of geographical distance that suggests that customer took the bike from where they got and kept it there or somewhere close.
- The missing values might also have occurred due to errors in recording data due to some technical glitches.

#### **Making sure the ride_id is consistent**

```sql
SELECT  DISTINCT LENGTH(ride_id)
FROM    `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_raw`;
```

The ride_id is consistent with 16 characters.

#### **Find the type of rideables available**

```sql
SELECT  DISTINCT rideable_type
FROM    `data-certifications-erl.divvy_tripdata.2023_cyclistic_tripdata_raw`;
```

There are 3 type of bikes:

- Classic Bikes
- Electric Bikes
- Docked Bikes

#### **Finding short and long rides (outliers)**

Usually rides less than a minute are when customers or workers testing out the bikes, or immediately finding an issue and returning it. This can also be accidental rentals or system testing.

Rides longer than a day can be due to bikes not returned properly, possible theft and even customers forgetting to dock or return the bikes.

**Observations**:

- There are **262,293** (4.58%) of rows with shorter rides (less than a minute) out of which **100,194** (1.75%) of rows don't have either start station or end station.
- There are **6,418** (0.11%) of rows with longer rides (longer than a day) out of which **6,285** (0.10%) of rows don't have either start station or end station.

**Action Item**:
For this project, since the amount of data is comparatively less, I am going to consider them as outliers and remove them from the table. I have saved up the result as separate tables, if in case I have to analyze why this short and long rides are happening and whether they are happening with casual riders or with riders with membership.

#### **Combining start and end stations to make sure every station have unique IDs.**

Now, we're going to combine all the data from the start_station_name and end_station_name columns, find the distinct values and filter to make sure if they have unique IDs.

**Observations**:

- There are 10 stations with 2 IDs. Those are:
  | Row | station_name | distinct_id_count | station_ids |
  |-----|-------------------------------|-------------------|----------------------------|
  | 1 | Buckingham Fountain | 2 | 15541, 15541.1.1 |
  | 2 | California Ave & Marquette Rd | 2 | 390, 21390 |
  | 3 | Central Ave & Roscoe St | 2 | 396, 21396 |
  | 4 | Kilpatrick Ave & Grand Ave | 2 | 374, 21374 |
  | 5 | Kostner Ave & Wrightwood Ave | 2 | 23321, 321 |
  | 6 | Lamon Ave & Armitage Ave | 2 | 357, 21357 |
  | 7 | Lincoln Ave & Peterson Ave | 2 | 462, 21462 |
  | 8 | Lockwood Ave & Wrightwood Ave | 2 | 312, 21312 |
  | 9 | Parkside Ave & Armitage Ave | 2 | 354, 21354 |
  | 10 | Wilton Ave & Diversey Pkwy\* | 2 | chargingstx2, chargingstx0 |

  - Here we can notice, that the IDs are still unique, but the second ID have a '21' or '23' at the front for a few, and .1.1 and tx0 instead of tx2.

**Action Items**:  
So, for the purpose, we're going to change the IDs without 21/23 to ones that have 21/23 to be consistent. Keep the one 15541 and chargingstx0.

#### **Finding station names with null end_lat or end_lng values.**

Since, we found that there are null values only in end_lat or end_lng, we are going to try and find those values as possible from the other datas.

There are 5 distinct station names with null values for end_lat and end_lng. The distinct station names are:

| Row | End Station Name           | End Lat | End Lng |
| --- | -------------------------- | ------- | ------- |
| 1   | Drexel Ave & 60th St       | null    | null    |
| 2   | Elizabeth St & Randolph St | null    | null    |
| 3   | Halsted St & Fulton St     | null    | null    |
| 4   | Lincoln Ave & Byron St     | null    | null    |
| 5   | Stony Island Ave & 63rd St | null    | null    |

Upon searching throughout the whole dataset for these distinct station names, we can find the latitude and longitude of these stations.

| Row | end_station_name           | end_lat      | end_lng       |
| --- | -------------------------- | ------------ | ------------- |
| 1   | Drexel Ave & 60th St       | null         | null          |
| 2   | Drexel Ave & 60th St       | 41.785861    | -87.604553    |
| 3   | Elizabeth St & Randolph St | null         | null          |
| 4   | Elizabeth St & Randolph St | 41.88        | -87.66        |
| 5   | Elizabeth St & Randolph St | 41.884336    | -87.658902    |
| 6   | Halsted St & Fulton St     | null         | null          |
| 7   | Halsted St & Fulton St     | 41.886847258 | -87.648195028 |
| 8   | Halsted St & Fulton St     | 41.886871    | -87.648089    |
| 9   | Halsted St & Fulton St     | 41.89        | -87.65        |
| 10  | Lincoln Ave & Byron St     | null         | null          |
| 11  | Lincoln Ave & Byron St     | 41.95        | -87.68        |
| 12  | Lincoln Ave & Byron St     | 41.952372    | -87.677296    |
| 13  | Stony Island Ave & 63rd St | null         | null          |
| 14  | Stony Island Ave & 63rd St | 0.0          | 0.0           |
| 15  | Stony Island Ave & 63rd St | 41.78        | -87.59        |
| 16  | Stony Island Ave & 63rd St | 41.780506    | -87.586853    |

**Observation**:

- We can see that for **Stony Island Ave & 63rd St**, there is a value as 0.0 for latitude and longitude. Therefore, let's search throughout the start_lat, start_lng and end_lat, end_lng for values with 0.0 as the values.
  - Upon running the query, I found that "OH Charging Stx - Test" for end station names with start_lat and start_lng with 0.0 as the value.

**Action Item**:

- We're going to fill in the value for the null and 0.0 values in end_lat and end_lng to the same value mentioned above and remove unnecessary rows.

#### **Finding the member types available in this dataset**

There are two types of members in this dataset:

- casual riders
- rides with membership

### **Data Cleaning**

Based on our exploration, we are going to clean the data step by step. We are using the `CREATE TABLE` to create a cleaned data and pass in all the separate sections as `WITH tablename` queries, so that it can be streamlined.

1. First, we create a query to drop the cleaned table, if existing.
2. Then we create the cleaned table as
   1. Exclude trips that are shorter than one minute or longer than one day as outliers, in the assumption that shorter rides were workers and people testing the bikes, or unsatisfied by the condition of the bikes and that longer rides are people forgetting to return the bikes or the bikes being stolen.
   2. Replace specific duplicate station IDs with unique identifiers.
   3. Find the minimum latitude and longitude for each station to handle missing values.
   4. Use the minimum coordinates found in the previous step to fill in missing values for end coordinates.
   5. Replace null station names with "Unknown" and null station IDs with '0'.
   6. Exclude rows that lack end destination information.
   7. Exclude rows with zero coordinates
   8. Finalize the table with all cleaned data.

After cleaning the data, we have **5,449,486** left to work with.

## **III. PROCESS**

We're going to continue using SQL for our process phase as Excel have a limit of 1,048,576 rows.

Before we analyze our cleaned dataset, we are going to process it and create some new columns by doing some calculations on existing column that will help us further in our analysis.

### **Overview**

The SQL operations are structured into three main parts:

1. **Dropping Columns**: Removes any existing columns that are to be recalculated or redefined.
2. **Adding Columns**: Introduces new columns to the dataset which will hold data calculated in the subsequent steps.
3. **Updating Columns**: Fills the newly added columns with values derived from the existing data in the dataset.

### **Columns Description**

Here are the columns created in this SQL script:

- `ride_length`: Duration of the ride formatted as HH:MM:SS.
- `day_of_week`: Numeric representation of the day of the week extracted from the ride start timestamp.
- `trip_distance`: Calculated distance of the trip based on geographical coordinates.
- `is_weekend`: Indicates whether the ride occurred on a weekend.
- `is_peak_hour`: Identifies if the ride falls within typical morning or evening peak hours.
- `ride_type`: Categorizes the ride based on its duration into 'Short', 'Medium', or 'Long'.
- `season`: Determines the season when the ride took place.
- `day_part`: Classifies the time of the day when the ride started (Morning, Afternoon, Evening, Night).

## **IV. ANALYZE**

Now, I am going to analyze the new table using R.
