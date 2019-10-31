source(paste0(getwd(),
              "/Funktionen/",
              "data_prep_dfm.R"),
       local = TRUE)

find_coll <- function(Token_object = Token_data , size, min_count) {
  if (min_count > 5) {
    coll_runtime <- tokens_select(
      Token_object,
      pattern = '^[a-z]',
      valuetype = 'regex',
      case_insensitive = FALSE,
      padding = TRUE
    )
    coll_stat <-
      textstat_collocations(coll_runtime, min_count = min_count, size = size)
    coll_stat <-
      coll_stat[order(coll_stat$count, decreasing = TRUE), ]
    coll_df <-
      data.frame(
        collocation_name = coll_stat[[1]],
        collocation_count = coll_stat[[2]],
        lambda = coll_stat[[5]],
        z_value = coll_stat[[6]],
        stringsAsFactors = FALSE
      )
    return(coll_df)
  }
  else
    print("your min_count Argument is to low")
}

#Test hier--------------
#df <- find_coll(Token_data, size = 3, min_count = 20)
