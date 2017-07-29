library(leaflet)
library(crosstalk)
library(plotly)

sd <- SharedData$new(quakes)
stations <- filter_slider("station", "Number of Stations", sd, ~stations)

p <- plot_ly(sd, x = ~depth, y = ~mag) %>% 
  add_markers(alpha = 0.5) %>% 
  highlight("plotly_selected")

map <- leaflet(sd) %>% 
  addTiles() %>% 
  addCircles()

tags <- bscols(
  widths = c(6, 6, 3), 
  p, map, stations
)

# note, this also create a lib/ folder with dependencies needed to render the vis
htmltools::save_html(tags, file = "map.html")