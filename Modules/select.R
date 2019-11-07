library(shiny)

source("functions/mongo parser.R")

#connect to mongoDB and return all collections
m <- mongoDB()
collections <- getCollections(m)

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


select <- function(input, output, session) {

  # when a new file is uploaded, it is automatically added and pre-selected
  observeEvent(global$coll, event.env = .GlobalEnv, ignoreNULL = TRUE, {
    collections <- getCollections(m)
    updateSelectInput(session, "selectData",
                      choices = collections,
                      selected = global$coll)
  })

  # when switching between collections, this resets the button and global$coll
  observeEvent(input$selectData, ignoreInit = TRUE, {
    global$coll <- NULL
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
      global$m <- mongoDB(collection = input$selectData)
      dur <- global$m$info()$stats$count / 65000
      if (dur > 4)
        showNotification("The data is processing and will be displayed shortly.",
                         type = "warning",
                         duration = dur)
      global$coll <- input$selectData
      global$data <- global$m$find('{}', fields = '{}')
      updateActionButton(session, "load", label = "Loaded to RAM")
    }
  })
}
