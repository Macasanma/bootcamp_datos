# ¿Cómo se relata una revolución?

Análisis de minería de textos y PLN sobre la cobertura de **El País** durante la Revolución Tunecina (2010-2011).

**Proyecto:** Macarena Sánchez Maeso — IT Academy, Itinerario de Análisis de Datos

---

## 📌 De qué trata

Este proyecto no analiza «qué pasó» en la Revolución Tunecina, sino **cómo la contó** un medio de referencia en español. A partir de un corpus propio de artículos de El País, se estudia:

- Qué actores protagonizan el relato (Ben Ali, Policía, Ejército, Ennahda…)
- Con qué tono se narra (titular vs. cuerpo de la noticia)
- Con qué emoción (ira, tristeza, alegría…)
- Con qué vocabulario se explica el conflicto en cada momento
- Si la revolución se explica como un fenómeno político o socioeconómico
- Cuándo y cuánto se cubrió el proceso

## 🗂️ Estructura del proyecto

El proyecto se organiza en 3 notebooks encadenados:

| Notebook | Qué hace | Entrada | Salida |
|---|---|---|---|
| `1_extraccion.ipynb` | Descarga los artículos de la hemeroteca de El País (scraping semi-manual, con trafilatura + BeautifulSoup) | Hemeroteca de El País | `corpus_elpais_manual.csv` (138 artículos) |
| `2_limpieza.ipynb` | Limpia el corpus: quita duplicados, falsos positivos, asigna fechas y fases históricas | CSV en bruto + `tunez.yaml` | `corpus_limpio_final.csv` (126 artículos) |
| `3_analisis.ipynb` | Aplica las técnicas de PLN y genera todas las tablas, gráficos y hallazgos | `corpus_limpio_final.csv` + `tunez.yaml` | Tablas, gráficos y variables para las conclusiones |

Además:

- `tunez.yaml` — diccionario de entidades (personas, lugares, organizaciones, conceptos y marcadores narrativos) usado para el reconocimiento de entidades (NER) a lo largo de todo el proyecto.
- `corpus_limpio_final.csv` — el corpus final de 126 artículos, ya limpio, con la fase histórica asignada.

## 🧠 Técnicas utilizadas

- **NER por diccionario** (YAML) para identificar actores, lugares y conceptos.
- **Análisis de sentimiento y de emociones** con PySentimiento (modelo BETO/BERT en español).
- **Minería de texto**: frecuencias, n-gramas y nubes de palabras.
- **Coocurrencias léxicas** y red de actores (NetworkX).
- **Léxicos propios**: índice de violencia ponderado y campos semánticos causales (regex / KWIC).
- **PCA** para visualizar el perfil emocional de los artículos.

## 📅 Las 4 fases históricas

| Fase | Rango | Artículos |
|---|---|---|
| Fase de protestas | 17/12/2010 – 13/01/2011 | 13 |
| Caída del régimen | 14/01/2011 – 28/02/2011 | 68 |
| Transición democrática | 01/03/2011 – 23/10/2011 | 24 |
| Periodo post-electoral | 24/10/2011 – 31/12/2011 | 21 |

## 🔍 Principales hallazgos

- **21 días de silencio**: el primer artículo del corpus es del 05/01/2011, tres semanas después de la autoinmolación de Bouazizi.
- **Ben Ali** aparece en el 80,2% de los artículos: el eje narrativo absoluto del corpus.
- El **cuerpo de la noticia** es sistemáticamente más negativo que el titular en las 4 fases.
- La **ira** domina el 77,8% de los artículos; la alegría solo aparece tras las elecciones.
- El vocabulario del conflicto cambia: de un léxico de **orden público** (protestas/caída del régimen) a uno **identitario** (periodo post-electoral).
- El marco explicativo pasa de socioeconómico a político y vuelve a recuperarse parcialmente (patrón en «U invertida»).

## ⚙️ Cómo ejecutarlo

```bash
pip install pandas pyyaml unidecode nltk wordcloud networkx seaborn matplotlib plotly scikit-learn pysentimiento beautifulsoup4 trafilatura
```

Ejecutar los notebooks en orden: `1_extraccion.ipynb` → `2_limpieza.ipynb` → `3_analisis.ipynb`.

## ⚠️ Limitaciones

- Obtención del corpus: dificultades técnicas para acceder a la hemeroteca debido a mecanismos anti-bot y a las restricciones de acceso mediante suscripción.
- Análisis de sentimiento: el modelo BERT basa sus predicciones en asociaciones estadísticas entre palabras y emociones, por lo que no siempre distingue entre la descripción de un acontecimiento y el posicionamiento editorial del medio.
- Alcance del corpus: el corpus se limita a un único medio, lo que permite un análisis en profundidad de su cobertura, aunque futuras investigaciones podrían ampliarse para comparar diferentes líneas editoriales.
