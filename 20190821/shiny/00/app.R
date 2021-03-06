library(shiny)
library(plotly)

# a tidy dataset of reactions outcomes for 1000 most common drugs
outcomes <- readRDS("data/outcomes-tidy.rds")

ui <- fluidPage(
  selectInput(
    "drug", "Select drug(s)", 
    choices = unique(outcomes$drug), 
    selected = "oxycodone",
    multiple = TRUE
  ),
  plotlyOutput("p")
)

server <- function(input, output, session) {
  
  output$p <- renderPlotly({
    outcomes %>%
      filter(drug %in% input$drug) %>%
      plot_ly() %>%
      add_bars(
        x = ~reaction,
        y = ~count,
        color = ~drug
      )
  })
  
}

shinyApp(ui, server)