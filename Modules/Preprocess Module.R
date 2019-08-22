source(paste0(getwd(), "/Modules/MongoDB parser.R"), local = TRUE)


preprocessUI <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(ns("textField"), 
                "Which field contains the text?", 
                choices = NULL),
    actionButton(ns("createIndex"), "Create Text Index")
  )
}


preprocess <- function(input, output, session, coll_runtime) {
  
  tindex <- reactiveVal()
  
  # checks for selected collection and updates selectInput accordingly
  observeEvent(coll_runtime(), ignoreNULL = TRUE, {
    
    m <- mongoDB(collection = coll_runtime())
    tindex(getTextIndex(m, TRUE))
    
    updateSelectInput(session, "textField",
                      choices = c("", colnames(df_runtime())),
                      selected = tindex())
  })
  
  # checks if collection already has a text index and updates button accordingly
  observeEvent(input$textField, ignoreNULL = TRUE, {
    
    if (is.null(tindex()))
      updateActionButton(session, "createIndex", label = "Create Text Index")
    else if (input$textField == tindex())
      updateActionButton(session, "createIndex", label = "Text Index updated")
    else
      updateActionButton(session, "createIndex", label = "Update Text Index")
  })
  
  # on clicking the Create Button, either creates a new text index or drops and replaces the old one
  # also displays an alert and updates the button
  observeEvent(input$createIndex, {
    
    m <- mongoDB(collection = req(coll_runtime()))
    
    # updates the button depending on whether the index is updated or created initially
    if (is.null(input$textField))
      shinyalert(title = "No text field selected",
                 text = "Please select the field that contains the text.",
                 type = "warning",
                 showConfirmButton = TRUE)
    else if (is.null(tindex())) {
      updateActionButton(session, "createIndex", label = "Text Index created")
      m$index(add = parseIndex(input$textField))
    }
    else if (input$textField != tindex()) {
      m$index(remove = getTextIndex(m))
      m$index(add = parseIndex(input$textField))
      updateActionButton(session, "createIndex", label = "Text Index updated")
    }
    tindex(getTextIndex(m, TRUE))
  })
}
