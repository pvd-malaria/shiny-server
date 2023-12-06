import pandas as pd
import numpy as np

df = pd.read_csv('data.csv', sep=';')

# Corrigir lat long do ID 295 para S ao invés de N
df.loc[df['ID'] == 295, 'Latitude graus'] = '0°46’ S'

# Corrigir Cumi0panema para Cuminapanema
df = df.replace('Cumi0panema', 'Cuminapanema')
df = df.replace('Reserva Cumi0panema', 'Reserva Cuminapanema')

# Remover s.l. de An. mediopunctatus s.l.
df = df.replace('An. mediopunctatus s.l.', 'An. mediopunctatus')

# Lat-Lon num único par para contar duplicados
df['lat-lon'] = df['Latitude'] + ';' + df['Longitude']

# Pegar a maior quantidade de repetições
max_dupes = df['lat-lon'].value_counts().max()
# Selecionar apenas os duplicados para fazer o círculo
duplicated_lat_lon = df['lat-lon'].value_counts() >= 2
duplicated_lat_lon = duplicated_lat_lon[duplicated_lat_lon].index.to_list()
duplicated_entries = df[df['lat-lon'].isin(duplicated_lat_lon)]

positions = {}

for latlon in duplicated_lat_lon:
    num = duplicated_entries[duplicated_entries['lat-lon'] == latlon].shape[0]
    lat, lon = [float(x) for x in latlon.replace(',', '.').split(';')]
    positions[latlon] = [latlon]
    angle = np.pi / 2
    step = 2 * np.pi / (num - 1)
    radius = 0.0125
    for i in range(1, num):
        new_lat = lat + radius * np.cos(angle)
        new_lon = lon + radius * np.sin(angle)
        new_latlon = '{:.5f};{:.5f}'.format(new_lat, new_lon).replace('.', ',')
        positions[latlon].append(new_latlon)
        angle += step * i
    all_latitudes = [x.split(';')[0] for x in positions[latlon]]
    all_longitudes = [x.split(';')[1] for x in positions[latlon]]
    df.loc[df['lat-lon'] == latlon, 'Latitude'] = all_latitudes
    df.loc[df['lat-lon'] == latlon, 'Longitude'] = all_longitudes

df = df.drop(columns=['lat-lon'])
df.to_csv('output.csv', index=False, sep=';')
