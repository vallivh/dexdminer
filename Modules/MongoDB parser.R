library(mongolite)
library(rapportools)

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

# finds all indexes of a collaction 
# either returns the text index or all other indexes
# can return full index names or original field names
# makes use of the automatic naming of indexes
getIndex <- function(con = NULL, fields = TRUE, text = FALSE) {
  vec <- con$index()$name
  if (text)
    end <- "_text"
  else 
    end <- "_1"
  
  index <- grep(paste0(end, "$"), vec, value = TRUE)
  if (fields)
    index <- unlist(strsplit(gsub(end, "", index), "_"))

  if (is.empty(index))
    return("")
  else
    return(index)
}

m <- mongoDB("Instruments")
i <- getIndex(m, text = TRUE)
i
