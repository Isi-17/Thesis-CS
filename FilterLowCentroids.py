import pandas as pd

# Load the CSV file into a DataFrame
df = pd.read_csv('CentroidDistribution.csv')

# Filter IDs with a lower number of different clusters than the threshold
filtered_rows = []
for index, row in df.iterrows():
    clusters = row[1:]  # [f(0), ..., f(20)]
    clusters_cleaned = [c for c in clusters if c != 0]  # Remove unused clusters

    different_clusters_count = len(clusters_cleaned)
    
    if different_clusters_count <= threshold_clusters:
        filtered_rows.append(row)
        
# Create a DataFrame with the filtered results
result_df = pd.DataFrame(filtered_rows)

# Generate a CSV with the filtered results
result_df.to_csv(f'Filtered{threshold_clusters}UsersLowCentroids.csv', index=False)

# Calculate and display the number of IDs in the DataFrame
print(f"Number of IDs in the DataFrame generated: {len(result_df)}")

