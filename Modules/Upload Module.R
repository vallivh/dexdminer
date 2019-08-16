library(shinyalert)
library(shiny)


uploadUI <- function(id){
  ns <- NS(id)
  tagList(
    fileInput(ns("file"), "Please select the file to upload", 
              multiple = FALSE, 
              accept = c("json"), 
              buttonLabel = "Select"),
    textInput(ns("coll_name"), "Name the document collection", placeholder = 'e.g. "Instruments"'),
    actionButton(ns("save"), "Save data as collection"),
    useShinyalert()
  )
}


upload <- function(input, output, session) {
  
  #increase the shiny upload limit
  options(shiny.maxRequestSize = 200*1024^2)
  
  observeEvent(input$save, {
    
    file <- input$file
    
    #check if a file has been uploaded, if not display alert
    if (is.null(file$datapath)) {
      shinyalert(title = "No file selected",
                 text = "Please selected a file to be uploaded first.",
                 showConfirmButton = TRUE,
                 timer = 5000)
    }
    #if yes, stream in data, save to MongoDB and update button
    else {

      dt <- stream_in(file(file$datapath))

      #name for collection is optional, uses filename if none specified
      if (input$coll_name == "")
        name <- basename(file$name)
      else
        name <- input$coll_name

      coll <- mongo(collection = name,
                    db = "mongotest",
                    url = "mongodb://127.0.0.1:27017/?gssapiServiceName=mongodb")
      coll$insert(dt)
      updateActionButton(session, "save", label = "Saved to MongoDB")
    }
  })
}