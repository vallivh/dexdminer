
preprocessUI <- function(id) {
  ns <- NS(id)
  tagList(
    actionButton(ns("createCorpus"), "Create Corpus"),
    actionButton(ns("createTokens"), "Create Tokens"),
    actionButton(ns("createDFM"), "Create DFM")
  )
}

preprocess <- function(input, output, session) {
  
  observeEvent(input$createCorpus, {
    text = getIndex(global$m, text = TRUE)
    docvars = getIndex(global$m)
    global$corpus <- corpus(global$data[c(text, docvars)], 
                            text_field = text)
    
    updateActionButton(session, "createCorpus", label = "Corpus created")
  })
}