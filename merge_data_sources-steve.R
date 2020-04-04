# Merge data sources

setwd("/Users/stevensmith/Projects/MIT_COVID19/data")


HealthCare_Capacity<-read.table("HealthCare_Capacity.modified.csv",header = F,sep="\t",skip = 1,stringsAsFactors = F)
US_County_Level<-read.csv("US_County_Level.modified.csv",header = T,stringsAsFactors = F)
US_County_Population<-read.table("US_County_Population.modified.txt",header = T,sep = "\t",stringsAsFactors = F,quote = "")

state_code_map<-read.table("/Users/stevensmith/Projects/MIT_COVID19/data/state_code_map.txt",header = T,sep = "\t",stringsAsFactors = F)
head(HealthCare_Capacity)
head(US_County_Level)
head(US_County_Population)

US_County_Population<-separate(US_County_Population, Geographic.Area, into = c("county","State"), sep = ", ")
US_County_Population$county<-gsub(US_County_Population$county,pattern = "^\\.",replacement = "")
US_County_Population$county<-gsub(US_County_Population$county,pattern = " County",replacement = "")

setdiff(US_County_Level$county,US_County_Population$county)
setdiff(US_County_Population$county,US_County_Level$county)


names(HealthCare_Capacity)<-c("HRR","Total Hospital Beds","Total ICU Beds","Available Hospital Beds","Potentially Available Hospital Beds","Available ICU Beds","Potentially Available ICU Beds","Adult Population","Population 65 over")
HealthCare_Capacity<-separate(HealthCare_Capacity, HRR, into = c("county","state_code"), sep = ", ")
#HealthCare_Capacity[HealthCare_Capacity$county=="Manhattan","county"]<-"New York City"
sum(HealthCare_Capacity$county=="New York")
setdiff(US_County_Level$county,HealthCare_Capacity$County)
setdiff(HealthCare_Capacity$county,US_County_Level$county)
intersect(HealthCare_Capacity$county,HealthCare_Capacity$county)
HealthCare_Capacity<-merge(HealthCare_Capacity,state_code_map)

US_County_Population$UID<-paste0(US_County_Population$county,"_",US_County_Population$State)
HealthCare_Capacity$UID<-paste0(HealthCare_Capacity$county,"_",HealthCare_Capacity$State)
US_County_Level$UID<-paste0(US_County_Level$county,"_",US_County_Level$state)
US_County_Population$county
tmp<-merge(select(US_County_Population,-c("county","State")),select(HealthCare_Capacity,-c("county","State")),by.x = "UID",by.y="UID",all = F)
master_table<-merge(select(US_County_Level,-c("county","state")),tmp,by.x = "UID",by.y="UID",all = F)
US_County_Population[grepl(US_County_Population$county,pattern = "^New"),]
master_table[grepl(master_table$UID,pattern = "^New York_New York"),]
write.table(master_table,file = "/Users/stevensmith/Projects/MIT_COVID19/data/MASTER_cases_population_beds.txt",quote = F,row.names = F)
unique(master_table$UID)
