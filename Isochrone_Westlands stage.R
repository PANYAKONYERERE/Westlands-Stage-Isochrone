pacman::p_load(httr,
               jsonlite,
               leaflet,
               sf,
               geojsonio,
               dplyr,
               htmlwidgets)

# Replace with your ORS API key
api_key <- "5b3ce3597851110001cf6248927a9c84f2074877b3bab0a355af1065"

# Coordinates of Westlands Stage, Nairobi
location <- list(36.8111, -1.2648)  # [lon, lat]

# Travel times in seconds: 5, 10, 15 minutes
intervals <- c(300, 600, 900)

url <- "https://api.openrouteservice.org/v2/isochrones/foot-walking"

body <- list(
  locations = list(location),
  range = intervals,
  range_type = "time",
  attributes = list("area"),
  units = "m"
)

response <- POST(
  url,
  add_headers("Authorization" = api_key, "Content-Type" = "application/json"),
  body = toJSON(body, auto_unbox = TRUE)
)

# Converting response to SF object
iso_sf <- st_read(content(response, "text"), quiet = TRUE)




pal <- colorFactor(c("#66c2a5", "#fc8d62", "#8da0cb"), domain = iso_sf$value)

leaflet() %>%
  addTiles() %>%
  addPolygons(data = iso_sf, color = ~pal(value), weight = 2, fillOpacity = 0.5) %>%
  addMarkers(lng = location[[1]], lat = location[[2]], popup = "Westlands Stage") %>%
  addLegend("bottomright", pal = pal, values = iso_sf$value,
            title = "Walking Time (seconds)",
            labFormat = labelFormat(suffix = " sec"))




my_map <- leaflet() %>%
  addTiles() %>%
  addPolygons(data = iso_sf, color = ~pal(value), weight = 2, fillOpacity = 0.5) %>%
  addMarkers(lng = location[[1]], lat = location[[2]], popup = "Westlands Stage") %>%
  addLegend("bottomright", pal = pal, values = iso_sf$value,
            title = "Walking Time (seconds)",
            labFormat = labelFormat(suffix = " sec"))

# Save. I added this so as to save the html file
saveWidget(my_map, file = "nairobi_isochrone_map.html", selfcontained = TRUE)

