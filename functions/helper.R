dfm_convert <- function(dfm) {
  df <- convert(dfm, to = "data.frame")
  df$year <- year(docvars(dfm, "date"))
  df$month <- month(docvars(dfm, "date"))
  return(df)
}

makeDic <- function(dic_name) {
  mdic <- mongoDB(collection = dic_name, db = "dics")
  dfdic <- mdic$find('{}', fields = '{}')
  dic <- dictionary(list(words = dfdic))
}