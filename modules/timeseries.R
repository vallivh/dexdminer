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
      choiceNames = c("none", "overall rating"),
      choiceValues = c("asin", "overall")
    ),
    actionButton(ns("update"), label = "Update Plot"),
    plotOutput(ns("bar_chart"))
  )
}


timeseries <- function(input, output, session) {
  
  observeEvent(input$update, {
    
    # get the aggregrated data from mongoDB and clean the dataframe
    df <- global$m$aggregate(
      paste0(
        '[{"$match":{"$text":{"$search": "', input$word,'"}}},
          {"$group":{
              "_id": {"', input$intervall, '": {"$', input$intervall, '": "$date"},
                      "rating": "$overall"},
              "count": {"$sum": 1}}},
          {"$sort": {"_id": 1}}]'
      )
    )
    df <- jsonlite::flatten(df)
    colnames(df) <- lapply(colnames(df), function(x){sub("_id.", "", x)})
    
    output$bar_chart <- renderPlot({
      ggplot(df, aes(y=count, x=month)) +
        geom_bar(aes(fill=rating), stat="identity")
    })
  })
}