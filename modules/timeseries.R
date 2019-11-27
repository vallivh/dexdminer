source("functions/plot_word_sex.R")

timeseriesUI <- function(id) {
  ns <- NS(id)
  tagList(
    textInput(
      ns("word"),
      placeholder = "Enter a word",
      label = "What are you looking for?",
      width = 500
    ),
    selectInput(
      ns("intervall"),
      label = "Time Intervall",
      choices = list(month = "month", year = "year"),
      width = 500
    ),
    radioButtons(
      ns("by"),
      label = "Plot by",
      choiceNames = c("none"),
      choiceValues = c(NA)
    ),
    actionButton(ns("update"), label = "Update Plot"),
    plotOutput(ns("bar_chart")),
    em("requires a Tokens object")
  )
}


timeseries <- function(input, output, session) {
  
  observeEvent(global$tokens, {
    choices <- names(docvars(global$tokens))
    choices <- choices[choices != "date"]
    updateRadioButtons(session, "by", 
                       choiceNames = choices,
                       choiceValues = choices)
  })
  
  observeEvent(input$update, {
    
    print(input$by)
    
    # get the aggregrated data from mongoDB and clean the dataframe
    df <- global$m$aggregate(
      paste0(
        '[{"$match":{"$text":{"$search": "', req(input$word),'"}}},
          {"$group":{
              "_id": {"', input$intervall, '": {"$', input$intervall, '": "$date"},
                      "', input$by, '": "$', input$by, '"},
              "count": {"$sum": 1}}},
          {"$sort": {"_id": 1}}]'
      )
    )
    df <- jsonlite::flatten(df)
    colnames(df) <- lapply(colnames(df), function(x){sub("_id.", "", x)})

    output$bar_chart <- renderPlot({
      ggplot(df, aes_string(y="count", x=isolate(input$intervall))) +
        geom_bar(aes_string(fill=isolate(input$by)), stat="identity")
    })
  })
}