library(leaflet)
library(dplyr)
library(sf)
library(RPostgres)
library(DBI)

con <- dbConnect(RPostgres::Postgres(), 
                 dbname = "map",
                 host = "localhost",
                 port = 5432,
                 user = "postgres",
                 password = "schef2002")

# Выполнение SQL-запроса
query <- "select code, count(*) from regions_all JOIN map_regions_codes ON LEFT(regions_all.okatof,2) = map_regions_codes.id JOIN coffers2024.yan_september_15_10 ON coffers2024.yan_september_15_10.inn = regions_all.inn group by code"
result <- dbGetQuery(con, query)


regions <- st_read("admin_4.shp")


shapefile_with_count <- regions %>%
  left_join(result, by = c("ISO3166.2" = "code"))

shapefile_with_count <- shapefile_with_count %>%
  filter(!is.na(count))

shapefile_with_count$count <- as.numeric(shapefile_with_count$count)

# Проверка на наличие значений
if (length(unique(shapefile_with_count$count)) > 0) {
  # Определяем палитру для цветов на основе населения
  # Установка палитры для цветового отображения на основе значений count
  bins <- c(0,20000, 50000, 100000, 300000, 500000, 800000,1000000,1500000)
  pal <- colorBin(palette = "Blues", domain = shapefile_with_count$count , bins=bins, na.color = "transparent")
  
  # Создаем интерактивную карту
  map <- leaflet(data = shapefile_with_count) %>%
    addTiles() %>%  # Добавляем базовый слой карты
    setView(lng = mean(st_coordinates(shapefile_with_count)[,1]), 
            lat = mean(st_coordinates(shapefile_with_count)[,2]), 
            zoom = 6) %>%
    addPolygons(fillColor = ~pal(count),  # Задаем цвет заливки на основе count
                weight = 1,
                opacity = 1,
                color = 'white',
                dashArray = '3',
                fillOpacity = 0.7,
                highlightOptions = highlightOptions(weight = 2, color = 'black', fillOpacity = 0.7),
                label = ~paste(name, "Хозяйствующие субъекты платившие налоги в период с 01.2024 по 09.2024: ", count),  # Всплывающая подсказка
                labelOptions = labelOptions(style = list('font-weight' = 'normal', padding = '3px 8px'),
                                            textsize = '15px',
                                            direction = 'auto')) %>%
    addLegend(pal = pal, values = ~count, opacity = 0.7, title = "Хозяйствующие субъекты платившие налоги в период с 01.2024 по 09.2024: ", position = "bottomright")
  
  # Отображаем карту
  map
  
} else {
  print("Нет доступных данных для отображения.")
}