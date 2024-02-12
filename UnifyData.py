archivos = ['File1.txt', 'File2.txt', 'File3.txt', 'File4.txt', 'File5.txt', 'File6.txt']

archivo_salida = 'FileData.txt'

# Función para concatenar archivos
def concatenar_archivos(archivos, archivo_salida):
    with open(archivo_salida, 'w') as salida:
        for archivo in archivos:
            with open(archivo, 'r') as f:
                contenido = f.read()
                salida.write(contenido)
                # salida.write('\n')

concatenar_archivos(archivos, archivo_salida)

print(f'Archivos concatenados en {archivo_salida}')
