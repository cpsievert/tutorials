library(shiny)
library(plotly)
library(dplyr)

# a tidy dataset of reactions outcomes for 1000 most common drugs
outcomes <- readRDS("data/outcomes-tidy.rds")
# Top 6 Principal Component scores for each drug
outcome_pca <- readRDS("data/pca-scores.rds")

ui <- fluidPage(
  plotlyOutput("p"),
  plotlyOutput("click")
)

server <- function(input, output, session) {
  
  output$p <- renderPlotly({
    outcome_pca %>%
      left_join(select_data(), by = "drug") %>%
      plot_ly(
        x = ~Comp.2, y = ~Comp.1, customdata = ~drug,
        text = ~drug, hoverinfo = "text", 
        color = ~I(ifelse(is.na(color), "black", color)), 
        size = ~I(ifelse(is.na(color), 10, 30))
      ) %>% 
      add_markers()
  })
  
  # Named character of selected drugs. The names keep 
  # track of which color corresponds to which drug
  selected_drugs <- reactiveVal()
  
  # Transform the named character vector into tidy data
  select_data <- reactive({
    selected_drugs() %>%
      tibble::enframe(name = "color", value = "drug") %>%
      mutate(drug = as.character(drug))
  })
  
  observeEvent(event_data("plotly_click"), {
    click <- setNames(
      event_data("plotly_click")$customdata, 
      # Generate a random color. In practice, you should
      # use a qualitative color palette
      sample(colors(), 1)
    )
    drugs <- selected_drugs()
    
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
  output$click <- renderPlotly({
    if (!length(selected_drugs())) return(NULL)
    
    outcomes %>%
      semi_join(select_data()) %>%
      plot_ly() %>%
      add_bars(
        x = ~reaction, y = ~count, 
        color = ~drug, colors = setNames(names(selected_drugs()), selected_drugs())
      )
  })
}

shinyApp(ui, server)
