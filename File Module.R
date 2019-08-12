library(shiny)
library(mongolite)
library(jsonlite)
library(tidytext)
x <- library(janeaustenr)

m <- mongo(url = "mongodb://127.0.0.1:27017/?gssapiServiceName=mongodb", collection = "music", db = "mongotest")

ui <- fluidPage(
  fileInput("file", "Please select the file to upload", multiple = FALSE, accept = c("text/csv", "json"), buttonLabel = "Select"),
  dataTableOutput("inputView")
)

server <- function(input, output) {
  
  output$inputView <- renderDataTable({
    file <- input$file
    
    if (is.null(file))
      return(NULL)
    
    data1 <- read_json(file$datapath, header = TRUE)
    m$insert(data1)
    data1
  })
}

shinyApp(ui = ui, server = server)
