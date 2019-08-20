source(paste0(getwd(),"/Modules/Display Table Module.R"), local = TRUE)

#defines the UI for the Upload Data Module
uploadUI <- function(id){
  ns <- NS(id)
  tagList(
    fileInput(ns("file"), "Please select the file to upload", 
              multiple = FALSE, 
              accept = c("json"), 
              buttonLabel = "Select"),
    textInput(ns("coll_name"), "Name the document collection*", placeholder = 'e.g. "Instruments"'),
    actionButton(ns("save"), "Save data as collection"),
    useShinyalert()
  )
}


upload <- function(input, output, session, coll_runtime) {
  
  # increases the shiny upload limit
  options(shiny.maxRequestSize = 500*1024^2)
  
  # once a file is uploaded, inputs are reset and the data is streamed into the global data frame
  observeEvent(input$file, {
    
    stream_in(input$file$datapath)
    updateActionButton(session, "save", label = "Save data as collection")
    updateTextInput(session, "coll_name", value = "")
    
    # displays a "in progress" message for big files
    dur <- input$file$size/10000000
    if (dur > 5)
      showNotification("The data is processing and will be displayed shortly.", 
                       type = "warning", 
                       duration = dur)
    
    df_runtime(df())
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
    else if (input$coll_name == "") {
      updateTextInput(session, "coll_name", placeholder = "*collection name required")
    }
    #once all is well, file data is streamed in and saved to MongoDB
    else {
      coll <- mongo(collection = input$coll_name,
                    db = "mongotest",
                    url = "mongodb://127.0.0.1:27017/?gssapiServiceName=mongodb")
      coll$insert(df())
      updateActionButton(session, "save", label = "Saved to MongoDB")
      coll_runtime(input$coll_name)
    }
  })
}