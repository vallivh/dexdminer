m <- mongoDB("Instruments")

m$find('{}', '{"_id":1}')
