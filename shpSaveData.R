library(sf)
library(dplyr)

# Функция для обработки шейп-файла и добавления данных о популяции
save_shapefile_with_population <- function(shapefile_path, population_csv_path, output_path) {
  # Чтение шейп-файла
  shapefile <- st_read(shapefile_path)
  
  # Чтение данных о популяции из CSV файла
  population_data <- read.csv(population_csv_path)
  
  # Объединение данных по региону
 # shapefile_with_population <- shapefile %>%
  #  left_join(population_data, by = "region_id")
  
  # Добавление нового столбца 'population'
  #shapefile_with_population <- shapefile_with_population %>%
   # mutate(population = ifelse(is.na(population), 0, population)) # Замена NA на 0
  
  # Сохранение обновленного шейп-файла
  #st_write(shapefile_with_population, output_path)
}
