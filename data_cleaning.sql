USE quality_of_life_dataset;

-- Test if the imported data from Excel has been transferred successfully
SELECT *
FROM quality_of_life;

-- Create a staging table for modifications
SELECT *
INTO quality_of_life_staging
FROM quality_of_life;

-- Display the staging table
SELECT * 
FROM quality_of_life_staging

-- Data Cleaning
-- 1. Correct quality_of_value values and data type

-- Update the column vlaues
UPDATE quality_of_life_staging
SET quality_of_life_value = 
	CASE
		WHEN quality_of_life_value LIKE '%:%' THEN TRIM(REPLACE(SUBSTRING(quality_of_life_value, 3, LEN(quality_of_life_value)), '''', ''))
		ELSE TRIM(REPLACE(quality_of_life_value, '''', ''))
	END;

-- Alter table and column type
ALTER TABLE quality_of_life_staging
ALTER COLUMN quality_of_life_value FLOAT;

-- Check columns information
SELECT * FROM INFORMATION_SCHEMA.COLUMNS

-- 2. Replace None by NULL

UPDATE quality_of_life_staging
SET 
    purchasing_power_category = CASE WHEN purchasing_power_category = 'None' THEN NULL ELSE purchasing_power_category END,
    safety_category = CASE WHEN safety_category = 'None' THEN NULL ELSE safety_category END,
    health_care_category = CASE WHEN health_care_category = 'None' THEN NULL ELSE health_care_category END,
    climate_category = CASE WHEN climate_category = 'None' THEN NULL ELSE climate_category END,
    cost_of_living_category = CASE WHEN cost_of_living_category = 'None' THEN NULL ELSE cost_of_living_category END,
    property_price_to_income_category = CASE WHEN property_price_to_income_category = 'None' THEN NULL ELSE property_price_to_income_category END,
    traffic_commute_time_category = CASE WHEN traffic_commute_time_category = 'None' THEN NULL ELSE traffic_commute_time_category END,
    pollution_category = CASE WHEN pollution_category = 'None' THEN NULL ELSE pollution_category END,
    quality_of_life_category = CASE WHEN quality_of_life_category = 'None' THEN NULL ELSE quality_of_life_category END
WHERE 
    purchasing_power_category = 'None'
    OR safety_category = 'None'
    OR health_care_category = 'None'
    OR climate_category = 'None'
    OR cost_of_living_category = 'None'
    OR property_price_to_income_category = 'None'
    OR traffic_commute_time_category = 'None'
    OR pollution_category = 'None'
    OR quality_of_life_category = 'None';

-- 3. Remove duplicates

WITH duplicates_cte AS (
SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY
			purchasing_power_value,
			purchasing_power_category,
			safety_value,
			safety_category,
			health_care_value,
			health_care_category,
			climate_value,
			climate_category,
			cost_of_living_value,
			cost_of_living_category,
			property_price_to_income_value,
			property_price_to_income_category,
			traffic_commute_time_value,
			traffic_commute_time_category,
			pollution_value,
			pollution_category,
			quality_of_life_value,
			quality_of_life_category
			ORDER BY country) AS row_num
FROM quality_of_life_staging)

SELECT *
FROM duplicates_cte
WHERE row_num > 1;

-- 4. Remove useless rows

DELETE
FROM quality_of_life_staging
WHERE purchasing_power_value = 0 
	AND purchasing_power_category IS NULL
	AND safety_value = 0
	AND safety_category IS NULL
	AND health_care_value = 0
	AND health_care_category IS NULL
	AND climate_value = 0
	AND climate_category IS NULL
	AND cost_of_living_value = 0
	AND cost_of_living_category IS NULL
	AND property_price_to_income_value = 0
	AND property_price_to_income_category IS NULL
	AND traffic_commute_time_value = 0
	AND traffic_commute_time_category IS NULL
	AND pollution_value = 0
	AND pollution_category IS NULL
	AND quality_of_life_value = 0
	AND quality_of_life_category IS NULL

	SELECT *
	FROM quality_of_life_staging
