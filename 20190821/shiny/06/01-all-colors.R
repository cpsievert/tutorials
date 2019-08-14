library(shiny)

ui <- fluidPage(
  actionButton("click", "click here"),
  plotlyOutput("p")
)

server <- function(input, output, session) {
  
  output$p <- renderPlotly({
    plot_ly(
      x = 1:10, y = 1:10, 
      marker = list(color = "black")
    )
  })
  
  observeEvent(input$click, {
    marker_color <- if (input$click %% 2) "black" else "red"
    
    plotlyProxy("p", session) %>%
      plotlyProxyInvoke("restyle", marker.color = marker_color)
  })
  
}

shinyApp(ui, server)