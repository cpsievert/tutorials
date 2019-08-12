library(shiny)
library(plotly)
library(dplyr)

# a tidy dataset of reactions outcomes for 1000 most common drugs
outcomes <- readRDS(here::here("data", "outcomes-tidy.rds"))

# Top 6 Principal Component scores for each drug
outcome_pca <- readRDS(here::here("data", "pca-scores.rds"))

ui <- fluidPage(
  plotlyOutput("p"),
  plotlyOutput("click")
)

server <- function(input, output, session) {
  
  output$p <- renderPlotly({
    outcome_pca %>%
      plot_ly(
        x = ~Comp.2, y = ~Comp.1, customdata = ~drug,
        text = ~drug, hoverinfo = "text"
      ) %>% 
      add_markers()
  })
  
  output$click <- renderPlotly({
    d <- event_data("plotly_click")$customdata
    if (is.null(d)) return(NULL)
    outcomes %>%
      filter(drug %in% d) %>%
      plot_ly() %>%
      add_bars(x = ~reaction, y = ~count) %>%
      layout(title = d)
  })
  
}

shinyApp(ui, server)