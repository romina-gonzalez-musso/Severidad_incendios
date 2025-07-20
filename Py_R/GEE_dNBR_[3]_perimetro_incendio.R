### -------------------------------- ######
#      Perímetro de incendio
#      Clases de severidad
#      Cálculo de superficies
# 
# Versión: RGM Julio 2025
### -------------------------------- ######

# Nota: el insumo es un .tif de dNBR escalado a USGS 
# Sale del código GEE_dNBR de python

# LIBRERIAS -------------------------------------------------
library("terra")
library("sf")
library("dplyr")
library("raster")

# TRAER EL dNBR --------------------------------------------
dNBR <- rast("/home/romina/Descargas/2025-08_Taller_APN_Severidad_incendios/Outputs/GEE/dNBR.tif")

# Proyectar (en ese caso a F1)
dNBR <- project(dNBR, "EPSG:22181")

# PERÍMETRO ÁREA QUEMADA ------------------------------------
# Definir umbral de corte entre área quemada
umbral <- 100

# Clasificar área quemada vs. no quemada
burnedArea_rast <- classify(dNBR, cbind(-Inf, umbral, NA))        # Valores entre -Inf y el umbral = NA
burnedArea_rast <- classify(burnedArea_rast, cbind(umbral, Inf, 1)) # Valores mayores al umbral = Quemados

# Plot
par(mfrow=c(1,2))    
plot(dNBR, main = "NBR", col = grey.colors(15), legend = FALSE)
plot(burnedArea_rast, main = "Área quemada", legend = FALSE, col = "red")

# Poligonizar y seleccionar polígonos de mayor tamaño
burnedArea_vect <- burnedArea_rast %>%
  as.polygons(.) %>%    # Del paquete terra
  st_as_sf(.) %>%       # Convertir a SF
  st_cast(.,"POLYGON")  # Multipolygon a Simpleparts

burnedArea_vect_max <- burnedArea_vect %>%
  mutate(area = st_area(burnedArea_vect)) %>% 
  slice_max(area, n = 4) # Seleccionar los dos polígonos de mayor tamaño

# Buffer (demora un poco) / 200 metros de buffer (puede variar)
buffer <- buffer(vect(burnedArea_vect_max), 200) 
buffer <- aggregate(buffer, dissolve = TRUE) # Disuelve polígonos que solapan

rm(burnedArea_vect_max, burnedArea_vect, umbral)

# Separar polígonos que quedan luego de aggregate
sf_buf <- st_as_sf(buffer)
# Une todos los polígonos en una sola geometría
multi <- st_union(sf_buf) 
# Separar en partes individuales
separated <- st_cast(multi, "POLYGON") |> st_as_sf()
# Vuelve a terra
buffer <- vect(separated)

# Graficar
par(mfrow=c(1,1))
plot(burnedArea_rast, legend = FALSE)
plot(buffer, add = TRUE)

# Opcional: indicar coordenada para seleccionar el polígono de incendio
coords <- data.frame(
  x = c(1522124.5, 1532410.9),
  y = c(5411404.6, 5398442.05))

# Coord a SpatVector
pt <- vect(coords, geom = c("x", "y"), crs = crs(buffer))
plot(pt, add = TRUE)

# Seleccionar polígonos que intersectan con al menos uno de los puntos
buffer <- buffer[rowSums(relate(buffer, pt, "intersects")) > 0, ]

# Graficar
par(mfrow=c(1,1))
plot(burnedArea_rast, legend = FALSE)
plot(buffer, add = TRUE)

rm(multi, pt, separated, sf_buf)

# Seleccionar todos los polígonos (píxeles) quemados del área buffer de incendio
perimeter_f1 <- terra::mask(burnedArea_rast, buffer) %>%
  terra::crop(., buffer) %>%
  as.polygons(.) %>%
  st_as_sf(.) %>%    
  st_cast(.,"POLYGON") 

# Calcular la superficie de cada polígono
perimeter_f1 <- perimeter_f1 %>%  
  mutate(area = st_area(perimeter_f1))

# Eliminar polígonos sueltos (ruido) < a 10.000m2 de superficie
perimeter_f1$sup <- as.numeric(perimeter_f1$area)
perimeter_f1 <- subset(perimeter_f1, sup > 10000)

# Graficar
par(mfrow=c(1,1))
plot(dNBR, col = grey.colors(10), legend = FALSE)
plot(perimeter_f1$geometry, col = (col=rgb(1, 0, 0, 0.2)), add = TRUE)

rm(buffer, col)

# Ver la superficie del incendio
sup_incendio <- as.numeric(sum(perimeter_f1$area)/10000)
print(paste0("La superficie del incendio es ", round(sup_incendio,1), " hectáreas"))

# CLASES DE SEVERIDAD USGS ------------------------------------
##### Clasificar el raster dNBR por clases de severidad USGS -----
nbr_f1_crop <- terra::mask(dNBR, vect(perimeter_f1)) %>%
  terra::crop(., vect(perimeter_f1))

plot(nbr_f1_crop, main = "dNBR recortado al área incendio", legend = FALSE) 

# Rangos de clasificación de Severidad USGS
NBR_ranges <- c(-Inf, -500, -1,  # NA
                -500, -251, 1,   # 1 - Enhanced Regrowth, High
                -251, -101, 2,   # 2 - Enhanced Regrowth, Low
                -101, 99, 3,     # 3 - Unburned
                99, 269, 4,      # 4 - Low Severity
                269, 439, 5,     # 5 - Moderate-low Severity
                439, 659, 6,     # 6 - Moderate-high Severity
                659, 1300, 7,    # 7 - High Severity
                1300, +Inf, -1)  # NA

# Matriz de clasificación
class.matrix <- matrix(NBR_ranges, ncol = 3, byrow = TRUE)

# Definir paleta de colores
my_col=c("#ffffff",      # -1 NA Values
         "#7a8737",      # 1 - Enhanced Regrowth, High
         "#acbe4d",      # 2 - Enhanced Regrowth, Low
         "#0ae042",      # 3 - Unburned
         "#fff70b",      # 4 - Low Severity
         "#ffaf38",      # 5 - Moderate-low Severity
         "#ff641b",      # 6 - Moderate-high Severity
         "#a41fd6")      # 7 - High Severity

nbr_class <- classify(nbr_f1_crop, class.matrix, right=NA)

plot(dNBR, col = grey.colors(10), legend = FALSE, main = "Severidad - Rangos USGS")
plot(nbr_class, col = my_col, add = TRUE, legend = FALSE)

# Armar la legenda con las clases USGS
nbr_class <- ratify(raster(nbr_class))
rat <- levels(nbr_class)[[1]]

# Ponerle texto a cada categoría del -1 al 7
rat$legend  <- c("NA", "1-Enhanced Regrowth, High", 
                 "2-Enhanced Regrowth, Low", "3-Unburned", 
                 "4-Low Severity", "5-Moderate-low Severity", 
                 "6-Moderate-high Severity", "7-High Severity") 

levels(nbr_class) <- rat

par(mar =  c(4, 2, 4, 8) + 0.1)
plot(nbr_class, col=my_col, legend=F,
     main = "Clases de severidad USGS") 
legend("right", inset = c(-0.30,0), legend =rat$legend, xpd = TRUE, 
       horiz = FALSE, fill = my_col, cex = 0.75)

nbr_class <- rast(nbr_class) # Pasar a Terra

rm(class.matrix, rat, my_col, NBR_ranges)

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
colnames(Sups) <- c("Categoría", "Sup_ha")

Sups <- Sups %>% 
  mutate(Percentage = Sup_ha/sum(Sup_ha)*100) %>% 
  mutate_if(is.numeric, ~round(., 2))

Sups

rm(class_usgs, burnedArea_rast)

# GUARDAR PRODUCTOS -------------------------
out_dir <- "/home/romina/Descargas/2025-08_Taller_APN_Severidad_incendios/Outputs/"

# Perímetro del incendio
perimeter_f1 <- vect(perimeter_f1)
writeVector(perimeter_f1, paste0(out_dir, "perimetro_f1.shp"), overwrite = TRUE)

# dNBR
# writeRaster(dNBR, paste0(out_dir, "dNBR.tif"), overwrite = TRUE)

# dNBR en Faja 1 cortado al área de incendio
writeRaster(nbr_f1_crop, paste0(out_dir, "dNBR_croped_f1.tif"))
# dNBR en Faja 1 cortado al área de incendio y clasificado USGS
writeRaster(nbr_class, paste0(out_dir, "dNBR_classified.tif"))

