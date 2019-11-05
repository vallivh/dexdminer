source(paste0(getwd(), "/Funktionen/target_collocation.R"),
       local = TRUE)

#UI---------------------
target_collUI <- function(id) {
  ns <- NS(id)
  tagList(
    sliderInput(
      ns("window_count"),
      label = "Window Count",
      min = 5,
      max = 20,
      step = 1,
      value = 10,
      width = '400px'
    ),
    sliderInput(
      ns("min_n_target"),
      label = "Minimum Number of Window Occurrences",
      min = 5,
      max = 100,
      step = 5,
      value = 10,
      width = '400px'
    ),
    numericInput(
      ns("return_count"),
      label = "Number of returned words",
      value = 50,
      min = 20,
      max = 100,
      step = 1,
      width = '100px'
    ),
    textInput(
      ns("target_word"),
      placeholder = "lower cases",
      label = "Word for Collocations",
      value = "Example",
      width = 600
    ),
    actionButton(ns("refresh_tc"), label = "Update Collocation"),
    DTOutput(ns("target_coll_out"))
  )
}

#Server----------------------------
target_coll <- function(input, output, session) {
  target_coll_data <- eventReactive(input$refresh_tc, {
    target_collocation(
      words = input$target_word,
      Token_object = Token_data(),
      window_count = input$window_count,
      min_n_target = input$min_n_target,
      return_count = input$return_count
    )
  })
  output$target_coll_out <-
    DT::renderDataTable(target_coll_data())
}
