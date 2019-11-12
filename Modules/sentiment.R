library(shiny)
library(jsonlite)
library(plotly)

source("functions/helper.R")

sentimentUI <- function(id) {
  ns <- NS(id)
  tagList(
    actionButton(ns("show"), "Show Sentiment", icon = icon("smile")),
    actionButton(ns("save"), "Save Results"),
    plotlyOutput(ns("sentiPlot"))
  )
}

sentiment <- function(input, output, session) {

  # Erzeugt aus global$tokens einen Data Frame mit Document ID und Anzahl der pos/neg Wörter im Dokument
  df <- reactive({
    dfm <- dfm(tokens_lookup(req(global$tokens), data_dictionary_LSD2015))
    dfm_convert(dfm)
  })

  # Beim Klick auf den Save Button werden die df() Daten in MongoDB gespeichert
  # es werden neue Felder 'positive' und 'negative' angelegt
  observeEvent(input$save, {
    apply(df(), 1,
          function(x) {
            global$m$update(
              query = paste0('{"_id":{"$oid":"', x[1], '"}}'),
              update = paste0('{"$set": {"positive": ', x[3], ', "negative": ', x[2], '}}'))
            })
    apply(c("positive", "negative"), 1,
          function(x) {
            global$m$index(add = parseIndex(x[1]))
          })
    global$data <- global$m$find('{}', fields = '{}')
  })

  # Beim Klick auf den Show Button wird ein Bar Chart der pos/neg Wörter gerendert
  # Vor-Aggregation auf Jahres- und Monatsebene geschieht in MongoDB
  # im Moment nur möglich, wenn pos/neg Count bereits in MongoDB gespeichert ist
  observeEvent(input$show, {
    
    if(c("positive", "negative") %in% names(global$data)) {
      df <- global$m$aggregate('[{"$group":{
                                    "_id": {"year": {"$year": "$date"}, "month": {"$month": "$date"}},
                                    "positive": {"$sum": "$positive"},
                                    "negative": {"$sum": "$negative"}
                                    }
                                  },
                                  {"$sort": {"_id": 1}}]')
      df <- jsonlite::flatten(df)
      colnames(df) <- lapply(colnames(df), function(x){sub("_id.", "", x)})
      df["negative"] <- -df["negative"]
    } else {
      df <- df()
    }

    output$sentiPlot <- renderPlotly({
      plot_ly(df, x = ~year, y = ~positive,
              type = "bar",
              name = "Positive Words") %>%
        add_trace(y = ~negative,
                  name = "Negative Words") %>%
        layout(title = "Count of pos/neg words",
               yaxis = list(title = "Count"),
               xaxis = list(title = "Time"),
               barmode = "relative")
    })
  })
}