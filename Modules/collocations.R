source(paste0(getwd(),
              "/Funktionen/",
              "collocations.R"),
       local = TRUE)

#UI-----------------------------
find_collocationUI <- function(id) {
  ns <- NS(id)
  tagList(
    actionButton(ns("get_coll"), label = "Update Collocations"),
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
    dataTableOutput(ns("coll_table"), width = 900)
  )
}

#Server-------------------------
find_collocation <- function(input, output, session) {
  col_datatable <- eventReactive(input$get_coll, {
    col_dataframe <- find_coll(
      Token_object = Token_data(),
      size = input$coll_size,
      min_count = input$min_count
    )
    return(col_dataframe)
  })
  output$coll_table <- renderDataTable(col_datatable())
}