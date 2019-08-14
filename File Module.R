library(shiny)
library(mongolite)
library(jsonlite)
library(tidytext)
x <- library(janeaustenr)


ui <- fluidPage(
  fileInput("file", "Please select the file to upload", 
            multiple = FALSE, 
            accept = c("text/csv", "json"), 
            buttonLabel = "Select"),
  dataTableOutput("inputView")
)

server <- function(input, output) {
  
  options(shiny.maxRequestSize = 30*1024^2)
  
  new_collection <- reactive({
    file <- input$file
    
    if (is.null(file))
      return(NULL)
    
    coll <- mongo(collection = as.character(file$name), 
                  db = "mongotest",
                  url = "mongodb://127.0.0.1:27017/?gssapiServiceName=mongodb")
    print(file$datapath)
    data1 <- stream_in(file$datapath)
    coll$insert(data1)
    data1
  })
  
  output$inputView <- renderDataTable({
    new_collection()
  })
}

shinyApp(ui = ui, server = server)
shinyApp(ui = ui, server = server)