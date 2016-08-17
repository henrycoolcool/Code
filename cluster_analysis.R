library(data.table)
library(lubridate)
library(dplyr)
library(leaflet)

#clean the raw data
df <- fread("201606-parkinglot-not-found.csv")
names(df) <- c("date","lat","lon","rad")
df1 = subset(df, lat>=21.9 & lat<=25.5 & lon>=120 & lon<=122 & rad<=3000 & rad>=300)
df1$date <- as.Date(df1$date)
df1 <- tbl_df(df1)
df1 = df1[,-3]


df1$wday <- wday(df1$date,label=T)
df1weekend <- subset(df1, wday == "Sun" | wday == "Sat")
df1workday <- subset(df1, wday == "Mon" | wday == "Tues" | wday == "Wed" | wday == "Thurs" | wday == "Fri")

#cluster analysis
d <- dist(df1, method = "euclidean")
fit <- hclust(d, method="ward") 
groups <- cutree(fit, k=10000)
df2 <- as.data.frame(groups)
df3[,ncol(df3)+1] <- df2
df3 <- df3[,-3]


#計算group內個數
df4 <- df3 %>%
  group_by(groups) %>%
  summarise(group_count = n(), mean_lat = mean(lat),mean_lon = mean(lon)) %>%
  arrange(desc(group_count))

#用leaflet畫互動式地圖
leaflet(coordinates) %>% addTiles() %>% 
  addMarkers(clusterOptions = markerClusterOptions(maxClusterRadius= 100))

