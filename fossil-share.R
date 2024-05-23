
library(tidyverse)
library(openxlsx)

data_edgar_co2_ffi <- read.xlsx("sources/EDGAR/IEA_EDGAR_CO2_1970_2022.xlsx",sheet=2,startRow = 10)
data_edgar_co2_ffi <- gather(data_edgar_co2_ffi,year,value,Y_1970:Y_2022)
data_edgar_co2_ffi$year <- gsub("Y_","",data_edgar_co2_ffi$year)
data_edgar_co2_ffi <- data_edgar_co2_ffi %>% 
  select(iso=Country_code_A3,country=Name,code=ipcc_code_2006_for_standard_report,code_description=ipcc_code_2006_for_standard_report_name,gas=Substance,fossil_bio,year,value)

data_edgar_co2_ffi <- data_edgar_co2_ffi %>% 
  filter(year==2022) %>% 
  group_by(year,code,code_description,fossil_bio,gas) %>% 
  summarise(value=sum(value,na.rm=TRUE)*1000) %>% 
  mutate(units="tCO2") %>% 
  mutate(source="EDGAR v8.0")


# EDGAR CH4 (https://edgar.jrc.ec.europa.eu/dataset_ghg80)

data_edgar_ch4 <- read.xlsx("sources/EDGAR/EDGAR_CH4_1970_2022.xlsx",sheet=2,startRow = 10)
data_edgar_ch4 <- gather(data_edgar_ch4,year,value,Y_1970:Y_2022)
data_edgar_ch4$year <- gsub("Y_","",data_edgar_ch4$year)
data_edgar_ch4 <- data_edgar_ch4 %>% 
  select(iso=Country_code_A3,country=Name,code=ipcc_code_2006_for_standard_report,code_description=ipcc_code_2006_for_standard_report_name,gas=Substance,fossil_bio,year,value)

data_edgar_ch4 <- data_edgar_ch4 %>% 
  filter(year==2022) %>% 
  group_by(year,code,code_description,fossil_bio,gas) %>% 
  summarise(value=sum(value,na.rm=TRUE)*1000) %>% 
  mutate(units="tCH4") %>% 
  mutate(source="EDGAR v8.0")


# EDGAR N2O (https://edgar.jrc.ec.europa.eu/dataset_ghg80)

data_edgar_n2o <- read.xlsx("sources/EDGAR/EDGAR_N2O_1970_2022.xlsx",sheet=2,startRow = 10)
data_edgar_n2o <- gather(data_edgar_n2o,year,value,Y_1970:Y_2022)
data_edgar_n2o$year <- gsub("Y_","",data_edgar_n2o$year)
data_edgar_n2o <- data_edgar_n2o %>% 
  select(iso=Country_code_A3,country=Name,code=ipcc_code_2006_for_standard_report,code_description=ipcc_code_2006_for_standard_report_name,gas=Substance,fossil_bio,year,value)

data_edgar_n2o <- data_edgar_n2o %>% 
  filter(year==2022) %>% 
  group_by(year,code,code_description,fossil_bio,gas) %>% 
  summarise(value=sum(value,na.rm=TRUE)*1000) %>% 
  mutate(units="tN2O") %>% 
  mutate(source="EDGAR v8.0")


# EDGAR F-gases (https://edgar.jrc.ec.europa.eu/dataset_ghg80)

data_edgar_fgas <- read.xlsx("sources/EDGAR/EDGAR_F-gases_1990_2022.xlsx",sheet=2,startRow = 10)
data_edgar_fgas <- gather(data_edgar_fgas,year,value,Y_1990:Y_2022)
data_edgar_fgas$year <- gsub("Y_","",data_edgar_fgas$year)
data_edgar_fgas <- data_edgar_fgas %>% 
  select(iso=Country_code_A3,country=Name,code=ipcc_code_2006_for_standard_report,code_description=ipcc_code_2006_for_standard_report_name,gas=Substance,fossil_bio,year,value)

data_edgar_fgas <- data_edgar_fgas %>% 
  filter(year==2022) %>% 
  group_by(year,code,code_description,fossil_bio,gas) %>% 
  summarise(value=sum(value,na.rm=TRUE)*1000) %>% 
  mutate(units="Fgas") %>% 
  mutate(source="EDGAR v8.0")
data_edgar_fgas$gas <- gsub("-","",data_edgar_fgas$gas)


### join

data <- rbind(data_edgar_co2_ffi,data_edgar_ch4)
data <- rbind(data,data_edgar_n2o)
data <- rbind(data,data_edgar_fgas)



gwps <- read.csv("https://raw.githubusercontent.com/openclimatedata/globalwarmingpotentials/main/globalwarmingpotentials.csv",skip = 9)

data <- left_join(data,gwps %>% select(gas=Species,AR6GWP100))
data <- data %>% 
  mutate(AR6GWP100=ifelse(gas=="CO2",1,AR6GWP100)) %>% 
  mutate(value_tco2e=value*AR6GWP100)

write.xlsx(data,"EDGAR-v8-totals.xlsx")
