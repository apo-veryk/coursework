import csv
import os

# Function to remove percentage signs from specified columns
def remove_percentage(csv_file, columns):
    # Get the base filename without the full path
    base_filename = os.path.basename(csv_file)
    # Remove extension from the filename
    filename, extension = os.path.splitext(base_filename)
    # Construct the new filename with the prefix 'cleaned_'
    new_filename = filename + '_cleaned' + extension
    
    # Open the CSV file for reading
    with open(csv_file, 'r', newline='') as infile:
        reader = csv.reader(infile)
        # Read header
        header = next(reader)
        
        # Get column indices for specified columns
        column_indices = [header.index(col) for col in columns]
        
        # Open a new CSV file for writing
        with open(new_filename, 'w', newline='') as outfile:
            writer = csv.writer(outfile)
            writer.writerow(header)  # Write header to new file
            
            # Iterate over rows in the CSV file
            for row in reader:
                # Remove percentage signs from specified columns
                for idx in column_indices:
                    if row[idx] and '%' in row[idx]:
                        row[idx] = row[idx].replace('%', '')
                # Write the cleaned row to the new CSV file
                writer.writerow(row)

# Specify the CSV file and columns containing percentage values
csv_file = 'C:\\Users\\nonee\\Downloads\\SQLCourseraProjectzx\\ChicagoPublicSchools.csv'
percentage_columns = ['AVERAGE_STUDENT_ATTENDANCE', 'Average_Teacher_Attendance', 'Individualized_Education_Program_Compliance_Rate']  # Add the names of columns with percentage values

# Remove percentage signs and create a new CSV file
remove_percentage(csv_file, percentage_columns)
