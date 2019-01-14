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
theme_simple <- function () { 
  theme_grey() %+replace% 
    theme(
      axis.line=element_line(colour="black"),
      panel.grid.minor=element_blank(), 
      panel.grid.major=element_blank(),
      panel.background=element_blank(), 
      axis.title=element_text(size=28,face="bold"),
      axis.text.x=element_text(size=24, colour="Black"),
      axis.text.y=element_text(size=24, colour="Black"),
      axis.ticks.length=unit(0.5,"cm"),
      axis.ticks=element_line(size=0.5, colour="Black"),
      panel.border=element_rect(fill=FALSE,size=0.5),
      legend.title=element_text(size=15),
      legend.key=element_blank()
    )
  
}

library("tidyverse"); theme_set(theme_simple())
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
CAN_farmprices_current<-read_xlsx('data/cansim-0020043 farm price_ee.xlsx',na=c("","..","<NA>","",'x'),skip=4)
CAN_farmprices_historic<-read_csv('data/cansim-0010017 farm price old.csv',na=c("","..","<NA>",""),skip=3,col_types=cols())

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

INPUTSINDIV <- CAN_expenses_inf.adj %>%
  group_by(Geography,Year,ExpenseType) %>%
  summarise(ExpenseByType = sum (truedol)) %>%
  filter(Geography == "Canada")

INPUTSINDIVPlot <- INPUTSINDIV %>%
  ggplot()+
  geom_vline(xintercept = 1937) +
  geom_vline(xintercept = 1945) +
  geom_vline(xintercept = 1949) +
  geom_vline(xintercept = 1953) +
  geom_vline(xintercept = 1958) +
  geom_vline(xintercept = 1960) +
  geom_vline(xintercept = 1969) +
  geom_vline(xintercept = 1973) +
  geom_vline(xintercept = 1980) +
  geom_vline(xintercept = 1981) +
  geom_vline(xintercept = 1990) + #approximate
  geom_vline(xintercept = 2001) +
  geom_vline(xintercept = 2008) +
  geom_point(aes(x=Year, y=ExpenseByType,colour = ExpenseType))


OUTPUTS<-CAN_prod %>% 
  filter(Harvest.disposition=='Production') %>% 
  group_by(Year,Geography,Harvest.disposition) %>% 
  summarise(Value=sum(ReportedValue,na.rm=T)) %>% 
  rename(Metric=Harvest.disposition)
YIELD<-CAN_prod %>%
  filter(Harvest.disposition=='Average yield') %>% 
  group_by(Year,Geography,Harvest.disposition) %>% 
  summarise(Value=(mean(ReportedValue,na.rm=T))) %>% 
  rename(Metric=Harvest.disposition)
AREA<-CAN_prod %>% 
  filter(Harvest.disposition=='Seeded area',Crop!='Summerfallow') %>% 
  group_by(Year,Geography,Harvest.disposition) %>% 
  summarise(Value=(sum(ReportedValue,na.rm=T))) %>% 
  rename(Metric=Harvest.disposition)
gap2<-bind_rows(INPUTS,OUTPUTS,YIELD,AREA) %>% 
  spread(Metric,Value) %>% 
  mutate(DolperB=(InputCost.CAD2016)/Production, BperDol=Production/InputCost.CAD2016) %>% 
  mutate(DolperHA=(InputCost.CAD2016/`Seeded area`))%>% 
  filter(InputCost.CAD2016>0,Production>0,Year>=1926,Geography=='Canada')

gap2$`Seeded area`[gap2$Year==2016] / gap2$`Seeded area`[gap2$Year==1926] #change in seeded area
gap2$Production[gap2$Year==2016] / gap2$Production[gap2$Year==1926] #change in production
gap2$InputCost.CAD2016[gap2$Year==2016] / gap2$InputCost.CAD2016[gap2$Year==1926] #change in input cost

#Market Prices - Converted from 2016 CAD to 2016 USD using conversion rate of 1.379. Obtained from https://www.irs.gov/individuals/international-taxpayers/yearly-average-currency-exchange-rates
MarketPrice_current<-CAN_farmprices_current %>% 
  rename(Crop=`Farm products`) %>% 
  filter(!Crop %in% c('Wheat excluding durum','Ontario wheat including payments','Ontario wheat excluding payments','Canadian Wheat Board, wheat including payments',"Canadian Wheat Board, durum including payments","Canadian Wheat Board, barley including payments",'Barley_EEBAD',"Canadian Wheat Board, selected barley including payments","Non-board wheat excluding durum",'Durum',"Canadian Wheat Board, barley excluding payments","Canadian Wheat Board, durum excluding payments","Canadian Wheat Board, selected barley excluding payments","Canadian Wheat Board, wheat excluding payments", "Not available", "Suppressed to meet the confidentiality requirements of the Statistics Act"), !is.na(Crop))%>%
  filter(Geography %in% geo) %>%
  gather(Year,Value,-Geography,-Crop) %>% 
  mutate(Value=as.numeric(Value)) %>% 
  separate(col=Year,sep='_',into=c('Year','Month'),extra='merge') %>% 
  group_by(Crop,Year) %>% 
  summarise(DolPerMetricTonne=mean(Value,na.rm=T))

MarketPrice_historic<-CAN_farmprices_historic %>%
  rename(Crop=`Type of crop`) %>%
  select(-`Harvest disposition`) %>%
  filter(Geography %in% geo) %>%
  filter(Geography!='Canada') %>% 
  gather(Year,Value,-Geography,-Crop)  %>%    
  separate(col=Crop,sep=' [(]',into=c('Crop','x2'),extra='merge') %>% 
  mutate(Crop=ifelse(Crop=='Corn for grain','Grain corn',Crop)) %>% 
  group_by(Crop,Year) %>% 
  summarise(DolPerMetricTonne=mean(as.numeric(Value),na.rm=T)) %>% 
  mutate(DolPerMetricTonne=ifelse(DolPerMetricTonne==0,NA, DolPerMetricTonne)) %>% 
  filter(!is.na(DolPerMetricTonne))

AvgFarmYield<-CAN_prod %>% 
  filter(Harvest.disposition =='Average yield',Geography=='Canada',ReportedValue!='<NA>') %>% 
  group_by(Year,Crop) %>% 
  summarise(MetricTonneperHA=mean(ReportedValue,na.rm=T)/1000) %>% 
  select(Crop,Year,MetricTonneperHA)
AvgFarmYield$Crop[AvgFarmYield$Crop=='Corn for grain'] <- "Grain corn" 

SumFarmArea<-CAN_prod %>% 
  filter(Harvest.disposition=='Seeded area',Geography=='Canada',ReportedValue!='<NA>') %>%
  group_by(Crop,Year) %>% 
  summarise(SeededArea=sum(ReportedValue,na.rm=T)) 
SumFarmArea$Crop[SumFarmArea$Crop=='Corn for grain'] <- "Grain corn" 

FarmInflation<-CAN_CPI%>%
  filter(`Products and product groups`=='All-items') %>% 
  rename(Type=`Products and product groups`) %>% 
  gather(Year,CPI,-Geography,-Type) %>%
  mutate(Year=as.numeric(Year)) %>% 
  select(-Type,-Geography)

MarketPrice<- bind_rows(MarketPrice_current, MarketPrice_historic) %>% 
  mutate(Year = as.numeric(Year)) %>%
  full_join(AvgFarmYield, by = c("Crop", "Year")) %>% 
  left_join(FarmInflation, by = "Year") %>% 
  mutate(Dol2016perMetricTonne = ((128.4/CPI)* DolPerMetricTonne)) %>% 
  mutate(Dol2016PerHA=(Dol2016perMetricTonne* MetricTonneperHA)) %>% 
  filter(!is.na(CPI)) %>% 
  left_join(SumFarmArea,by = c("Crop", "Year"))




MarketPrice_index<-MarketPrice %>%
  filter(!is.na(Dol2016perMetricTonne),Year>=1926) %>% 
  group_by(Crop) %>% 
  summarize(Year=min(Year)) %>% 
  left_join(MarketPrice, by = c("Crop", "Year")) %>% 
  rename(IndexYield_ton.ha=MetricTonneperHA, IndexPrice_2016dol.ton=Dol2016perMetricTonne, IndexRevenue_2016dol.ha=Dol2016PerHA, IndexArea_ha=SeededArea) %>% 
  select(Crop, IndexYield_ton.ha, IndexPrice_2016dol.ton, IndexRevenue_2016dol.ha, IndexArea_ha) %>% 
  full_join(MarketPrice, by = "Crop") %>% 
  mutate(Yield_index=MetricTonneperHA/IndexYield_ton.ha, Price_index= Dol2016perMetricTonne/IndexPrice_2016dol.ton, Revenue_index= Dol2016PerHA/IndexRevenue_2016dol.ha,Area_index= SeededArea/IndexArea_ha) %>% 
  filter(!Crop %in% c('Borage seed','Canary seed','Caraway seed','Chick peas','Coriander seed','Fababeans','Lentils','Safflower','Triticale')) %>% 
  right_join(gap2 %>% 
          filter(Geography=='Canada') %>% 
          select(Year, InputCost.CAD2016,`Seeded area`,Geography) %>% 
          mutate(InputCost.CAD2016perha=(InputCost.CAD2016/`Seeded area`)) %>%
          mutate(Cost_index= InputCost.CAD2016perha/8.68195), by = "Year") %>% 
  mutate(PROFIT=((MetricTonneperHA* Dol2016perMetricTonne)-InputCost.CAD2016perha))

crops<-c('Barley','Canola','Flaxseed','Grain corn','Oats','Peas, dry','Rye, all','Soybeans','Wheat, all')

InputProfitYieldMeans<-MarketPrice_index %>% 
  filter(Crop %in% crops) %>% 
  select(Year,Crop,Dol2016perMetricTonne,MetricTonneperHA,InputCost.CAD2016perha,PROFIT) %>% 
  gather(METRIC,VALUE,-Year,-Crop) %>% 
  group_by(Year,METRIC)%>% 
  summarise(value=mean(VALUE),se=(sd(VALUE)/sqrt(n())))

InputProfitYieldPointsGraph<-MarketPrice_index %>% 
  filter(Crop %in% crops) %>% 
  select(Year,Crop,Dol2016perMetricTonne,MetricTonneperHA,InputCost.CAD2016perha,PROFIT) %>% 
  gather(METRIC,VALUE,-Year,-Crop) %>%
  ggplot()+
  geom_point(aes(Year,VALUE, colour = Crop))+
  facet_grid(METRIC~., scales = "free_y")

Profitpointsgraph<-MarketPrice_index %>% 
  filter(Crop %in% crops) %>% 
  select(Year,Crop,PROFIT) %>% 
  ggplot()+
  geom_point(aes(Year,PROFIT, colour = Crop))

yearprofitsdatacount<-MarketPrice_index %>% 
  filter(Crop %in% crops) %>% 
  select(Year,Crop,PROFIT) %>%
  group_by(Year) %>%
  summarise(count=length(PROFIT))

InputProfitYieldmeansgraph<-InputProfitYieldMeans %>%
  ggplot()+
  geom_point(aes(Year,value))+
  facet_grid(METRIC~., scales = "free_y")

#when plot means does not appear that there is a change in variation. and any variation looks to be driven by market price (highly correlated for obvious reasons - profit is calculated from market price)
#when look at all points for profit - maybe increase in variation in profits but could be artefact of more points? also why is my graph looking different from ellen's (e.g higher maximum value)

Fig3Sums<-MarketPrice_index %>% 
  filter(Crop %in% crops) %>%
  select(Year,SeededArea,Crop) %>% 
  gather(METRIC,VALUE,-Year,-Crop) %>% 
  group_by(Year,METRIC)%>% 
  summarise(value=sum(VALUE),se=(sd(VALUE)/sqrt(n()))) %>% 
  mutate(value=(value/16646500))

Fig3Points<-bind_rows(Fig3Means,Fig3Sums)