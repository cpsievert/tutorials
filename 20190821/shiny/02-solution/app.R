library(shiny)
library(plotly)
library(dplyr)

# a tidy dataset of reactions outcomes for 1000 most common drugs
outcomes <- readRDS(here::here("data", "outcomes-tidy.rds"))

# Top 6 Principal Component scores for each drug
outcome_pca <- readRDS(here::here("data", "pca-scores.rds"))

ui <- fluidPage(
  p(
    "Clicking on the points below prints", tags$i("accumulated"), 
    "click info. Note how double-clicking clears the history of selected drugs and repeatedly clicking a point adds/removes it from consideration."
  ), 
  p(tags$b("Your turn:"), "Provide a visual cue of which drugs are selected on the scatterplot."),
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
      add_markers() %>%
      filter(drug %in% selected_drugs()) %>%
      add_markers(size = I(40), color = I("black")) %>%
      layout(showlegend = FALSE)
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