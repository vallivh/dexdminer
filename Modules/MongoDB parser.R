library(mongolite)
library(rapportools)

# makes connecting to MongoDB a lot easier, default db should be changed here
mongoDB <- function(collection = NULL, db = "monogtest") {
  if (is.null(collection)) {
    mongo(db = db,
          url = "mongodb://127.0.0.1:27017/?gssapiServiceName=mongodb")
  }
  else
    mongo(collection = collection,
          db = db,
          url = "mongodb://127.0.0.1:27017/?gssapiServiceName=mongodb")
}

# converts a list of fields into a json string to be used in $find(..., fields = )
parseFields <- function(flist){
  inBrackets <- paste0(paste0('"', flist, '": 1'), collapse = ",")
  fullQuery <- paste0("{", inBrackets, "}")
  return(fullQuery) 
}

# makes creating a text index a lot easier
# could be expanded to indexes in general
parseIndex <- function(field, text = FALSE){
  if (text)
    end <- '"text"'
  else 
    end <- 1
  
  inBrackets <- paste0(paste0('"', field, '": ', end), collapse = ",")
  fullQuery <- paste0("{", inBrackets, "}")
  return(fullQuery)
}

# finds all indexes of a collaction 
# either returns the text index or all other indexes
# can return full index names or original field names
# makes use of the automatic naming of indexes
getIndex <- function(con = NULL, fields = TRUE, text = FALSE) {
  indexes <- con$index()$name
  if (text)
    end <- "_text"
  else 
    end <- "_1"
  
  index <- grep(paste0(end, "$"), indexes, value = TRUE)
  if (fields)
    index <- sub(end, "", index)

  if (is.empty(index))
    return(NULL)
  else
    return(index)
}
