
sentimentUI <- function(id) {
  ns <- NS(id)
  tagList(
    actionButton(ns("showSenti"), "Show Sentiment", icon = icon("smile")),
    actionButton(ns("saveSenti"), "Save Results")
  )
}

sentiment <- function(input, output, session) {
  
  df <- reactive({
    lookup <- dfm(tokens_lookup(req(global$tokens), data_dictionary_LSD2015))
    convert(lookup, to = "data.frame")
  })
  
  observeEvent(input$showSenti, {
    print(global$m$aggregate('[{"$group":{
                                  "_id": {"year": {"$year": "$date"}, "month": {"$month": "$date"}}, 
                                  "positive": {"$sum": "$positive"}, 
                                  "negative": {"$sum": "$negative"}
                                  }
                                },
                                {"$sort": {"_id": 1}}]'))
  })
  
  observeEvent(input$saveSenti, {
    apply(df(), 1, function(x) {global$m$update(query = paste0('{"_id":{"$oid":"', x[1], '"}}'), 
                                              update = paste0('{"$set": {"positive": ', x[3], ', "negative": ', x[2], '}}'))})
    global$data <- global$m$find('{}', fields = '{}')
  })
}