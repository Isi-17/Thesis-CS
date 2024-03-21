import pandas as pd
import numpy as np

# Read the dataset with hourly energy consumptions
final_data_df = pd.read_csv('FinalData.csv', delimiter=',')

# Read the dataset with centroids
centroids_data_df = pd.read_csv('ireland_centroids.csv', delimiter=';')

# Add a column for the associated centroid to each consumption row
final_data_centroid_df = final_data_df[['Day']].copy()
final_data_centroid_df['Centroid'] = np.nan

# Change decimal format of consumption columns
centroids_data_df = centroids_data_df.replace(',', '.', regex=True).astype(float)

# Iterate through each row in the consumption dataset
for i in range(len(final_data_df)):
    # Extract hourly consumption values from the row. row[1:-1] excludes the first and last columns: 'Day' and 'Centroid'
    consumption_array = np.array(final_data_df.iloc[i, 1:-1], dtype=float) # [hour_1, hour_2, ..., hour_24]

    # Calculate the Euclidean distance to each centroid
    distances = np.linalg.norm(centroids_data_df.values - consumption_array, axis=1)
    # distances = [distance_centroid_1, distance_centroid_2, ..., distance_centroid_21]

    # Assign the centroid with the lowest distance as letters A, B, C, ..., U
    final_data_centroid_df.iloc[i, -1] = chr(65 + int(np.argmin(distances)))

# Save the updated dataset with assigned centroids
final_data_centroid_df.to_csv('final_data_cluster.csv', index=True)