library(shiny)
library(anytime)

source("functions/mongo parser.R")

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
    actionButton(ns("createCorpus"), "Create Corpus")
  )
}


dataprep <- function(input, output, session) {

  rv <- reactiveValues(
    fields = NULL,
    tindex = NULL,
    docvars = NULL
  )

  # checks for selected collection, requests tindex and gets column names
  # updates text and date field
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
                             choices = rv$fields[!rv$fields %in% c("_id",
                                                                   rv$tindex,
                                                                   input$dateField)],
                             selected = rv$docvars,
                             inline = TRUE)
  })

  # checks if collection already has a text index and updates button accordingly
  observeEvent({input$textField
                global$coll}, ignoreNULL = TRUE, priority = 1, {

    if (is.empty(rv$tindex))
      updateActionButton(session, "createIndex",
                         label = "Create Text Index")
    else if (input$textField == rv$tindex)
      updateActionButton(session, "createIndex",
                         label = "Text Index up to date")
    else
      updateActionButton(session, "createIndex",
                         label = "Update Text Index")
  })

  # resets the Corpus and Button on changes of collection or variables
  observeEvent({input$textField
                input$dateField
                input$docvars
                global$coll}, ignoreNULL = TRUE, priority = 1, {

    global$corpus <- NULL
    updateActionButton(session, "createCorpus", label = "Create Corpus")
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

  # converts the date field, indexes the docvars and creates a corpus
  observeEvent(input$createCorpus, {

    # adds a new "date" field in a unified POSIXct format
    # loads _id and input date field from Mongo, converts the date and updates all documents
    # this still needs validation for further datasets and formats and missing date fields
    if (req(input$dateField) != "date") {
      df <- global$m$find('{}', fields = parseFields(c("_id", input$dateField)))
      df$date <- paste0(as.integer(anytime(df[, 2])), "000")
      
      apply(df, 1, 
            function(x) {
              global$m$update(
                query = paste0('{"_id":{"$oid":"', x[1], '"}}'),
                update = paste0('{"$set": {"date": {"$date": {"$numberLong": "', x[3], '"}}}}'))
              })

      global$data <- global$m$find('{}', fields = '{}')
    }

    # removes or adds only docvars/indexes that have changed
    newDocvars <- setdiff(c("date", input$docvars), rv$docvars)
    oldDocvars <- setdiff(rv$docvars, c("date", input$docvars))
    if (length(oldDocvars) > 0)
      apply(array(oldDocvars), 1,
            function(x) {
              global$m$index(remove = paste0(x[1], "_1"))
              })
    if (length(newDocvars) > 0)
      apply(array(newDocvars), 1,
            function(x) {
              global$m$index(add = parseIndex(x[1]))
              })

    rv$docvars <- getIndex(global$m)

    # creates the corpus object and updates the button
    global$corpus <- corpus(global$data[c("_id", input$textField, rv$docvars)],
                            docid_field = "_id",
                            text_field = input$textField)
    updateActionButton(session, "createCorpus", label = "Corpus created")
  })
}
