### --------------------------------------------------------- ######
#    Delimitación de áreas con potencial regeneración natural
#                       
# Input: dNBR clasificado, clasif CIEFAP y perimetro (.shp)
# Versión: RGM Julio 2025
### -------------------------------------------------------- ######

potRegNatural <- function(dir_dNBR, dir_perimetro, dir_clasif_ciefap, output_dir, 
                          semilleros = c("Ci", "Co", "Le"), 
                          clases_severidad_baja = c(4, 5), buffer_dist = 30) {
  
  # Librerías
  library(terra)
  library(dplyr)
  library(tidyterra)
  
  # Assets
  perimetro <- vect(dir_perimetro)
  
  clasif_ciefap <- vect(dir_clasif_ciefap) %>%
    terra::project(., "EPSG:22181") 
  
  clasif_ciefap <- crop(clasif_ciefap, perimetro) # Cortar al perímetro de incendio
  
  NBR <- rast(dir_dNBR) %>%
    terra::project(., "EPSG:22181")
  
  # Seleccionar Tipos bosques semilleros (Ci, Co, Le)
  semilleros <- clasif_ciefap %>%
    filter(Ley_N2 %in% c("Ci", "Co", "Le"))
  
  # Enmascarar el raster seleccionando clases 4 y 5 -----------
  # Clase 4 = Baja severidad / Clase 5 = Moderado-bajo
  clases_severidad_baja <- c(4, 5)
  
  severidad_baja <- ifel(NBR %in% clases_severidad_baja, NBR, NA)
  
  # Extraer zonas de severidad baja/moderada dentro de semilleros ----
  semilleros_severidad_baja <- mask(severidad_baja, semilleros)
  semilleros_severidad_baja <- as.polygons(semilleros_severidad_baja) 
  
  # Asignar los tipos ftales
  semilleros_severidad_baja <- terra::intersect(semilleros_severidad_baja, semilleros) %>%
    select(Ley_N2, legend)
  
  # Buffer 30m 
  buffer_dist <- 30
  buffer <- buffer(semilleros_severidad_baja, width = buffer_dist)
  
  # Regeneracion potencial: disolver a un único polígono
  regen_potencial <- aggregate(buffer)
  # Perdida potencial: semilleros - regeneración
  perdida_potencial <- erase(semilleros, regen_potencial)
  
  # Calcular superficies (en ha)
  regen_potencial$area_ha <- expanse(regen_potencial, unit = "ha")
  perdida_potencial$area_ha <- expanse(perdida_potencial, unit = "ha")
  
  # GUARDAR VECTORES --------------------
  writeVector(semilleros, paste0(output_dir, "1_semilleros.shp"), overwrite = TRUE)
  writeVector(semilleros_severidad_baja,  paste0(output_dir,"2_semilleros_baja_severidad.shp"), overwrite = TRUE)
  writeVector(regen_potencial, paste0(output_dir, "3_regeneracion_pot.shp"), overwrite = TRUE)
  writeVector(perdida_potencial, paste0(output_dir, "4_perdida_pot.shp"), overwrite = TRUE)
  
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
  
  Sups <- data.frame(Clase = c("Regeneración potencial", "Pérdida potencial"), 
                     Sup_ha = c(regen_potencial$area_ha, sum(perdida_potencial$area_ha)))
  
  
  return(as.data.frame(Sups))
  
  
  
}
  
