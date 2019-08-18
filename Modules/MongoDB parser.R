parseFields <- function(flist){
  inBrackets <- paste0(paste0('"', flist, '": true'), collapse = ",")
  fullQuery <- paste0("{", inBrackets, "}")
  return(fullQuery) 
}

parseQuery <- function(...){
  
}

mongoDB <- function(db = "mongotest", collection = NULL) {
  if (missing(collection)) {
    m <- mongo(db = db,
               url = "mongodb://127.0.0.1:27017/?gssapiServiceName=mongodb")
    return(m)
  }
  else
    mongo(collection = collection,
          db = db,
          url = "mongodb://127.0.0.1:27017/?gssapiServiceName=mongodb")
}
