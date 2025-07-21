### -------------------------------- ######
#      Clases por Tipo forestal
# 
# Versión: RGM Julio 2025
### -------------------------------- ######

# Nota: el insumo es un .tif de dNBR con las clases USGS
# Y el mapa de tipos ftales del CIEFAP

# LIBRERIAS -------------------------------------------------
library("terra")
library("sf")
library("dplyr")
library("raster")

# Llamar a las funciones
source("/home/romina/Descargas/2025-08_Taller_APN_Severidad_incendios/Functions/USGSxTipoFtal_funciones.R")

# TRAER EL dNBR y el shape del CIEFAP --------------------------------------------
dir_ciefap <-"/home/romina/Documentos/GIS/GIS_SHAPES/Neuquén_Bosque_Nativo/2016_CIEFAP_Clasificacion_FINAL_Julio-2016/2_RN_vf_20160616/clas_mer_BAP_continental_modentr_vf_rn.shp"
dir_nbr_class <- "/home/romina/Descargas/2025-08_Taller_APN_Severidad_incendios/Outputs/dNBR_classified.tif"


# Ver el listado de tipos forestales en el área de estudio
perimetro <- vect("/home/romina/Descargas/2025-08_Taller_APN_Severidad_incendios/Outputs/perimetro_f1.shp")
clasif_ciefap <- vect(dir_ciefap)
clasif_ciefap_incendio <- crop(clasif_ciefap, perimetro)

plot(clasif_ciefap_incendio)

# Tipos Ftales presentes (Ley Nivel 2)
unique(clasif_ciefap_incendio$Ley_N2)

# Definir el tipo forestal
Tipo_ftal <- "Co"

# Aplicar la función que extrae los polígonos de del tipo Ftal
Tipo_ftal <- shapeUSGSxTipoFtal(Tipo_ftal)
Tipo_ftal$ID <- 1:nrow(Tipo_ftal)

# Función para calcular la superficie por clase de severidad
supUSGSxTipoFtal(Tipo_ftal)

# Graficar
plotUSGS(Tipo_ftal)
