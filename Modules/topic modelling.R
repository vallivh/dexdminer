source("functions/tm.R")

#UI-------------------
tmUI <- function(id) {
  ns <- NS(id)
  tagList(
    sliderInput(
      ns("num_of_docs"),
      label = "Number of documents",
      min = 10,
      max = 2000,
      step = 10,
      value = 50,
      width = '400px'
    ),
    sliderInput(
      ns("min_termfreq"),
      label = "Minimum Term Frequency",
      min = 0.5,
      max = 1,
      step = 0.05,
      value = 0.8,
      width = '400px'
    ),
    sliderInput(
      ns("max_docfreq"),
      label = "Maximum Document Frequency",
      min = 0,
      max = 0.5,
      step = 0.05,
      value = 0.2,
      width = '400px'
    ),
    numericInput(
      ns("topic_number"),
      label = "Number of Topics",
      value = 2,
      min = 2,
      max = 10,
      step = 1,
      width = '100px'
      
    ),
    numericInput(
      ns("return_words"),
      label = "Number of returned Words",
      value = 10,
      min = 3,
      max = 30,
      step = 1,
      width = '200px'
    ),
    actionButton(ns("start"), label = "Apply"),
    DTOutput(ns("datatable_r"))
  )
  
}

#Server----------------
tm <- function(input, output, session) {
  
  datatable_r <- eventReactive(input$start, {
      a <- tm_func(
        dfm_object = global$dfm,
        num_of_docs = input$num_of_docs,
        min_termfreq = input$min_termfreq,
        max_docfreq = input$max_docfreq,
        topic_number = input$topic_number,
        return_words = input$return_words
      )
      return(a)
  })

  output$datatable_r <- renderDT({
    datatable_r()
  })
}
