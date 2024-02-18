import pandas as pd

# df_distrib = pd.read_csv('DistribuciónCentroides.csv')
df_distrib = pd.read_csv('filter2LowCentroids.csv')
df_data_consumptions = pd.read_csv('FinalData+Cluster.csv')

# Cantidad mínima de días consecutivos requeridos
num_dias_consecutivos = 400

id_clustersconsec = []

for index, row in df_distrib.iterrows():
    id_vivienda = row['ID'] # guardamos el ID de la vivienda de la fila actual
    
    # DataFrame con las filas de df_data_consumptions que corresponden a la vivienda actual
    df_id = df_data_consumptions[df_data_consumptions['ID'] == id_vivienda]
    
    # Ordena por fecha para asegurar que los días están en orden cronológico
    df_id = df_id.sort_values(by='date')
    # print(df_id)
    
    # Inicializamos variable para guardar el día anterior, variable contadora y lista de clusters
    dia_anterior = None
    dias_consecutivos = 0
    lista_clusters = []
  
    for idx, r in df_id.iterrows():
        cluster_dia = r['Centroide'] # guardamos el cluster del día actual
        dia_actual = r['date']  # guardamos el día actual

        # Verifico si el día actual es consecutivo al día anterior
        if dia_anterior is not None and dia_actual == dia_anterior + 1:
            dias_consecutivos += 1
            lista_clusters.append(cluster_dia)
            # print(dia_actual, dias_consecutivos, lista_clusters)
            
            if dias_consecutivos == num_dias_consecutivos:
                break
        else:
            if dia_anterior is None:
                dias_consecutivos = 1
                lista_clusters.append(cluster_dia)
            else:
                # print('Reset')
                dias_consecutivos = 0
                lista_clusters = []

        # Actualizar el día anterior
        dia_anterior = dia_actual
    
    if dias_consecutivos == num_dias_consecutivos:
        id_clustersconsec.append([id_vivienda] + lista_clusters)
        # print('----------------')
        # print(id_vivienda, lista_clusters)
        # print('----------------')

df_secpatron= pd.DataFrame(id_clustersconsec, columns=['ID'] + [f'ClusterDia{i+1}' for i in range(num_dias_consecutivos)])

df_secpatron.to_csv(f'secuencia_patrones_2_{num_dias_consecutivos}.csv', index=False)
# df_secpatron.to_csv(f'secuencia_patrones_{num_dias_consecutivos}.csv', index=False)