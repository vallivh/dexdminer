source("functions/find_collo.R")

#UI-----------------------------
collocationUI <- function(id) {
  ns <- NS(id)
  tagList(
    actionButton(ns("update"), label = "Update Collocations"),
    numericInput(
      ns("coll_size"),
      label = "Size of the Collocation",
      min = 2,
      value = 3,
      max = 10,
      step = 1,
      width = 100
    ),
    sliderInput(
      ns("min_count"),
      label = "Minimum count of the Collocation",
      min = 10,
      max = 300,
      value = 30,
      step = 5,
      width = 700
      
    ),
    DT::dataTableOutput(ns("coll_table")),
    em("requires a Tokens object")
  )
}

#Server-------------------------
collocation <- function(input, output, session) {
  col_datatable <- eventReactive(input$update, {
    col_dataframe <- find_coll(
      Token_object = global$tokens,
      size = input$coll_size,
      min_count = input$min_count
    )
    return(col_dataframe)
  })
  output$coll_table <- DT::renderDataTable(col_datatable())
}