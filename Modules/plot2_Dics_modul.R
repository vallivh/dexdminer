source(paste0(getwd(),
              "/Funktionen/",
              "plot_2Dic.R"),
       local = TRUE)

#UI----------------------------
plot_2DicUI <- function(id, dictionary_id) {
  ns <- NS(id)
  tagList(
    selectInput(
      ns("dictio1"),
      label = "Dictionary 1",
      choices = c("Press Update")
    ),
    selectInput(
      ns("dictio2"),
      label = "Dictionary 2",
      choices = c("Press Update")
    ),
    selectInput(
      ns("intervall_dictionaries"),
      label = "Intervall",
      choices = list(month = "month", year = "year")
    ),
    actionButton(ns("refresh_plot_data"), label = "Update Plot"),
    actionButton(ns("refresh_2dictionaries"), label = "Update Dictionaries"),
    radioButtons(
      ns("plot_style"),
      label = "Choose your Barchart Style",
      choices = c("Gouped Barchart" = "group", "Stacked Barchart" = "stack")
    ),
    plotlyOutput(ns("bar_chart_dicts"))
  )
}

#Server--------------------------------
plot_2Dic <- function(input, output, session) {
  vec_name_obj <- eventReactive(input$refresh_2dictionaries, {
    liste <-
      import_excels(list.files(paste0(getwd(), "/Daten/Dictionaries/")))
    vec_name <- c()
    i <- 1
    for (i in 1:length(liste)) {
      vec_name[i] <- names(liste[[i]])
      i <- i + 1
    }
    return(vec_name)
  })
  
  observeEvent(input$refresh_2dictionaries,
               {
                 updateSelectInput(session = session,
                                   inputId = "dictio1",
                                   choices = vec_name_obj())
               })
  observeEvent(input$refresh_2dictionaries,
               {
                 updateSelectInput(session = session,
                                   inputId = "dictio2",
                                   choices = vec_name_obj())
               })
  plot_data <- eventReactive(input$refresh_plot_data, {
    plot_dictionaries(
      dfm = dfm_data(),
      dictio_1 = import_excel(as.character(input$dictio1)),
      dictio_2 = import_excel(paste0(as.character(input$dictio2))),
      intervall = input$intervall_dictionaries,
      barmode = input$plot_style
    )
  })
  
  output$bar_chart_dicts <- renderPlotly({
    plot_data()
  })
}