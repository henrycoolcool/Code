library(data.table)
library(dplyr)
library(lubridate)
library(ggplot2)

#抓出cohort group
df1 = fread("~/Documents/parkinglot-log-20160810.csv")
df1 = tbl_df(df1)
df1 = df1[,c(1,4)]
df1$date = strftime(df1$V1, format = '%Y-%m')
df1 = df1[,-1]
names(df1) = c('device_id', 'date')
df1 = unique(df1)

result = aggregate(date~device_id,df1,min)

df2 = merge(df1, result, by = "device_id", all.x = T)

df3 = df2[-c(1:18),]
names(df3) = c("device_id", "date", "date_of_join")

df4 = df3 %>%
  group_by(date_of_join) %>%
  count(date_of_join, date, sort= T) %>%
  arrange(date_of_join,date)


#替換 period 改成 level
df5 = data.frame()
for(i in 1:length(unique(df4$date_of_join))){
  temp <- df4[df4$date_of_join == unique(df4$date_of_join)[i],]
  for(j in 1:length(temp$date)){
    temp$date[j] = j
  }
  df5 = rbind(df5, temp)
}
names(df5) = c('cohort', 'period', 'count')

#計算retention
df6 =data.frame()
for(i in 1:length(unique(df5$cohort))){
  temp <- df5[df5$cohort == unique(df5$cohort)[i],]
  a = temp$count[1]
  for(j in 1:length(temp$count)){
    temp$count[j] = temp$count[j] / a
  }
  df6 = rbind(df6, temp)
}
names(df6) = c('cohort', 'period', 'retention')

for(i in 1:length(unique(df6$cohort))){
  df6[df6$cohort == unique(df6$cohort)[i],]$cohort = i
}
df6$cohort = as.integer(df6$cohort)
df6$period = as.integer(df6$period)

#畫HeatMap
ggplot(df6, aes(x = period, y = cohort)) +
  ggtitle('Retention by cohort') +
  theme_bw() +
  xlab('Period (Month)') +
  scale_x_continuous(breaks=seq(1, 15, 1))+
  ylab('Cohort') +
  scale_y_reverse(breaks=seq(1, 15, 1), labels=c("2015-6", "2015-7", "2015-8",
                                                 "2015-9", "2015-10", "2015-11", "2015-12", "2016-1",
                                                 "2016-2", "2016-3", "2016-4", "2016-5", "2016-6", "2016-7","2016-8"))+
  geom_tile(aes(fill = retention), color='white') +
  geom_text(aes(label = sprintf("%.1f %%", 100 * retention)), color = "black") +
  scale_fill_gradient(low = 'white', high = '#007799', space = 'Lab') +
  theme(axis.ticks=element_blank(),
        axis.line=element_blank(),
        panel.border=element_blank(),
        panel.grid.major=element_line(color='#eeeeee')) 


