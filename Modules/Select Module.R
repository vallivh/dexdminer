library(shiny)
library(mongolite)
library(jsonlite)
library(ndjson)
source(paste0(getwd(), "/Modules/MongoDB parser.R"), local = TRUE)

#connect to mongoDB and return all collections
m <- mongoDB()
collections <- m$run('{"listCollections":1, "nameOnly": true}')

selectUI <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(ns("selectData"), 
                label = "Please select a dataset", 
                choices = c("",collections$cursor$firstBatch$name),
                selected = ""),
    uiOutput(ns("selectVar")),
    actionButton(ns("load"), "Load Data")
  )
}

select <- function(input, output, session, df_runtime, coll_runtime) {
  
  observeEvent(coll_runtime(), {
    collections <- m$run('{"listCollections":1}')
    updateSelectInput(session, "selectData", selected = coll_runtime())
  })
  
  #connect to collection selected in dropdown
  observeEvent(input$selectData, {
    
    mon <- mongoDB(db = "weird", collection = input$selectData)

    if (is.null(coll_runtime()) || (input$selectData != coll_runtime())) {
      dur <- mon$count()/10000000
      if (dur > 5)
        showNotification("The data is processing and will be displayed shortly.",
                         type = "message",
                         duration = dur)
      df_runtime(mon$find('{}'))
    }
  })
  
  #when Load Button is clicked, save selected data to global data frame
  observeEvent(input$load, {
    updateActionButton(session, "load", label = "Loaded to RAM")
  })
}
