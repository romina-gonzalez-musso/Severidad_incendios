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
source("./Functions/USGSxTipoFtal_funciones.R")

# TRAER EL dNBR y el shape del CIEFAP --------------------------------------------
dir_ciefap <-"./Inputs/clas_mer_BAP_continental_modentr_vf_rn.shp"
dir_nbr_class <- "./Outputs/R_procesamiento_incendio/dNBR_classified.tif"


# Ver el listado de tipos forestales en el área de estudio
perimetro <- vect("./Outputs/R_procesamiento_incendio/perimetro_f1.shp")
clasif_ciefap <- vect(dir_ciefap)
clasif_ciefap_incendio <- crop(clasif_ciefap, perimetro)

plot(clasif_ciefap_incendio)

# Tipos Ftales presentes (Ley Nivel 2)
unique(clasif_ciefap_incendio$Ley_N2)

# Definir el tipo forestal
Tipo_ftal <- "Co"

# Aplicar la función que extrae los polígonos de del tipo Ftal
Poligonos_Tipo_ftal <- shapeUSGSxTipoFtal(Tipo_ftal)
Poligonos_Tipo_ftal$ID <- 1:nrow(Poligonos_Tipo_ftal)

# Función para calcular la superficie por clase de severidad
supUSGSxTipoFtal(Poligonos_Tipo_ftal)

# Graficar
plotUSGS(Poligonos_Tipo_ftal)


## Guardar polígonos
dir_salida <- "./Outputs/"
nombre_shape <- paste0("Severidad_", Tipo_ftal, ".shp") 
guardar <- paste0(dir_salida, nombre_shape)

writeVector(vect(Poligonos_Tipo_ftal), guardar)

