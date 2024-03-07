import pandas as pd
import numpy as np

# Read the dataset with hourly energy consumptions
df_data_consumptions = pd.read_csv('FinalData.csv', delimiter=',')

# Read the dataset with centroids
df_centroids = pd.read_csv('ireland_centroids.csv', delimiter=';')

# Add a column for the associated centroid to each consumption row
df_data_consumptions['Centroid'] = np.nan

# Change decimal format of consumption columns
df_centroids.iloc[:, 1:] = df_centroids.iloc[:, 1:].replace(',', '.', regex=True).astype(float)

# Iterate through each row in the consumption dataset
for index, row in df_data_consumptions.iterrows():
    # Extract hourly consumption values from the row
    hour_consumption = row[2:-1]  # [hour_1, hour_2, ..., hour_24]

    consumption_array = hour_consumption.values.astype(float)
    
    # Calculate the Euclidean distance to each centroid
    distances = np.linalg.norm(df_centroids.iloc[:, 1:].values - consumption_array, axis=1)
    # 1: Skip the first column with row names: '0' '1' ... '20'
    # distances = [distance_centroid_1, distance_centroid_2, ..., distance_centroid_21]
 
    # Assign the centroid with the lowest distance
    df_data_consumptions.at[index, 'Centroid'] = chr(65 + int(np.argmin(distances)))

# Save the updated dataset with assigned centroids
df_data_consumptions.to_csv('FinalData+Cluster.csv', index=False)
