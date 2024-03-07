import csv
import pickle

# Input and output files
input_file = 'FileData.txt'
output_file = 'FinalData.csv'

# Dictionary to store the data
data = {}

# Read the input file and store the lines
with open(input_file, 'r') as file:
    lines = file.readlines()

# Process each line in the input file
for line in lines:
    # Split the line into three parts: ID, date, and consumption
    ID, date, consumption = line.split()

    # Extract day and hour information from the date
    day = int(date[:3])
    half_hour = int(date[3:5])
    hour = (half_hour - 1) // 2
    
    # Initialize the data dictionary if necessary
    if ID not in data:
        data[ID] = {}
    
    if day not in data[ID]:
        data[ID][day] = [0.0] * 24

    # Update the consumption information
    if 0 <= hour <= 23:
        data[ID][day][hour] += float(consumption) * 1000  # Convert kWh to Wh

# Additional filters:
# - Total daily consumption must be greater than 100 Wh
# - Maximum consumption in an hour must not exceed 15000 Wh
# - No zero values for any hour

low_threshold = 100
high_threshold = 15000

# Identify IDs with daily consumption below the minimum threshold
IDs_below_threshold = {
    ID for ID, date_and_consumption in data.items()
    if any(sum(consumption_list) < low_threshold for day, consumption_list in date_and_consumption.items())
}

print('Number of users with daily consumption below 100 Wh:', len(IDs_below_threshold)) # 220

# Count the total number of days meeting the condition
total_days_below_threshold = sum(
    sum(sum(consumption_list) < low_threshold for day, consumption_list in date_and_consumption.items())
    for ID, date_and_consumption in data.items()
)

print('Total number of days with daily consumption below 100 Wh:', total_days_below_threshold) # 15729

# Identify IDs with maximum consumption exceeding 15000 Wh in any hour
IDs_above_threshold = {
    ID for ID, date_and_consumption in data.items()
    if any(max(consumption_list) > high_threshold for day, consumption_list in date_and_consumption.items())
}

print('Number of users with maximum consumption above 15000 Wh:', len(IDs_above_threshold)) # 946

# Remove lines with zero values for any hour
cleaned_data = {
    ID: {
        day: consumption_list
        for day, consumption_list in date_and_consumption.items()
        if all(hour_consumption != 0 for hour_consumption in consumption_list)
    }
    for ID, date_and_consumption in data.items()
}

# Filter the data based on additional conditions
filtered_data = {
    ID: {
        day: consumption_list
        for day, consumption_list in date_and_consumption.items()
        if sum(consumption_list) > low_threshold
    }
    for ID, date_and_consumption in cleaned_data.items()
    if ID not in IDs_above_threshold
}

# Create the CSV file
with open(output_file, 'w', newline='') as file:
    writer = csv.writer(file)
    # Header
    writer.writerow(['ID', 'date', 'H0', 'H1', 'H2', 'H3', 'H4', 'H5', 'H6', 'H7', 'H8', 'H9', 'H10', 'H11', 'H12', 'H13', 'H14', 'H15', 'H16', 'H17', 'H18', 'H19', 'H20', 'H21', 'H22', 'H23'])
    
    # Write each row to the CSV file
    for ID, date_and_consumption in filtered_data.items():
        for day, consumption_list in date_and_consumption.items():
            # Join to combine the first two columns with spaces and the rest with commas
            row = [ID, day] + consumption_list
            writer.writerow(row)
            
# Save variable filtered_data
with open('filtered_data.pkl', 'wb') as file:
    pickle.dump(filtered_data, file)