
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
                                               "stopwords"),
                              selected = c("nums",
                                           "punct",
                                           "symbols",
                                           "stopwords")),
           uiOutput(ns("language")),
           actionButton(ns("createTokens"), "Create Tokens")),
    column(6,
           checkboxGroupInput(ns("dfmOpt"), "DFM Options", 
                              choiceNames = c("All Lowercase", 
                                              "Stemming"),
                              choiceValues = c("tolower",
                                               "stem"),
                              selected = c("tolower")),
           actionButton(ns("createDFM"), "Create DFM"))
  )
}

preprocess <- function(input, output, session) {
  
  ns <- session$ns
  
  observeEvent(global$coll, event.env = .GlobalEnv, {
    updateActionButton(session, "createTokens", label = "Create Tokens")
    updateActionButton(session, "createDFM", label = "Create DFM")
  })
  
  observeEvent(input$tokOpt, {
    if ("stopwords" %in% input$tokOpt)
      output$language <- renderUI({
        selectInput(ns("language"), 
                    "Please select the language", 
                    choices = c(English = "en", German = "de"))
      })
  })
  
  observeEvent(input$createTokens, {
    
    global$tokens <- tokens(req(global$corpus), 
                            what = "word",
                            remove_numbers = ("nums" %in% input$tokOpt),
                            remove_punct = ("punct" %in% input$tokOpt),
                            remove_symbols = ("symbols" %in% input$tokOpt),
                            remove_urls = ("urls" %in% input$tokOpt),
                            include_docvars = TRUE)
    
    if ("stopwords" %in% input$tokOpt)
      global$tokens <- tokens_remove(global$tokens, pattern = stopwords(input$language))
    
    updateActionButton(session, "createTokens", label = "Tokens created")
  })
  
  observeEvent(input$createDFM, {
    
    global$dfm <- dfm(req(global$tokens), 
                      tolower = ("tolower" %in% input$dfmOpt),
                      stem = ("stem" %in% input$dfmOpt))
    
    updateActionButton(session, "createDFM", label = "DFM created")
  })
}