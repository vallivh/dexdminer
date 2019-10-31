
displayTableUI <- function(id) {
  ns <- NS(id)
  DT::dataTableOutput(ns("table"))
}


displayTable <- function(input, output, session, data) {
  output$table <- DT::renderDataTable({
    if (is.element("_id", colnames(data)))
      data[names(data) != "_id"]
    else
      data
  })
}