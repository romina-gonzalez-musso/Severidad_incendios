### --------------------------------------------------------- ######
#    Delimitación de áreas con potencial regeneración natural
#
# Versión: RGM Julio 2025
### -------------------------------------------------------- ######

# Nota: el insumo es un .tif de dNBR con las clases USGS
# Y el mapa de tipos ftales del CIEFAP

# Seleccionar Tipos bosques semilleros (Ci, Co, Le)
# En severidad baja o moderada
# Calcular buffer 30m 
# Regeneración potencial = la suma de los buffer
# Pérdida potencial = todos los polígonos Ci-Co-Le menos la regeneración potencial. 

# LIBRERIAS ------------
library(terra)
library(dplyr)
library(tidyterra)

# TRAER LOS ASSETS -----------------------
dir_clasif_ciefap <- "./Inputs/clas_mer_BAP_continental_modentr_vf_rn.shp"
dir_dNBR <- "./Outputs/R_procesamiento_incendio/dNBR_classified.tif"
dir_perimetro <- "./Outputs/R_procesamiento_incendio/perimetro_f1.shp"

perimetro <- vect(dir_perimetro)

clasif_ciefap <- vect(dir_clasif_ciefap) %>%
  terra::project(., "EPSG:22181") 

clasif_ciefap <- crop(clasif_ciefap, perimetro) # Cortar al perímetro de incendio

NBR <- rast(dir_dNBR) %>%
  terra::project(., "EPSG:22181")

rm(dir_clasif_ciefap, dir_dNBR, dir_perimetro)

# Plot
plot(NBR)
plot(clasif_ciefap, lwd=0.7, add = TRUE)

# REGENERACION POTENCIAL -------------------------------------
# Seleccionar Tipos bosques semilleros (Ci, Co, Le) ---------
semilleros <- clasif_ciefap %>%
  filter(Ley_N2 %in% c("Ci", "Co", "Le"))

# Ver los polígonos seleccionados
plot(clasif_ciefap)
plot(semilleros, col = "yellow", add = TRUE)

# Enmascarar el raster seleccionando clases 4 y 5 -----------
# Clase 4 = Baja severidad / Clase 5 = Moderado-bajo
clases_severidad_baja <- c(4, 5)

severidad_baja <- ifel(NBR %in% clases_severidad_baja, NBR, NA)

plot(severidad_baja)

# Extraer zonas de severidad baja/moderada dentro de semilleros ----
semilleros_severidad_baja <- mask(severidad_baja, semilleros)
plot(semilleros_severidad_baja)

semilleros_severidad_baja <- as.polygons(semilleros_severidad_baja) 
plot(semilleros_severidad_baja)

# Asignar los tipos ftales
semilleros_severidad_baja <- terra::intersect(semilleros_severidad_baja, semilleros) %>%
  select(Ley_N2, legend)

# Buffer 30m (tarda un toque) -----------------
buffer_dist <- 30
buffer <- buffer(semilleros_severidad_baja, width = buffer_dist)

plot(buffer, col = "red")
plot(semilleros_severidad_baja, add = TRUE )

# Regeneracion potencial: disolver a un único polígono
regen_potencial <- aggregate(buffer)
plot(regen_potencial)

# Ver plot de regeneración
plot(perimetro)
plot(semilleros, col="black", add = TRUE)
plot(regen_potencial, col = "lightgreen", add = TRUE)

# Perdida potencial: semilleros - regeneración
perdida_potencial <- erase(semilleros, regen_potencial)

plot(perdida_potencial, col = "red", add = TRUE)

# Calcular superficies (en ha)
regen_potencial$area_ha <- expanse(regen_potencial, unit = "ha")
perdida_potencial$area_ha <- expanse(perdida_potencial, unit = "ha")

Sups <- data.frame(Clase = c("Regeneración potencial", "Pérdida potencial"), 
           Sup_ha = c(regen_potencial$area_ha, sum(perdida_potencial$area_ha)))


# PLOTS
# 1
my_col <- c("#ffffff", "#7a8737", "#acbe4d", "#0ae042",
            "#fff70b", "#ffaf38", "#ff641b", "#a41fd6")
plot(NBR, col = my_col)
plot(clasif_ciefap, lwd=0.7, add = TRUE,
     main = "dNBR y polígonos clasif CIEFAP")

# 2 Ver los polígonos seleccionados
plot(clasif_ciefap)
plot(semilleros, col = "yellow", add = TRUE, 
     main = "Polígonos tipos forestales semilleros")

# 3 Ver plot de regeneración
colores_grises <- gray.colors(7, start = 0.9, end = 0.1)  
plot(NBR, col = colores_grises, legend = FALSE,
     main = "Renegeración potencial vs. pérdida potencial")
plot(perimetro, add = TRUE, border = "black", col = NA, lwd = 1)
plot(regen_potencial, add = TRUE, col = adjustcolor("green", alpha.f = 0.5))
plot(perdida_potencial, add = TRUE, col = adjustcolor("red", alpha.f = 0.5))


# Crear panel 2x2
par(mfrow = c(2, 2), mar = c(4, 4, 3, 2))  # Ajustar márgenes

# --- PLOT 1 ---
my_col <- c("#ffffff", "#7a8737", "#acbe4d", "#0ae042",
            "#fff70b", "#ffaf38", "#ff641b", "#a41fd6")
plot(NBR, col = my_col, main = "dNBR y polígonos clasif CIEFAP")
plot(clasif_ciefap, lwd = 0.7, add = TRUE)

# --- PLOT 2 (vacío o personalizado) ---
my_col2 <- c("#0ae042","#ffaf38")
plot(severidad_baja, col = my_col2, main = "Severidad baja y moderada-baja")


# --- PLOT 3 ---
plot(clasif_ciefap, main = "Polígonos tipos forestales semilleros", lwd = 0.6)
plot(semilleros, col = "yellow", add = TRUE)

# --- PLOT 4 ---
colores_grises <- gray.colors(7, start = 0.9, end = 0.1)
plot(NBR, col = colores_grises, legend = FALSE,
     main = "Regeneración potencial vs. pérdida")
plot(perimetro, add = TRUE, border = "black", col = NA, lwd = 1)
plot(regen_potencial, add = TRUE, col = adjustcolor("green", alpha.f = 0.5), border = NA)
plot(perdida_potencial, add = TRUE, col = adjustcolor("red", alpha.f = 0.5), border = NA)


# GUARDAR VECTORES --------------------
writeVector(semilleros, "./Outputs/R_trayectorias_potenciales/1_semilleros.shp", overwrite = TRUE)
writeVector(semilleros_severidad_baja, "./Outputs/R_trayectorias_potenciales/2_semilleros_baja_severidad.shp", overwrite = TRUE)
writeVector(regen_potencial, "./Outputs/R_trayectorias_potenciales/3_regeneracion_pot.shp", overwrite = TRUE)
writeVector(perdida_potencial, "./Outputs/R_trayectorias_potenciales/4_perdida_pot.shp", overwrite = TRUE)

