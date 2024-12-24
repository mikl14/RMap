library(leaflet)
library(dplyr)
library(sf)

# Загружаем данные о регионах (например, из GeoJSON файла или shapefile)
# Здесь предполагается, что у вас есть файл с геоданными регионов
regions <- st_read("admin_4.shp")

regions$population <- as.numeric(regions$population)
regions <- na.omit(regions)  # Удаляем строки с NA значениями

# Проверка на наличие значений
if (length(unique(regions$population)) > 0) {
  # Определяем палитру для цветов на основе населения
  pal <- colorNumeric(palette = "YlOrRd", domain = regions$population)
  
  # Создаем интерактивную карту
  map <- leaflet(data = regions) %>%
    addTiles() %>%  # Добавляем базовый слой карты
    setView(lng = mean(st_coordinates(regions)[,1]), lat = mean(st_coordinates(regions)[,2]), zoom = 6) %>%
    addPolygons(fillColor = ~pal(population),  # Задаем цвет заливки на основе населения
                weight = 1,
                opacity = 1,
                color = 'white',
                dashArray = '3',
                fillOpacity = 0.7,
                highlightOptions = highlightOptions(weight = 2, color = 'black', fillOpacity = 0.7),
                label = ~paste(name, "<br>Population: ", population),  # Всплывающая подсказка
                labelOptions = labelOptions(style = list('font-weight' = 'normal', padding = '3px 8px'),
                                            textsize = '15px',
                                            direction = 'auto')) %>%
    addLegend(pal = pal, values = ~population, opacity = 0.7, title = "Population", position = "bottomright")
  
  # Отображаем карту
  map
} else {
  print("Нет доступных данных для отображения.")
}