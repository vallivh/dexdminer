
m <- mongoDB("Instruments")

df <- m$find('{}')

df$date <- anytime(df$reviewTime)

df$date

df[9,]
