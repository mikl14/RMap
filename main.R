library(leaflet)
library(dplyr)
library(sf)


source("shpSaveData.R")

# Параметры для функции
shapefile_path <- "admin_4.shp"
data_csv_path <- "reg.csv"

# Загружаем данные о регионах (например, из GeoJSON файла или shapefile)
# Здесь предполагается, что у вас есть файл с геоданными регионов
regions <- st_read("admin_4.shp")


# Чтение шейп-файла
shapefile <- st_read(shapefile_path)

# Чтение данных о популяции из CSV файла
read_data <- read.csv2(data_csv_path)

shapefile_with_population <- shapefile %>%
  left_join(read_data, by = c("ref" = "id"))


shapefile_with_population$population <- as.numeric(shapefile_with_population$data)

# Проверка на наличие значений
if (length(unique(shapefile_with_population$population)) > 0) {
  # Определяем палитру для цветов на основе населения
  pal <- colorNumeric(palette = "YlOrRd", domain = shapefile_with_population$population)
  
  # Создаем интерактивную карту
  map <- leaflet(data = shapefile_with_population) %>%
    addTiles() %>%  # Добавляем базовый слой карты
    setView(lng = mean(st_coordinates(shapefile_with_population)[,1]), lat = mean(st_coordinates(shapefile_with_population)[,2]), zoom = 6) %>%
    addPolygons(fillColor = ~pal(data),  # Задаем цвет заливки на основе населения
                weight = 1,
                opacity = 1,
                color = 'white',
                dashArray = '3',
                fillOpacity = 0.7,
                highlightOptions = highlightOptions(weight = 2, color = 'black', fillOpacity = 0.7),
                label = ~paste(name, "<br>Индекс плешивых собак 2024г: ", data),  # Всплывающая подсказка
                labelOptions = labelOptions(style = list('font-weight' = 'normal', padding = '3px 8px'),
                                            textsize = '15px',
                                            direction = 'auto')) %>%
    addLegend(pal = pal, values = ~data, opacity = 0.7, title = "Индекс плешивых собак 2024г", position = "bottomright")
  
  # Отображаем карту
  map
} else {
  print("Нет доступных данных для отображения.")
}