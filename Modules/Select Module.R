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


select <- function(input, output, session, coll_runtime) {
  
  # when a new file is uploaded, it is automatically added and pre-selected
  observeEvent(coll_runtime(), {
    collections <- m$run('{"listCollections":1, "nameOnly": true}')$cursor$firstBatch$name
    updateSelectInput(session, "selectData", choices = collections, selected = coll_runtime())
  })

  # when switching between collections, this resets the button and coll_runtime
  observeEvent(input$selectData, {
    coll_runtime(NULL)
    updateActionButton(session, "load", label = "Load Data")
  })
  
  # when Load Button is clicked, save selected data to global data frame or display an error message 
  observeEvent(input$load, {
               
    if (is.empty(input$selectData))
      shinyalert(title = "No dataset selected",
                 text = "Please select a collection from the dropdown menu.",
                 showConfirmButton = TRUE,
                 type = "warning",
                 timer = 5000)
    else {
      m <- mongoDB(collection = input$selectData)
      dur <- m$info()$stats$count/65000
      if (dur > 4)
        showNotification("The data is processing and will be displayed shortly.",
                         type = "warning",
                         duration = dur)
      coll_runtime(input$selectData)
      df_runtime(m$find('{}'))
      updateActionButton(session, "load", label = "Loaded to RAM")
    }
  })
}
