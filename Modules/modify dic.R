library(rhandsontable)

modifyDicUI <- function(id) {
  ns <- NS(id)
  tagList(
    DTOutput(ns("table")),
    actionButton(ns("update"), "Update Dictionary")
  )
}


modifyDic <- function(input, output, session) {
  
  dic <- reactiveVal()
  
  observeEvent(global$dicoll, {
    dic(datatable(global$dic[names(global$dic) != "_id"], editable = TRUE))
    
    output$table <- renderDT({
      dic()
    })
  })
  
  observeEvent(input$update, {
    global$mdic$drop()
    global$mdic$insert(dic()$x$data[!1])
    updateActionButton(session, "update", 
                       label = "Dictionary updated")
  })
  
}