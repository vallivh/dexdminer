library(rhandsontable)
library(DT)

modifyDicUI <- function(id) {
  ns <- NS(id)
  tagList(
    textInput(ns("name"), "Dictionary name:", width = "50%"),
    DTOutput(ns("table")),
    actionButton(ns("update"), "Create Dictionary"),
    actionButton(ns("add_row"), "Add row")
  )
}


modifyDic <- function(input, output, session) {
  
  v <- reactiveValues(dic = data.frame(Words = c(NA)))
  
  proxy = dataTableProxy("table")
  
  observeEvent(global$dicoll, {
    v$dic <<- global$dic[names(global$dic) != "_id"]
    updateTextInput(session, "name", value = global$dicoll)
    updateActionButton(session, "update",
                       label = "Update dictionary")
  })
  
  observeEvent(input$add_row, {
    v$dic[nrow(v$dic)+1,] <- NA
  })
  
  output$table <- renderDT({
    datatable(v$dic, editable = TRUE)
  })
  
  observeEvent(input$table_cell_edit, {
    cell = input$table_cell_edit
    i = cell$row
    j = cell$col
    k = cell$value
    v$dic[i, j] <<- k
    replaceData(proxy, v$dic)
  })

  observeEvent(input$update, {
    global$mdic$drop()
    global$mdic <- mongoDB(input$name, db = "dics")
    global$mdic$insert(v$dic)
    updateActionButton(session, "update",
                       label = "Dictionary updated")
    global$dicoll <- input$name
  })
}