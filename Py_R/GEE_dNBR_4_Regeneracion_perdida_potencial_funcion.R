### --------------------------------------------------------- ######
#    Delimitación de áreas con potencial regeneración natural
#
# Versión: RGM Julio 2025
### -------------------------------------------------------- ######

# LLAMAR A LA FUNCIÓN
source("./Functions/PotRegNat.R")

# CONFIGURAR PARÁMETROS LA FUNCIÓN: -------------------------------------
# Directorios a Clasif CIEFAP, dNBR clasificado, perímetro y de Salida

dir_clasif_ciefap <- "./Inputs/clas_mer_BAP_continental_modentr_vf_rn.shp"
dir_dNBR <- "./Outputs/R_procesamiento_incendio/dNBR_classified.tif"
dir_perimetro <- "./Outputs/R_procesamiento_incendio/perimetro_f1.shp"
output_dir <- "./Outputs//R_trayectorias_potenciales/"

# Parámetros
semilleros = c("Ci", "Co", "Le")      # Tipos ftales semilleros (Ci, Co, Le)
clases_severidad_baja = c(4, 5)       # Severdiad baja y moderada-baja
buffer_dist = 30                      # Buffer de regeneración potencial desde semilleros


# CORRER LA FUNCIÓN:  (puede demorar 2 o 3 min) -------------------------------------
potRegNatural(dir_dNBR = dir_dNBR, 
              dir_perimetro = dir_perimetro, 
              dir_clasif_ciefap = dir_clasif_ciefap, 
              output_dir = output_dir, 
              semilleros = semilleros, 
              clases_severidad_baja = clases_severidad_baja, 
              buffer_dist = buffer_dist)





            