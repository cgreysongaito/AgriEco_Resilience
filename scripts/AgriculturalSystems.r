##########################################
# R script to evaluate variability in profits for Canadian farms
#
#
# Christopher J. Greyson-Gaito (with code from Dr. Ellen Esch)
#
#
# Started 30th November 2018
#
#
#############################################


# Libraries ---------------------------------------------------------------


library(tidyverse)
library(cowplot)
library(readxl)
library(gridExtra)
library(scales)
library(lubridate)
library(zoo)


# Data input and cleaning -------------------------------------------------
geo<-c('Canada','Newfoundland and Labrador','Prince Edward Island','Nova Scotia','New Brunswick','Quebec','Ontario','Manitoba','Saskatchewan','Alberta','British Columbia')


CAN_yield<-read_csv('data/cansim-0010017 Area,Yield,etc2.csv',na=c("","..",'x'),skip=3,col_types=cols())
CAN_expenses_current<-read_csv('data/cansim-0020005 FERT.csv',skip=6,na=c("",'x','..'),col_types=cols())
CAN_expenses_historic <-read_csv('data/cansim-0020015 OLD FERT.csv',skip=5,na=c("",'x','..'),col_types=cols())
CAN_CPI<-read_csv('data/cansim-3260021 CPI.csv',skip=3,col_types=cols())

# Profit Variability ------------------------------------------------------

CAN_prod<-CAN_yield%>%
  rename(Harvest.disposition=`Harvest disposition`,Crop=`Type of crop`) %>%
  filter(Geography %in% geo) %>% 
  gather(Year,ReportedValue,-Geography,-Harvest.disposition,-Crop) %>% 
  mutate(Year=as.numeric(Year))%>%
  separate(col= Crop,sep=' [(]',into=c('Crop','Notes'),extra='merge') %>% 
  separate(col=Harvest.disposition,sep=' [(]',into=c('Harvest.disposition','HarvestMetric'),extra='merge') %>% 
  mutate(HarvestMetric=paste("(",HarvestMetric,sep="")) %>%
  select(-Notes) %>% 
  filter(!is.na(ReportedValue))

CAN_expenses_current_calc<-CAN_expenses_current%>%
  rename(ExpenseType=`Expenses and rebates`)%>%
  gather(Year, Cost,-Geography,-ExpenseType)%>% 
  filter(Geography %in% geo) %>%
  spread(ExpenseType, Cost) %>%
  mutate(`Fertilizer and lime, after rebates`=ifelse(is.na(`Fertilizer and lime, after rebates`),
                                                     as.numeric((`Fertilizer, after rebates`) + (`Lime, after rebates`)),
                                                     as.numeric(`Fertilizer and lime, after rebates`))) %>%
  mutate(`Fertilizer and lime rebates`=ifelse(is.na(`Fertilizer and lime rebates`),
                                              as.numeric((`Fertilizer rebates`) + (`Lime rebates`)),
                                              as.numeric(`Fertilizer and lime rebates`))) %>%
  mutate(`Fertilizer and lime`=ifelse(is.na(`Fertilizer and lime`),
                                      as.numeric((`Fertilizer and lime rebates`) + (`Fertilizer and lime, after rebates`)),
                                      as.numeric(`Fertilizer and lime`))) %>%
  mutate(`Pesticides`=ifelse(is.na(`Pesticides`),
                             as.numeric((`Pesticides, after rebates`) + (`Pesticide rebates`)),
                             as.numeric(`Pesticides`))) %>%
  mutate(`Total expenses before rebates`=ifelse(is.na(`Total expenses before rebates`),
                                                as.numeric((`Total rebates`) + (`Total expenses after rebates`)),
                                                as.numeric(`Total expenses before rebates`))) %>%
  mutate(`Cash wages including room and board, after rebates`=ifelse(is.na(`Cash wages, room and board, before rebates`),
                                                                     as.numeric((`Cash wage rebates`) + (`Cash wages, after rebates`)),
                                                                     as.numeric(`Cash wages, room and board, before rebates`))) %>%
  mutate(`Commercial seed`=ifelse(is.na(`Commercial seed`),
                                  as.numeric((`Commercial seed, after rebates`) + (`Commercial seed rebates`)),
                                  as.numeric(`Commercial seed`))) %>%
  mutate(Year=as.numeric(Year)) %>%
  gather(ExpenseType,Cost,-Geography,-Year) %>%
  filter(!is.na(Cost))

CAN_expenses_historic_calc<-CAN_expenses_historic %>%
  rename(ExpenseType =`Expenses and rebates`) %>% 
  gather(Year, Cost,-Geography,-ExpenseType) %>% 
  filter(Geography %in% geo) %>%
  spread(ExpenseType, Cost) %>% 
  rename(`Fertilizer and lime`=`Fertilizer and limestone`,
         `Total operating expenses after rebates`=`Total operating expenses`, 
         `Interest`=`Interest on indebtedness`,
         `Cash wages, room and board, before rebates`=`Wages to farm labour`) %>%
  mutate(`Pesticides`=ifelse(is.na(`Pesticides`),
                             as.numeric(`Pesticides and containers`),
                             as.numeric(`Pesticides`))) %>%
  mutate(Year=as.numeric(Year)) %>%
  gather(ExpenseType, Cost,-Geography,-Year) %>%
  filter(!is.na(Cost))

CAN_expenses<-rbind(CAN_expenses_current_calc, CAN_expenses_historic_calc)%>% 
  mutate(ExpenseType=as.factor(ExpenseType)) %>% 
  filter(ExpenseType =='Fertilizer and lime'| 
           ExpenseType =='Pesticides'| 
           ExpenseType =='Commercial seed'| 
           ExpenseType =='Irrigation')

CAN_inflation<-CAN_CPI %>%
  filter(`Products and product groups`=='All-items') %>% 
  rename(type=`Products and product groups`) %>% 
  gather(Year,value,-Geography,-type)%>%
  mutate(Year=as.numeric(Year))%>%
  select(-type,-Geography)

CAN_expenses_inf.adj<-CAN_expenses %>% 
  left_join(CAN_inflation, by="Year") %>%
  mutate(truedol=(128.4/value)*Cost * 1000 ) %>% #because reported in 1000 dollars - PLACEHOLDER what is truedol and 128.4
  filter(!is.na(Cost)) 


INPUTS<-CAN_expenses_inf.adj %>% 
  group_by(Geography,Year) %>% 
  summarise(Value=sum(truedol,na.rm=T))%>% #PLACEHOLDER - if summarising by geography, how to deal with CANADA as part of geography
  mutate(Metric="InputCost.CAD2016") 

OUTPUTS<-CAN_prod %>% 
  filter(Harvest.disposition=='Production') %>% 
  group_by(Year,Geography,Harvest.disposition) %>% 
  summarise(Value=sum(ReportedValue,na.rm=T)) %>% 
  rename(Metric=Harvest.disposition)
YIELD<-CAN_prod %>% #LPlaceholder - identifying what ellen doing here
  filter(Harvest.disposition=='Average yield',HarvestMetric=='(kilograms per hectare)') %>% 
  group_by(Year,Geography,Harvest.disposition) %>% 
  summarise(Value=(mean(ReportedValue,na.rm=T))) %>% 
  rename(Metric=Harvest.disposition)
AREA<-CAN_prod %>% 
  filter(Harvest.disposition=='Seeded area',HarvestMetric=='(hectares)',Crop!='Summerfallow') %>% 
  group_by(Year,Geography,Harvest.disposition) %>% 
  summarise(Value=(sum(ReportedValue,na.rm=T))) %>% 
  rename(Metric=Harvest.disposition)
gap2<-bind_rows(INPUTS,OUTPUTS,YIELD,AREA) %>% 
  spread(Metric,Value) %>% 
  mutate(DolperB=(InputCost.CAD2016)/Production, BperDol=Production/InputCost.CAD2016) %>% 
  mutate(DolperHA=(InputCost.CAD2016/`Seeded area`))%>% 
  filter(InputCost.CAD2016>0,Production>0,Year>=1926,Geography=='Canada')

gap2$`Seeded area`[gap2$Year==2016] / gap2$`Seeded area`[gap2$Year==1926]