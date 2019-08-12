library(shiny)
library(mongolite)
library(jsonlite)
library(nycflights13)

m <- mongo(url = "mongodb://127.0.0.1:27017/?gssapiServiceName=mongodb", collection = "nycflights", db = "mongotest")

ui <- fluidPage(
  selectInput("carrier", "Select a carrier:", m$distinct("carrier"), multiple = TRUE),
  tableOutput("avgDelays")
)

server <- function(input, output) {
  
  output$avgDelays <- renderTable({
    
    carrierString <- paste(paste0('"', input$carrier, '"'), collapse = ",")
    
    m$aggregate(test <- paste0('[
                {"$match":{"carrier":{"$in":[',carrierString,']}}},
                {"$group":{"_id":"$carrier", "average_delay":{"$avg":"$arr_delay"}}}
                ]'))
  })
}

shinyApp(ui = ui, server = server)
