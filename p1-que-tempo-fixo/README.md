# P1. Que tempo fixo? - Pipeline de Datos Meteorológicos

## 1. Descripción del Proyecto y de la Estación
Este proyecto implementa un pipeline de datos completo para la obtención, limpieza, análisis y almacenamiento de datos meteorológicos históricos (2021-2025). 
Los datos procesados corresponden a la siguiente estación:
* **Nombre:** A Coruña / Alvedro (aeropuerto)
* **Indicativo:** 08002
* **Coordenadas:** Latitud 43.3000, Longitud -8.3833
* **Altitud:** 97 m

## 2. Fuente de los Datos
* **Origen original:** Meteostat (`meteostat.net`). Archivo modificado con fines didácticos para presentar problemas de calidad.
* **URL de descarga:** `https://raw.githubusercontent.com/bigdatawirtz/datasets/main/datasets/meteo_alvedro_2021_2025.csv`
* **Condiciones de uso:** Datos públicos utilizados con fines educativos.
* **Fecha de descarga:** Octubre de 2026.

## 3. Instrucciones de Ejecución
Para reproducir este proyecto de principio a fin, sigue estos pasos:

1. **Clonar el repositorio y preparar el entorno:**
   ```bash
   git clone https://github.com/carlosOvies-dev/Sistemas_BigData.git
   cd Sistemas_BigData/que_tempo_fixo
   python -m venv venv
   source venv/bin/activate  # En Linux/Mac
   # o venv\Scripts\activate en Windows
   pip install -r requirements.txt
   ```
2. **Estructura de carpetas requerida:**
   El repositorio incluye la estructura `datos/raw/`, `datos/clean/`, `notebooks/` y `output/`. El cuaderno creará las subcarpetas de datos si no existen y descargará los archivos automáticamente desde cero.
3. **Levantar la base de datos PostgreSQL:**
   Configura las credenciales copiando el archivo de entorno y levantando el contenedor de Docker (esto ejecutará automáticamente el script `initdb/01_crear_tabla.sql` para crear la tabla).
   ```bash
   cp .env.example .env
   docker compose up -d
   ```
4. **Ejecutar el análisis:**
   Abre Jupyter Notebook y ejecuta todas las celdas del cuaderno principal (`notebooks/01_analisis_meteo.ipynb`) de forma secuencial.
   ```bash
   jupyter notebook
   ```

## 4. Decisiones de Limpieza y Procesamiento
Durante la carga e inspección de los datos en bruto (`raw`), se detectaron y corrigieron múltiples anomalías para generar el dataset limpio (`clean`) en formato UTF-8.

| Problema Detectado | Método de Detección | Decisión / Solución Aplicada |
| :--- | :--- | :--- |
| **Metadatos iniciales** | Inspección de las primeras líneas en binario (`readline`). | Ignorar las 6 primeras filas en la lectura (`skiprows=6`). |
| **Codificación incorrecta** | Presencia de secuencias de bytes (`\xf3`, `\xf1`). | Especificar `encoding='latin1'` en `pd.read_csv`. |
| **Separadores no estándar** | Columnas separadas por `;`, decimales con `,` y miles con `.`. | Usar los parámetros `sep=';'`, `decimal=','` y `thousands='.'`. |
| **Código de texto en Precipitación** | Aparición del valor `'Ip'` (Inapreciable) en la inspección. | Convertir explícitamente a nulo al cargar con `na_values=['Ip']`. |
| **Formatos de fecha mezclados** | Coexistencia de `YYYY-MM-DD` y `DD/MM/YYYY` al final del archivo. | Filtrar con `.str.contains('/')`, convertir cada grupo con su formato exacto en `pd.to_datetime`, concatenar y ordenar cronológicamente. |
| **Fechas duplicadas** | Comprobación con `.duplicated(subset=['Data'], keep=False)` (26 filas afectadas, 13 días repetidos). | Eliminar duplicados conservando la primera aparición (`drop_duplicates(subset=['Data'], keep='first')`). |
| **Días ausentes en el calendario** | Comparación con un calendario teórico completo (`pd.date_range` de 1826 días). Faltaban 27 días. | Reindexar el DataFrame con el calendario completo, insertando las 27 fechas ausentes con valores `NaN`. |
| **Errores de sensores (-9999.0)** | Tabla de diagnóstico (`min()` y `max()`) y visualización previa. | Convertir en `NaN` valores fuera de rango físico: temperaturas `< -50` o `> 50`, precipitación `< 0`, humedad `< 0` o `> 100`, y viento `< 0` o `> 300`. |
| **Inconsistencias térmicas** | Filtro lógico (`Tmin > Tmax` o `Tmedia` fuera de `[Tmin, Tmax]`). Detectado el día `2025-02-13` (`Tmedia = 31.3 ºC` > `Tmax = 15.2 ºC`). | Anular (`NaN`) los valores térmicos de las filas inconsistentes para recalcularlos posteriormente. |
| **Picos térmicos anómalos (Outliers estacionales)** | Filtro condicional en primavera (mes de marzo con `Tmax > 30 ºC`) e inspección de extremos anuales. Detectados `39.2 ºC` (`2024-03-19`) y `36.2 ºC` (`2025-03-21`). | Convertir dichos valores irreales en `NaN` para recalcularlos mediante interpolación lineal con los días contiguos. |
| **Valores nulos en variables continuas** | Conteo de `isna().sum()` en temperaturas, presión, humedad y viento tras limpiar errores y reindexar. | Rellenar huecos mediante **interpolación lineal** (`.interpolate(method='linear')`) al tratarse de magnitudes físicas continuas. |
| **Valores nulos en Precipitación** | Conteo de `isna().sum()` (155 nulos entre `'Ip'`, errores y días ausentes). | Rellenar con `0.0` (`.fillna(0.0)`), ya que la lluvia no es continua (no se debe interpolar) y tanto `'Ip'` como la falta de registro se asumen como 0 mm. |
| **Columnas extra y tipos para SQL** | Columnas auxiliares creadas durante el análisis (`Ano`, `Mes`, `AnoMes`, etc.). | Filtrar únicamente las 8 columnas originales y convertir `Data` a objeto `date` antes de insertar en PostgreSQL con `to_sql`. |

## 5. Uso de la Inteligencia Artificial
Durante el desarrollo del proyecto, se han utilizado herramientas de IA generativa (ChatGPT / Gemini) como asistente de programación para las siguientes tareas:
* **Depuración de errores (Troubleshooting):** Diagnóstico y solución de fallos de conexión entre Pandas/SQLAlchemy y el contenedor de PostgreSQL en Docker.
* **Refactorización de infraestructura:** Adaptación del código para utilizar scripts de inicialización SQL (`initdb`) y ajustar versiones de imágenes Docker (`postgres:17`).
* **Gestión de tipos de datos:** Resolución de conflictos de tipos al transferir variables temporales a la base de datos relacional.
* **Revisión y estructuración:** Auditoría del cumplimiento de requisitos del enunciado y maquetación en Markdown de la documentación técnica.