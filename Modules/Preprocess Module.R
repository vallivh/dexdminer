source(paste0(getwd(), "/Modules/MongoDB parser.R"), local = TRUE)


preprocessUI <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(ns("indexFields"), 
                "Which fields contain textual data?", 
                choices = NULL,
                multiple = TRUE),
    actionButton(ns("createIndex"), "Create/Update Text Index")
  )
}


preprocess <- function(input, output, session, coll_runtime) {
  
  observeEvent(coll_runtime(), {
    updateSelectInput(session, "indexFields", 
                      choices = colnames(df_runtime()))
    
    m <- mongoDB(collection = coll_runtime())
    tindex <- getTextIndex(con = m)
    cat("Index name:", tindex)
    
    if (!is.null(tindex)) {
      updateSelectInput(session, "indexFields",
                        choices = colnames(df_runtime()),
                        selected = getTextIndex(m, TRUE))
      updateActionButton(session, "createIndex", label = "Update Text Index")
    }
  })
  
  observeEvent(input$createIndex, {
    if (is.null(tindex()))
      updateActionButton(session, "createIndex", label = "Text Index created")
    else {
      m$index(remove = tindex)
      updateActionButton(session, "createIndex", label = "Text Index updated")
    }
    m$index(add = parseIndex(input$indexFields))
  })
}  
