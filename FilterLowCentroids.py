import pandas as pd

# Cargar el archivo CSV en un DataFrame
df = pd.read_csv('DistribuciónCentroides.csv')

# Especificar el umbral de número mínimo de clusters diferentes (sobre 20)
umbral_clusters = 2

# Filtrar IDs con menor número de clusters diferentes que el umbral
filtered_rows = []
for index, row in df.iterrows():
    clusters = row[1:]  # [f(0), ..., f(20)]
    clusters_cleaned = [c for c in clusters if c != 0.0]

    unique_clusters = []
    for c in clusters_cleaned:
        if c not in unique_clusters:
            unique_clusters.append(c)

    clusters_diferentes = len(unique_clusters)
    
    if clusters_diferentes <= umbral_clusters:
        filtered_rows.append(row)
        

# DataFrame con los resultados
result_df = pd.DataFrame(filtered_rows)


# Genero un CSV con los resultados filtrados
result_df.to_csv('filter2LowCentroids.csv', index = False)
