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
    dic(global$dic[names(global$dic) != "_id"])
    output$table <- renderDT({
      datatable(dic(), editable = "column")
    })
  })
  
  observeEvent(input$update, {
    proxy = dataTableProxy("table")
    replaceData(proxy, dic())
    print(dic())
    # global$mdic$drop()
    # global$mdic$insert(dic())
    updateActionButton(session, "update", 
                       label = "Dictionary updated")
  })
  
}