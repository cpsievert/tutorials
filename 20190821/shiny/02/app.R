library(shiny)
library(plotly)
library(dplyr)

# a tidy dataset of reactions outcomes for 1000 most common drugs
outcomes <- readRDS("data/outcomes-tidy.rds")
# Top 6 Principal Component scores for each drug
outcome_pca <- readRDS("data/pca-scores.rds")

ui <- fluidPage(
  p("Clicking on the points below prints info about the particular point."), 
  p(tags$b("Your turn:")),
  p("1. Modify the click output to display all the ", tags$code("outcomes"), " data for the clicked drug."),
  p("2. Modify the click output again, this time to display bar chart of ", tags$code("reaction"), " counts for the clicked drug."),
  plotlyOutput("p"),
  verbatimTextOutput("click")
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
  
  output$click <- renderPrint({
    event_data("plotly_click")
  })
  
}

shinyApp(ui, server)