-- Exploratory Data Analysis -- 

----------------1. Analyse de la structure des usagers -----------------------------------------

SELECT
  member_casual,
  COUNT(*) AS count_per_category,
  ROUND((COUNT(*) / SUM(COUNT(*)) OVER ()) * 100, 2) AS percentage
FROM 
  `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
GROUP BY 
  member_casual;

---------------2. Analyse des comportements par rapport au temps d'utilisation -----------------------------------------  

--2.1 Analyse des tendances d'usage par mois

SELECT 
  FORMAT_DATETIME('%Y-%m', started_at) AS year_month,
  SUM(CASE WHEN member_casual = 'member' THEN 1 ELSE 0 END) AS member_trips, 
  SUM(CASE WHEN member_casual = 'casual' THEN 1 ELSE 0 END) AS casual_trips
FROM 
  `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
GROUP BY 
  year_month
ORDER BY 
  year_month;


SELECT 
  FORMAT_DATETIME('%Y-%m', started_at) AS year_month,
  ROUND(SUM(CASE WHEN member_casual = 'member' THEN 1 ELSE 0 END)/COUNT(*), 2) AS member_percentage, 
  ROUND(SUM(CASE WHEN member_casual = 'casual' THEN 1 ELSE 0 END)/COUNT(*),2) AS casual_percentage
FROM 
  `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
GROUP BY 
  year_month
ORDER BY 
  year_month;

--2.2 Analyse des tendances d'usage par jour de la semaine

-- Ajouter la colonne week_day
ALTER TABLE `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
ADD COLUMN week_day INT64;

-- Mettre à jour la colonne week_day
UPDATE `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
SET week_day = EXTRACT(DAYOFWEEK FROM started_at)
WHERE TRUE;

SELECT 
  week_day,
  SUM(CASE WHEN member_casual = 'member' THEN 1 ELSE 0 END) AS member_trips, 
  SUM(CASE WHEN member_casual = 'casual' THEN 1 ELSE 0 END) AS casual_trips
FROM 
  `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
GROUP BY 
  week_day
ORDER BY 
  week_day;

-- 2.3 Analyse des tendances d'usage par heure de la journée

SELECT 
  EXTRACT(HOUR FROM started_at) AS hour,
  SUM(CASE WHEN member_casual = 'member' THEN 1 ELSE 0 END) AS member_trips, 
  SUM(CASE WHEN member_casual = 'casual' THEN 1 ELSE 0 END) AS casual_trips
FROM 
  `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
GROUP BY 
  hour
ORDER BY 
  hour;

-- 2.4 Analyse de la durée des locations

SELECT 
  member_casual,
  ROUND(AVG(trip_duration), 2) AS avg_trip_duration,
  ROUND(MIN(trip_duration), 2) AS min_trip_duration,
  ROUND(MAX(trip_duration), 2) AS max_trip_duration
FROM 
  `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
GROUP BY 
  member_casual
;

SELECT 
  *
FROM 
  `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
WHERE
  trip_duration = 1559.0
;

SELECT 
  *
FROM 
  `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
WHERE
  trip_duration BETWEEN 1499.0 AND 1559.0
  AND end_lat IS NOT NULL
;

SELECT 
  *
FROM 
  `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
WHERE
  trip_duration BETWEEN 1499.0 AND 1559.0
  AND end_lat IS NOT NULL
;

-- Exploration des trajets effectués lors du changement d'heure

SELECT *
FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
WHERE DATE(started_at) = '2023-11-04'
  AND DATE(ended_at) = '2023-11-05'; -- 95 résultats

SELECT *
FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
WHERE DATE(started_at) = '2024-03-09'
  AND DATE(ended_at) = '2024-03-10'; -- 42 résultats

SELECT *
FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
WHERE DATE(started_at) = '2024-03-09'
  AND DATE(ended_at) = '2024-03-11'; -- 2 résultats

-- Analyse des durées de location par rapport à la durée incluse dans l'abonnement (45 minutes)

-- En nombre de voyages
SELECT 
  member_casual,
  SUM(CASE WHEN trip_duration <= 45.0 THEN 1 ELSE 0 END) AS trips_under_45_minutes,
  SUM(CASE WHEN trip_duration > 45.0 AND end_lat IS NOT NULL THEN 1 ELSE 0 END) AS trips_over_45_minutes 
FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
GROUP BY
  member_casual
  ;

--En pourcentage
WITH trip_durations AS
 (SELECT 
  member_casual,
  SUM(CASE WHEN trip_duration <= 45.0 THEN 1 ELSE 0 END) AS trips_under_45_minutes,
  SUM(CASE WHEN trip_duration > 45.0 AND end_lat IS NOT NULL THEN 1 ELSE 0 END) AS trips_over_45_minutes 
FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
GROUP BY
  member_casual)

SELECT 
  member_casual,
  ROUND(trips_under_45_minutes/(trips_under_45_minutes + trips_over_45_minutes)* 100, 2) AS under_45_min_percentage,
  ROUND(trips_over_45_minutes/(trips_under_45_minutes + trips_over_45_minutes)* 100, 2) AS over_45_min_percentage
FROM trip_durations
  ;

---------------3. Analyse des préférences en matière de type de vélo -----------------------------------------

SELECT 
  rideable_type,
  SUM(CASE WHEN member_casual = 'member' THEN 1 ELSE 0 END) AS member_usage,
  SUM(CASE WHEN member_casual = 'casual' THEN 1 ELSE 0 END) AS casual_usage 
FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
GROUP BY
  rideable_type
  ;

SELECT 
  member_casual,
  SUM(CASE WHEN rideable_type = 'classic_bike' THEN 1 ELSE 0 END) AS classic_bike_usage,
  SUM(CASE WHEN rideable_type = 'electric_bike' THEN 1 ELSE 0 END) AS electric_bike_usage,
  SUM(CASE WHEN rideable_type = 'electric_scooter' THEN 1 ELSE 0 END) AS scooter_usage,
FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
GROUP BY
  member_casual
  ;

-- Pourcentages

WITH bike_usage AS (
  SELECT 
    member_casual,
    SUM(CASE WHEN rideable_type = 'classic_bike' THEN 1 ELSE 0 END) AS classic_bike_usage,
    SUM(CASE WHEN rideable_type = 'electric_bike' THEN 1 ELSE 0 END) AS electric_bike_usage,
    SUM(CASE WHEN rideable_type = 'electric_scooter' THEN 1 ELSE 0 END) AS scooter_usage
  FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
  GROUP BY
    member_casual
),
total_usage AS (
  SELECT 
    member_casual,
    SUM(classic_bike_usage + electric_bike_usage + scooter_usage) AS total_trips
  FROM bike_usage
  GROUP BY member_casual
)

SELECT 
  bu.member_casual,
  ROUND(bu.classic_bike_usage / tu.total_trips * 100, 2) AS classic_bike_percentage,
  ROUND(bu.electric_bike_usage / tu.total_trips * 100, 2) AS electric_bike_percentage,
  ROUND(bu.scooter_usage / tu.total_trips * 100, 2) AS scooter_percentage
FROM bike_usage bu
JOIN total_usage tu ON bu.member_casual = tu.member_casual
ORDER BY bu.member_casual;

---------------4. Analyse des préférences géographiques -----------------------------------------

-- 4.1 Analyse des stations les plus fréquentées

SELECT 
  start_station_name,
  COUNT(*) AS trips_from_station
FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
WHERE start_station_name IS NOT NULL
  AND member_casual = 'member'
GROUP BY
  start_station_name
ORDER BY 
  trips_from_station DESC
LIMIT 10  ;

SELECT 
  start_station_name,
  COUNT(*) AS trips_from_station
FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
WHERE start_station_name IS NOT NULL
  AND member_casual = 'casual'
GROUP BY
  start_station_name
ORDER BY 
  trips_from_station DESC
LIMIT 10  ;

-- Les stations de départ et d'arrivée les plus utilisées par les membres aux heures de pointe (autour de 8 heures et de 17 heures)

SELECT 
  start_station_name,
  COUNT(*) AS trips_from_station,
  ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS morning_start_rank
FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
WHERE 
  start_station_name IS NOT NULL
  AND member_casual = 'member'
  AND EXTRACT(HOUR FROM started_at) IN (7, 8)
GROUP BY
  start_station_name
ORDER BY 
  trips_from_station DESC
LIMIT 10;

SELECT 
  start_station_name,
  COUNT(*) AS trips_from_station,
  ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS evening_start_rank
FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
WHERE 
  start_station_name IS NOT NULL
  AND member_casual = 'member'
  AND EXTRACT(HOUR FROM started_at) IN (16,17)
GROUP BY
  start_station_name
ORDER BY 
  trips_from_station DESC
LIMIT 10;

SELECT 
  end_station_name,
  COUNT(*) AS trips_to_station,
  ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS morning_end_rank
FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
WHERE 
  end_station_name IS NOT NULL
  AND member_casual = 'member'
  AND EXTRACT(HOUR FROM started_at) IN (7,8)
GROUP BY
  end_station_name
ORDER BY 
  trips_to_station DESC
LIMIT 10;

SELECT 
  end_station_name,
  COUNT(*) AS trips_to_station,
  ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS evening_end_rank
FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
WHERE 
  end_station_name IS NOT NULL
  AND member_casual = 'member'
  AND EXTRACT(HOUR FROM started_at) IN (16,17)
GROUP BY
  end_station_name
ORDER BY 
  trips_to_station DESC
LIMIT 10;

-- Résumé 

WITH morning_start AS (
  SELECT 
    start_station_name AS station_name,
    ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS morning_start_rank
  FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
  WHERE 
    start_station_name IS NOT NULL
    AND member_casual = 'member'
    AND EXTRACT(HOUR FROM started_at) IN (7, 8)
  GROUP BY
    start_station_name
  ORDER BY 
    morning_start_rank
  LIMIT 10
),

evening_start AS (
  SELECT 
    start_station_name AS station_name,
    ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS evening_start_rank
  FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
  WHERE 
    start_station_name IS NOT NULL
    AND member_casual = 'member'
    AND EXTRACT(HOUR FROM started_at) IN (16, 17)
  GROUP BY
    start_station_name
  ORDER BY 
    evening_start_rank
  LIMIT 10
),

morning_end AS (
  SELECT 
    end_station_name AS station_name,
    ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS morning_end_rank
  FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
  WHERE 
    end_station_name IS NOT NULL
    AND member_casual = 'member'
    AND EXTRACT(HOUR FROM started_at) IN (7, 8)
  GROUP BY
    end_station_name
  ORDER BY 
    morning_end_rank
  LIMIT 10
),

evening_end AS (
  SELECT 
    end_station_name AS station_name,
    ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS evening_end_rank
  FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
  WHERE 
    end_station_name IS NOT NULL
    AND member_casual = 'member'
    AND EXTRACT(HOUR FROM started_at) IN (16, 17)
  GROUP BY
    end_station_name
  ORDER BY 
    evening_end_rank
  LIMIT 10
)

SELECT 
  COALESCE(morning_start.station_name, evening_start.station_name, morning_end.station_name, evening_end.station_name) AS station_name,
  morning_start.morning_start_rank,
  evening_start.evening_start_rank,
  morning_end.morning_end_rank,
  evening_end.evening_end_rank
FROM 
  morning_start
  FULL OUTER JOIN evening_start ON morning_start.station_name = evening_start.station_name
  FULL OUTER JOIN morning_end ON COALESCE(morning_start.station_name, evening_start.station_name) = morning_end.station_name
  FULL OUTER JOIN evening_end ON COALESCE(morning_start.station_name, evening_start.station_name, morning_end.station_name) = evening_end.station_name
ORDER BY 
  station_name;


-- 4.2 Analyse des types de stations préférés

-- Points de départ
WITH start_station_types AS (
  SELECT 
    member_casual,
    SUM(CASE WHEN start_station_type = 'station' THEN 1 ELSE 0 END) AS started_at_stations,
    SUM(CASE WHEN start_station_type = 'public_rack' THEN 1 ELSE 0 END) AS started_at_public_racks,
    SUM(CASE WHEN start_station_type = 'off_grid' THEN 1 ELSE 0 END) AS started_off_grid
  FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
  GROUP BY
    member_casual
)

SELECT
  member_casual,
  ROUND(started_at_stations / (started_at_stations + started_at_public_racks + started_off_grid) * 100, 2) AS percent_started_at_stations,
  ROUND(started_at_public_racks / (started_at_stations + started_at_public_racks + started_off_grid) * 100, 2) AS percent_started_at_public_racks,
  ROUND(started_off_grid / (started_at_stations + started_at_public_racks + started_off_grid) * 100, 2) AS percent_started_off_grid
FROM start_station_types
;

-- Points d'arrivée

WITH end_station_types AS (
  SELECT 
    member_casual,
    SUM(CASE WHEN end_station_type = 'station' THEN 1 ELSE 0 END) AS ended_at_stations,
    SUM(CASE WHEN end_station_type = 'public_rack' THEN 1 ELSE 0 END) AS ended_at_public_racks,
    SUM(CASE WHEN end_station_type = 'off_grid' THEN 1 ELSE 0 END) AS ended_off_grid
  FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
  WHERE
    end_lat IS NOT NULL AND end_lng IS NOT NULL
  GROUP BY
    member_casual
)

SELECT
  member_casual,
  ROUND(ended_at_stations / (ended_at_stations + ended_at_public_racks + ended_off_grid) * 100, 2) AS percent_ended_at_stations,
  ROUND(ended_at_public_racks / (ended_at_stations + ended_at_public_racks + ended_off_grid) * 100, 2) AS percent_ended_at_public_racks,
  ROUND(ended_off_grid / (ended_at_stations + ended_at_public_racks + ended_off_grid) * 100, 2) AS percent_ended_off_grid
FROM end_station_types;

-- 4.3 Analyse des fréquences de voyages aller-retour

-- Ajouter la colonne round_trip
ALTER TABLE `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
ADD COLUMN round_trip STRING;

-- Mettre à jour la colonne round_trip en fonction des valeurs des colonnes de station
UPDATE `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
SET round_trip = CASE
  WHEN start_station_name IS NULL OR end_station_name IS NULL THEN 'n/a'
  WHEN start_station_name = end_station_name THEN 'Yes'
  ELSE 'No'
END
WHERE TRUE;

-- Explorer les fréquences de voyages aller-retour

SELECT
  member_casual,
  round_trips_total,
  ROUND(round_trips_total / (round_trips_total + one_way_total) * 100, 2) AS round_trip_percentage
FROM (
  SELECT
    member_casual,
    SUM(CASE WHEN round_trip = 'Yes' THEN 1 ELSE 0 END) AS round_trips_total,
    SUM(CASE WHEN round_trip = 'No' THEN 1 ELSE 0 END) AS one_way_total
  FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
  GROUP BY member_casual
);

---------------5. Analyse des cas de non-rendu de vélos (locations non terminées) -----------------------------------------

SELECT
  member_casual,
  count(*) AS occurences
FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
WHERE end_lat IS NULL
  OR end_lng IS NULL
GROUP BY member_casual
;

