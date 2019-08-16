library(shiny)
library(mongolite)
library(jsonlite)

uploadUI <- function(id){
  ns <- NS(id)
  tagList(
    fileInput("file", "Please select the file to upload", 
              multiple = FALSE, 
              accept = c("json"), 
              buttonLabel = "Select"),
    textInput("coll_name", "Name the document collection", placeholder = 'e.g. "Instruments"'),
    actionButton("save", "Save data as collection")
  )
}

# mainPanel(
#   tags$h4("Feel free to explore the data a bit before saving to MongoDB"),
#   tags$em("It may take a moment for the file to be processed...", id = "temp"),
#   dataTableOutput("inputView")
# )

uploadServer <- function(input, output, session) {
  
  options(shiny.maxRequestSize = 200*1024^2)
  
  file <- reactive({
    file <- input$file
  })
  
  df <- reactive({
    if (is.null(file()$datapath))
      return(NULL)
    else
      x <- stream_in(file()$datapath)
    print(x)
  })
  
  # output$inputView <- renderDataTable({
  #   if (is.data.frame(df()))
  #     removeUI(selector = "#temp")
  #   df()
  # })
  
  observeEvent(input$save, {
    
    # if (input$coll_name == "")
    #   name <- basename(file()$name)
    # else
    #   name <- input$coll_name
    #   
    # coll <- mongo(collection = name, 
    #               db = "mongotest",
    #               url = "mongodb://127.0.0.1:27017/?gssapiServiceName=mongodb")
    # coll$insert(df())
    updateActionButton(session, "save", label = "Saved to MongoDB")
    print(input$save)
  })
}