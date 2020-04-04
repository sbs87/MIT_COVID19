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




tmp<-merge(US_County_Population_Cleaned,HealthCare_Capacity)
intersect(names(US_County_Population_Cleaned),names(HealthCare_Capacity))
head(HealthCare_Capacity)
filter(US_County_Level,UID=="Albany_New York")
intersect(names(tmp),names(US_County_Level))
master_table<-merge(US_County_Level,tmp)
names(master_table)
head(names(master_table))
nrow(master_table)
head(master_table)



intersect(names(master_table),
names(US_County_Population_Cleaned))
write.table(master_table,file = "/Users/stevensmith/Projects/MIT_COVID19/data/MASTER_cases_population_beds.txt",quote = F,row.names = F,sep="\t")
intersect(names(master_table),
names(select(US_County_Population_Cleaned,c("X","Census","X2019","UID"))))
