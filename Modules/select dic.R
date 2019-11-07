library(shiny)

source("functions/mongo parser.R")

#connect to mongoDB and return all dictionary collections
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
    actionButton(ns("load"), "Load Dictionary"),
    actionButton(ns("delete"), "Delete Dictionary")
  )
}


selectDic <- function(input, output, session) {

  # when a new file is uploaded, it is automatically added and pre-selected
  observeEvent(global$dicoll, ignoreInit = TRUE, {
    mdic <<- mongoDB(db = "dics")
    dicoll <<- getCollections(mdic)
    updateSelectInput(session, "selectDic",
                      choices = dicoll,
                      selected = global$dicoll)
  })

  # when switching between dic collections, this resets the button and global$dicoll
  observeEvent(input$selectDic, ignoreInit = TRUE, {
    global$dicoll <- NULL
    global$mdic <- mongoDB(collection = input$selectDic, db = "dics")
    updateActionButton(session, "load", label = "Load Dictionary")
    updateActionButton(session, "delete", label = "Delete Dictionary")
  })

  # when Load Button is clicked, save selected data to global dic data frame or display an error message
  observeEvent(input$load, {

    if (is.empty(input$selectDic))
      shinyalert(title = "No dataset selected",
                 text = "Please select a collection from the dropdown menu.",
                 showConfirmButton = TRUE,
                 type = "warning",
                 timer = 5000)
    else {
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
  
  # deletes the dictionary that is currently selected from MongoDB and updates button
  observeEvent(input$delete, {
    global$mdic$drop()
    global$dic <- data.frame(Words = c(NA))
    global$dicoll <- ""
    updateActionButton(session, "delete",
                       label = "Dictionary deleted")
  })
}
