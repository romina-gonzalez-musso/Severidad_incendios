
## **LIBRERÍAS Y REQUERIMIENTOS**

### **1. Google Earth Engine (GEE)**

<img src="https://github.com/romina-gonzalez-musso/Severidad_incendios/blob/main/_images/Logo_GEE.jpg" width="25%" />

Es necesario contar con una cuenta de usuario de Google Earth Engine con
un Cloud Project habilitado. En este repositorio se demostrará el uso de
GEE a través de Python. Sin embargo, el mismo procedimiento puede
reproducirse utilizando el Code Editor nativo de GEE, que funciona en
lenguaje *JavaScript*.

### **2. Python - Dos opciones:**

<img src="https://github.com/romina-gonzalez-musso/Severidad_incendios/blob/main/_images/Logo_Python.png" width="22%" />

#### **2a. Con Google Colab** *(recomendado para principiantes)*

<img src="https://github.com/romina-gonzalez-musso/Severidad_incendios/blob/main/_images/Logo_colab.jpg" width="19%" />

Google Colab es una plataforma en la nube que permite escribir y
ejecutar código en Python, especialmente útil para tareas de ciencia de
datos. Solo se necesita una cuenta de Gmail para acceder. Colab ya
incluye herramientas como Google Earth Engine (GEE) y la librería
[*geemap*](https://geemap.org/) preinstaladas, lo que facilita el
trabajo sin necesidad de instalar nada en la computadora. Además,
permite exportar productos (por ejemplo, imágenes) directamente a Google
Drive.

#### **2b. En instalación local** *(recomendado para usuarios avanzados)*

<img src="https://github.com/romina-gonzalez-musso/Severidad_incendios/blob/main/_images/Logo_jupyter.png" width="20%" />

También es posible trabajar con Google Earth Engine de forma local
utilizando Python. Para ello, solo es necesario instalar la librería
[*geemap*](https://geemap.org/) y descargar los notebooks de Jupyter en
el directorio local. Esta opción permite ejecutar los análisis
directamente desde la computadora, manteniendo una estructura similar a
la de Colab.

### **3. R y librerías**

<img src="https://github.com/romina-gonzalez-musso/Severidad_incendios/blob/main/_images/Logo_R.png" width="12%" />

Se necesitan las siguientes librerías de R:

``` r
# Instalar
install.packages("terra")
install.packages("sf")
install.packages("dplyr")
install.packages("raster")
install.packages("tidyterra")
```
