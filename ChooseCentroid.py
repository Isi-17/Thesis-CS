import pandas as pd
import numpy as np

# CSV con los consumos de energía por hora
df_data_consumptions = pd.read_csv('FinalData.csv', delimiter=',')

# CSV con los centroides
df_centroids = pd.read_csv('ireland_centroids.csv', delimiter=';')

# Añadimos columna de centroide asociado a cada fila de consumo
df_data_consumptions['Centroide'] = np.nan

# Cambiamos formato decimal de las columnas de consumo
df_centroids.iloc[:, 1:] = df_centroids.iloc[:, 1:].replace(',', '.', regex=True).astype(float)

for index, row in df_data_consumptions.iterrows():
    # row = [id, date, hour_1, hour_2, ..., hour_24, Centroid]
    hour_consumption = row[2:-1] # [hour_1, hour_2, ..., hour_24]

    consumption_array = hour_consumption.values.astype(float)
    
    # Calcular la distancia con cada centroide
    distances = np.linalg.norm(df_centroids.iloc[:, 1:].values - consumption_array, axis=1)
    # 1: para saltar la primera columna con los nombres de las filas: '0' '1' ... '20'
    # distancias = [distancia_centroide_1, distancia_centroide_2, ..., distancia_centroide_21]
 
    # Asignar el centroide con la distancia más baja
    df_data_consumptions.at[index, 'Centroide'] = int(np.argmin(distances))

df_data_consumptions.to_csv('FinalData+Cluster.csv', index=False)
