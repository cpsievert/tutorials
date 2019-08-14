library(shiny)
library(plotly)
library(dplyr)

# a tidy dataset of reactions outcomes for 1000 most common drugs
outcomes <- readRDS("data/outcomes-tidy.rds")
# Top 6 Principal Component scores for each drug
outcome_pca <- readRDS("data/pca-scores.rds")

ui <- fluidPage(
  plotlyOutput("p"),
  verbatimTextOutput("click")
)

server <- function(input, output, session) {
  
  output$p <- renderPlotly({
    outcome_pca %>%
      plot_ly(
        x = ~Comp.2, y = ~Comp.1, customdata = ~drug,
        text = ~drug, hoverinfo = "text",
        color = ~I(ifelse(drug %in% selected_drugs(), "red", "black")),
        size = ~I(ifelse(drug %in% selected_drugs(), 30, 10))
      ) %>% 
      add_markers()
  })
  
  # Reactive value for managing a 
  # set of 'selected drugs'
  selected_drugs <- reactiveVal()
  
  # Update selected drugs on click event
  observeEvent(event_data("plotly_click"), {
    click <- event_data("plotly_click")$customdata
    drugs <- selected_drugs()
    
    # If the clicked drug is already selected,
    # then remove it from selection set; otherwise,
    # we add it to the selection set
    drugs <- if (click %in% drugs) {
      setdiff(drugs, click)
    } else {
      c(click, drugs)
    }
    
    selected_drugs(drugs)
  })
  
  # clear selected drugs on double-click
  observeEvent(event_data("plotly_doubleclick"), {
    selected_drugs(NULL)
  })
  
  # display the selected drugs
  output$click <- renderPrint({
    selected_drugs()
  })
}

shinyApp(ui, server)