
target_collocation <-
  function(words,
           Token_object,
           window_count = 10,
           min_n_target = 10,
           return_count = 50) {
    #Aufteilen in zwei Corpora, welche dann miteinander verglichen werden können-----------
    dfm_word <-
      dfm(tokens_keep(Token_object,
                      pattern = phrase(words),
                      window = window_count))
    
    dfm_no_word <-
      dfm(tokens_remove(Token_object,
                        pattern = phrase(words),
                        window = window_count))
    
    #Berechnung der Keyness---------------
    tstat_key_word <-
      textstat_keyness(rbind(dfm_word, dfm_no_word), seq_len(ndoc(dfm_word)))
    
    
    #Subsetting falls gewünscht-----------------
    tstat_key_word_subset <-
      tstat_key_word[tstat_key_word$n_target > min_n_target,]
    
    head(tstat_key_word_subset, return_count)
  }