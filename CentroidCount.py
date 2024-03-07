import pandas as pd

df = pd.read_csv("FinalData+Cluster.csv")

#########   Count of centroids in sorted order      #########

# Count of occurrences for each centroid
centroid_count_ord = df['Centroid'].value_counts().sort_index()

print("Count of occurrences for each centroid:")
print(centroid_count_ord.to_string().replace('\n', '\n    '))

# Save to a CSV with the ordered centroid count
centroid_count_ord.to_csv('CentroidCountOrd.csv')

# Centroide
# A    524708
# B       583
# C      6012
# D    224530
# E      2818
# F    748779
# G     85323
# H     26110
# I     28735
# J     78610
# K    155179
# L    262283
# M    122324
# N      5467
# O      3529
# P     27301
# Q    168034
# R     77462
# S     89427
# T     85133
# U     49755

#########   Count of centroids in descending order  #########

# Count the number of occurrences for each centroid
centroid_count_desc = df['Centroid'].value_counts()

print("Count of occurrences for each centroid in descending order:")
print(centroid_count_desc.to_string().replace('\n', '\n    '))

# Save to a CSV with the ordered centroid count
centroid_count_desc.to_csv('CentroidCountDesc.csv')

# Centroide
# F    748779
# A    524708
# L    262283
# D    224530
# Q    168034
# K    155179
# M    122324
# S     89427
# G     85323
# T     85133
# J     78610
# R     77462
# U     49755
# I     28735
# P     27301
# H     26110
# C      6012
# N      5467
# O      3529
# E      2818
# B       583

#########   Distribution of centroids for each user   #########

# Create a new DataFrame grouped by ID and Centroid
grouped_by_user_centroid = df.groupby(['ID', 'Centroid']).size().reset_index(name='Count')

# Use pivot_table to obtain the desired table
user_centroid_table = grouped_by_user_centroid.pivot_table(index='ID', columns='Centroid', values='Count', fill_value=0)

# Save to a CSV with the distribution of centroids.
user_centroid_table.to_csv('CentroidDistribution.csv')
