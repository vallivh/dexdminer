
preprocessUI <- function(id) {
  ns <- NS(id)
  tagList(
    actionButton(ns("createCorpus"), "Create Corpus"),
    actionButton(ns("createTokens"), "Create Tokens"),
    actionButton(ns("createDFM"), "Create DFM")
  )
}

preprocess <- function(input, output, session) {
  
  observeEvent(global$coll, event.env = .GlobalEnv, {
    updateActionButton(session, "createCorpus", label = "Create Corpus")
    updateActionButton(session, "createTokens", label = "Create Tokens")
    updateActionButton(session, "createDFM", label = "Create DFM")
  })
  
  observeEvent(input$createCorpus, {
    text = getIndex(global$m, text = TRUE)
    docvars = getIndex(global$m)
    global$corpus <- corpus(global$data[c("_id", text, docvars)], 
                            docid_field = "_id",
                            text_field = text)
    
    updateActionButton(session, "createCorpus", label = "Corpus created")
  })
  
  observeEvent(input$createTokens, {
    global$tokens <- tokens(req(global$corpus), 
                            what = "word",
                            remove_numbers = TRUE,
                            remove_punct = TRUE,
                            remove_symbols = TRUE,
                            include_docvars = TRUE)
    
    global$tokens <- tokens_remove(global$tokens, pattern = stopwords("en"))
    updateActionButton(session, "createTokens", label = "Tokens created")
  })
  
  observeEvent(input$createDFM, {
    global$dfm <- dfm(global$tokens, tolower = TRUE)
    updateActionButton(session, "createDFM", label = "DFM created")
  })
}