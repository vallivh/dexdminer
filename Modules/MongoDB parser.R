library(mongolite)

# makes connecting to MongoDB a lot easier, default db should be changed here
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

# converts a list of fields into a json string to be used in $find(fields = )
parseFields <- function(flist){
  inBrackets <- paste0(paste0('"', flist, '": true'), collapse = ",")
  fullQuery <- paste0("{", inBrackets, "}")
  return(fullQuery) 
}

# makes creating a text index a lot easier
# could be expanded to indexes in general
parseIndex <- function(tlist, name = NULL){
  inBrackets <- paste0(paste0('"', tlist, '": "text"'), collapse = ",")
  fullQuery <- paste0("{", inBrackets, "}")
  return(fullQuery)
}

# finds the text index of a collaction and re-converts it into component fields on demand
# makes use of the automatic naming of indexes
getTextIndex <- function(con = NULL, fields = FALSE) {
  key <- con$index()$textIndexVersion
  if (is.null(key))
    return(NULL)
  else {
    for (i in 1:length(key)) {
      if (!is.na(key[i])) {
        indexName <- con$index()$name[i]
        if (fields)
          return (unlist(strsplit(gsub("_text", "", indexName), "_")))
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