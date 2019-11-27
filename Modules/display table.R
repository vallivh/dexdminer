
displayTableUI <- function(id) {
  ns <- NS(id)
  DTOutput(ns("table"))
}


displayTable <- function(input, output, session, data) {
  output$table <- renderDT({
    if (is.element("_id", colnames(data)))
      data[names(data) != "_id"]
    else
      data
  })
}