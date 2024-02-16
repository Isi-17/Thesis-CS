import pickle

# Cargar el archivo
with open('filtered_data.pkl', 'rb') as file:
    loaded_filtered_data = pickle.load(file)

# loaded_filtered_data es un diccionario con la siguiente estructura (incluye cabecera)
# {
#     ID: {
#         day: [consumption[0], consumption[1], ..., consumption[23]]
#     }
# }


print('Número de usuarios únicos:', len(loaded_filtered_data)-1)
print('Número de filas:', sum([len(dateANDconsumption) for dateANDconsumption in loaded_filtered_data.values()]))
print('Número de usuarios con más de 365 días:', sum([len(dateANDconsumption) > 365 for dateANDconsumption in loaded_filtered_data.values()]))
print('Número de usuarios con menos de 365 días:', sum([len(dateANDconsumption) < 365 for dateANDconsumption in loaded_filtered_data.values()]))

# Número de usuarios únicos: 5488
# Número de filas: 2772102
# Número de usuarios con más de 365 días: 5118
# Número de usuarios con menos de 365 días: 367