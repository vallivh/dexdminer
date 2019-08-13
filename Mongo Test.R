library(mongolite)
library(jsonlite)
library(nycflights13)
library(ndjson)
source("MongoDB parser.R")

m <- mongo(url = "mongodb://127.0.0.1:27017/?gssapiServiceName=mongodb", collection = "nycflights", db = "mongotest")

getwd()

df <- stream_in("/Users/Valentin/Desktop/reviews_Musical_Instruments_5.json")
typeof(df)
m$insert(df)

m$count()
qry1 <- m$find('{"month":{ "$in": [1,2] }, "day":1, "carrier":"AA"}', fields = '{"year": true, "month": true, "day": true, "carrier": true}')
qry2 <- m$distinct("month", query = '{"month":{"$in":[1,2]}}')
qry3 <- m$aggregate('[
          {"$match":{"carrier":{"$in":[""]}}},
          {"$group":{"_id":"$carrier", "average_delay":{"$avg":"$arr_delay"}}}
          ]')

x <- m$find()
typeof(x)

qry4 <- m$find('{}', fields = parseFields(c('year', 'month', 'day')))
qry4
