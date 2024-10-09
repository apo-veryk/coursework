from sqlalchemy import create_engine
import pandas as pd
import urllib.parse

# Encode the password
encoded_password = urllib.parse.quote_plus('K5U^J@p#@*qsJyRv')

# Define the database connection string
db_string = f'postgresql://postgres:{encoded_password}@localhost/CourserosSQL'

# Create an SQLAlchemy engine
engine = create_engine(db_string)

# Connect to your PostgreSQL database
#conn = psycopg2.connect(
#    dbname="CourserosSQL",
#    user="postgres",
#    host="localhost",
#    password="K5U^J@p#@*qsJyRv")

# Define your SQL query
sql_query = """
SELECT 
    CORR(cen.per_capita_income, pub.gr3_5_grade_level_read) AS first_attempt_read, -- 0.4745488176791565
    CORR(cen.per_capita_income, pub.gr3_5_grade_level_math) AS first_attempt_math, -- 0.4417121631862694
    CORR(cen.per_capita_income, pub.both_grade_3_5) AS bothpercap,
    CORR(cen.percent_of_housing_crowded, isat_all) AS HousesCrowded_ISAT_corr,
    CORR(cen.percent_of_housing_crowded, college_enrollment) AS HousesCrowded_college_corr,
    CORR(cen.percent_households_below_poverty, isat_all) AS BelowPvrt_ISAT_corr,
    CORR(cen.percent_households_below_poverty, college_enrollment) AS BelowPvrt_college_corr,
    CORR(cen.percent_households_below_poverty, both_grade_3_5) AS BelowPvrt_3_5_gradeLvl_corr,
    CORR(cen.percent_households_below_poverty, both_pace_3_5) AS BelowPvrt_3_5_KeepPace_corr,
    CORR(cen.percent_households_below_poverty, both_grade_6_8) AS BelowPvrt_6_8_gradeLvl_corr,
    CORR(cen.percent_households_below_poverty, both_pace_6_8) AS BelowPvrt_6_8_KeepPace_corr,
    CORR(cen.percent_aged_16__unemployed, isat_all) AS age16unemployed_ISAT_corr,
    CORR(cen.percent_aged_16__unemployed, college_enrollment) AS age16unemployed_college_corr,
    CORR(cen.percent_aged_25__without_high_school_diploma, isat_all) AS age25wOutHighSchl_ISAT_corr, 
    CORR(cen.percent_aged_25__without_high_school_diploma, college_enrollment) AS age25wOutHighSchl_college_corr,
    CORR(cen.percent_aged_under_18_or_over_64, isat_all) AS ageUnder18orOver64_ISAT_corr,
    CORR(cen.percent_aged_under_18_or_over_64, college_enrollment) AS ageUnder18orOver64_college_corr,
    CORR(cen.per_capita_income, isat_all) AS perCapitaInc_ISAT_corr,
    CORR(cen.per_capita_income, college_enrollment) AS perCapitaInc_college_corr,
    CORR(cen.per_capita_income, both_grade_3_5) AS PerCapInc_3_5_gradeLvl_corr, 
    CORR(cen.per_capita_income, both_pace_3_5) AS PerCapInc_3_5_KeepPace_corr,
    CORR(cen.per_capita_income, both_grade_6_8) AS PerCapInc_6_8_gradeLvl_corr, 
    CORR(cen.per_capita_income, both_pace_6_8) AS PerCapInc_6_8_KeepPace_corr,
    CORR(cen.hardship_index, isat_all) AS hardship_ISAT_corr, 
    CORR(cen.hardship_index, college_enrollment) AS hardship_college_corr,
    CORR(cen.hardship_index, both_grade_3_5) AS hard_3_5_gradeLvl_corr,
    CORR(cen.hardship_index, both_pace_3_5) AS hard_3_5_KeepPace_corr,
    CORR(cen.hardship_index, both_grade_6_8) AS hard_6_8_gradeLvl_corr,
    CORR(cen.hardship_index, both_pace_6_8) AS hard_6_8_KeepPace_corr,
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
"""

# Execute the SQL query and fetch results into a DataFrame
df = pd.read_sql(sql_query, engine)

# Close the database connection
#conn.close()

# Close the engine
engine.dispose()

# Save the DataFrame to a CSV file
df.to_csv('output.csv', index=False)
