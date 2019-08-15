library(shiny)
library(mongolite)
library(jsonlite)
library(tidytext)
x <- library(janeaustenr)


ui <- fluidPage(
  titlePanel("Upload new data"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Please select the file to upload", 
                multiple = FALSE, 
                accept = c("json"), 
                buttonLabel = "Select"),
      textInput("coll_name", "Name the collection", placeholder = "e.g. Instruments"),
      actionButton("save", "Save data to collection")
    ),
    mainPanel(
      tags$h4("Feel free to explore the data a bit before saving to MongoDB"),
      tags$em("It may take a moment for the file to be processed...", id = "temp"),
      dataTableOutput("inputView")
    )
  )  
)

server <- function(input, output, session) {
  
  options(shiny.maxRequestSize = 200*1024^2)
  
  file <- reactive({
    file <- input$file
  })
  
  df <- reactive({
    if (is.null(file()))
      tags$p("The file is processing...")
    else
      stream_in(file()$datapath)
  })
  
  output$inputView <- renderDataTable({
    if (is.data.frame(df()))
      removeUI(selector = "#temp")
    df()
  })
  
  observeEvent(input$save, {

    if (input$coll_name == "")
      name <- basename(file()$name)
    else
      name <- input$coll_name
      
    coll <- mongo(collection = name, 
                  db = "mongotest",
                  url = "mongodb://127.0.0.1:27017/?gssapiServiceName=mongodb")
    coll$insert(df())
    updateActionButton(session, "save", label = "Saved to MongoDB")
  })
}

shinyApp(ui = ui, server = server)