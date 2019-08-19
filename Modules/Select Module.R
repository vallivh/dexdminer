library(mongolite)
source(paste0(getwd(), "/Modules/MongoDB parser.R"), local = TRUE)

#connect to mongoDB and return all collections
m <- mongoDB()
collections <- m$run('{"listCollections":1, "nameOnly": true}')$cursor$firstBatch$name

selectUI <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(ns("selectData"), 
                label = "Please select a collection", 
                choices = c("", collections),
                selected = ""),
    uiOutput(ns("selectVar")),
    actionButton(ns("load"), "Load Data")
  )
}


select <- function(input, output, session, df_runtime, coll_runtime) {
  
  observeEvent(coll_runtime(), {
    collections <- m$run('{"listCollections":1, "nameOnly": true}')$cursor$firstBatch$name
    updateSelectInput(session, "selectData", choices = collections, selected = coll_runtime())
  })

  #connect to collection selected in dropdown
  observeEvent(input$selectData, {
    
    updateActionButton(session, "load", label = "Load Data")
    
    if (input$selectData != "") {
      m <- mongoDB(collection = input$selectData)
      dur <- m$info()$stats$count/65000
      if (dur > 4)
        showNotification("The data is processing and will be displayed shortly.",
                         type = "warning",
                         duration = dur)
      df_runtime(m$find('{}'))
    }
  })
  
  #when Load Button is clicked, save selected data to global data frame
  observeEvent(input$load, {
    if (input$selectData != "") {
      coll_runtime(input$selectData)
      updateActionButton(session, "load", label = "Loaded to RAM")
    }
    else
      shinyalert(title = "No dataset selected",
                 text = "Please select a collection from the dropdown menu.",
                 showConfirmButton = TRUE,
                 type = "warning",
                 timer = 5000)
  })
}
