
preprocessUI <- function(id) {
  ns <- NS(id)
  tagList(
    column(6, 
           checkboxGroupInput(ns("tokOpt"), "Token Options", 
                              choiceNames = c("Remove Numbers", 
                                              "Remove Punctuation",
                                              "Remove Symbols",
                                              "Remove URLs",
                                              "Remove Stopwords"),
                              choiceValues = c("nums",
                                               "punct",
                                               "symbols",
                                               "urls",
                                               "stopwords")),
           actionButton(ns("createTokens"), "Create Tokens")),
    column(6, 
           actionButton(ns("createDFM"), "Create DFM"))
  )
}

preprocess <- function(input, output, session) {
  
  ns <- session$ns
  
  observeEvent(global$coll, event.env = .GlobalEnv, {
    updateActionButton(session, "createTokens", label = "Create Tokens")
    updateActionButton(session, "createDFM", label = "Create DFM")
  })
  
  observeEvent(input$createTokens, {
    print("nums" %in% input$tokOpt)
    global$tokens <- tokens(req(global$corpus), 
                            what = "word",
                            remove_numbers = ("nums" %in% input$tokOpt),
                            remove_punct = ("punct" %in% input$tokOpt),
                            remove_symbols = ("symbols" %in% input$tokOpt),
                            remove_urls = ("urls" %in% input$tokOpt),
                            include_docvars = TRUE)
    
    if ("stopwords" %in% input$tokOpt)
      global$tokens <- tokens_remove(global$tokens, pattern = stopwords("en"))
    
    updateActionButton(session, "createTokens", label = "Tokens created")
  })
  
  observeEvent(input$createDFM, {
    global$dfm <- dfm(global$tokens, tolower = TRUE)
    updateActionButton(session, "createDFM", label = "DFM created")
  })
}