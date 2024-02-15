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
# F    595753
# A    407568
# L    204827
# D    174041
# Q    129181
# K    121115
# M     93836
# S     69629
# G     66462
# T     65406
# J     60771
# R     59686
# U     38936
# I     23300
# P     20851
# H     20372
# C      5378
# N      4657
# O      3448
# E      2376
# B       557

# -----------------------------------
# Conteo centroides ordenado
conteo_centroides_ord = df['Centroide'].value_counts().sort_index()

print("Conteo de veces que se repite cada Centroide:")
print(conteo_centroides_ord)

# Guardo en un CSV con el conteo_centroides_ord
conteo_centroides_ord.to_csv('ConteoCentroidesOrd.csv')

# Centroide
# A    407568
# B       557
# C      5378
# D    174041
# E      2376
# F    595753
# G     66462
# H     20372
# I     23300
# J     60771
# K    121115
# L    204827
# M     93836
# N      4657
# O      3448
# P     20851
# Q    129181
# R     59686
# S     69629
# T     65406
# U     38936

# -----------------------------------
# Conteo para cada usuario cuántas veces repite en distintos días cada uno de los centroides
# Crear un nuevo DataFrame con la información agrupada por ID y Centroide
agrupado_por_usuario_centroide = df.groupby(['ID', 'Centroide']).size().reset_index(name='Conteo')

# Utilizar pivot_table para obtener la tabla deseada
tabla_usuario_centroide = agrupado_por_usuario_centroide.pivot_table(index='ID', columns='Centroide', values='Conteo', fill_value=0)

# Guardo en un CSV con la distribución de los centroides.
tabla_usuario_centroide.to_csv('DistribuciónCentroides.csv')
