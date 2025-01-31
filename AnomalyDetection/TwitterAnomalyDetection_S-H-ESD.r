#This document is for anomaly detection with Google Analytics Reporting API data
#The following three packages must be installed from github instead of CRAN
#devtools::install_github("twitter/AnomalyDetection")
#devtools::install_github("google/CausalImpact")
#devtools::install_github("rga", "skardhamar")

library(rga)
library(dygraphs)
library(zoo)
library(tidyr)
library(lubridate)
library(d3heatmap)
library(dply)
library(stringr)
library(DT)
library(RMySQL)
library(CausalImpact) 
library(AnomalyDetection)

#Plotting data
df1 <- ga$getData(id=ga_id,
                    batch=TRUE,
                    start.date="",
                    end.date="",
                    metrics="ga:sesssions",
                    dimensions="",
                    filters="")
ggplot(df1, aes(x=date, y=sessions, color=sessions))+
       geom_line()

#Convert data variable
df1$date <- as.POSIXct(df1$date)

#Keep only desired variables (date & count)
#Apply anomaly detection
df1_anomaly <- AnomalyDetectionTS(df1, max_anoms=0.01, direction="pos", plot=TRUE, e_value=T)

#jpeg("anomaly_detection.jpg", width=8.25, height=5.25, units="in", res=500, pointsize=4)

#Plot original data and anomaly points
df1_anomaly$plot
dev.off()

#Calculate deviation percentage from the expected value
df1_anomaly$anoms$per
