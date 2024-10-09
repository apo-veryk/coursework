# coursework

Chicago Public Datasets Project
Project Overview
This project aims to analyze various public datasets related to the City of Chicago, including public schools, crime rates, and census data. By cleaning and organizing these datasets, the goal is to uncover insights into how different factors, such as educational institutions and census statistics, correlate with crime rates across different areas in Chicago.

The project includes cleaned datasets, original datasets, Python scripts for data processing, SQL scripts for querying, and Power BI visualizations.

Repository Structure
/data/:

cleaned_datasets/: Cleaned versions of the datasets used for analysis.
cleaned_ChicagoPublicSchools.csv: Cleaned dataset for public school data in Chicago.
cleaned_ChicagoCrimeData.csv: Cleaned dataset for crime data in Chicago.
cleaned_ChicagoCensusData.csv: Cleaned dataset for census data.
original_datasets/: Raw versions of the datasets as downloaded from public sources.
/scripts/:

Python and SQL scripts used for data processing and analysis.
Chicago 31-5 SQL course Final Project w6.sql: SQL queries used for analysis during the final project.
Python scripts used to clean, transform, and analyze data (contained in Python scripts used.zip).
/analysis/:

goopy Chicago1stTry.pbix: Power BI file with visualizations and analysis of the data.
Datasets
Chicago Public Schools
File: cleaned_ChicagoPublicSchools.csv
Description: This dataset contains information about public schools in Chicago, including school names, types, and performance metrics. Cleaned to remove redundant data and ensure consistency.
Chicago Crime Data
File: cleaned_ChicagoCrimeData.csv
Description: Crime data recorded in Chicago, including type of crime, location, and date. This dataset has been cleaned for use in the analysis.
Chicago Census Data
File: cleaned_ChicagoCensusData.csv
Description: Census data for Chicago, including demographic and socioeconomic information. Cleaned to ensure all fields are properly formatted.
Instructions to Run the Project
Python Scripts
Clone the repository to your local machine:
bash
Copy code
git clone https://github.com/yourusername/ChicagoPublicDatasetsProject.git
Navigate to the /scripts/ folder and run any of the Python scripts. For example:
bash
Copy code
python your_script.py
Ensure that all necessary libraries are installed. You can install them via pip:
bash
Copy code
pip install -r requirements.txt
SQL Queries
SQL queries can be run using any standard SQL environment. Use the provided file Chicago 31-5 SQL course Final Project w6.sql for querying the datasets.
Power BI Visualization
Open the goopy Chicago1stTry.pbix file in Power BI Desktop to view the visualizations. The analysis in this file focuses on crime statistics and their relationship with census and public school data.
Requirements
To run the Python scripts and view the Power BI visualizations, you will need the following:

Python (3.7 or above) with the following libraries:
pandas
numpy
matplotlib
seaborn
scikit-learn (if applicable)
Power BI Desktop for viewing the .pbix file.
SQL: Any SQL environment (e.g., MySQL, PostgreSQL, etc.) for running SQL queries.
How to Contribute
If you’d like to contribute to this project:

Fork the repository.
Create a new branch (git checkout -b feature-branch).
Commit your changes (git commit -m 'Add feature').
Push to the branch (git push origin feature-branch).
Open a pull request.
