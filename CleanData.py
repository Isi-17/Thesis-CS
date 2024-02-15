import csv
import pickle

# Ficheros de entrada y salida
ficheroEntrada = 'FileData.txt'
ficheroSalida = 'FinalData.csv'

# Diccionario para almacenar los datos
data = {}

with open(ficheroEntrada, 'r') as file:
    lines = file.readlines()

for line in lines:
    # Divido la línea en tres partes: ID, date y consumo
    ID, date, consumption = line.split()

    # Dia: primeras 3 cifras de la fecha
    day = int(date[:3])

    # Hora: últimas 2 cifras de la fecha. La hora viene dada en medias horas desde 01 hasta 48
    half_hour = int(date[3:5])  # [1, 48]
    hour = (half_hour - 1) // 2  # [0, 23]
    
    # Si el ID no está en el diccionario, lo añado
    if ID not in data:
        data[ID] = {}

    # Si el día no está en el diccionario, lo añado y le asigno una lista de 48 elementos: dia ++ 47 valores None correspindeintes a las medias horas. 
    if day not in data[ID]:
        data[ID][day] = [day] + [None] * 47 # [dia, consumo[0], consumo[1], ..., consumo[47]]

    if 1 <= half_hour <= 48:
        data[ID][day][half_hour - 1] = float(consumption) * 1000  # kWH -> wH
        
# Elimino las líneas con valores None
data_cleaned = {
    ID: {
        day: consumption_list
        for day, consumption_list in dateANDconsumption.items() 
        if None not in consumption_list
    }
    for ID, dateANDconsumption in data.items()
}

# Ahora sumo los valores de las primeras y segundas medias horas para obtener los 24 valores por hora
data_hourly = {
    ID: {
        day: [day] + [sum(data[ID][day][i:i + 2]) for i in range(0, 48, 2)]
        for day in dateANDconsumption
    }
    for ID, dateANDconsumption in data_cleaned.items()
} # [fecha, consumo[0], consumo[1], ..., consumo[23]]

# Aplico los filtros adicionales:
# - El consumo total del día debe ser mayor de 100 Wh
# - El consumo máximo en una hora no debe superar los 15000 Wh
low_umbral = 100
high_umbral = 15000

# Identifico los ID que cumplen con la condición de consumo mínimo
IDs_low_umbral = {
    ID for ID, dateANDconsumption in data_hourly.items() 
    if any(sum(consumption_list[1:]) < low_umbral for day, consumption_list in dateANDconsumption.items())
}

print('Número de usuarios con algún consumo diario inferior a 100 Wh:', len(IDs_low_umbral)) # 164

# Identifico los ID que cumplen con la condición de consumo máximo
IDs_high_umbral = {
    ID for ID, dateANDconsumption in data_hourly.items() 
    if any(max(consumption_list[1:]) > high_umbral for day, consumption_list in dateANDconsumption.items())
    }

print('Número de usuarios con consumo máximo superior a 15000 Wh:', len(IDs_high_umbral)) # 741


filtered_data = {
    ID: {
        day: consumption_list
        for day, consumption_list in dateANDconsumption.items()
        if sum(consumption_list[1:]) > low_umbral # consumo total del día mayor de 100 Wh
    }
    for ID, dateANDconsumption in data_hourly.items()
    if ID not in IDs_high_umbral # no supera los 15000 Wh
}

# Creación del fichero CSV
with open(ficheroSalida, 'w', newline='') as file:
    writer = csv.writer(file)
    # Cabecera
    writer.writerow(['ID', 'date', 'H0', 'H1', 'H2', 'H3', 'H4', 'H5', 'H6', 'H7', 'H8', 'H9', 'H10', 'H11', 'H12', 'H13', 'H14', 'H15', 'H16', 'H17', 'H18', 'H19', 'H20', 'H21', 'H22', 'H23'])
    
    # Recorro el diccionario y escribo cada fila
    for ID, dateANDconsumption in filtered_data.items(): # dateANDconsumption = [dia, consumo[0], consumo[1], ..., consumo[23]]
        for day, consumption_list in dateANDconsumption.items():
            # Join para unir las primeras dos columnas con espacios y el resto con comas
            # row = [ID {consumption_list[0]} {consumption_list[1]}"] + consumption_list[2:]
            row = [ID] + consumption_list
            writer.writerow(row)

# Guardamos variable filtered_data
with open('filtered_data.pkl', 'wb') as file:
    pickle.dump(filtered_data, file)

