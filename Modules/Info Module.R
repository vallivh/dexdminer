
infoUI <- function(id) {
  ns <- NS(id)
  tagList(
    infoBoxOutput(ns("numdocs"), width = 12),
    infoBoxOutput(ns("size"), width = 12),
    infoBoxOutput(ns("docvars"), width = 12)
  )
}


info <- function(input, output, session) {
  
  output$numdocs <- renderValueBox({
    valueBox(value = format(global$m$count(), big.mark = ".", decimal.mark = ","), 
             subtitle = "DOCUMENTS",
             icon = icon("list-ol"))
  })
  
  output$size <- renderValueBox({
    if (is.null(global$m$info()$stats$size))
      size = 0
    else
      size = global$m$info()$stats$size/10^6
    
    valueBox(value = format(size, big.mark = ".", decimal.mark = ",", digits = 3), 
             subtitle = "MB",
             icon = icon("hdd"))
  })
  
  output$docvars <- renderValueBox({
    if (is.empty(getIndex(global$m)))
      num = 0
    else
      num = length(getIndex(global$m))
    
    valueBox(value = format(num, big.mark = ".", decimal.mark = ","), 
             subtitle = "DOCVARS",
             icon = icon("tags"))
  })
}