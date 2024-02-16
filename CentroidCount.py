import pandas as pd

df = pd.read_csv("FinalData+Cluster.csv")

# -----------------------------
# Conteo centroides orden descendente
# Contar el número de veces que se repite cada Centroide
conteo_centroides_num = df['Centroide'].value_counts()

print("Conteo de veces que se repite cada Centroide orden descendente:")
print(conteo_centroides_num)

# Guardo en un CSV con el conteo_centroides_ord
conteo_centroides_num.to_csv('ConteoCentroidesDesc.csv')

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

# -----------------------------------
# Conteo centroides ordenado
conteo_centroides_ord = df['Centroide'].value_counts().sort_index()

print("Conteo de veces que se repite cada Centroide:")
print(conteo_centroides_ord)

# Guardo en un CSV con el conteo_centroides_ord
conteo_centroides_ord.to_csv('ConteoCentroidesOrd.csv')

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

# -----------------------------------
# Conteo para cada usuario cuántas veces repite en distintos días cada uno de los centroides
# Crear un nuevo DataFrame con la información agrupada por ID y Centroide
agrupado_por_usuario_centroide = df.groupby(['ID', 'Centroide']).size().reset_index(name='Conteo')

# Utilizar pivot_table para obtener la tabla deseada
tabla_usuario_centroide = agrupado_por_usuario_centroide.pivot_table(index='ID', columns='Centroide', values='Conteo', fill_value=0)

# Guardo en un CSV con la distribución de los centroides.
tabla_usuario_centroide.to_csv('DistribuciónCentroides.csv')
