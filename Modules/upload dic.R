library(shiny)
library(shinyalert)
library(ndjson)

source("functions/mongo parser.R")

#defines the UI for the Upload Data Module
uploadDicUI <- function(id){
  ns <- NS(id)
  tagList(
    fileInput(ns("file"), "Please select the file to upload",
              multiple = FALSE,
              accept = c("json"),
              buttonLabel = "Select"),
    textInput(ns("dic_name"),
              "Name the dictionary*",
              placeholder = 'e.g. "Instruments"'),
    actionButton(ns("save"), "Save dic as collection"),
    useShinyalert()
  )
}


uploadDic <- function(input, output, session) {

  # increases the shiny upload limit
  options(shiny.maxRequestSize = 500 * 1024 ^ 2)

  # once a file is uploaded, inputs are reset and the data is streamed into the global data frame
  observeEvent(input$file, {

    updateActionButton(session, "save", label = "Save dic as collection")
    updateTextInput(session, "dic_name", value = "")

    # displays a "in progress" message for big files
    dur <- input$file$size / 10 ^ 7
    if (dur > 5)
      showNotification("The data is processing and will be displayed shortly.",
                       type = "warning",
                       duration = dur)
    
    global$dic <- read.xlsx(
      input$file$datapath,
      sheet = 1,
      cols = 1,
      colNames = FALSE,
      skipEmptyRows = TRUE,
      rowNames = FALSE
    )
  },
    ignoreNULL = TRUE)

  observeEvent(input$save, {

    #checks if file has been uploaded, if not displays alert
    if (is.null(input$file$datapath)) {
      shinyalert(title = "No file selected",
                 text = "Please select a file to be uploaded.",
                 type = "warning",
                 showConfirmButton = TRUE)
    }
    #checks for the mandatory collection name
    else if (input$dic_name == "") {
      updateTextInput(session, "dic_name",
                      placeholder = "*collection name required")
    }
    #once all is well, file data is streamed in and saved to MongoDB
    else {
      global$mdic <- mongoDB(input$dic_name, db = "dics")
      global$mdic$insert(global$dic)
      global$dicoll <- input$dic_name
      updateActionButton(session, "save", label = "Saved to MongoDB")
    }
  })
}