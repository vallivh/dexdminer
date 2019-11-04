library(shiny)

source("functions/mongo parser.R")

#connect to mongoDB and return all collections
mdic <- mongoDB(db = "dics")
dicoll <- getCollections(mdic)

selectDicUI <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(ns("selectDic"),
                label = "Please select a collection",
                choices = c("", dicoll),
                selected = ""),
    uiOutput(ns("selectVar")),
    actionButton(ns("load"), "Load Dictionary")
  )
}


selectDic <- function(input, output, session) {

  # when a new file is uploaded, it is automatically added and pre-selected
  observeEvent(global$dicoll, event.env = .GlobalEnv, ignoreNULL = TRUE, {
    dicoll <- getCollections(mdic)
    updateSelectInput(session, "selectDic",
                      choices = dicoll,
                      selected = global$dicoll)
  })

  # when switching between collections, this resets the button and global$coll
  observeEvent(input$selectDic, ignoreInit = TRUE, {
    global$dicoll <- NULL
    updateActionButton(session, "load", label = "Load Dictionary")
  })

  # when Load Button is clicked, save selected data to global data frame or display an error message
  observeEvent(input$load, {

    if (is.empty(input$selectDic))
      shinyalert(title = "No dataset selected",
                 text = "Please select a collection from the dropdown menu.",
                 showConfirmButton = TRUE,
                 type = "warning",
                 timer = 5000)
    else {
      global$mdic <- mongoDB(collection = input$selectDic, db = "dics")
      dur <- global$mdic$info()$stats$count / 65000
      if (dur > 4)
        showNotification("The data is processing and will be displayed shortly.",
                         type = "warning",
                         duration = dur)
      global$dicoll <- input$selectDic
      global$dic <- global$mdic$find('{}', fields = '{}')
      updateActionButton(session, "load", label = "Loaded to RAM")
    }
  })
}
