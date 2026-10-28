-- Creamos la tabla si no existe
CREATE TABLE IF NOT EXISTS meteo_alvedro (
    "Data" DATE PRIMARY KEY,
    "Temp. media (ºC)" DOUBLE PRECISION,
    "Temp. mínima (ºC)" DOUBLE PRECISION,
    "Temp. máxima (ºC)" DOUBLE PRECISION,
    "Humidade relativa (%)" INTEGER,
    "Precipitación (mm)" DOUBLE PRECISION,
    "Vento medio (km/h)" DOUBLE PRECISION,
    "Presión (hPa)" DOUBLE PRECISION
);