sentiment_analysis <-
  function(Token_object,
           dictionary = data_dictionary_LSD2015,
           intervall = "year") {
    #year------------------
    if ("year" == intervall) {
      dfm_sent <-
        dfm(tokens_lookup(Token_object, dictionary = dictionary))
      
      dfm_runtime <- dfm_group(dfm_sent, groups = "year")
      data_runtime <-
        data.frame(
          sentiment_count_pos = as.vector(dfm_runtime[, "positive"]),
          sentiment_count_neg = as.vector(dfm_runtime[, "negative"]),
          Zeit = docvars(dfm_runtime, 'year')
        )
      return(
        p <- plot_ly(
          data_runtime ,
          y = data_runtime[, 1],
          x = data_runtime[, 3],
          type = "bar",
          name = "Positive"
        ) %>%
          add_trace(y = data_runtime[, 2], name = "Negative") %>%
          layout(yaxis = list(title = 'Count'), barmode = 'group')
        
      )
    }
    #Else keine Daten vorhanden gebe Nullen aus----------------
    else
      data_runtime <-
        data.frame(word_count = as.vector(rep(0, nrow(dfm_runtime))),
                   Zeit = docvars(dfm_runtime, 'month'))
    return(
      plot_ly(
        data_runtime,
        y = data_runtime[, 1],
        x = data_runtime[, 2],
        type = "bar",
        name = "char_title"
      )
    )
   }