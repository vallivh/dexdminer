library(mongolite)

parseFields <- function(flist){
  inBrackets <- paste0(paste0('"', flist, '": true'), collapse = ",")
  fullQuery <- paste0("{", inBrackets, "}")
  return(fullQuery) 
}

parseIndex <- function(tlist, name = NULL){
  inBrackets <- paste0(paste0('"', tlist, '": "text"'), collapse = ",")
  fullQuery <- paste0("{", inBrackets, "}")
  if (!is.null(name))
    fullQuery <- paste0(fullQuery, ', {"name": "', name, '"}')
  return(fullQuery)
}

parseIndex(c("review", "summary"), "textIndex")

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

