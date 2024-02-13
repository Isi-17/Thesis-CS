import pandas as pd

# Cargar el CSV en un DataFrame
df = pd.read_csv("FinalData+Cluster.csv")

# -----------------------------
# Conteo centroides orden descendente
# Contar el número de veces que se repite cada Centroide
conteo_centroides_num = df['Centroide'].value_counts()

print("Conteo de veces que se repite cada Centroide orden descendente:")
print(conteo_centroides_num)

# Crear un CSV con el conteo_centroides_ord
conteo_centroides_num.to_csv('ConteoCentroidesDesc.csv')

# Centroide
# 5.0     626728
# 0.0     427366
# 11.0    219736
# 3.0     183851
# 16.0    150524
# 10.0    136042
# 12.0    107227
# 18.0     86392
# 19.0     78349
# 6.0      74878
# 9.0      73180
# 17.0     72846
# 20.0     58513
# 8.0      40531
# 15.0     37268
# 7.0      36946
# 13.0     18594
# 2.0      18007
# 14.0     12619
# 1.0       7357
# 4.0       6992

# -----------------------------------
# Conteo centroides ordenado
conteo_centroides_ord = df['Centroide'].value_counts().sort_index()

print("Conteo de veces que se repite cada Centroide:")
print(conteo_centroides_ord)

# Crear un CSV con el conteo_centroides_ord
conteo_centroides_ord.to_csv('ConteoCentroidesOrd.csv')

# Centroide
# 0.0     427366
# 1.0       7357
# 2.0      18007
# 3.0     183851
# 4.0       6992
# 5.0     626728
# 6.0      74878
# 7.0      36946
# 8.0      40531
# 9.0      73180
# 10.0    136042
# 11.0    219736
# 12.0    107227
# 13.0     18594
# 14.0     12619
# 15.0     37268
# 16.0    150524
# 17.0     72846
# 18.0     86392
# 19.0     78349
# 20.0     58513

# -----------------------------------
# Conteo para cada usuario cuántas veces repite en distintos días cada uno de los centroides
# Crear un nuevo DataFrame con la información agrupada por ID y Centroide
agrupado_por_usuario_centroide = df.groupby(['ID', 'Centroide']).size().reset_index(name='Conteo')

# Utilizar pivot_table para obtener la tabla deseada
tabla_usuario_centroide = agrupado_por_usuario_centroide.pivot_table(index='ID', columns='Centroide', values='Conteo', fill_value=0)

tabla_usuario_centroide.to_csv('DistribuciónCentroides.csv')