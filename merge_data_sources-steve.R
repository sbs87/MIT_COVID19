# Merge data sources
rm(list=ls())
setwd("/Users/stevensmith/Projects/MIT_COVID19/data")


HealthCare_Capacity<-read.table("HealthCare_Capacity.modified.csv",header = F,sep="\t",skip = 1,stringsAsFactors = F)
US_County_Level<-read.csv("US_County_Level.modified.csv",header = T,stringsAsFactors = F)
#US_County_Population<-read.table("US_County_Population.modified.txt",header = T,sep = "\t",stringsAsFactors = F,quote = "")
US_County_Population_Cleaned<-read.csv("/Users/stevensmith/Projects/MIT_COVID19/data_cleaned/US_County_Population_Cleaned.csv",header = T)
state_code_map<-read.table("/Users/stevensmith/Projects/MIT_COVID19/data/state_code_map.txt",header = T,sep = "\t",stringsAsFactors = F)
FIPS_map<-read.csv("FIPS_map.csv",header = T)

US_County_Level<-merge(US_County_Level,FIPS_map,by.x = "fips",by.y = "FIPS")



US_County_Population_Cleaned$County<-gsub(US_County_Population_Cleaned$County,pattern = " County",replacement = "")
US_County_Population_Cleaned[US_County_Population_Cleaned$County=="NYC","County"]<-"New York"
US_County_Population_Cleaned$UID<-paste0(US_County_Population_Cleaned$County,"_",US_County_Population_Cleaned$State)
US_County_Population_Cleaned<-select(US_County_Population_Cleaned,-c("County","State"))

names(HealthCare_Capacity)<-c("HRR","Total Hospital Beds","Total ICU Beds","Available Hospital Beds","Potentially Available Hospital Beds","Available ICU Beds","Potentially Available ICU Beds","Adult Population","Population 65 over")
HealthCare_Capacity<-separate(HealthCare_Capacity, HRR, into = c("county","state.code"), sep = ", ")


HealthCare_Capacity<-merge(HealthCare_Capacity,state_code_map) %>% select(-c("abrev","state.code"))
HealthCare_Capacity$UID<-paste0(HealthCare_Capacity$county,"_",HealthCare_Capacity$State)
HealthCare_Capacity<-select(HealthCare_Capacity,-c("State","county"))

US_County_Level$UID<-paste0(US_County_Level$county,"_",US_County_Level$state)
US_County_Level<-select(US_County_Level,-c("state","county"))

master_table.pop<-merge(US_County_Level,US_County_Population_Cleaned,all.x = T)
master_table<-merge(master_table.pop,HealthCare_Capacity,all.x = T)


tmp<-merge(US_County_Population_Cleaned,HealthCare_Capacity)
intersect(names(US_County_Population_Cleaned),names(HealthCare_Capacity))
head(HealthCare_Capacity)
filter(US_County_Level,UID=="Albany_New York")
intersect(names(tmp),names(US_County_Level))

names(master_table)
head(names(master_table))
nrow(master_table)
head(master_table)



intersect(names(master_table),
names(US_County_Population_Cleaned))
write.table(master_table,file = "/Users/stevensmith/Projects/MIT_COVID19/data/MASTER_cases_population_beds.txt",quote = F,row.names = F,sep="\t")
intersect(names(master_table),
names(select(US_County_Population_Cleaned,c("X","Census","X2019","UID"))))




master_table$case_per_2019_op<-master_table$cases/master_table$X2019

ggplot(dplyr::filter(master_table,UID=="New York_New York"),aes(x=date,y=cases))+geom_point()
tmp<-matrix(master_table$Lat)
row.names(tmp)<-master_table$UID

tmp.dist<-dist(unique(tmp))
nrow(master_table)

install.packages("geosphere")
library(geosphere)
distm(c(master_table$Lat[1], master_table$Long_[1]), c(master_table$Lat[2], master_table$Long_[2]), fun = distHaversine)


master_table$date=="2020-04-01"
head(master_table)
select(master_table,c("UID","date","day_before_index"))
MERGED_PETER<-read.csv("/Users/stevensmith/Projects/MIT_COVID19/data_cleaned/Distance_Calculations.csv",header = T,stringsAsFactors = F)

master_table.filter<-filter(MERGED_PETER,!is.na(Area_.sqmi.),!is.na(Population))
master_table.filter$day_before_index<-as.Date(master_table.filter$date)-1
master_table.filter$date<-as.Date(master_table.filter$date)


for(i in 1:nrow(master_table.filter)){
  #i<-1
  day_before_index.i<-master_table.filter[i,"day_before_index"]
  UID.i<-master_table.filter[i,"Unique_ID"]
  day_before_cases<-NA
  if(min( master_table.filter[master_table.filter$Unique_ID==UID.i,"date"])>=day_before_index.i){
    day_before_cases<-NA
  }else{
    day_before_cases<-master_table.filter[master_table.filter$Unique_ID==UID.i & master_table.filter$date==day_before_index.i,"cases"][1]
  
  }
if(is.null(length(day_before_cases))){
  day_before_cases<-NA
}
  master_table.filter[i,"day_before_cases"]<-day_before_cases
}

master_table.filter$day_before_cases


ggplot(master_table.filter,aes(x=date,y=day_before_cases))+geom_point()+
  geom_point(aes(y=cases),col='red')


write.csv(master_table.filter,"/Users/stevensmith/Projects/MIT_COVID19/output/MASTER_filtered_withlag.csv",quote = F,row.names = F)

