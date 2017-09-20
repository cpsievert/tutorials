library(sf)
library(dplyr)
library(albersusa)
library(plotly)

usa <- usa_sf("laea")

# st_centroid gets the center POINT of polygons
uscenter <- st_centroid(usa)

# solution to (1)
ggplot() + 
  geom_sf(data = usa) +
  geom_sf(data = uscenter)

uscoord <- st_coordinates(uscenter)
# ggplot2 likes data frames, not matrices
class(uscoord)
ustext <- mutate(as.data.frame(uscoord), name = usa$name)

# solution to (2)
ggplot() + 
  geom_sf(data = usa) +
  geom_text(data = ustext, aes(X, Y, label = name))


# Pro tip: swap out geom_text() for ggrepel::geom_text_repel()
# Unfortunately, ggplotly() doesn't (yet) support it, hopefully soon!
ggplot() + 
  geom_sf(data = usa) +
  ggrepel::geom_text_repel(data = ustext, aes(X, Y, label = name))



# BONUS: add text *on click*!!
library(crosstalk)
ustxt <- SharedData$new(ustext)
p <- ggplot() + 
  geom_sf(data = usa, aes(fill = pop_2010, text = paste("Population", pop_2010))) +
  geom_text(
    data = ustxt, alpha = 0,
    aes(X, Y, label = name, text = "Click to label me")
  )

ggplotly(p, tooltip = "text") %>%
  highlight(
    persistent = TRUE, 
    selected = attrs_selected(
      hoverinfo = "none",
      textfont = list(color = "black")
    )
  )

# produces this...
browseURL("https://cloud.githubusercontent.com/assets/1365941/25501881/f816c3d8-2b59-11e7-98e1-fcd94877d584.gif")
