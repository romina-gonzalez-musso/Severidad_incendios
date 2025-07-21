### ------------------------------------------------------------ ######
# Perímetro de incendio - Clases de severidad - Cálculo de superficie
# Input: el dNBR en formato .tif
# 
# Versión: RGM Julio 2025
### ------------------------------------------------------------- ######

procesar_incendio <- function(nbr_dir, output_dir, buffer_size = 200, 
                              n_poligonos = 2, umbral = 100, coords = NULL) {
  
  # Librerías
  library(terra)
  library(sf)
  library(dplyr)
  library(raster)
  
  # Proyectar (en ese caso a F1)
  dNBR <- rast(nbr_dir)
  dNBR <- project(dNBR, "EPSG:22181")
  
  # Clasificar área quemada vs. no quemada
  burnedArea_rast <- classify(dNBR, cbind(-Inf, umbral, NA))
  burnedArea_rast <- classify(burnedArea_rast, cbind(umbral, Inf, 1))
  
  # OBTENER PERÍMETRO DEL INCENDIO
  # Poligonizar y seleccionar polígonos de mayor tamaño
  burnedArea_vect <- burnedArea_rast %>%
    as.polygons() %>%
    st_as_sf() %>%
    st_cast("POLYGON")
  
  burnedArea_vect_max <- burnedArea_vect %>%
    mutate(area = st_area(.)) %>%
    slice_max(area, n = n_poligonos)
  
  # Buffer (demora un poco) / 200 metros de buffer (puede variar)
  buffer <- buffer(vect(burnedArea_vect_max), buffer_size)
  buffer <- aggregate(buffer, dissolve = TRUE)
  
  # Separar polígonos que quedan luego de aggregate
  sf_buf <- st_as_sf(buffer)
  # Une todos los polígonos en una sola geometría y separar en partes individuales
  separated <- st_cast(st_union(sf_buf), "POLYGON") |> st_as_sf()
  
  buffer <- vect(separated)
  
  # Opcional: indicar coordenada para seleccionar el polígono de incendio
  if (!is.null(coords)) {
    pt <- vect(coords, geom = c("x", "y"), crs = crs(buffer))
    buffer <- buffer[rowSums(relate(buffer, pt, "intersects")) > 0, ]
  }
  
  # Seleccionar todos los polígonos (píxeles) quemados del área buffer de incendio
  perimeter_f1 <- terra::mask(burnedArea_rast, buffer) %>%
    terra::crop(buffer) %>%
    as.polygons() %>%
    st_as_sf() %>%
    st_cast("POLYGON") %>%
    mutate(area = st_area(.), sup = as.numeric(area)) %>%
    subset(sup > 10000) # Eliminar polígonos sueltos (ruido) < a 10.000m2 de superficie
  
  # Calcular la superficie de cada polígono
  sup_incendio <- sum(perimeter_f1$sup) / 10000
  
  nbr_f1_crop <- terra::mask(dNBR, vect(perimeter_f1)) %>%
    terra::crop(vect(perimeter_f1))
  
  
  # CLASES DE SEVERIDAD USGS 
  ##### Clasificar el raster dNBR por clases de severidad USGS 
  NBR_ranges <- c(-Inf, -500, -1,  # NA
                  -500, -251, 1,   # 1 - Enhanced Regrowth, High
                  -251, -101, 2,   # 2 - Enhanced Regrowth, Low
                  -101, 99, 3,     # 3 - Unburned
                  99, 269, 4,      # 4 - Low Severity
                  269, 439, 5,     # 5 - Moderate-low Severity
                  439, 659, 6,     # 6 - Moderate-high Severity
                  659, 1300, 7,    # 7 - High Severity
                  1300, +Inf, -1)  # NA
  
  
  # Rangos de clasificación de Severidad USGS
  class.matrix <- matrix(NBR_ranges, ncol = 3, byrow = TRUE)
  my_col <- c("#ffffff", "#7a8737", "#acbe4d", "#0ae042",
              "#fff70b", "#ffaf38", "#ff641b", "#a41fd6")
  
  # Armar la legenda con las clases USGS
  nbr_class <- classify(nbr_f1_crop, class.matrix, right=NA)
  nbr_class <- ratify(raster(nbr_class))
  rat <- levels(nbr_class)[[1]]
  
  # Ponerle texto a cada categoría del -1 al 7
  rat$legend <- c("NA", "1-Enhanced Regrowth, High", "2-Enhanced Regrowth, Low", 
                  "3-Unburned", "4-Low Severity", "5-Moderate-low Severity", 
                  "6-Moderate-high Severity", "7-High Severity")
  levels(nbr_class) <- rat
  nbr_class <- rast(nbr_class)
  
  
  ##### Calcular superficies ------
  # Poligonizar la clasificación (puede tardar un par de minutos)
  class_usgs <- nbr_class %>%
    as.polygons() %>%
    st_as_sf() %>%
    st_cast("POLYGON") %>%
    # Eliminar categorías de "no quemado"
    subset(!(nd %in% c("1-Enhanced Regrowth, High", 
                       "2-Enhanced Regrowth, Low", "3-Unburned")))
  
  # Calcular superficie por categoría
  class_usgs_f1 <- st_transform(class_usgs, crs = 22181)
  class_usgs_f1 <- class_usgs_f1 %>%
    mutate(area_m2 = st_area(.),
           area_ha = units::set_units(area_m2, ha))
  
  ## Superficie total incendio obtenida de la clasificación USGS 
  sup_incendio_USGS <- sum(class_usgs_f1$area_ha)
  
  
  ##### Tabla de superficies por clase de severidad ----
  Sups <- aggregate(class_usgs_f1$area_ha, list(class_usgs_f1$nd), FUN=sum)
  colnames(Sups) <- c("Categoría", "Sup_ha")
  Sups <- Sups %>%
    mutate(Percentage = Sup_ha/sum(Sup_ha)*100) %>%
    mutate_if(is.numeric, ~round(., 2))
  
  # Mostrar resultados
  print(paste0("Perímetro vectorial: ", round(sup_incendio,1), 
               " USGS: ", round(sup_incendio_USGS,1)))
  
  
  # Guardar productos
  writeVector(vect(perimeter_f1), paste0(output_dir, "perimetro_f1.shp"), overwrite = TRUE)
  writeRaster(nbr_f1_crop, paste0(output_dir, "dNBR_croped_f1.tif"), overwrite = TRUE)
  writeRaster(nbr_class, paste0(output_dir, "dNBR_classified.tif"), overwrite = TRUE)
  
  
  # EXPORTAR GRAFICOS
  png(filename = paste0(output_dir, "1_Umbral_area_quemada.png"), width = 2500, height = 1500, res = 300)
  par(mfrow=c(1,2))    
  plot(dNBR, main = "NBR", col = grey.colors(15), legend = FALSE)
  plot(burnedArea_rast, main = "Área quemada", legend = FALSE, col = "red")
  dev.off()
  
  png(filename = paste0(output_dir, "2_Poligonos_area_quemada.png"), width = 2500, height = 1500, res = 300)
  par(mfrow=c(1,1))
  plot(burnedArea_rast, legend = FALSE)
  if (!is.null(coords)) {
    plot(pt, add = TRUE)
  }
  plot(buffer, add = TRUE)
  dev.off()
  
  png(filename = paste0(output_dir, "3_Perimetro_incendio.png"), width = 2500, height = 1500, res = 300)
  par(mfrow=c(1,1))
  plot(dNBR, col = grey.colors(10), legend = FALSE)
  plot(perimeter_f1$geometry, col = (col=rgb(1, 0, 0, 0.2)), add = TRUE)
  dev.off()
  
  png(filename = paste0(output_dir, "4_Clasif_USGS_Sevedidad.png"), width = 2500, height = 1500, res = 300)
  plot(nbr_class, col = my_col, main = "Clasif. USGS Sevedidad (dNBR)")
  dev.off()
  
  return(as.data.frame(Sups))
}