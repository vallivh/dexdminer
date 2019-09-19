library(mongolite)
library(jsonlite)
library(anytime)
library(lubridate)
library(ndjson)

source(paste0(getwd(), "/Modules/MongoDB parser.R"))

m <- mongo(url = "mongodb://127.0.0.1:27017/?gssapiServiceName=mongodb", collection = "Instruments", db = "mongotest")
m$info()

m$run('{"listCollections": 1, "nameOnly": true}')

m$index(add = '{"reviewTime":1}')

qry1 <- m$find('{"month":{ "$in": [1,2] }, "day":1, "carrier":"AA"}', fields = '{"year": true, "month": true, "day": true, "carrier": true}')
qry2 <- m$distinct("month", query = '{"month":{"$in":[1,2]}}')
qry3 <- m$aggregate('[
          {"$match":{"carrier":{"$in":[""]}}},
          {"$group":{"_id":"$carrier", "average_delay":{"$avg":"$arr_delay"}}}
          ]')

qry4 <- m$find('{}', limit = 1)

#Textsuche benötigt text-Index, danach einfach über $find()
m$index(add = '{"reviewText": "text", "summary": "text"}')

date <- anytime(qry4$reviewTime)
day(date)