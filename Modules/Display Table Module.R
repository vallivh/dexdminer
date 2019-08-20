
displayTableUI <- function(id) {
  ns <- NS(id)
  dataTableOutput(ns("table"))
}


displayTable <- function(input, output, session, data) {
  output$table <- renderDataTable({
    data
  })
}