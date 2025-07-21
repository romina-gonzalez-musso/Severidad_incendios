
## **2. OBTENER PERÍMETRO DEL INCENDIO Y CALCULAR SUPERFICIES**

<img src="https://github.com/romina-gonzalez-musso/Severidad_incendios/blob/main/_images/3_R_perimetro.png" width="48%" />

El **dNBR (.tif)** obtenido con GEE se procesa en R para obtener el
**perímetro del incendio**, calcular la **superficie total** y la
**superficie por clase de severidad** de [acuerdo a
USGS.](https://un-spider.org/advisory-support/recommended-practices/recommended-practice-burn-severity/in-detail/normalized-burn-ratio).

Los pasos están detallados en este tutorial de [estimación de
superficies de incendio afectadas por categoría de severidad
USGS](https://github.com/romina-gonzalez-musso/Severidad_Incendio-Steffen-Martin22/blob/master/_mds/2_NBR.md).
Sin embargo, este repositorio tiene algunas actualizaciones que mejoran
la aplicación de la función.

### **Opción 1: usando directamente la función `Procesar_incendio`**

Más sencillo, solamente se deben indicar los parámetros de la función:

``` r
Sups <- procesar_incendio(nbr_dir = nbr_dir,          # Indicar el directorio donde está en dNBR.tif
                          output_dir = output_dir,    # Indicar un directorio de salida de todos los productos
                          buffer_size = buffer_size,  # Indicar unn área buffer de búsqueda de polígonos de incendio (Ej 200)
                          n_poligonos = n_poligonos,  # Indicar el número de polígonos "grandes" a evaluar como quemados (Ej. 3)
                          umbral = umbral,            # Umbral de valores considerados "quemados". Según USGS >100 = quemado
                          coords = coords)            # Opcional: indicar coordenadas Posgar F1 para ayudar a ubicar los polígonos de incendio
```

[![Abrir en
R](https://img.shields.io/badge/Abrir_en-R-276DC3?logo=R&logoColor=white)]()

### **Opción 2: buscar imágenes con un rango de fechas**

Si no se buscaron imágenes de antemano, se puede crear un compuesto de
imágenes pre y post incendio a partir de indicar un rango de fechas.
Tratar que el rango sea lo más acotado posible.

[![Abrir en
Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/romina-gonzalez-musso/Severidad_incendios/blob/main/Py_R/GEE_dNBR_1_Compuesto_rango_fechas.ipynb)

[![Abrir
notebook](https://img.shields.io/badge/Ver%20Notebook%20en-Jupyter-orange?logo=jupyter)](https://github/romina-gonzalez-musso/Severidad_incendios/blob/main/Py_R/GEE_dNBR_1_Compuesto_rango_fechas.ipynb)
