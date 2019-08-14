library(shiny)
library(DT)

# a tidy dataset of reactions outcomes for 1000 most common drugs
outcomes <- readRDS("data/outcomes-tidy.rds")

ui <- fluidPage(
  dataTableOutput("dt"),
  verbatimTextOutput("cell_click")
)

server <- function(input, output, session) {
  
  output$dt <- renderDataTable({
    outcomes
  })
  
  output$cell_click <- renderPrint({
    input$dt_cell_clicked
  })
  
}

shinyApp(ui, server)