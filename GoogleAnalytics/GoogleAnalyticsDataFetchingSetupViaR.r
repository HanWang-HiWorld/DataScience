---
title: "Google Analytics R Data Fetching"
author: "Han Wang"
output: 
  html_document:
    section_number: true
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

####How to fetch data from Google Analytics Server  
####1. Set Up From Google Analytics Developer Console Side  
Follow the steps from Google Analytics Developer instruction  https://developers.google.com/analytics/devguides/reporting/core/v4/ and create a service account  https://console.developers.google.com/. Record the account id and secret or dowwnload the JSON credential document to somewhere you can remember and also secure.  

####2. Get R Ready  
Head up to R environmet customization after every essential part is set up from your google developer console.  
There are three preliminary Google Analytics and R packages. The set up methods will be introduced individually.  
2.1 `RGA`  
```{r RGA, include=TRUE, echo=TRUE, message=FALSE, warning=FALSE}

```

2.2 `GoogleAnalyticsR`  

2.3 `skardhamar/rga`  
Two installation options for `rga`, `devtools::install_github(skardhamar/rga)` is recommanded over the CRAN installation if fetching dataset with more than 10,000 observations. If already installed `rga` from CRAN, `rm(rga)` before installation of the github version.

```{r skardhamar_rga, echo=TRUE, eval=FALSE}
install.packages("devtools")
library(devtools)
devtools::install_github(skardhamar/rga)
library(rga)

```
