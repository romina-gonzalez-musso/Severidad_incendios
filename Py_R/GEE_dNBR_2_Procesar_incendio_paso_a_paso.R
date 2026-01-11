### -------------------------------- ######
#       Perímetro de incendio
#       Clases de severidad
#       Cálculo de superficies
# 
# Versión: RGM Enero 2026 - simplificada
### -------------------------------- ######

library("terra")
library("sf")
library("dplyr")
library("raster")
library("tidyterra")


# --- Área quemada -------------------------------
dNBR <- rast("./Outputs/GEE/dNBR.tif")
poligono <- vect("./Inputs/Area_incendio_Alerces.shp") 

# Enmascarar al polígono y reproyectar
dNBR <- crop(dNBR, poligono)
dNBR <- mask(dNBR, poligono)
dNBR <- project(dNBR, "EPSG:22181")

# Umbral USGS quemado vs. no quemado
umbral <- 100
burned <- dNBR > umbral
burned <- burned %>% filter(nd == TRUE)

# Plot
par(mfrow=c(1,2))    
plot(dNBR, main = "NBR", col = grey.colors(15), legend = FALSE)
plot(burned, main = "Área quemada", legend = FALSE, col = "red")

# --- Perímetro -------------------------------
# Identificar parches conectados  - Esto demora así que acotar al área de incendio
# Asigna un ID a cada polígono quemado contiguo
patch <- patches(burned, directions = 8)

# Poligonizar
perimeter <- as.polygons(patch, dissolve = TRUE)
perimeter <- st_as_sf(perimeter)

# Calcular la superficie de cada polígono
perimeter <- perimeter %>%  
  mutate(area = st_area(perimeter))

# Eliminar polígonos sueltos (ruido) 
area_min <- 15000  # En m2
perimeter$sup <- as.numeric(perimeter$area)
perimeter <- subset(perimeter, sup > area_min) 

# Graficar
par(mfrow=c(1,1))
plot(dNBR, col = grey.colors(10), legend = FALSE)
plot(perimeter$geometry, col = (col=rgb(1, 0, 0, 0.2)), add = TRUE)

# Ver la superficie del incendio
sup_incendio <- as.numeric(sum(perimeter$area)/10000)
print(paste0("La superficie del incendio es ", round(sup_incendio,1), " hectáreas"))

rm(patch, burned)

# --- CLASIFICACIÓN DE SEVERIDAD USGS (dNBR) -------------------------------
# Recortar y enmascarar al perímetro del incendio
nbr_f1_crop <- mask(dNBR, vect(perimeter)) %>% 
  crop(vect(perimeter))

# Rangos y etiquetas de clasificación USGS
class_matrix <- matrix(c(
  -Inf, -500, NA,     # NA
  -500, -251, 1,      # 1 - Enhanced Regrowth, High
  -251, -101, 2,      # 2 - Enhanced Regrowth, Low
  -101, 99, 3,        # 3 - Unburned
  99, 269, 4,         # 4 - Low Severity
  269, 439, 5,        # 5 - Moderate-low Severity
  439, 659, 6,        # 6 - Moderate-high Severity
  659, 1300, 7,       # 7 - High Severity
  1300, +Inf, NA      # NA
), ncol = 3, byrow = TRUE)


# Clasificación
nbr_class <- classify(nbr_f1_crop, class_matrix, include.lowest = TRUE)

# Definir etiquetas y colores (mapeo fijo)
labels_usgs <- c(
  "1-Enhanced Regrowth, High",
  "2-Enhanced Regrowth, Low",
  "3-Unburned",
  "4-Low Severity",
  "5-Moderate-low Severity",
  "6-Moderate-high Severity",
  "7-High Severity")

color_usgs <- c(
  "#7a8737",  # 1 - Enhanced Regrowth, High
  "#acbe4d",  # 2 - Enhanced Regrowth, Low
  "#0ae042",  # 3 - Unburned
  "#fff70b",  # 4 - Low Severity
  "#ffaf38",  # 5 - Moderate-low Severity
  "#ff641b",  # 6 - Moderate-high Severity
  "#a41fd6")  # 7 - High Severity


# Detectar categorías presentes en el raster
present_ids <- sort(unique(na.omit(values(nbr_class))))

# Filtrar etiquetas y colores solo para las clases presentes
labels_present <- labels_usgs[present_ids]
colors_present <- color_usgs[present_ids]

# Plot limpio
plot(nbr_class, col = colors_present, axes = FALSE, legend = FALSE,
     main = "Severidad del incendio (USGS - dNBR)")
legend("topleft", inset = c(-0.05, 0), legend = labels_present, 
       fill = colors_present, cex = 0.75, bty = "n", xpd = TRUE)

# Limpiar
rm(class_matrix, color_usgs, present_ids, labels_present, colors_present)

##### Calcular superficies ------
# Poligonizar la clasificación (puede tardar un par de minutos)
class_usgs <- nbr_class %>%
  as.polygons(.) %>%    # Del paquete terra
  st_as_sf(.) %>%       # Convertir a SF
  st_cast(.,"POLYGON")  # Multipolygon a Simpleparts

# Eliminar categorías de "no quemado"
class_usgs <- subset(class_usgs, class_usgs$nd != "1-Enhanced Regrowth, High" & 
                       class_usgs$nd != "2-Enhanced Regrowth, Low" & 
                       class_usgs$nd != "3-Unburned")

# Calcular superficie por categoría
class_usgs_f1 <-  st_transform(class_usgs, crs = 22181) # POSGAR F1

# Agregar la columna de superficie en m2
class_usgs_f1 <- class_usgs_f1 %>% 
  mutate(area_m2 = st_area(class_usgs_f1))

# Agregar columna de superficie en ha
class_usgs_f1$area_ha <- units::set_units(class_usgs_f1$area, ha)

## Superficie total incendio obtenida de la clasificación USGS 
sup_incendio_USGS <- sum(class_usgs_f1$area_ha)

print(paste0("Perímetro: ", round(sup_incendio,1), 
             " USGS: ", round(sup_incendio_USGS,1)))

##### Tabla de superficies por clase de severidad ----
Sups <- aggregate(class_usgs_f1$area_ha, list(class_usgs_f1$nd), FUN=sum) 
colnames(Sups) <- c("Cat_num", "Sup_ha")

Sups <- Sups %>%
  mutate(Cat_num = Cat_num, 
    Categoria = factor(Cat_num, levels = 4:7, labels = labels_usgs[4:7]),
    Percentage = Sup_ha / sum(Sup_ha) * 100) %>%
  mutate(across(where(is.numeric), ~ round(.x, 2))) %>%
  select(Cat_num, Categoria, Sup_ha, Percentage)


Sups

rm(class_usgs)

# GUARDAR PRODUCTOS -------------------------
out_dir <- "./Outputs/R_procesamiento_incendio/"

# Perímetro del incendio
perimeter_f1 <- vect(perimeter)
writeVector(perimeter_f1, paste0(out_dir, "perimetro_f1_Alerces.shp"), overwrite = TRUE)

# dNBR
# writeRaster(dNBR, paste0(out_dir, "dNBR.tif"), overwrite = TRUE)

# dNBR en Faja 1 cortado al área de incendio
writeRaster(nbr_f1_crop, paste0(out_dir, "dNBR_croped_f1_Alerces.tif"))

# dNBR en Faja 1 cortado al área de incendio y clasificado USGS
writeRaster(nbr_class, paste0(out_dir, "dNBR_classified_Alerces.tif"))

# Guardar tabla de superficies de clases USGS
write.csv2(Sups, paste0(out_dir, "Sups_x_claseSeveridad.csv"), row.names = TRUE)

