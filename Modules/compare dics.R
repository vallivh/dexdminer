source("functions/plot_2Dic.R")

#connect to mongoDB and return all dictionary collections
mdic <- mongoDB(db = "dics")
dicoll <- getCollections(mdic)

#UI----------------------------
compareDicsUI <- function(id, dictionary_id) {
  ns <- NS(id)
  tagList(
    selectInput(ns("dic1"),
                label = "Please select a collection",
                choices = c("", dicoll),
                selected = ""),
    selectInput(ns("dic2"),
                label = "Please select a collection",
                choices = c("", dicoll),
                selected = ""),
    selectInput(ns("intervall"),
                label = "Intervall",
                choices = c(month = "month", year = "year")),
    radioButtons(ns("plot_style"),
                 label = "Choose your Barchart Style",
                 choices = c("Gouped Barchart" = "group", "Stacked Barchart" = "stack")),
    actionButton(ns("refresh_plot_data"), label = "Update Plot"),
    plotlyOutput(ns("bar_chart_dicts"))
  )
}

#Server--------------------------------
compareDics <- function(input, output, session) {
  
  observeEvent(global$dicoll, ignoreInit = FALSE, {
    dicoll <- getCollections(mdic)
    updateSelectInput(session, "dic1",
                      choices = dicoll)
    updateSelectInput(session, "dic2",
                      choices = dicoll)
  })
  
  makeDic <- function(dic_name) {
    mdic <- mongoDB(collection = dic_name, db = "dics")
    dfdic <- mdic$find('{}', fields = '{}')
    dic <- dictionary(list(words = dfdic))
  }
  
  plot_data <- eventReactive(input$refresh_plot_data, {
    plot_dictionaries(
      dfm = global$dfm,
      dictio_1 = makeDic(input$dic1),
      dictio_2 = makeDic(input$dic2),
      intervall = input$intervall,
      barmode = input$plot_style
    )
  })
  
  output$bar_chart_dicts <- renderPlotly({
    plot_data()
  })
}