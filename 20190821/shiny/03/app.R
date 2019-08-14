library(shiny)

ui <- fluidPage(
  p("The time difference between clicks is printed to the R console."),
  p("Note that in order to compute the difference, Shiny needs to 'remember' the time the last click occurred."),
  p(),
  actionButton("click", "Click me")
)

server <- function(input, output, session) {
  
  click_time <- reactiveVal(Sys.time())
  
  observeEvent(input$click, {
    print(Sys.time() - click_time())
    click_time(Sys.time())
  })
  
}

shinyApp(ui, server)