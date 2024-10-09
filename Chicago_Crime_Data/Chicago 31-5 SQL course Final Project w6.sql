-- Active: 1713798495497@@localhost@5432@CourserosSQL@public

-- You have been asked to produce some reports about the communities and crimes in the Chicago area.

-- List school names, community names and average attendance for communities with a hardship index of 98
SELECT pub.name_of_school, pub.community_area_name, pub.average_student_attendance, pub.average_teacher_attendance --, cen.hardship_index
FROM public.pubschools pub
    INNER JOIN public.census cen
    ON cen.community_area_number = pub.community_area_number
WHERE cen.hardship_index = 98;

-- List all crimes that took place at a school. Include case number, crime type and community name
SELECT cri.case_number, cri.PRIMARY_TYPE, cen.COMMUNITY_AREA_NAME , cri.LOCATION_DESCRIPTION
FROM public.crime cri
    INNER JOIN public.census cen
    ON cen.community_area_number = cri.community_area_number
WHERE cri.LOCATION_DESCRIPTION ILIKE '%school%';

-- For privacy reasons, you have been asked to create a view that enables users to select just the
-- school name and the icon fields from the CHICAGO_PUBLIC_SCHOOLS table

-- Return all of the columns from the view
CREATE VIEW view1 AS 
SELECT NAME_OF_SCHOOL AS School_Name, Safety_Icon AS Safety_Rating, Family_Involvement_Icon AS Family_Rating, 
    Environment_Icon AS Environment_Rating,  Instruction_Icon AS Instruction_Rating, 
    Leaders_Icon AS Leaders_Rating,  Teachers_Icon AS Teachers_Rating
FROM public.pubschools;

-- Return just the school name and leaders rating from the view
SELECT School_Name, Leaders_Rating
FROM public.view1;

-- The icon fields are calculated based on the value in the corresponding score field. You need to make
-- sure that when a score field is updated, the icon field is updated too. To do this, you will
-- write a stored procedure that receives the school id and a leaders score as input parameters,
-- calculates the icon setting and updates the fields appropriately.

-- Create or replace a stored procedure called UPDATE_LEADERS_SCORE that takes a in_School_ID parameter
-- as an integer and a in_Leader_Score parameter as an integer. If someone calls your code with a score
-- outside of the allowed range (0-99), rollback the current work if the score did not fit any of the
-- preceding categories. Add a statement to commit the current unit of work at the end of the procedure
CREATE OR REPLACE PROCEDURE UPDATE_LEADERS_SCORE (
    IN in_School_ID INT,
    IN in_Leader_Score INT
)
LANGUAGE plpgsql
AS $$ 
BEGIN
    IF in_Leader_Score BETWEEN 80 AND 99 THEN 
        UPDATE public.pubschools
        SET leaders_icon = 'Very Strong'
        WHERE school_id = in_School_ID;
    ELSEIF in_Leader_Score BETWEEN 60 AND 79 THEN
        UPDATE public.pubschools
        SET leaders_icon = 'Strong'
        WHERE school_id = in_School_ID;    
    ELSEIF in_Leader_Score BETWEEN 40 AND 59 THEN
        UPDATE public.pubschools
        SET leaders_icon = 'Average'
        WHERE school_id = in_School_ID;
    ELSEIF in_Leader_Score BETWEEN 20 AND 39 THEN
        UPDATE public.pubschools
        SET leaders_icon = 'Weak'
        WHERE school_id = in_School_ID;
    ELSEIF in_Leader_Score BETWEEN 0 AND 19 THEN
        UPDATE public.pubschools
        SET leaders_icon = 'Very weak'
        WHERE school_id = in_School_ID;
    ELSE 
        ROLLBACK;
    END IF;        
    COMMIT; 
END; 
$$

-- ... *converting the school_id column from VARCHAR into an INT, for better data handling ...
ALTER TABLE pubschools
ALTER COLUMN school_id TYPE INT 
USING school_id::INT;

-- ... Return school_id & leaders_icon ...
SELECT school_id, leaders_icon FROM pubschools
ORDER BY school_id; 

-- Call the stored procedure, passing a valid school ID and a leader score of 50, to check that
-- the procedure works as expected.
CALL UPDATE_LEADERS_SCORE(610038, 80);
--609676
-- ... return school_id & leaders_icon for non-"Weak" leaders_icon (since all schools have a 'Weak' leaders_icon)
-- ... again, to check that the procedure works as expected ...
SELECT school_id, leaders_icon FROM pubschools
WHERE leaders_icon <> 'Weak'; 

SELECT * FROM pubschools pub
    INNER JOIN census cen 
    ON cen.community_area_number = pub.community_area_number;

SELECT * FROM census;

SELECT * FROM crime
ORDER BY date;

-- ... *converting more text columns into integers ...
ALTER TABLE pubschools
ALTER COLUMN parent_engagement_score TYPE INTEGER
USING CASE WHEN parent_engagement_score ~ '^\d+$' THEN parent_engagement_score::INTEGER ELSE NULL END;
ALTER TABLE pubschools
ALTER COLUMN teachers_score TYPE INTEGER
USING CASE WHEN teachers_score ~ '^\d+$' THEN teachers_score::INTEGER ELSE NULL END;
ALTER TABLE pubschools
ALTER COLUMN parent_environment_score TYPE INTEGER
USING CASE WHEN parent_environment_score ~ '^\d+$' THEN parent_environment_score::INTEGER ELSE NULL END;
ALTER TABLE pubschools
ALTER COLUMN family_involvement_score TYPE INTEGER
USING CASE WHEN family_involvement_score ~ '^\d+$' THEN family_involvement_score::INTEGER ELSE NULL END;
ALTER TABLE pubschools
ALTER COLUMN gr3_5_grade_level_math TYPE INTEGER
USING CASE WHEN gr3_5_grade_level_math ~ '^\d+$' THEN gr3_5_grade_level_math::INTEGER ELSE NULL END;
ALTER TABLE pubschools
ALTER COLUMN gr3_5_grade_level_read TYPE INTEGER
USING CASE WHEN gr3_5_grade_level_read ~ '^\d+$' THEN gr3_5_grade_level_read ::INTEGER ELSE NULL END;
ALTER TABLE pubschools
ALTER COLUMN gr3_5_keep_pace_math TYPE INTEGER
USING CASE WHEN gr3_5_keep_pace_math ~ '^\d+$' THEN gr3_5_keep_pace_math::INTEGER ELSE NULL END;
ALTER TABLE pubschools
ALTER COLUMN gr3_5_keep_pace_read TYPE INTEGER
USING CASE WHEN gr3_5_keep_pace_read ~ '^\d+$' THEN gr3_5_keep_pace_read::INTEGER ELSE NULL END;
ALTER TABLE pubschools
ALTER COLUMN gr6_8_grade_level_math TYPE INTEGER
USING CASE WHEN gr6_8_grade_level_math ~ '^\d+$' THEN gr6_8_grade_level_math::INTEGER ELSE NULL END;
ALTER TABLE pubschools
ALTER COLUMN gr6_8_grade_level_read TYPE INTEGER
USING CASE WHEN gr6_8_grade_level_read ~ '^\d+$' THEN gr6_8_grade_level_read::INTEGER ELSE NULL END;
ALTER TABLE pubschools
ALTER COLUMN gr6_8_keep_pace_math TYPE INTEGER
USING CASE WHEN gr6_8_keep_pace_math ~ '^\d+$' THEN gr6_8_keep_pace_math::INTEGER ELSE NULL END;
ALTER TABLE pubschools
ALTER COLUMN gr6_8_keep_pace_read TYPE INTEGER
USING CASE WHEN gr6_8_keep_pace_read ~ '^\d+$' THEN gr6_8_keep_pace_read::INTEGER ELSE NULL END;

SELECT parent_engagement_score, gr6_8_keep_pace_read, gr3_5_grade_level_math, family_involvement_score, parent_environment_score FROM pubschools;

-- ...calculating general/mean scores for Grades 3-5/6-8 and ISATs while removing NULL both_gradeS & NULL isat_all values...
SELECT gr3_5_grade_level_math, gr3_5_grade_level_read, 
    CASE 
        WHEN COALESCE(gr3_5_grade_level_math, gr3_5_grade_level_read) IS NOT NULL THEN 
            (COALESCE(gr3_5_grade_level_math, 0) + COALESCE(gr3_5_grade_level_read, 0)) / 
            (CASE WHEN gr3_5_grade_level_math IS NOT NULL AND gr3_5_grade_level_read IS NOT NULL THEN 2 ELSE 1 END)
        ELSE NULL
    END AS both_grade_3_5,
    CASE 
        WHEN COALESCE(gr6_8_grade_level_math, gr6_8_grade_level_read) IS NOT NULL THEN 
            (COALESCE(gr6_8_grade_level_math, 0) + COALESCE(gr6_8_grade_level_read, 0)) / 
            (CASE WHEN gr6_8_grade_level_math IS NOT NULL AND gr6_8_grade_level_read IS NOT NULL THEN 2 ELSE 1 END)
        ELSE NULL
    END AS both_grade_6_8,
    (COALESCE(isat_exceeding_math, 0) + COALESCE(isat_exceeding_reading, 0)) / 
    (CASE WHEN isat_exceeding_math IS NOT NULL AND isat_exceeding_reading IS NOT NULL THEN 2 ELSE 1 END)
    AS isat_all, isat_exceeding_math, isat_exceeding_reading, 
    gr6_8_grade_level_math, gr6_8_grade_level_read, school_id
FROM pubschools
WHERE     (CASE 
        WHEN COALESCE(gr3_5_grade_level_math, gr3_5_grade_level_read) IS NOT NULL THEN 
            (COALESCE(gr3_5_grade_level_math, 0) + COALESCE(gr3_5_grade_level_read, 0)) / 
            (CASE WHEN gr3_5_grade_level_math IS NOT NULL AND gr3_5_grade_level_read IS NOT NULL THEN 2 ELSE 1 END)
        ELSE NULL
    END IS NOT NULL
OR CASE 
        WHEN COALESCE(gr6_8_grade_level_math, gr6_8_grade_level_read) IS NOT NULL THEN 
            (COALESCE(gr6_8_grade_level_math, 0) + COALESCE(gr6_8_grade_level_read, 0)) / 
            (CASE WHEN gr6_8_grade_level_math IS NOT NULL AND gr6_8_grade_level_read IS NOT NULL THEN 2 ELSE 1 END)
        ELSE NULL
    END IS NOT NULL) 
OR (COALESCE(isat_exceeding_math, 0) + COALESCE(isat_exceeding_reading, 0)) / 
    (CASE WHEN isat_exceeding_math IS NOT NULL OR isat_exceeding_reading IS NOT NULL THEN 2 ELSE 1 END) > 0;

-- adding new columns, cleaned from NULLs, in the schools table for later use 
ALTER TABLE pubschools
ADD COLUMN both_grade_3_5 FLOAT,
ADD COLUMN both_grade_6_8 FLOAT,
ADD COLUMN both_pace_3_5 FLOAT,
ADD COLUMN both_pace_6_8 FLOAT,
ADD COLUMN all_grades_3_8 FLOAT,
ADD COLUMN all_pace_3_8 FLOAT,
ADD COLUMN all_studs_3_8 FLOAT,
ADD COLUMN isat_all FLOAT;

-- updating the new columns with the computed values
UPDATE pubschools
SET 
    both_grade_3_5 = CASE 
                        WHEN COALESCE(gr3_5_grade_level_math, gr3_5_grade_level_read) IS NOT NULL THEN  
                            (COALESCE(gr3_5_grade_level_math, 0) + COALESCE(gr3_5_grade_level_read, 0)) / 
                            (CASE WHEN gr3_5_grade_level_math IS NOT NULL AND gr3_5_grade_level_read IS NOT NULL THEN 2 ELSE 1 END)
                        ELSE NULL
                    END,
    both_grade_6_8 = CASE 
                        WHEN COALESCE(gr6_8_grade_level_math, gr6_8_grade_level_read) IS NOT NULL THEN 
                            (COALESCE(gr6_8_grade_level_math, 0) + COALESCE(gr6_8_grade_level_read, 0)) / 
                            (CASE WHEN gr6_8_grade_level_math IS NOT NULL AND gr6_8_grade_level_read IS NOT NULL THEN 2 ELSE 1 END)
                        ELSE NULL
                    END,
    both_pace_3_5 = CASE 
                        WHEN COALESCE(gr3_5_keep_pace_math, gr3_5_keep_pace_read) IS NOT NULL THEN 
                            (COALESCE(gr3_5_keep_pace_math, 0) + COALESCE(gr3_5_keep_pace_read, 0)) / 
                            (CASE WHEN gr3_5_keep_pace_math IS NOT NULL AND gr3_5_keep_pace_read IS NOT NULL THEN 2 ELSE 1 END)
                        ELSE NULL
                    END,
    both_pace_6_8 = CASE 
                        WHEN COALESCE(gr6_8_keep_pace_math, gr6_8_keep_pace_read) IS NOT NULL THEN 
                            (COALESCE(gr6_8_keep_pace_math, 0) + COALESCE(gr6_8_keep_pace_read, 0)) / 
                            (CASE WHEN gr6_8_keep_pace_math IS NOT NULL AND gr6_8_keep_pace_read IS NOT NULL THEN 2 ELSE 1 END)
                        ELSE NULL
                    END,
    isat_all = CASE 
                    WHEN isat_exceeding_math IS NOT NULL AND isat_exceeding_reading IS NOT NULL THEN 
                        (isat_exceeding_math + isat_exceeding_reading) / 2 
                    WHEN isat_exceeding_math IS NULL THEN 
                        isat_exceeding_reading 
                    WHEN isat_exceeding_reading IS NULL THEN
                        isat_exceeding_math
                    ELSE NULL 
                END;

-- ensuring the new columns work as expected 
SELECT both_grade_3_5, gr3_5_grade_level_math, gr3_5_grade_level_read, gr6_8_grade_level_math, gr6_8_grade_level_read,
    both_pace_3_5, both_grade_6_8, both_pace_6_8, isat_all, isat_exceeding_math, isat_exceeding_reading, school_id
FROM pubschools;

-- ensure we have sufficient data to investigate students' performance over time, we DON'T !
SELECT COUNT(*) FROM pubschools
WHERE both_grade_3_5 IS NOT NULL
AND both_grade_3_5 <> 0; -- 81 out of 566 schools
SELECT COUNT(*) FROM pubschools
WHERE both_pace_3_5 IS NOT NULL
AND both_pace_3_5 <> 0; -- 88 out of 566 schools
SELECT COUNT(*) FROM pubschools 
WHERE both_grade_6_8 IS NOT NULL
AND both_grade_6_8 <> 0; -- 93 out of 566 schools
SELECT COUNT(*) FROM pubschools
WHERE both_pace_6_8 IS NOT NULL
AND both_pace_6_8 <> 0; -- 73 out of 566 schools
SELECT COUNT(*) FROM pubschools
WHERE isat_all IS NOT NULL
AND isat_all <> 0; -- 474 out of 566 schools!


-- ...finding the CorrCoef regarding different scores & safety score... / correlation coefficient
SELECT 'envrmt_corr' AS corr_to_safety,
    CORR(environment_score, safety_score) AS corr_value FROM pubschools UNION ALL
SELECT 'instruction_score_corr', 
    CORR(instruction_score, safety_score) FROM pubschools UNION ALL
SELECT 'parent_engage_corr',
    CORR(parent_engagement_score, safety_score) FROM pubschools UNION ALL
SELECT 'teachers_score_corr',
    CORR(teachers_score, safety_score) FROM pubschools UNION ALL
SELECT 'parent_env_corr',
    CORR(parent_environment_score, safety_score) FROM pubschools UNION ALL
SELECT 'student_attend_corr',
    CORR(average_student_attendance, safety_score) FROM pubschools UNION ALL
SELECT 'teacher_attend_corr',
    CORR(average_teacher_attendance, safety_score) FROM pubschools UNION ALL
SELECT 'misconduct_corr',
    CORR(rate_of_misconducts_per_100_students, safety_score) FROM pubschools UNION ALL
SELECT 'family_involvement_corr',
    CORR(family_involvement_score, safety_score) FROM pubschools
ORDER BY corr_value DESC;



-- ... counting crimes based on Community ...
SELECT COUNT(*) AS crime_comm_count, cri.community_area_number, cen.community_area_name
FROM crime cri
    INNER JOIN census cen
    ON cen.community_area_number = cri.community_area_number
GROUP BY cen.community_area_name, cri.community_area_number
ORDER BY crime_count DESC;

ALTER TABLE census
ADD COLUMN crime_comm_count INT;
UPDATE census
SET crime_comm_count = (SELECT COUNT(*) FROM crime cri
        WHERE census.community_area_number = cri.community_area_number);

-- ... count arrests based on Community ...
SELECT COUNT(*) AS arrest_true, cri.community_area_number, cen.community_area_name
FROM crime cri
    INNER JOIN census cen
    ON cen.community_area_number = cri.community_area_number
WHERE cri.arrest ILIKE '%true%'
GROUP BY cri.community_area_number, cen.community_area_name;

-- create new columns for later use on Arrests vs Non-Arrests based on Community
ALTER TABLE census
ADD COLUMN arrest_true_count INT,
ADD COLUMN arrest_true_percentage FLOAT;
UPDATE census 
SET arrest_true_count = (
    SELECT COUNT(*)
    FROM crime
    WHERE crime.community_area_number = census.community_area_number
      AND crime.arrest ILIKE '%true%'
    GROUP BY census.community_area_number),
arrest_true_percentage = ROUND((arrest_true_count::NUMERIC / crime_comm_count::NUMERIC), 2);

-- ensuring the new columns are correct 
SELECT arrest_true_count, crime_comm_count, arrest_true_percentage, community_area_number, community_area_name FROM census
ORDER BY arrest_true_percentage DESC;

-- ensure we have sufficient data to investigate teachers_score / already an INT, no need to *convert
SELECT count(*)
FROM pubschools
WHERE teachers_score <> 0 --233
AND teachers_score IS NOT NULL;
-- ensure we have sufficient data to investigate leaders_score
SELECT COUNT(*) FROM pubschools
WHERE leaders_score NOT ILIKE '%nda%'   --295
AND leaders_score NOT LIKE '0%'
AND leaders_score IS NOT NULL;      
-- create a new column in order to *convert the leaders_score column from TEXT to FLOAT 
ALTER TABLE pubschools
ADD COLUMN leaders_num_score FLOAT;
UPDATE pubschools
SET leaders_num_score = CASE
    WHEN leaders_score NOT LIKE '%NDA%' AND leaders_score ~ '^[0-9]+(\.[0-9]+)?$' THEN CAST(leaders_score AS FLOAT)
    ELSE NULL
END;
-- ensuring it works
SELECT leaders_score, leaders_num_score
FROM pubschools;



-- ... Finding the CorrCoef regarding how different socioeconomic factors' impact on students' performance, 
-- ... grade & keep-pace levels of teens, college enrollments, and ISAT scores; as students age/ correlation coefficient
--- SocioEconomics_StudPerfor.csv

SELECT 
    CORR(cen.percent_of_housing_crowded, isat_all) AS HousesCrowded_ISAT_corr,
    CORR(cen.percent_of_housing_crowded, college_enrollment) AS HousesCrowded_college_corr,
    CORR(cen.percent_of_housing_crowded, both_grade_6_8) AS HousesCrowded_6_8_gradeLvl_corr,
    CORR(cen.percent_of_housing_crowded, both_grade_3_5) AS HousesCrowded_3_5_gradeLvl_corr,
    CORR(cen.percent_of_housing_crowded, both_pace_6_8) AS HousesCrowded_6_8_KeepPace_corr,
    CORR(cen.percent_of_housing_crowded, both_pace_3_5) AS HousesCrowded_3_5_KeepPace_corr,
    CORR(cen.percent_households_below_poverty, isat_all) AS BelowPvrt_ISAT_corr,
    CORR(cen.percent_households_below_poverty, college_enrollment) AS BelowPvrt_college_corr,
    CORR(cen.percent_households_below_poverty, both_grade_3_5) AS BelowPvrt_3_5_gradeLvl_corr,
    CORR(cen.percent_households_below_poverty, both_pace_3_5) AS BelowPvrt_3_5_KeepPace_corr,
    CORR(cen.percent_households_below_poverty, both_grade_6_8) AS BelowPvrt_6_8_gradeLvl_corr,
    CORR(cen.percent_households_below_poverty, both_pace_6_8) AS BelowPvrt_6_8_KeepPace_corr,
    CORR(cen.percent_aged_16__unemployed, isat_all) AS age16unemployed_ISAT_corr,
    CORR(cen.percent_aged_16__unemployed, college_enrollment) AS age16unemployed_college_corr,
    CORR(cen.percent_aged_16__unemployed, both_grade_3_5) AS age16unemployed_3_5_gradeLvl_corr,
    CORR(cen.percent_aged_16__unemployed, both_grade_6_8) AS age16unemployed_6_8_gradeLvl_corr,
    CORR(cen.percent_aged_16__unemployed, both_pace_3_5) AS age16unemployed_3_5_KeepPace_corr,
    CORR(cen.percent_aged_16__unemployed, both_pace_6_8) AS age16unemployed_6_8_KeepPace_corr,
    CORR(cen.percent_aged_25__without_high_school_diploma, isat_all) AS age25wOutHighSchl_ISAT_corr, 
    CORR(cen.percent_aged_25__without_high_school_diploma, college_enrollment) AS age25wOutHighSchl_college_corr,
    CORR(cen.percent_aged_25__without_high_school_diploma, both_pace_6_8) AS age25wOutHighSchl_6_8_KeepPace_corr, 
    CORR(cen.percent_aged_25__without_high_school_diploma, both_grade_6_8) AS age25wOutHighSchl_6_8_gradeLvl_corr,
    CORR(cen.percent_aged_25__without_high_school_diploma, both_pace_3_5) AS age25wOutHighSchl_3_5_KeepPace_corr, 
    CORR(cen.percent_aged_25__without_high_school_diploma, both_grade_3_5) AS age25wOutHighSchl_3_5_gradeLvl_corr,
    CORR(cen.percent_aged_under_18_or_over_64, both_grade_6_8) AS ageUnder18orOver64_6_8_gradeLvl_corr,
    CORR(cen.percent_aged_under_18_or_over_64, both_pace_3_5) AS ageUnder18orOver64_3_5_KeepPace_corr,
    CORR(cen.percent_aged_under_18_or_over_64, both_pace_6_8) AS ageUnder18orOver64_6_8_KeepPace_corr,
    CORR(cen.percent_aged_under_18_or_over_64, both_grade_3_5) AS ageUnder18orOver64_3_5_gradeLvl_corr,
    CORR(cen.percent_aged_under_18_or_over_64, isat_all) AS ageUnder18orOver64_ISAT_corr,
    CORR(cen.percent_aged_under_18_or_over_64, college_enrollment) AS ageUnder18orOver64_college_corr,
    CORR(cen.per_capita_income, isat_all) AS perCapitaInc_ISAT_corr,
    CORR(cen.per_capita_income, college_enrollment) AS perCapitaInc_college_corr,
    CORR(cen.per_capita_income, both_grade_3_5) AS PerCapInc_3_5_gradeLvl_corr, 
    CORR(cen.per_capita_income, both_pace_3_5) AS PerCapInc_3_5_KeepPace_corr,
    CORR(cen.per_capita_income, both_grade_6_8) AS PerCapInc_6_8_gradeLvl_corr, 
    CORR(cen.per_capita_income, both_pace_6_8) AS PerCapInc_6_8_KeepPace_corr,
    CORR(cen.hardship_index, isat_all) AS hard_ISAT_all_corr,
    CORR(cen.hardship_index, isat_exceeding_reading) AS hard_ISAT_read_corr,
    CORR(cen.hardship_index, isat_exceeding_math) AS hard_ISAT_math_corr,
    CORR(cen.hardship_index, college_enrollment) AS hard_college_corr,
    CORR(cen.hardship_index, both_grade_3_5) AS hard_3_5_gradeLvl_corr,
    CORR(cen.hardship_index, both_pace_3_5) AS hard_3_5_KeepPace_corr,
    CORR(cen.hardship_index, both_grade_6_8) AS hard_6_8_gradeLvl_corr,
    CORR(cen.hardship_index, both_pace_6_8) AS hard_6_8_KeepPace_corr,
    CORR(crime_comm_count, both_grade_3_5) AS crime_3_5_gradeLvl_corr,
    CORR(crime_comm_count, both_grade_6_8) AS crime_6_8_gradeLvl_corr,
    CORR(crime_comm_count, college_enrollment) AS crime_college_corr, 
    CORR(crime_comm_count, isat_all) AS crime_ISAT_corr,
    CORR(crime_comm_count, both_pace_6_8) AS crime_6_8_KeepPace_corr, 
    CORR(crime_comm_count, both_pace_3_5) AS crime_3_5_KeepPace_corr,
    CORR(college_enrollment, isat_all) AS college_isat_corr,
    CORR(safety_score, isat_all) AS safety_ISAT_corr,
    CORR(safety_score, college_enrollment) AS safety_college_corr,
    CORR(safety_score, both_grade_3_5) AS safety_3_5_gradeLvl_corr,
    CORR(safety_score, both_pace_3_5) AS safety_3_5_KeepPace_corr,
    CORR(safety_score, both_grade_6_8) AS safety_6_8_gradeLvl_corr,
    CORR(safety_score, both_pace_6_8) AS safety_6_8_KeepPace_corr,    
    CORR(environment_score, isat_all) AS envrmt_ISAT_corr,
    CORR(environment_score, college_enrollment) AS envrmt_college_corr,
    CORR(environment_score, both_grade_3_5) AS evnrmt_3_5_gradeLvl_corr,
    CORR(environment_score, both_pace_3_5) AS evnrmt_3_5_KeepPace_corr,
    CORR(environment_score, both_grade_6_8) AS evnrmt_6_8_gradeLvl_corr,
    CORR(environment_score, both_pace_6_8) AS evnrmt_6_8_KeepPace_corr,
    CORR(instruction_score, isat_all) AS instruction_ISAT_corr,
    CORR(instruction_score, college_enrollment) AS instruction_college_corr,
    CORR(parent_environment_score, isat_all) AS parent_env_ISAT_corr,
    CORR(parent_environment_score, college_enrollment) AS parent_env_college_corr,
    CORR(parent_environment_score, both_grade_3_5) AS parent_env_3_5_gradeLvl_corr,
    CORR(parent_environment_score, both_pace_3_5) AS parent_env_3_5_KeepPace_corr,
    CORR(parent_environment_score, both_grade_6_8) AS parent_env_6_8_gradeLvl_corr,
    CORR(parent_environment_score, both_pace_6_8) AS parent_env_6_8_KeepPace_corr,
    CORR(parent_engagement_score, isat_all) AS parent_engage_ISAT_corr,
    CORR(parent_engagement_score, college_enrollment) AS parent_engage_college_corr,
    CORR(parent_engagement_score, both_grade_3_5) AS parent_engage_3_5_gradeLvl_corr,
    CORR(parent_engagement_score, both_pace_3_5) AS parent_engage_3_5_KeepPace_corr,
    CORR(parent_engagement_score, both_grade_6_8) AS parent_engage_6_8_gradeLvl_corr,
    CORR(parent_engagement_score, both_pace_6_8) AS parent_engage_6_8_KeepPace_corr,
    CORR(family_involvement_score, isat_all) AS fam_invlvmnt_ISAT_corr,
    CORR(family_involvement_score, college_enrollment) AS fam_invlvmnt_college_corr,
    CORR(family_involvement_score, both_grade_3_5) AS fam_invlvmnt_3_5_gradeLvl_corr,
    CORR(family_involvement_score, both_pace_3_5) AS fam_invlvmnt_3_5_KeepPace_corr,
    CORR(family_involvement_score, both_grade_6_8) AS fam_invlvmnt_6_8_gradeLvl_corr,
    CORR(family_involvement_score, both_pace_6_8) AS fam_invlvmnt_6_8_KeepPace_corr,
    CORR(leaders_num_score, isat_all) AS leaders_score_ISAT_corr,
    CORR(leaders_num_score, college_enrollment) AS leaders_score_college_corr,
    CORR(leaders_num_score, both_grade_3_5) AS leaders_3_5_gradeLvl_corr,
    CORR(leaders_num_score, both_pace_3_5) AS leaders_3_5_KeepPace_corr,
    CORR(leaders_num_score, both_grade_6_8) AS leaders_6_8_gradeLvl_corr,
    CORR(leaders_num_score, both_pace_6_8) AS leaders_6_8_KeepPace_corr,
    CORR(teachers_score, isat_all) AS teachers_score_ISAT_corr,
    CORR(teachers_score, college_enrollment) AS teachers_score_college_corr,
    CORR(teachers_score, both_grade_3_5) AS teachers_3_5_gradeLvl_corr,
    CORR(teachers_score, both_pace_3_5) AS teachers_3_5_KeepPace_corr,
    CORR(teachers_score, both_grade_6_8) AS teachers_6_8_gradeLvl_corr,
    CORR(teachers_score, both_pace_6_8) AS teachers_6_8_KeepPace_corr,
    CORR(average_student_attendance, isat_all) AS student_attend_ISAT_corr,
    CORR(average_student_attendance, college_enrollment) AS student_attend_college_corr,
    CORR(average_teacher_attendance, isat_all) AS teacher_attend_ISAT_corr,
    CORR(average_teacher_attendance, college_enrollment) AS teacher_attend_college_corr,
    CORR(rate_of_misconducts_per_100_students, isat_all) AS misconduct_ISAT_corr,
    CORR(rate_of_misconducts_per_100_students, college_enrollment) AS misconduct_college_corr
FROM pubschools pub
    INNER JOIN census cen 
    ON cen.community_area_number = pub.community_area_number;
 

-- ... Count crimes by community & its impact on student performance, also studying how "attendance" is impacted 
-- ... Then, finding the Correlation-Coefficient regarding different socioeconomic metrics, & how they impact 
-- ... students' performance (grade level of students, college enrollments, as well as ISAT scores ...  

--- same but only the ones needed for final analysis in BI ---  

--- how Total Crimes in each community are correlated to other socieconomic measures / correlation coefficient
--- TotalCrimesPerCommu_SocioEconomics.csv
SELECT
    CORR(crime_comm_count, hardship_index) AS crime_hard_corr,
    CORR(crime_comm_count, per_capita_income) AS crime_capita_inc_corr,
    CORR(crime_comm_count, percent_aged_16__unemployed) AS crime_age16_unempl_corr,
    CORR(crime_comm_count, percent_aged_under_18_or_over_64) AS crime_u18_o64_corr,
    CORR(crime_comm_count, percent_aged_25__without_high_school_diploma) AS crime_age25wOutHschool_corr,
    CORR(crime_comm_count, percent_of_housing_crowded) AS crime_house_crowded_corr,
    CORR(crime_comm_count, percent_households_below_poverty) AS crime_belowPvrt_corr --- max co.coef and just =0.358 
FROM census;


-- ensure we have sufficient data to investigate students' & teachers' attendance
SELECT count(*)
FROM pubschools
WHERE average_student_attendance <> 0       --565
AND average_student_attendance IS NOT NULL;
SELECT count(*)
FROM pubschools
WHERE average_teacher_attendance <> 0       --558
AND average_teacher_attendance IS NOT NULL;

--- what impacts attendance / correlation coefficient
--- WhatImpactsAttendance.csv
SELECT 
    CORR(crime_comm_count, average_student_attendance) AS crime_stud_attend_corr,
    CORR(crime_comm_count, average_teacher_attendance) AS crime_teach_attend_corr,
    CORR(hardship_index, average_student_attendance) AS hards_stud_attend_corr,
    CORR(hardship_index, average_teacher_attendance) AS hards_teach_attend_corr,
    CORR(per_capita_income, average_student_attendance) AS crime_stud_att_corr,
    CORR(per_capita_income, average_teacher_attendance) AS crime_teach_att_corr,
    CORR(percent_aged_16__unemployed, average_student_attendance) AS age16_unempl_stud_att_corr,
    CORR(percent_aged_16__unemployed, average_teacher_attendance) AS age16_unempl_teach_att_corr,
    CORR(percent_aged_25__without_high_school_diploma, average_student_attendance) AS age25wOutHschool_unempl_stud_att_corr,
    CORR(percent_aged_25__without_high_school_diploma, average_teacher_attendance) AS age25wOutHschool_unempl_teach_att_corr,
    CORR(percent_of_housing_crowded, average_student_attendance) AS house_crowded_unempl_stud_att_corr,
    CORR(percent_of_housing_crowded, average_teacher_attendance) AS house_crowded_unempl_teach_att_corr,
    CORR(percent_households_below_poverty, average_student_attendance) AS belowPvrt_stud_attend_corr,
    CORR(percent_households_below_poverty, average_teacher_attendance) AS belowPvrt_teach_attend_corr
FROM pubschools pub
    INNER JOIN census cen
    ON cen.community_area_number = pub.community_area_number;

--- what really affects Students' ISATs / correlation coefficient 
--- WhatImpactsISATs.csv
SELECT
    CORR(hardship_index, isat_all) AS hard_ISAT_corr,
    CORR(average_student_attendance, isat_all) AS stud_attend_ISAT_corr, ---
    CORR(average_teacher_attendance, isat_all) AS teach_attend_ISAT_corr, ---
    CORR(safety_score, isat_all) AS safety_ISAT_corr, ---
    CORR(crime_comm_count, isat_all) AS crime_ISAT_corr, ---
    CORR(instruction_score, isat_all) AS instruction_ISAT_corr,
    CORR(environment_score, isat_all) AS envrmt_ISAT_corr,
    CORR(family_involvement_score, isat_all) AS fam_invlvmnt_ISAT_corr, ---
    CORR(parent_engagement_score, isat_all) AS par_eng_ISAT_corr, ---
    CORR(parent_environment_score, isat_all) AS par_env_ISAT_corr, ---
    CORR(percent_aged_16__unemployed, isat_all) AS age16unempl_ISAT_corr, ---
    CORR(percent_aged_25__without_high_school_diploma, isat_all) AS age25_no_High_school_ISAT_corr, ---
    CORR(teachers_score, isat_all) AS teachers_score_ISAT_corr, ---
    CORR(leaders_num_score, isat_all) AS leaders_score_ISAT_corr, ---
    CORR(per_capita_income, isat_all) AS perCapitaInc_ISAT_corr, ---
    CORR(percent_households_below_poverty, isat_all) AS BelowPvrt_ISAT_corr, ---
    CORR(percent_of_housing_crowded, isat_all) AS houses_crowded_ISAT_corr
FROM pubschools pub
    INNER JOIN census cen
    ON cen.community_area_number = pub.community_area_number;
