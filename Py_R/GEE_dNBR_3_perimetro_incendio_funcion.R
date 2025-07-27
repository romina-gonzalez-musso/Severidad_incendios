### --------------------------------------------------- ######
#             FUNCIÓN PROCESAR INCENDIO
# Perímetro, clases de severidad y cálculo de superficies
# 
# Versión: RGM Julio 2025
### ------------------------------------------------- ######

# LLAMAR A LA FUNCIÓN
source("./Functions/Procesar_incendio.R")

# SETEAR PARÁMETROS: 
nbr_dir <- "./Outputs/GEE/dNBR.tif"
output_dir <- "./Outputs/R_procesamiento_incendio/"

umbral <- 100       # Umbral de área quemada (>100 es quemado según USGS)
buffer_size <- 200  # Buffer para buscar área quemada
n_poligonos <- 4    # Número de polígonos "grandes" para definir como polígonos de incendio


# Opcional: poner algunas coordenadas dentro del área de incendio
coords <- data.frame(
  x = c(1522124.5, 1532410.9),
  y = c(5411404.6, 5398442.05))


# Correr la función (puede demorar 1 o 2 min):
Sups <- procesar_incendio(nbr_dir = nbr_dir,
                          output_dir = output_dir, 
                          buffer_size = buffer_size, 
                          n_poligonos = n_poligonos,  
                          umbral = umbral,
                          coords = coords)



# Guardar tabla de superficies de clases USGS
write.csv2(Sups, paste0(output_dir, "Sups_x_claseSeveridad.csv"), row.names = TRUE)

            