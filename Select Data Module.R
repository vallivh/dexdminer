library(shiny)
library(mongolite)
library(jsonlite)
library(ndjson)
source("MongoDB parser.R")

m <- mongo(url = "mongodb://127.0.0.1:27017/?gssapiServiceName=mongodb", db = "mongotest")

collections <- m$run('{"listCollections":1}')
df_runtime = data.frame()

ui <- fluidPage(
  selectInput(inputId = "selectedColl", label = "Please select a dataset", choices = collections$cursor$firstBatch$name),
  uiOutput("selectVar"),
  actionButton("load", "Load Data"),
  tableOutput("table")
)

server <- function(input, output) {
  
  db <- reactive({
    mongo(url = "mongodb://127.0.0.1:27017/?gssapiServiceName=mongodb", collection = input$selectedColl, db = "mongotest")
  })
  
  ds <- reactive({
    db()$find(query = '{}', limit = 50)
  })  
  
  output$selectVar <- renderUI({
    checkboxGroupInput("varSelected", "Please select variables", choices = colnames(ds()), 
                       selected = colnames(ds()), inline = TRUE)
  })
  
  output$table <- renderTable(ds()[c(input$varSelected)])
  
  observeEvent(input$load, {
    insertUI(selector = "#load", where = "afterEnd", 
             ui = textInput("success", label = NULL, width = '30%',
                            value = "The dataset has been loaded to RAM and is available for all modules."))
    df_runtime = db()$find(query = '{}', fields = parseFields(input$varSelected))
  })
}

shinyApp(ui = ui, server = server)
