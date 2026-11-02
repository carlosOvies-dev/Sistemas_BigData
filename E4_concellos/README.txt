Proxecto: E4 - Web Scraping dos Concellos da Coruña

Resumo do exercicio:
Neste proxecto realízase un pipeline de obtención e limpeza de datos mediante web scraping sobre unha páxina de Wikipedia coa información demográfica dos concellos da provincia da Coruña.

Pasos realizados no notebook:
1. Comprobación de permisos de scraping mediante RobotFileParser e revisión da licenza.
2. Descarga responsable do ficheiro HTML identificándose cun User-Agent propio e almacenamento local en datos/raw/.
3. Extracción da táboa de municipios e poboación empregando BeautifulSoup.
4. Limpeza e conversión dos datos de poboación a formato numérico enteiro.
5. Validación dos datos extraídos fronte aos totais da páxina e comparación con pandas.read_html.
6. Análise demográfica respondendo a catro cuestións sobre a distribución da poboación.
7. Exportación do conxunto de datos limpo a formato CSV (UTF-8) en datos/clean/.