
## **LIBRERÍAS Y REQUERIMIENTOS**

### **1. Google Earth Engine (GEE)**

<img src="https://github.com/romina-gonzalez-musso/Severidad_incendios/blob/main/_images/Logo_GEE.jpeg" width="30%" />

Se debe tener una cuenta de usuario de GEE con Cloud Project habilitado.

En este repositorio se mostrará el uso de GEE en Python. Pero el mismo
procedimiento puede reproducirse usando el Code Editor nativo de GEE que
corre en *javascript*.

### **2. Python - Dos opciones:**

<img src="https://github.com/romina-gonzalez-musso/Severidad_incendios/blob/main/_images/Logo_python.png" width="30%" />

#### **2a. Con Google Colab** *(recomendado para principiantes)*

<img src="https://github.com/romina-gonzalez-musso/Severidad_incendios/blob/main/_images/Logo_Colab.jpeg" width="30%" />

Se puede ejecutar GEE usando Colab. Solo se necesita una cuenta de gmail
para acceder a los notebooks de Colab.

**¿Qué es Google Colab?** Es una plataforma en la nube que permite
escribir y ejecutar código Python para tareas de ciencia de datos. Ya
trae instalado GEE y *geemap* y permite exportar los productos (ej.
imágenes) a Google Drive sin necesidad de instalar nada en al
computadora.

#### **2b. En instalación local** *(recomendado para usuarios avanzados)*

<img src="https://github.com/romina-gonzalez-musso/Severidad_incendios/blob/main/_images/Logo_jupyter.png" width="30%" />

Para ejecutar GEE en Python en forma local. En este caso se debe
instalar solamente [*geemap*](https://geemap.org/) y descargar los
Jupyter notebooks al directorio local.

### **3. R y librerías**

<img src="https://github.com/romina-gonzalez-musso/Severidad_incendios/blob/main/_images/Logo_R.png" width="30%" />

Se necesitan las siguientes librerías de R:

``` r
# Instalar
install.packages("terra")
install.packages("sf")
install.packages("dplyr")
install.packages("raster")

# Probar que se hayan instalado bien
library("terra")
library("sf")
library("dplyr")
library("raster")
```
