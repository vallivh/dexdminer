source(paste0(getwd(), "/Modules/MongoDB parser.R"), local = TRUE)


preprocessUI <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(ns("indexFields"), 
                "Which fields contain textual data?", 
                choices = NULL,
                multiple = TRUE),
    actionButton(ns("createIndex"), "Create Text Index")
  )
}


preprocess <- function(input, output, session, coll_runtime) {
  
  tindex <- reactiveVal()
  
  # checks for selected collection and updates selectInput accordingly
  # checks if collection already has a text index and updates button accordingly
  observeEvent(coll_runtime(), {
    m <- mongoDB(collection = coll_runtime())
    tindex(getTextIndex(m, TRUE))
    
    if (!is.null(tindex()))
      updateActionButton(session, "createIndex", label = "Update Text Index")
    else
      updateActionButton(session, "createIndex", label = "Create Text Index")
    
    updateSelectInput(session, "indexFields",
                      choices = colnames(df_runtime()),
                      selected = tindex())
  }, ignoreNULL = TRUE)
  
  # on clicking the Create Button, either creates a new text index or drops and replaces the old one
  observeEvent(input$createIndex, {
    m <- mongoDB(collection = coll_runtime())
    
    if (is.null(tindex()))
      updateActionButton(session, "createIndex", label = "Text Index created")
    else {
      m$index(remove = getTextIndex(m))
      updateActionButton(session, "createIndex", label = "Text Index updated")
    }
    
    m$index(add = parseIndex(input$indexFields))
  })
}  
