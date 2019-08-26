source(paste0(getwd(), "/Modules/MongoDB parser.R"), local = TRUE)


dataprepUI <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(ns("textField"), 
                "Which field contains the text?", 
                choices = NULL),
    actionButton(ns("createIndex"), "Create Text Index"),
    selectInput(ns("dateField"),
                "Please select a date field (preferably in a unified format).",
                choices = NULL),
    checkboxGroupInput(ns("docvars"),
                       "Select additional variables as docvars for the corpus.",
                       choices = NULL),
    actionButton(ns("createDocvars"), "Create Docvars")
  )
}


dataprep <- function(input, output, session) {
  
  rv <- reactiveValues(
    fields = NULL,
    tindex = NULL,
    docvars = NULL
  )
  
  # checks for selected collection, requests tindex and gets column names
  # updates tindex and date field
  observe(priority = 2, {
    
    rv$tindex <- getIndex(global$m, text = TRUE)
    rv$docvars <- getIndex(global$m)
    rv$fields <- colnames(isolate(global$data))
    
    updateSelectInput(session, "textField",
                      choices = c("", rv$fields),
                      selected = rv$tindex)
    
    updateSelectInput(session, "dateField",
                      choices = c("", rv$fields[rv$fields != rv$tindex]),
                      selected = "date")
  })
  
  # checks tindex and date field and updates the docvar choices accordingly
  # seperate observer ensures correct running order
  observe({
    
    updateCheckboxGroupInput(session, "docvars",
                             choices = rv$fields[!rv$fields %in% c(rv$tindex, input$dateField)],
                             selected = rv$docvars,
                             inline = TRUE)
  })
  
  # checks if collection already has a text index and updates button accordingly
  observeEvent({input$textField
                global$coll}, ignoreNULL = TRUE, priority = 1, {
    
    if (is.empty(rv$tindex))
      updateActionButton(session, "createIndex", label = "Create Text Index")
    else if (input$textField == rv$tindex)
      updateActionButton(session, "createIndex", label = "Text Index up to date")
    else
      updateActionButton(session, "createIndex", label = "Update Text Index")
  })
  
  # on clicking the Create Button, either creates a new text index or drops and replaces the old one
  # also updates the button or displays an alert
  observeEvent(input$createIndex, {

    if (is.empty(input$textField))
      shinyalert(title = "No text field selected",
                 text = "Please select the field that contains the text.",
                 type = "warning",
                 showConfirmButton = TRUE)
    else {
      if (is.empty(rv$tindex))
        updateActionButton(session, "createIndex", label = "Text Index created")
      else if (input$textField != rv$tindex) {
        global$m$index(remove = getTextIndex(global$m, fields = FALSE, text = TRUE))
        updateActionButton(session, "createIndex", label = "Text Index updated")
      }
      # create text index and update reactive value
      global$m$index(add = parseIndex(input$textField, text = TRUE))
      rv$tindex <- getIndex(global$m, text = TRUE)
    }
  })
  
  # on clicking the Create Button, converts the date field to POSIXct
  # creates indexes for the date and all selected docvars (saving the docvars and optimizing the DB)
  observeEvent(input$createDocvars, {
    
    # this still needs validation for further datasets and formats and missing date fields
    # loads an _id/date data frame from Mongo, converts the data into a third column and updates all documents
    df <- global$m$find('{}', fields = parseFields(c("_id", req(input$dateField))))
    df$date <- anydate(df[, 2])
    apply(df, 1, function(x) {global$m$update(query = paste0('{"_id":{"$oid":"', x[1], '"}}'), 
                                          update = paste0('{"$set": {"date": "', x[3], '"}}'))})

    apply(array(c("date", input$docvars)), 1, function(x) {global$m$index(add = parseIndex(x[1]))})
    rv$docvars <- getIndex(global$m)
    global$data <- global$m$find('{}')
    updateActionButton(session, "createDocvars", label = "Docvars created")
  })
}
