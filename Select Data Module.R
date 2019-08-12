library(shiny)
library(mongolite)
library(jsonlite)
library(tidytext)
library(ndjson)
x <- library(janeaustenr)

m <- mongo(url = "mongodb://127.0.0.1:27017/?gssapiServiceName=mongodb", db = "mongotest")

m$count()
collections <- m$run('{"listCollections":1}')

ui <- fluidPage(
  selectInput(inputId = "selectedColl", label = "Please select a dataset", choices = collections$cursor$firstBatch$name),
  uiOutput("selectYear"),
  submitButton("Load Data"),
  tableOutput("table")
)

server <- function(input, output) {
  
  dataset <- reactive({
    ds <- mongo(url = "mongodb://127.0.0.1:27017/?gssapiServiceName=mongodb", collection = input$selectedColl, db = "mongotest")
    ds$find(query = '{}', limit = 100)
  })
  
  output$selectYear <- renderUI({
    checkboxGroupInput("varChoice", "Please select variables", choices = colnames(dataset()), selected = colnames(dataset()), inline = TRUE)
  })
  
  output$table <- renderTable(dataset()[c(input$varChoice)])
}

shinyApp(ui = ui, server = server)
