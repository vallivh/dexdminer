
plot_dictionaries <-
  function(dfm, dictio_1, dictio_2, intervall, barmode = "stack") {
    missing_values1 <- dictio_1[[1]] == ""
    dictio_1[[1]][missing_values1] <- "-"
    missing_values2 <- dictio_2[[1]] == ""
    dictio_2[[1]][missing_values2] <- "-"
    if (intervall == "year") {
      dfm_runtime <- dfm_group(dfm, groups = "year")
      data <-
        data.frame(
          dic1_counts = rowSums(dfm_lookup(dfm_runtime, dictionary = dictio_1)) ,
          dic2_counts = rowSums(dfm_lookup(dfm_runtime, dictionary = dictio_2)) ,
          year = docvars(dfm_runtime)
        )
      return(
        plot_ly(
          data,
          x = data$year,
          y = data$dic1_counts,
          type = 'bar',
          name = 'Dictionary 1'
        ) %>%
          add_trace(y = data$dic2_counts, name = 'Dictionary 2') %>%
          layout(yaxis = list(title = 'Count'), barmode = barmode)
      )
    }
    if (intervall == "month") {
      dfm_runtime <- dfm_group(dfm, groups = "month")
      data <-
        data.frame(
          dic1_counts = rowSums(dfm_lookup(dfm_runtime, dictionary = dictio_1)) ,
          dic2_counts = rowSums(dfm_lookup(dfm_runtime, dictionary = dictio_2)) ,
          month = docvars(dfm_runtime)
        )
      return(
        plot_ly(
          data,
          x = data$month,
          y = data$dic1_counts,
          type = 'bar',
          name = 'Dictionary 1'
        ) %>%
          add_trace(y = data$dic2_counts, name = 'Dictionary 2') %>%
          layout(yaxis = list(title = 'Count'), barmode = barmode)
      )
    }
  }

# #Test-----------
# dictio_test1 <- import_excel("Dictionary Guitar.xlsx")
# dictio_test2 <- import_excel("Dictionary Guitar.xlsx")
# dfm_test <- data_prep_dfm(paste0(getwd(), "/Daten/Text_data/Musical_Instruments_5.json"))
# plot_dictionaries(dfm_test, dictio_test1, dictio_test2, intervall = "month",barmode = "group")
# dfm_lookup(dfm_test, dictio_test1)
