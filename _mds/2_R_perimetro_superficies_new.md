
## **2. OBTENER PERÍMETRO DEL INCENDIO Y CALCULAR SUPERFICIES**

*ACTUALIZADO: Enero 2026*

<img src="https://github.com/romina-gonzalez-musso/Severidad_incendios/blob/main/_images/3_R_perimetro.png" width="30%" />

El **dNBR (.tif)** obtenido con GEE se procesa en R para obtener el
**perímetro del incendio**, calcular la **superficie total** y la
**superficie por las clases de severidad** de
[USGS](https://un-spider.org/advisory-support/recommended-practices/recommended-practice-burn-severity/in-detail/normalized-burn-ratio).

Los pasos están detallados en este tutorial de [estimación de
superficies de incendio afectadas por categoría de severidad
USGS](https://github.com/romina-gonzalez-musso/Severidad_Incendio-Steffen-Martin22/blob/master/_mds/2_NBR.md)
y puede ser útil para comprender cómo se obtiene el área quemada. Sin
embargo, las funciones de este repositorio tienen algunas
actualizaciones y mejoras.

------------------------------------------------------------------------

### **Opción 1: usando directamente la función `Procesar_incendio`**

Más sencillo, la
[función](https://github.com/romina-gonzalez-musso/Severidad_incendios/blob/main/R_Functions/Procesar_incendio.R)
debe estar descargada en el directorio de trabajo y solo se le deben
indicar los parámetros:

``` r
Sups <- procesar_incendio(nbr_dir = nbr_dir,          # Indicar el directorio donde está en dNBR.tif
                          output_dir = output_dir,    # Indicar un directorio de salida de todos los productos
                          umbral = umbral,            # Umbral de valores considerados "quemados". Según USGS >100 = quemado
                          poligono = poligono,        # Shape del área a procesar
                          area_min = area_min)        # Superficie mínima de los polígonos quemados. Para eliminar ruido
```

[![Abrir en
R](https://img.shields.io/badge/Abrir_en-R-276DC3?logo=R&logoColor=white)](https://github.com/romina-gonzalez-musso/Severidad_incendios/blob/main/Py_R/GEE_dNBR_2_Procesar_incendio_funcion.R)

------------------------------------------------------------------------

### **Opción 2: script completo paso a paso**

Si se quiere ir ejecutando gradualmente la secuencia de pasos para ver
los resultados parciales y hacer modificaciones al código, este es el
script completo.

[![Abrir en
R](https://img.shields.io/badge/Abrir_en-R-276DC3?logo=R&logoColor=white)](https://github.com/romina-gonzalez-musso/Severidad_incendios/blob/main/Py_R/GEE_dNBR_2_Procesar_incendio_paso_a_paso.R)

------------------------------------------------------------------------
