source(paste0(getwd(), "/Modules/MongoDB parser.R"), local = TRUE)


preprocessUI <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(ns("textField"), 
                "Which field contains the text?", 
                choices = NULL),
    actionButton(ns("createIndex"), "Create Text Index"),
    selectInput(ns("dateField"),
                "Please select a date field",
                choices = NULL),
    checkboxGroupInput(ns("docvars"),
                       "Select additional variables as docvars for the corpus.",
                       choices = NULL)
  )
}


preprocess <- function(input, output, session, coll_runtime) {
  
  rv <- reactiveValues(
    fields = NULL,
    tindex = NULL
  )
  
  # checks for selected collection and updates selectInput accordingly
  observe(priority = 2, {
    
    m <- mongoDB(collection = req(coll_runtime()))
    rv$tindex <- getIndex(m, text = TRUE)
    rv$fields <- colnames(df_runtime())
    
    updateSelectInput(session, "textField",
                      choices = c("", rv$fields),
                      selected = rv$tindex)
    
    updateSelectInput(session, "dateField",
                      choices = c("", rv$fields[rv$fields != rv$tindex]))
  })
  
  observe({
    updateCheckboxGroupInput(session, "docvars",
                             choices = rv$fields[!rv$fields %in% c(rv$tindex, input$dateField)],
                             inline = TRUE)
  })
  
  # checks if collection already has a text index and updates button accordingly
  observeEvent(input$textField, ignoreNULL = TRUE, priority = 1, {
    
    if (is.empty(rv$tindex))
      updateActionButton(session, "createIndex", label = "Create Text Index")
    else if (input$textField == rv$tindex)
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
    else if (is.null(rv$tindex)) {
      updateActionButton(session, "createIndex", label = "Text Index created")
      m$index(add = parseIndex(input$textField))
    }
    else if (input$textField != rv$tindex) {
      m$index(remove = getTextIndex(m, fields = FALSE, text = TRUE))
      m$index(add = parseIndex(input$textField))
      updateActionButton(session, "createIndex", label = "Text Index updated")
    }
    tindex(getTextIndex(m, text = TRUE))
  })
}
