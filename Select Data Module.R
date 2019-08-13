library(shiny)
library(mongolite)
library(jsonlite)
library(ndjson)
source("MongoDB parser.R")

#connect to mongoDB and return all collections
m <- mongo(url = "mongodb://127.0.0.1:27017/?gssapiServiceName=mongodb", db = "mongotest")
collections <- m$run('{"listCollections":1}')

#create global data frame for use in other modules (not working?)
df_runtime = data.frame()

ui <- fluidPage(
  selectInput(inputId = "selectedColl", label = "Please select a dataset", choices = collections$cursor$firstBatch$name),
  uiOutput("selectVar"),
  actionButton("load", "Load Data"),
  tableOutput("table")
)

server <- function(input, output) {
  
  #connect to collection selected in dropdown
  db <- reactive({
    mongo(url = "mongodb://127.0.0.1:27017/?gssapiServiceName=mongodb", collection = input$selectedColl, db = "mongotest")
  })
  
  #return some data for visual overview and to fetch variable names to select
  ds <- reactive({
    db()$find(query = '{}', limit = 50)
  })  
  
  output$selectVar <- renderUI({
    checkboxGroupInput("varSelected", "Please select variables", choices = colnames(ds()), 
                       selected = colnames(ds()), inline = TRUE)
  })
  
  output$table <- renderTable(ds()[c(input$varSelected)])
  
  #when Load Button is clicked, save selected data to global data frame
  #data limited atm to 10.000 observations for speed!s
  observeEvent(input$load, {
    insertUI(selector = "#load", where = "afterEnd", 
             ui = textInput("success", label = NULL, width = '30%',
                            value = "The dataset has been loaded to RAM and is available for all modules."))
    df_runtime = db()$find(query = '{}', fields = parseFields(input$varSelected), limit = 10000)
  })
}

shinyApp(ui = ui, server = server)
