source(paste0(getwd(), "/Modules/sentiment_analysis.R"), local = TRUE)

sentimentUI <- function(id) {
  ns <- NS(id)
  tagList(
    actionButton(ns("showSenti"), "Show Sentiment", icon = icon("smile"))
  )
}

sentiment <- function(input, output, session) {
  
  observeEvent(input$showSenti, {
    
    posneg <- tokens_lookup(global$tokens, data_dictionary_LSD2015)
    print(str(posneg))
  })
}