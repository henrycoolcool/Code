library(data.table)
library(dplyr)
library(ggplot2)
library(lubridate)
library(jsonlite)

##處理json
pk = fromJSON("pklots.json")

v = c("parkinglot_periods", "available_lots", "id", "lat", "lng", "name", "address")

names(pk) = c("parkinglot_id", "lat", "lng","available_lots", "name", "address", "parkinglot_periods")

pk = pk[,names(pk) %in% v]


##Read CSV
df = fread("/myCSV.csv")

df = tbl_df(df)

df1 = fread("~/Documents/大聲公/undefine/with_device_id.csv")

df1 = tbl_df(df1)

names(df1) = c("id", "days", "duration", "avg", "clicks_per_day")


##分類
disloyal = as.vector(filter(df1, days == 1)[[1]])

loyal = as.vector(filter(df1, days >= 6)[[1]])

df_loyal = df[df$device_id %in% loyal,]

df_disloyal = df[df$device_id %in% disloyal,]

##預設地區停車場ID
default_lot = c(5857, 3837, 32, 1998, 4134, 31, 63, 1293, 60, 151, 40, 59,
                1300, 65, 43, 5237, 4625, 1280, 96, 48, 42, 1591, 1220, 66,
                995, 1224, 1289, 4830, 1025, 849, 1666, 1223, 67, 1097, 3586,
                1283, 1304, 815, 5517, 1298, 1096, 1027, 1225, 1291, 1296, 1162, 1295, 5515, 1281)



##留下第一天的紀錄
test1 = df_loyal

result = aggregate(date~device_id,df_loyal,min)

test = merge(df_loyal, result, by = 'device_id',all.x =TRUE)

test = test[test$date.y == test$date.x,]


##點停車場前有點定位或點搜尋
test = df_loyal
IDs<-unique(test$device_id)
df2 = data.frame()

for (i in 1:length(IDs)){ 
  temp <- test[test$device_id==IDs[i],]
  for(j in 1:nrow(temp)){
    if(temp$log_type[j]!='marker_click'){
      temp = temp[j:nrow(temp),]
      df2 = rbind(df2,temp)
      break
    }
  }
  print(IDs[i])
}











