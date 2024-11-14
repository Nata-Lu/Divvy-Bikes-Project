-- Agrégation des données dans une table temporaire pour le projet

CREATE OR REPLACE TABLE `gcc-capstone-project.cyclists_data.one_year_trips` AS
SELECT *  
FROM `gcc-capstone-project.cyclists_data.10_2023_trips` 
UNION DISTINCT
SELECT *  
FROM `gcc-capstone-project.cyclists_data.11_2023_trips` 
UNION DISTINCT
SELECT *  
FROM `gcc-capstone-project.cyclists_data.12_2023_trips` 
UNION DISTINCT
SELECT *  
FROM `gcc-capstone-project.cyclists_data.01_2024_trips` 
UNION DISTINCT
SELECT *  
FROM `gcc-capstone-project.cyclists_data.02_2024_trips` 
UNION DISTINCT
SELECT *  
FROM `gcc-capstone-project.cyclists_data.03_2024_trips` 
UNION DISTINCT
SELECT *  
FROM `gcc-capstone-project.cyclists_data.04_2024_trips` 
UNION DISTINCT
SELECT *  
FROM `gcc-capstone-project.cyclists_data.05_2024_trips` 
UNION DISTINCT
SELECT *  
FROM `gcc-capstone-project.cyclists_data.06_2024_trips` 
UNION DISTINCT
SELECT *  
FROM `gcc-capstone-project.cyclists_data.07_2024_trips` 
UNION DISTINCT
SELECT *  
FROM `gcc-capstone-project.cyclists_data.08_2024_trips` 
UNION DISTINCT
SELECT *  
FROM `gcc-capstone-project.cyclists_data.09_2024_trips`;

-- Nettoyage de données

SELECT *
FROM `gcc-capstone-project.cyclists_data.one_year_trips` 
LIMIT 1000;

------------------------------------ 1. Élimination des doublons --------------------------

SELECT DISTINCT ride_id
FROM `gcc-capstone-project.cyclists_data.one_year_trips`; -- le nombre de résultats (5,854,333) est inférieur au nombre d'enregistrements dans la table d'origine (5,854,544)

-- Visualiser les doublons
WITH duplicate_rides AS (
  SELECT 
    ride_id,
    COUNT(*) AS count
  FROM 
    `gcc-capstone-project.cyclists_data.one_year_trips`
  GROUP BY 
    ride_id
  HAVING 
    count > 1
)

SELECT 
  t.*
FROM 
  `gcc-capstone-project.cyclists_data.one_year_trips` t
JOIN 
  duplicate_rides d
ON 
  t.ride_id = d.ride_id
ORDER BY 
  t.ride_id;

-- Normaliser le format de date et heure

UPDATE `gcc-capstone-project.cyclists_data.one_year_trips`
SET 
  started_at = TIMESTAMP_TRUNC(started_at, SECOND),
  ended_at = TIMESTAMP_TRUNC(ended_at, SECOND)
WHERE 
  started_at IS NOT NULL AND ended_at IS NOT NULL;

-- Eliminer les doublons

CREATE OR REPLACE TABLE `gcc-capstone-project.cyclists_data.one_year_trips_deduped` AS
SELECT DISTINCT *
FROM `gcc-capstone-project.cyclists_data.one_year_trips`;

-- Vérifier

SELECT 
  ride_id, 
  COUNT(*) AS count
FROM 
  `gcc-capstone-project.cyclists_data.one_year_trips_deduped`
GROUP BY 
  ride_id
HAVING 
  COUNT(*) > 1; -- "No data to display"

-- Vérifier le format de ride_id

SELECT  
  LENGTH(ride_id) AS ride_id_length
FROM 
  `gcc-capstone-project.cyclists_data.one_year_trips_deduped`
GROUP BY ride_id_length
ORDER BY ride_id_length; -- ride_id a toujours une longueur fixe de 16 caractères

------------------------------- 2. Verification des données par catégories (rideable_type et member_casual) -----------------------

SELECT  
  DISTINCT rideable_type
FROM 
  `gcc-capstone-project.cyclists_data.one_year_trips_deduped`; -- 3 types: electric_bike, electric_scooter, classic_bike - OK

SELECT  
  DISTINCT member_casual
FROM 
  `gcc-capstone-project.cyclists_data.one_year_trips_deduped`; -- 2 catégories: member, casual - OK

---------------------------------- 3. Vérification de la cohérence logique des données temporelles -------------------------------

-- Identifier les lignes incoherentes

SELECT
*,
TIMESTAMP_DIFF(ended_at, started_at, MINUTE) AS trip_duration
FROM
`gcc-capstone-project.cyclists_data.one_year_trips_deduped`
WHERE
TIMESTAMP_DIFF(ended_at, started_at, MINUTE) < 0; -- 116 résultats hétérogènes

-- Créer une nouvelle table avec la colonne trip_duration et exclure les lignes incohérentes

CREATE OR REPLACE TABLE `gcc-capstone-project.cyclists_data.one_year_trips_cleaned` AS
SELECT
*,
TIMESTAMP_DIFF(ended_at, started_at, MINUTE) AS trip_duration
FROM
`gcc-capstone-project.cyclists_data.one_year_trips_deduped`
WHERE
TIMESTAMP_DIFF(ended_at, started_at, MINUTE) >= 0;

------------------------------ 4. Nettoyage des données pour les points de départ et d'arrivée ---------------------

-- Normaliser les coordonnées GPS

UPDATE `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
SET 
  start_lat = ROUND(start_lat, 3),
  start_lng = ROUND(start_lng, 3),
  end_lat = ROUND(end_lat, 3),
  end_lng = ROUND(end_lng, 3)
WHERE TRUE;

UPDATE `gcc-capstone-project.cyclists_data.stations`
SET 
  Latitude = ROUND(Latitude, 3),
  Longitude = ROUND(Longitude, 3)
WHERE TRUE;

-- ---------

SELECT DISTINCT 
  start_station_name, 
  start_station_id,
  start_lat,
  start_lng
FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
WHERE start_station_name IS NOT NULL AND start_station_id IS NOT NULL
ORDER BY start_station_name; -- 8715 lignes

SELECT DISTINCT 
  start_station_name, 
  start_station_id,
  --start_lat,
  --start_lng
FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
WHERE start_station_name LIKE 'Public Rack%'
ORDER BY start_station_name; -- 684 lignes

-- Ajouter les colonnes station_type

ALTER TABLE `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
ADD COLUMN start_station_type STRING,
ADD COLUMN end_station_type STRING;

-- Mise à jour des nouvelles colonnes avec les valeurs conditionnelles
UPDATE `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
SET 
  start_station_type = CASE 
    WHEN start_station_name IS NULL AND start_station_id IS NULL THEN 'off_grid'
    WHEN start_station_name LIKE 'Public Rack%' THEN 'public_rack'
    ELSE 'station'
  END,
  end_station_type = CASE 
    WHEN end_station_name IS NULL AND end_station_id IS NULL THEN 'off_grid'
    WHEN end_station_name LIKE 'Public Rack%' THEN 'public_rack'
    ELSE 'station'
  END
  WHERE TRUE;

-------------------------------------------- Noms de stations --------------------------------------------------
-- Visualiser les noms de stations erronés

SELECT DISTINCT
  start_station_name, 
  start_station_id,
  start_station_type,
  start_lat,
  start_lng,
  ref.*
FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned` main
JOIN `gcc-capstone-project.cyclists_data.stations_prep` ref
  ON main.start_station_id = ref.station_id
WHERE start_station_type = 'station' AND main.start_station_name != ref.station_name
ORDER BY main.start_station_name;

-- Corriger les noms de stations

UPDATE `gcc-capstone-project.cyclists_data.one_year_trips_cleaned` AS main
SET main.start_station_name = ref.station_name
FROM `gcc-capstone-project.cyclists_data.stations_prep` AS ref
WHERE main.start_station_id = ref.station_id
  AND main.start_station_type = 'station' 
  AND main.start_station_name != ref.station_name;

SELECT DISTINCT start_station_name
FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
WHERE start_station_id = '15541.1.1'; -- checked OK

-- Répéter pour les stations d'arrivée

-- Visualiser les noms de stations erronés
SELECT DISTINCT
  end_station_name, 
  end_station_id,
  end_station_type,
  end_lat,
  end_lng,
  ref.*
FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned` main
JOIN `gcc-capstone-project.cyclists_data.stations_prep` ref
  ON main.end_station_id = ref.station_id
WHERE end_station_type = 'station' AND main.end_station_name != ref.station_name
ORDER BY main.end_station_name;

-- Corriger les noms de stations

UPDATE `gcc-capstone-project.cyclists_data.one_year_trips_cleaned` AS main
SET main.end_station_name = ref.station_name
FROM `gcc-capstone-project.cyclists_data.stations_prep` AS ref
WHERE main.end_station_id = ref.station_id
  AND main.end_station_type = 'station' 
  AND main.end_station_name != ref.station_name;

--------------------------------------- Identifiants des stations ------------------------------------

-- Visualiser les incohérences dans les identifiants des stations

SELECT DISTINCT
  start_station_name, 
  start_station_id,
  start_station_type,
  ref.*
FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned` main
JOIN `gcc-capstone-project.cyclists_data.stations_prep` ref
  ON main.start_station_name = ref.station_name
WHERE start_station_type = 'station' AND main.start_station_id != ref.station_id
ORDER BY main.start_station_name;

-- Vérifier les cas qui ne corrensondent pas au modèle principal
SELECT *
FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
WHERE start_station_name IN ('Steelworkers Park', 'Lamon Ave & Chicago Ave', 'Indiana Ave & 133rd St')
ORDER BY start_station_name;

-- Corriger les identifiants de stations

UPDATE `gcc-capstone-project.cyclists_data.one_year_trips_cleaned` AS main
SET main.start_station_id = ref.station_id
FROM `gcc-capstone-project.cyclists_data.stations_prep` AS ref
WHERE main.start_station_name = ref.station_name
  AND main.start_station_type = 'station' 
  AND main.start_station_id != ref.station_id;

SELECT DISTINCT start_station_id
FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
WHERE start_station_name = 'Albany Ave & Douglas Blvd'; -- checked OK

-- Répéter pour les stations d'arrivée
-- Visualiser les incohérences dans les identifiants des stations

SELECT DISTINCT
  end_station_name, 
  end_station_id,
  end_station_type,
  ref.*
FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned` main
JOIN `gcc-capstone-project.cyclists_data.stations_prep` ref
  ON main.end_station_name = ref.station_name
WHERE end_station_type = 'station' AND main.end_station_id != ref.station_id
ORDER BY main.end_station_name;

-- Corriger les identifiants de stations

UPDATE `gcc-capstone-project.cyclists_data.one_year_trips_cleaned` AS main
SET main.end_station_id = ref.station_id
FROM `gcc-capstone-project.cyclists_data.stations_prep` AS ref
WHERE main.end_station_name = ref.station_name
  AND main.end_station_type = 'station' 
  AND main.end_station_id != ref.station_id;

------------------------------------------

SELECT DISTINCT 
  start_station_name, 
  start_station_id,
  --start_lat,
  --start_lng,
  start_station_type
FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
WHERE start_station_name IS NOT NULL 
  AND start_station_id IS NOT NULL
  AND start_station_type = 'station'
ORDER BY start_station_name; -- 1034 résultats

-- Vérifier des incohérences restantes
SELECT DISTINCT 
  main.start_station_name, 
  main.start_station_id, 
  main.start_station_type,
  ref.*
FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned` main
FULL OUTER JOIN `gcc-capstone-project.cyclists_data.stations_prep` ref
  ON main.start_station_name = ref.station_name
WHERE main.start_station_type = 'station'
  AND ref.station_id IS NULL
  AND ref.station_name IS NULL
ORDER BY main.start_station_name;

-- Manual corrections
UPDATE `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
SET start_station_name = CASE
    WHEN start_station_name = 'Harlem & Irving Park' THEN 'Harlem Ave & Irving Park Rd'
    WHEN start_station_name = 'Kilbourn & Belden' THEN 'Kilbourn Ave & Belden Ave'
    WHEN start_station_name = 'Kilbourn & Roscoe' THEN 'Kilbourn Ave & Roscoe St'
    WHEN start_station_name = 'La Villita Park (Albany/30th)' THEN 'La Villita Park'
    WHEN start_station_name = 'Lavergne & Fullerton' THEN 'Lavergne Ave & Fullerton Ave'
    WHEN start_station_name = 'Bloomingdale Ave & Harlem Ave' THEN 'Harlem Ave & Bloomingdale Ave'
    WHEN start_station_name = 'Cicero Ave & Grace St' THEN 'Grace St & Cicero Ave'
    WHEN start_station_name = 'Mayfield & Roosevelt Rd' THEN 'Mayfield Ave & Roosevelt Rd'
    WHEN start_station_name = 'Mulligan Ave & Wellington Ave' THEN 'Wellington Ave & Mulligan Ave'
    WHEN start_station_name = 'Narragansett & McLean' THEN 'Narragansett Ave & McLean Ave'
    WHEN start_station_name = 'Narragansett & Wrightwood' THEN 'Narragansett Ave & Wrightwood Ave'
    WHEN start_station_name = 'Nordica & Medill' THEN 'Nordica Ave & Medill Ave'
    WHEN start_station_name = 'Pulaski & Ann Lurie Pl' THEN 'Pulaski Rd & Ann Lurie Pl'
    WHEN start_station_name = 'Pulaski Rd & 21st St' THEN '21st St & Pulaski Rd'
    WHEN start_station_name = 'Sacramento Ave & Pershing Rd' THEN 'Pershing Rd & Sacramento Ave'
    WHEN start_station_name = 'Sayre & Diversey' THEN 'Sayre Ave & Diversey Ave'
    WHEN start_station_name = 'Spaulding Ave & 63rd St' THEN 'Spaulding Ave & 63rd'
    WHEN start_station_name = 'St Louis Ave & Norman Bobbins Ave' THEN 'St Louis Ave & Norman Bobbins Pl'
    ELSE start_station_name  -- Conserve la valeur actuelle pour les autres lignes
END
WHERE start_station_name IN (
    'Harlem & Irving Park',
    'Kilbourn & Belden',
    'Kilbourn & Roscoe',
    'La Villita Park (Albany/30th)',
    'Lavergne & Fullerton',
    'Bloomingdale Ave & Harlem Ave',
    'Cicero Ave & Grace St',
    'Mayfield & Roosevelt Rd',
    'Mulligan Ave & Wellington Ave',
    'Narragansett & McLean',
    'Narragansett & Wrightwood',
    'Nordica & Medill',
    'Pulaski & Ann Lurie Pl',
    'Pulaski Rd & 21st St',
    'Sacramento Ave & Pershing Rd',
    'Sayre & Diversey',
    'Spaulding Ave & 63rd St',
    'St Louis Ave & Norman Bobbins Ave'
);

-- Pour les stations d'arrivée

SELECT DISTINCT 
  main.end_station_name, 
  main.end_station_id, 
  main.end_station_type,
  ref.*
FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned` main
FULL OUTER JOIN `gcc-capstone-project.cyclists_data.stations_prep` ref
  ON main.end_station_name = ref.station_name
WHERE main.end_station_type = 'station'
  AND ref.station_id IS NULL
  AND ref.station_name IS NULL
ORDER BY main.end_station_name;

-- Manual corrections
UPDATE `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
SET end_station_name = CASE
    WHEN end_station_name = 'Harlem & Irving Park' THEN 'Harlem Ave & Irving Park Rd'
    WHEN end_station_name = 'Kilbourn & Belden' THEN 'Kilbourn Ave & Belden Ave'
    WHEN end_station_name = 'Kilbourn & Roscoe' THEN 'Kilbourn Ave & Roscoe St'
    WHEN end_station_name = 'La Villita Park (Albany/30th)' THEN 'La Villita Park'
    WHEN end_station_name = 'Lavergne & Fullerton' THEN 'Lavergne Ave & Fullerton Ave'
    WHEN end_station_name = 'Bloomingdale Ave & Harlem Ave' THEN 'Harlem Ave & Bloomingdale Ave'
    WHEN end_station_name = 'Cicero Ave & Grace St' THEN 'Grace St & Cicero Ave'
    WHEN end_station_name = 'Mayfield & Roosevelt Rd' THEN 'Mayfield Ave & Roosevelt Rd'
    WHEN end_station_name = 'Mulligan Ave & Wellington Ave' THEN 'Wellington Ave & Mulligan Ave'
    WHEN end_station_name = 'Narragansett & McLean' THEN 'Narragansett Ave & McLean Ave'
    WHEN end_station_name = 'Narragansett & Wrightwood' THEN 'Narragansett Ave & Wrightwood Ave'
    WHEN end_station_name = 'Nordica & Medill' THEN 'Nordica Ave & Medill Ave'
    WHEN end_station_name = 'Pulaski & Ann Lurie Pl' THEN 'Pulaski Rd & Ann Lurie Pl'
    WHEN end_station_name = 'Pulaski Rd & 21st St' THEN '21st St & Pulaski Rd'
    WHEN end_station_name = 'Sacramento Ave & Pershing Rd' THEN 'Pershing Rd & Sacramento Ave'
    WHEN end_station_name = 'Sayre & Diversey' THEN 'Sayre Ave & Diversey Ave'
    WHEN end_station_name = 'Spaulding Ave & 63rd St' THEN 'Spaulding Ave & 63rd'
    WHEN end_station_name = 'St Louis Ave & Norman Bobbins Ave' THEN 'St Louis Ave & Norman Bobbins Pl'
    ELSE end_station_name  -- Conserve la valeur actuelle pour les autres lignes
END
WHERE end_station_name IN (
    'Harlem & Irving Park',
    'Kilbourn & Belden',
    'Kilbourn & Roscoe',
    'La Villita Park (Albany/30th)',
    'Lavergne & Fullerton',
    'Bloomingdale Ave & Harlem Ave',
    'Cicero Ave & Grace St',
    'Mayfield & Roosevelt Rd',
    'Mulligan Ave & Wellington Ave',
    'Narragansett & McLean',
    'Narragansett & Wrightwood',
    'Nordica & Medill',
    'Pulaski & Ann Lurie Pl',
    'Pulaski Rd & 21st St',
    'Sacramento Ave & Pershing Rd',
    'Sayre & Diversey',
    'Spaulding Ave & 63rd St',
    'St Louis Ave & Norman Bobbins Ave'
);

-- Répéter les operations de correction des identifiants (lignes 282 et 307 ^)



----------------------------------- Coordonnées GPS des stations -----------------------------------------

-- Visualiser les incohérences dans les coordonnées GPS des stations

SELECT DISTINCT
  start_station_name,
  start_station_id,
  start_station_type,
  start_lat,
  start_lng
FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
WHERE start_station_type = 'station'
ORDER BY start_station_name; --7595 résultats, après start_lat 4847, après start_lng 1067

-- Start_lat

SELECT DISTINCT
  main.start_station_name,
  main.start_station_id,
  main.start_station_type,
  main.start_lat,
  ref.station_name,
  ref.station_id,
  ref.station_lat,
  main.start_lat - ref.station_lat AS lat_difference
FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned` main
JOIN `gcc-capstone-project.cyclists_data.stations_prep` ref
  ON main.start_station_name = ref.station_name
WHERE start_station_type = 'station' 
AND main.start_lat != ref.station_lat
ORDER BY main.start_station_name; --avant 3631 résultats -- après 'There is no data to display.'

-- Normaliser les coordonnées des stations

UPDATE `gcc-capstone-project.cyclists_data.one_year_trips_cleaned` AS main
SET main.start_lat = ref.station_lat
FROM `gcc-capstone-project.cyclists_data.stations_prep` AS ref
WHERE main.start_station_name = ref.station_name
  AND main.start_station_id = ref.station_id
  AND main.start_station_type = 'station' 
  AND main.start_lat != ref.station_lat
  --AND main.start_lat - ref.station_lat BETWEEN -0.01 AND 0.01
  ;

-- Start_lng

SELECT DISTINCT
  main.start_station_name,
  main.start_station_id,
  main.start_station_type,
  main.start_lng,
  ref.station_name,
  ref.station_id,
  ref.station_lng,
  main.start_lng - ref.station_lng AS lng_difference
FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned` main
JOIN `gcc-capstone-project.cyclists_data.stations_prep` ref
  ON main.start_station_name = ref.station_name
WHERE start_station_type = 'station' 
AND main.start_lng != ref.station_lng
ORDER BY main.start_station_name; -- avant 3782 résultats -- après 'There is no data to display.'

-- Normaliser les coordonnées des stations

UPDATE `gcc-capstone-project.cyclists_data.one_year_trips_cleaned` AS main
SET main.start_lng = ref.station_lng
FROM `gcc-capstone-project.cyclists_data.stations_prep` AS ref
WHERE main.start_station_name = ref.station_name
  --AND main.start_station_id = ref.station_id
  AND main.start_station_type = 'station' 
  AND main.start_lng != ref.station_lng
  AND main.start_lat - ref.station_lat BETWEEN -0.01 AND 0.01
  ;

-- End_lat

SELECT DISTINCT
  main.end_station_name,
  main.end_station_id,
  main.end_station_type,
  main.end_lat,
  ref.station_name,
  ref.station_id,
  ref.station_lat,
  main.end_lat - ref.station_lat AS lat_difference
FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned` main
JOIN `gcc-capstone-project.cyclists_data.stations_prep` ref
  ON main.end_station_name = ref.station_name
WHERE end_station_type = 'station' 
AND main.end_lat != ref.station_lat
ORDER BY main.end_station_name; --avant 336 résultats -- après 'There is no data to display.'

-- Normaliser les coordonnées des stations

UPDATE `gcc-capstone-project.cyclists_data.one_year_trips_cleaned` AS main
SET main.end_lat = ref.station_lat
FROM `gcc-capstone-project.cyclists_data.stations_prep` AS ref
WHERE main.end_station_name = ref.station_name
  --AND main.end_station_id = ref.station_id
  AND main.end_station_type = 'station' 
  AND main.end_lat != ref.station_lat
  AND main.end_lat - ref.station_lat BETWEEN -0.01 AND 0.01
  ;

-- End_lng

SELECT DISTINCT
  main.end_station_name,
  main.end_station_id,
  main.end_station_type,
  main.end_lng,
  ref.station_name,
  ref.station_id,
  ref.station_lng,
  main.end_lng - ref.station_lng AS lng_difference
FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned` main
JOIN `gcc-capstone-project.cyclists_data.stations_prep` ref
  ON main.end_station_name = ref.station_name
WHERE end_station_type = 'station' 
AND main.end_lng != ref.station_lng
ORDER BY main.end_station_name; -- avant 322 résultats -- après 'There is no data to display.'

-- Normaliser les coordonnées des stations

UPDATE `gcc-capstone-project.cyclists_data.one_year_trips_cleaned` AS main
SET main.end_lng = ref.station_lng
FROM `gcc-capstone-project.cyclists_data.stations_prep` AS ref
WHERE main.end_station_name = ref.station_name
  AND main.end_station_id = ref.station_id
  AND main.end_station_type = 'station' 
  AND main.end_lng != ref.station_lng
  --AND main.start_lat - ref.station_lat BETWEEN -0.01 AND 0.01
  ;
--------Standartiser les coordonnées GPS pour les stations restantes et les racks publics

-- Visualiser les stations ne figurant pas dans la table de référence

SELECT DISTINCT 
  start_station_name,
  start_station_id,
  start_lat,
  start_lng,
  ROUND (AVG(start_lat) OVER (PARTITION BY start_station_name),3) AS avg_lat,
  ROUND (AVG (start_lng) OVER (PARTITION BY start_station_name),3) AS avg_lng,
FROM 
  `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
WHERE 
  start_station_type = 'station'
  AND start_station_name NOT IN (
    SELECT station_name 
    FROM `gcc-capstone-project.cyclists_data.stations_prep`
  )
ORDER BY start_station_name;

-- Remplacer les coordonnées par les valeurs moyenne par station

-- Note: Sauf dans BigQuery ce code doit marcher (BigQuery ne supporte pas les opérations d'UPDATE directes utilisant une CTE)
WITH station_avg AS (
  SELECT DISTINCT 
    start_station_name,
    start_station_id,
    ROUND(AVG(start_lat) OVER (PARTITION BY start_station_name), 3) AS avg_lat,
    ROUND(AVG(start_lng) OVER (PARTITION BY start_station_name), 3) AS avg_lng
  FROM 
    `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
  WHERE 
    start_station_type = 'station'
    AND start_station_name NOT IN (
      SELECT station_name 
      FROM `gcc-capstone-project.cyclists_data.stations_prep`
    )
)

UPDATE `gcc-capstone-project.cyclists_data.one_year_trips_cleaned` AS main
SET 
  main.start_lat = station_avg.avg_lat,
  main.start_lng = station_avg.avg_lng
FROM station_avg
WHERE 
  main.start_station_name = station_avg.start_station_name
  AND main.start_station_type = 'station';

-- Dans BigQuery -- a. Créer une table temporaire pour stocker les moyennes

CREATE OR REPLACE TABLE `gcc-capstone-project.cyclists_data.station_avg_temp` AS
SELECT DISTINCT 
  start_station_name,
  start_station_id,
  ROUND(AVG(start_lat) OVER (PARTITION BY start_station_name), 3) AS avg_lat,
  ROUND(AVG(start_lng) OVER (PARTITION BY start_station_name), 3) AS avg_lng
FROM 
  `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
WHERE 
  start_station_type = 'station'
  AND start_station_name NOT IN (
    SELECT station_name 
    FROM `gcc-capstone-project.cyclists_data.stations_prep`
  );

-- b. Mettre à jour la table principale avec les moyennes

UPDATE `gcc-capstone-project.cyclists_data.one_year_trips_cleaned` AS main
SET 
  main.start_lat = temp.avg_lat,
  main.start_lng = temp.avg_lng
FROM `gcc-capstone-project.cyclists_data.station_avg_temp` AS temp
WHERE 
  main.start_station_name = temp.start_station_name
  AND main.start_station_type = 'station';

-- Pour les stations d'arrivée 

-- a. Créer une table temporaire pour stocker les moyennes (utilise le même nom de table temporaire)

CREATE OR REPLACE TABLE `gcc-capstone-project.cyclists_data.station_avg_temp` AS
SELECT DISTINCT 
  end_station_name,
  end_station_id,
  ROUND(AVG(end_lat) OVER (PARTITION BY end_station_name), 3) AS avg_lat,
  ROUND(AVG(end_lng) OVER (PARTITION BY end_station_name), 3) AS avg_lng
FROM 
  `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
WHERE 
  end_station_type = 'station'
  AND end_station_name NOT IN (
    SELECT station_name 
    FROM `gcc-capstone-project.cyclists_data.stations_prep`
  );

-- b. Mettre à jour la table principale avec les moyennes

UPDATE `gcc-capstone-project.cyclists_data.one_year_trips_cleaned` AS main
SET 
  main.end_lat = temp.avg_lat,
  main.end_lng = temp.avg_lng
FROM `gcc-capstone-project.cyclists_data.station_avg_temp` AS temp
WHERE 
  main.end_station_name = temp.end_station_name
  AND main.end_station_type = 'station';

----------- Touches finales

SELECT DISTINCT 
  start_station_name,
  start_station_id,
  start_lat,
  start_lng,
FROM 
  `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
WHERE 
  start_station_type = 'station'
ORDER BY start_station_name; -- 1019 résultats, pour les coordonnées GPS uniques - 1005 résultats

-- Identifier quelques incohérences restantes

WITH repeated_coordinates AS (
  SELECT 
    start_lat,
    start_lng
  FROM (
    SELECT DISTINCT 
      start_station_name,
      start_station_id,
      start_lat,
      start_lng
    FROM 
      `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
    WHERE 
      start_station_type = 'station'
  ) AS unique_stations
  GROUP BY 
    start_lat, 
    start_lng
  HAVING 
    COUNT(*) > 1
)

SELECT DISTINCT
  main.start_station_name,
  main.start_station_id,
  main.start_lat,
  main.start_lng
FROM 
  `gcc-capstone-project.cyclists_data.one_year_trips_cleaned` AS main
JOIN 
  repeated_coordinates AS rc
ON 
  main.start_lat = rc.start_lat
  AND main.start_lng = rc.start_lng
WHERE 
  main.start_station_type = 'station'
ORDER BY 
  main.start_lat, 
  main.start_lng, 
  main.start_station_name; -- 28 résultats (14 stations en double)

-- Manual corrections
UPDATE `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
SET start_station_name = CASE
    WHEN start_station_name = 'Rainbow Beach' THEN 'Rainbow - Beach'
    WHEN start_station_name = 'Damen Ave/Coulter St' THEN 'Damen Ave & Coulter St'
    WHEN start_station_name = 'SCOOTERS CLASSIC - 2132 W Hubbard ST' THEN 'MTV Hubbard St'
    WHEN start_station_name = 'N Clark St & W Elm St' THEN 'Clark St & Elm St' --
    WHEN start_station_name = 'N Southport Ave & W Newport Ave' THEN 'Southport Ave & Roscoe St'
    WHEN start_station_name = 'Orange & Addison' THEN 'Orange Ave & Addison St'
    WHEN start_station_name = 'Plainfield & Irving Park' THEN 'Pittsburgh Ave & Irving Park Rd'
    WHEN start_station_name = 'Narragansett & Irving Park' THEN 'Merrimac Park'
    ELSE start_station_name  -- Conserve la valeur actuelle pour les autres lignes
END
WHERE start_station_name IN (
    'Rainbow Beach',
    'Damen Ave/Coulter St',
    'SCOOTERS CLASSIC - 2132 W Hubbard ST',
    'N Clark St & W Elm St',
    'N Southport Ave & W Newport Ave',
    'Orange & Addison',
    'Plainfield & Irving Park',
    'Narragansett & Irving Park'
);
  
UPDATE `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
SET start_station_id = '021320'
WHERE start_station_id = 'Hubbard Bike-checking (LBS-WH-TEST)';

------ Pour les stations d'arrivée
SELECT DISTINCT 
  end_station_name,
  end_station_id,
  end_lat,
  end_lng,
FROM 
  `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
WHERE 
  end_station_type = 'station'
ORDER BY end_station_name; 

WITH repeated_coordinates AS (
  SELECT 
    end_lat,
    end_lng
  FROM (
    SELECT DISTINCT 
      end_station_name,
      end_station_id,
      end_lat,
      end_lng
    FROM 
      `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
    WHERE 
      end_station_type = 'station'
  ) AS unique_stations
  GROUP BY 
    end_lat, 
    end_lng
  HAVING 
    COUNT(*) > 1
)

SELECT DISTINCT
  main.end_station_name,
  main.end_station_id,
  main.end_lat,
  main.end_lng
FROM 
  `gcc-capstone-project.cyclists_data.one_year_trips_cleaned` AS main
JOIN 
  repeated_coordinates AS rc
ON 
  main.end_lat = rc.end_lat
  AND main.end_lng = rc.end_lng
WHERE 
  main.end_station_type = 'station'
ORDER BY 
  main.end_lat, 
  main.end_lng, 
  main.end_station_name;

-- Manual corrections
UPDATE `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
SET end_station_name = CASE
    WHEN end_station_name = 'Rainbow Beach' THEN 'Rainbow - Beach'
    WHEN end_station_name = 'Damen Ave/Coulter St' THEN 'Damen Ave & Coulter St'
    WHEN end_station_name = 'Base - 2132 W Hubbard' THEN 'MTV Hubbard St'
    WHEN end_station_name = 'SCOOTERS - 2132 W Hubbard ST' THEN 'MTV Hubbard St'
    WHEN end_station_name = 'SCOOTERS CLASSIC - 2132 W Hubbard ST' THEN 'MTV Hubbard St'
    WHEN end_station_name = 'N Clark St & W Elm St' THEN 'Clark St & Elm St' --
    WHEN end_station_name = 'N Southport Ave & W Newport Ave' THEN 'Southport Ave & Roscoe St'
    WHEN end_station_name = 'Orange & Addison' THEN 'Orange Ave & Addison St'
    WHEN end_station_name = 'Plainfield & Irving Park' THEN 'Pittsburgh Ave & Irving Park Rd'
    WHEN end_station_name = 'Narragansett & Irving Park' THEN 'Merrimac Park'
    WHEN end_station_name = 'OH - BONFIRE - TESTING' THEN 'Franklin St & Illinois St'
    ELSE end_station_name  -- Conserve la valeur actuelle pour les autres lignes
END
WHERE end_station_name IN (
    'Rainbow Beach',
    'Damen Ave/Coulter St',
    'Base - 2132 W Hubbard',
    'SCOOTERS - 2132 W Hubbard ST',
    'SCOOTERS CLASSIC - 2132 W Hubbard ST',
    'N Clark St & W Elm St',
    'N Southport Ave & W Newport Ave',
    'Orange & Addison',
    'Plainfield & Irving Park',
    'Narragansett & Irving Park',
    'OH - BONFIRE - TESTING'
);
  
UPDATE `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
SET end_station_id = '021320'
WHERE end_station_id = 'Hubbard Bike-checking (LBS-WH-TEST)';

-- IMPORTANT : Répéter les opérations de normalisation des identifiants (ligne 288 et 307)

-- Unifier les coordonnées GPS des racks publics

--Visualiser les racks publics

SELECT DISTINCT 
  start_station_name,
  start_station_id,
  start_lat,
  start_lng,
FROM 
  `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
WHERE 
  start_station_type = 'public_rack'
ORDER BY start_station_name; -- 1000 lignes, sans GPS 684 lignes

-- a. Créer une table temporaire pour stocker les moyennes

CREATE OR REPLACE TABLE `gcc-capstone-project.cyclists_data.station_avg_temp` AS
SELECT DISTINCT 
  start_station_name,
  start_station_id,
  ROUND(AVG(start_lat) OVER (PARTITION BY start_station_name), 3) AS avg_lat,
  ROUND(AVG(start_lng) OVER (PARTITION BY start_station_name), 3) AS avg_lng
FROM 
  `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
WHERE 
  start_station_type = 'public_rack'
 ;

-- b. Mettre à jour la table principale avec les moyennes

UPDATE `gcc-capstone-project.cyclists_data.one_year_trips_cleaned` AS main
SET 
  main.start_lat = temp.avg_lat,
  main.start_lng = temp.avg_lng
FROM `gcc-capstone-project.cyclists_data.station_avg_temp` AS temp
WHERE 
  main.start_station_name = temp.start_station_name
  AND main.start_station_type = 'public_rack';

-- Pour les points d'arrivée 

-- a. Créer une table temporaire pour stocker les moyennes (utilise le même nom de table temporaire)

CREATE OR REPLACE TABLE `gcc-capstone-project.cyclists_data.station_avg_temp` AS
SELECT DISTINCT 
  end_station_name,
  end_station_id,
  ROUND(AVG(end_lat) OVER (PARTITION BY end_station_name), 3) AS avg_lat,
  ROUND(AVG(end_lng) OVER (PARTITION BY end_station_name), 3) AS avg_lng
FROM 
  `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
WHERE 
  end_station_type = 'public_rack'
  ;

-- b. Mettre à jour la table principale avec les moyennes

UPDATE `gcc-capstone-project.cyclists_data.one_year_trips_cleaned` AS main
SET 
  main.end_lat = temp.avg_lat,
  main.end_lng = temp.avg_lng
FROM `gcc-capstone-project.cyclists_data.station_avg_temp` AS temp
WHERE 
  main.end_station_name = temp.end_station_name
  AND main.end_station_type = 'public_rack';

-- Check 

SELECT DISTINCT 
  end_station_name,
  end_station_id,
  end_lat,
  end_lng,
FROM 
  `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
WHERE 
  end_station_type = 'public_rack'
ORDER BY end_station_name;

-------------------------Verification de la cohérence des coordonnées GPS ----------------------------

SELECT
  MIN(start_lat) AS min_start_lat,
  MAX(start_lat) AS max_start_lat,
  MIN(end_lat) AS min_end_lat,
  MAX(end_lat) AS max_end_lat,
  MIN(start_lng) AS min_start_lng,
  MAX(start_lng) AS max_start_lng,
  MIN(end_lng) AS min_end_lng,
  MAX(end_lng) AS max_end_lng
FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
; 

-- Identifier les erreurs

SELECT
  *
FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
WHERE end_lat NOT BETWEEN 41.0 AND 43.0
  OR end_lng NOT BETWEEN -89.0 AND -87.0; -- 31 résultats incohérent

-- Supprimer les lignes contenant les erreurs

DELETE FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
WHERE end_lat NOT BETWEEN 41.0 AND 43.0
  OR end_lng NOT BETWEEN -89.0 AND -87.0;


----------- Vérification des valeurs nulles ------------------------------

SELECT 
  SUM(CASE WHEN ride_id IS NULL THEN 1 ELSE 0 END) AS null_ride_id,
  SUM(CASE WHEN rideable_type IS NULL THEN 1 ELSE 0 END) AS null_bike_type,
  SUM(CASE WHEN started_at IS NULL THEN 1 ELSE 0 END) AS null_started_at,
  SUM(CASE WHEN ended_at IS NULL THEN 1 ELSE 0 END) AS null_ended_at,
  SUM(CASE WHEN start_station_name IS NULL THEN 1 ELSE 0 END) AS null_start_station_name,
  SUM(CASE WHEN start_station_id IS NULL THEN 1 ELSE 0 END) AS null_start_station_id,
  SUM(CASE WHEN start_lat IS NULL THEN 1 ELSE 0 END) AS null_start_lat,
  SUM(CASE WHEN start_lng IS NULL THEN 1 ELSE 0 END) AS null_start_lng,
  SUM(CASE WHEN end_station_name IS NULL THEN 1 ELSE 0 END) AS null_end_station_name,
  SUM(CASE WHEN end_station_id IS NULL THEN 1 ELSE 0 END) AS null_end_station_id,
  SUM(CASE WHEN end_lat IS NULL THEN 1 ELSE 0 END) AS null_end_lat,
  SUM(CASE WHEN end_lng IS NULL THEN 1 ELSE 0 END) AS null_end_lng,
  SUM(CASE WHEN member_casual IS NULL THEN 1 ELSE 0 END) AS null_user_type
FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`;


SELECT
  *
FROM `gcc-capstone-project.cyclists_data.one_year_trips_cleaned`
WHERE end_lat IS NULL
  OR end_lng IS NULL;



