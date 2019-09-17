
infoUI <- function(id) {
  ns <- NS(id)
  tagList(
    infoBoxOutput(ns("objects"), width = 12),
    infoBoxOutput(ns("numdocs"), width = 12),
    infoBoxOutput(ns("size"), width = 12),
    infoBoxOutput(ns("docvars"), width = 12)
  )
}


info <- function(input, output, session) {
  
  # zeigt die Anzahl der Dokumente (Zeilen) in der ausgewählten Collection an
  output$numdocs <- renderValueBox({
    valueBox(value = format(global$m$count(), big.mark = ".", decimal.mark = ","), 
             subtitle = "DOCUMENTS",
             icon = icon("list-ol"))
  })
  
  # zeigt die Größe (in MB) der ausgewählten Collection an
  output$size <- renderValueBox({
    if (is.null(global$m$info()$stats$size))
      size = 0
    else
      size = global$m$info()$stats$size/10^6
    
    valueBox(value = format(size, big.mark = ".", decimal.mark = ",", digits = 3), 
             subtitle = "MB",
             icon = icon("hdd"))
  })
  
  # zeigt die Anzahl der Docvars im aktuellen Corpus an
  # funktioniert noch nicht beim initiallen Erzeugen der Docvars
  output$docvars <- renderValueBox({
    if (is.null(getIndex(global$m)))
      num = 0
    else
      num = length(getIndex(global$m))
    
    valueBox(value = format(num, big.mark = ".", decimal.mark = ","), 
             subtitle = "DOCVARS",
             icon = icon("tags"))
  })
  
  # zeigt den Namen der ausgewählten Collection an
  # bzw. informiert über die im RAM verfügbaren TM Objekte
  output$objects <- renderValueBox({
    if (is.null(global$coll))
      valueBox(value = "No Collection", 
               subtitle = "SELECTED",
               icon = icon("times"))
    else if (is.null(global$corpus))
      valueBox(value = global$coll, 
               subtitle = "SELECTED",
               icon = icon("check"))
    else {
      val <- "Corpus"
      if (!is.null(global$dfm))
        val <- "Corpus, Tokens & DFM"
      else if (!is.null(global$tokens))
        val <- "Corpus & Tokens"
      
      valueBox(value = val, 
               subtitle = "CREATED",
               icon = icon("check"))
    }
  })
}