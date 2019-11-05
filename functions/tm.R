
tm_func <-
  function(dfm_object,
           numb_of_docs = 50,
           min_termfreq = 0.8,
           max_docfreq = 0.2,
           topic_number = 2,
           return_words = 10) {

    #auswählen eines Datensatzes---------
    dfm_runtime <- dfm_object[1:numb_of_docs]
    
    #Gruppieren des Datensatzes nach ID des Produktes---------
    dfm_runtime <-
      dfm_group(dfm_runtime, groups = docvars(dfm_runtime, field = "asin"))
    
    #Trimmen der dfm und entfernen von nichts sagenden Worten---------
    dfm_trimed <-
      dfm_trim(
        dfm_runtime,
        min_termfreq = min_termfreq,
        termfreq_type = "quantile",
        max_docfreq = max_docfreq ,
        docfreq_type = "prop"
      )

    #Topic Model-----------
    dtm <- convert(dfm_trimed, to = "topicmodels")
    lda <- LDA(dtm, k = topic_number)
    
    #returnen eines Dataframes mit den gegebenen Worten
    return(data.frame(terms(lda, return_words), stringsAsFactors = FALSE))
  }
