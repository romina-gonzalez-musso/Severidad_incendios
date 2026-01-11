### --------------------------------------------------- ######
#             FUNCIÓN PROCESAR INCENDIO
# Perímetro, clases de severidad y cálculo de superficies
# 
# Versión: RGM Enero 2026
### ------------------------------------------------- ######

# LLAMAR A LA FUNCIÓN
source("./Functions/Procesar_incendio.R")

# SETEAR PARÁMETROS: 
nbr_dir <- "./Outputs/GEE/dNBR.tif"
output_dir <- "./Outputs/R_procesamiento_incendio/"


# Señalar el área a procesar con un polígono en SHAPE > Más chico == más preciso y rápido
poligono <- "./Inputs/Area_incendio_Alerces.shp"  

umbral <- 100            # Umbral de área quemada (>100 es quemado según USGS)
area_min <- 15000        # Eliminar ruido. Polígonos menores a un umbral de superficie en m2. Ej. 15000m2 = 1.5ha


# Correr la función (puede demorar 1 o 2 min):
Sups <- procesar_incendio(nbr_dir = nbr_dir,
                          output_dir = output_dir,
                          poligono = poligono, 
                          umbral = umbral,
                          area_min = area_min)

Sups

# Guardar tabla de superficies de clases USGS
write.csv2(Sups, paste0(output_dir, "Sups_x_claseSeveridad.csv"), row.names = TRUE)

            