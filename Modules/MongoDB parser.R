library(mongolite)

mongoDB <- function(collection = NULL, db = "mongotest") {
  if (is.null(collection)) {
    m <- mongo(db = db,
               url = "mongodb://127.0.0.1:27017/?gssapiServiceName=mongodb")
    return(m)
  }
  else
    mongo(collection = collection,
          db = db,
          url = "mongodb://127.0.0.1:27017/?gssapiServiceName=mongodb")
}


parseFields <- function(flist){
  inBrackets <- paste0(paste0('"', flist, '": true'), collapse = ",")
  fullQuery <- paste0("{", inBrackets, "}")
  return(fullQuery) 
}


parseIndex <- function(tlist, name = NULL){
  inBrackets <- paste0(paste0('"', tlist, '": "text"'), collapse = ",")
  fullQuery <- paste0("{", inBrackets, "}")
  return(fullQuery)
}


getTextIndex <- function(con = NULL, fields = FALSE) {
  key <- con$index()$textIndexVersion
  if (is.null(key))
    return(NULL)
  else {
    for (i in 1:length(key)) {
      if (!is.na(key[i])) {
        indexName <- con$index()$name[i]
        if (fields)
          return (strsplit(gsub("_text", "", indexName), "_"))
        else
          return(indexName)
        break
      }
      else {
        indexName <- NULL
        next
      }
    }
  }
}

name <- getTextIndex(mongoDB("Instruments"))
name
