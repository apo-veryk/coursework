import pandas as pd
from scipy.stats import pearsonr
import numpy as np

# Load the data from CSV files
pubschools_df = pd.read_csv(r'C:\Users\nonee\cleaned_ChicagoPublicSchools.csv')
census_df = pd.read_csv(r'C:\Users\nonee\cleaned_ChicagoCensusData.csv')

# Merge the DataFrames on 'community_area_number'
merged_df = pd.merge(pubschools_df, census_df, on='COMMUNITY_AREA_NUMBER', how='inner')

# Calculate the average of 'isat_exceeding_math' and 'isat_exceeding_reading' with handling NULL values
merged_df['average_isat'] = merged_df.apply(lambda row: 
                                            (row['ISAT_Exceeding_Math__'] + row['ISAT_Exceeding_Reading__']) / 2 
                                            if pd.notnull(row['ISAT_Exceeding_Math__']) and pd.notnull(row['ISAT_Exceeding_Reading__']) 
                                            else row['ISAT_Exceeding_Math__'] if pd.notnull(row['ISAT_Exceeding_Math__']) 
                                            else row['ISAT_Exceeding_Reading__'], axis=1)

# Drop rows with NaNs after merging
merged_df.dropna(subset=['HARDSHIP_INDEX', 'average_isat'], inplace=True)

# Calculate the average of 'isat_exceeding_math' and 'isat_exceeding_reading'
merged_df['average_isat'] = (merged_df['ISAT_Exceeding_Math__'] + merged_df['ISAT_Exceeding_Reading__']) / 2

# Select the columns for correlation calculation
column_x = merged_df['HARDSHIP_INDEX']
column_y = merged_df['average_isat']

# Calculate Pearson correlation coefficient
correlation_coefficient, p_value = pearsonr(column_x, column_y)

print("Pearson Correlation Coefficient:", correlation_coefficient)
print("P-value:", p_value)
