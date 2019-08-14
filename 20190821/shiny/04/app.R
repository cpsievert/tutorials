library(shiny)
library(plotly)
library(dplyr)

# a tidy dataset of reactions outcomes for 1000 most common drugs
outcomes <- readRDS("data/outcomes-tidy.rds")
# Top 6 Principal Component scores for each drug
outcome_pca <- readRDS("data/pca-scores.rds")

ui <- fluidPage(
  p(
    "Clicking on the points below prints", tags$i("accumulated"), 
    "click info. Note how double-clicking clears the history of selected drugs and repeatedly clicking a point adds/removes it from consideration.",
    " This management of click info is handled via a ", tags$code("reactiveVal()"), " named ", tags$code("selected_drugs")
  ), 
  p(tags$b("Your turn:"), "Modify the app to provide a visual cue (on the scatterplot) of which drugs have been clicked."),
  plotlyOutput("p"),
  verbatimTextOutput("click")
)

server <- function(input, output, session) {
  
  output$p <- renderPlotly({
    outcome_pca %>%
      plot_ly(
        x = ~Comp.2, y = ~Comp.1, customdata = ~drug,
        text = ~drug, hoverinfo = "text",
        # TIP: you can provide a vector of colors/sizes
        color = I("black"), size = I(10)
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