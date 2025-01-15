#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat May 18 10:09:08 2019

@author: hanwang
"""

from selenium import webdriver
import time
import pandas as pd
import os
#import html5lib
#import lxml
import requests
import time
from time import sleep
from selenium.common.exceptions import TimeoutException
from selenium.common.exceptions import NoSuchElementException

abspath = os.path.abspath(r"/Downloads/chromedriver")
driver = webdriver.Chrome(executable_path=abspath)

"""
1.HK Market
"""

"""
Sector and Industry Name
"""
sec = 'https://finance.yahoo.com/quote/1305.HK/profile?p=1305.HK&.tsrc=fin-srch'
driver.get(sec)
tbl1 = driver.find_element_by_xpath("""//*[@id="Col1-0-Profile-Proxy"]/section/div[1]/div/div/p[2]""").get_attribute('innerHTML')
tbl1


def hk_se(sehk_code):
    hk_code=str(sehk_code)
    url = 'https://finance.yahoo.com/quote/'+str(hk_code)+'.HK/profile?p='+str(hk_code)+'.HK&.tsrc=fin-srch'
    driver.get(url)
    sleep=(0.01)
    tbl = driver.find_element_by_xpath("""//*[@id="Col1-0-Profile-Proxy"]/section/div[1]/div/div/p[2]""").get_attribute('innerHTML') 
    if len(tbl) >0: 
        return tbl
    else:
        return

hkcol = ['Code', 'Info']
hkdf2 = pd.DataFrame(columns=hkcol, index= range(1,9999))
hkdf2

for i in range(1, 9999):
    try:
        try: 
           df_i = hk_se(str(i).zfill(4))        
        except NoSuchElementException:
            continue
    except TimeoutException:
        continue
    hkdf2.loc[i].Info = df_i

hkdf2.to_excel("/Users/hanwang/Desktop/HK_SE.xlsx")


"""
2. United States Market
"""
#TEST ======== #
sec_us = 'https://finance.yahoo.com/quote/AA/profile?p=AA'
driver.get(sec_us)
data_us = driver.find_element_by_xpath("""//*[@id="Col1-0-Profile-Proxy"]/section/div[1]/div/div/p[2]""").get_attribute('innerHTML')
data_com = driver.find_element_by_xpath("""//*[@id="quote-header-info"]/div[2]/div[1]/div[1]/h1""").get_attribute('innerHTML')
data_us
data_com
#TEST END ==== #

tickerus = pd.read_excel(r"/US_JP_OTH/Ticker_US_new.xlsx")
tickerus = pd.DataFrame(tickerus)
list(tickerus)

uscol = ['Symbol','Com_Name','Info']
usdf2 = pd.DataFrame(columns=uscol, index = tickerus.Ticker)
usdf2

def us_se(us_code):
    us_code=str(us_code)
    url = 'https://finance.yahoo.com/quote/'+str(us_code)+'/profile?p='+str(us_code)
    driver.get(url)
    sleep=(0.01)
    tbl = driver.find_element_by_xpath("""//*[@id="Col1-0-Profile-Proxy"]/section/div[1]/div/div/p[2]""").get_attribute('innerHTML') 
    if len(tbl) >0: 
        return tbl
    else:
        return
    
def us_com(us_code):
    url = 'https://finance.yahoo.com/quote/'+str(us_code)+'/profile?p='+str(us_code)
    driver.get(url)
    sleep=(0.01)
    element = driver.find_element_by_xpath("""//*[@id="quote-header-info"]/div[2]/div[1]/div[1]/h1""").get_attribute('innerHTML')
    element
    if len(element) >0: 
        return element
    else:
        return
    
for i in tickerus.Ticker:
    try:
        try: 
           df_i = us_com(i)  
           df_j = us_se(i)
        except NoSuchElementException:
            continue
    except TimeoutException:
        continue
    usdf2.loc[i].Info = df_j
    usdf2.loc[i].Com_Name = df_i
    usdf2.loc[i].Symbol = i
usdf2.to_excel("/US_JP_OTH/Output/NYSE_Com_Sector.xlsx")


"""
3. London Market
"""
#TEST ======== #
sec_london = 'https://finance.yahoo.com/quote/AA.L/profile?p=AA.L&.tsrc=fin-srch'
driver.get(sec_london)
data_uk = driver.find_element_by_xpath("""//*[@id="Col1-0-Profile-Proxy"]/section/div[1]/div/div/p[2]""").get_attribute('innerHTML')
data_uk
#TEST END ==== #

tickeruk = pd.read_excel(r"/US_JP_OTH/London_Symbols.xlsx")
tickeruk = pd.DataFrame(tickeruk)
list(tickeruk)

ukcol = ['Symbol','Info']
ukdf2 = pd.DataFrame(columns=uscol, index = tickeruk.Symbol)
ukdf2

def uk_se(uk_code):
    uk_code=str(uk_code)
    url = 'https://finance.yahoo.com/quote/'+str(uk_code)+'.L/profile?p='+str(uk_code)+'.L&.tsrc=fin-srch'
    driver.get(url)
    sleep=(0.01)
    tbl = driver.find_element_by_xpath("""//*[@id="Col1-0-Profile-Proxy"]/section/div[1]/div/div/p[2]""").get_attribute('innerHTML') 
    if len(tbl) >0: 
        return tbl
    else:
        return

for i in tickeruk.Symbol:
    try:
        try: 
           df_i = uk_se(i)        
        except NoSuchElementException:
            continue
    except TimeoutException:
        continue
    ukdf2.loc[i].Info = df_i
    ukdf2.loc[i].Symbol = i
    
ukdf2.to_excel("/US_JP_OTH/Output/LSE_Com_Sector.xlsx")


"""
4. Singapore Market
"""
#TEST ======== #
sec_si = 'https://finance.yahoo.com/quote/1B0.SI/profile?p=1B0.SI&.tsrc=fin-srch'
driver.get(sec_si)
data_si = driver.find_element_by_xpath("""//*[@id="Col1-0-Profile-Proxy"]/section/div[1]/div/div/p[2]""").get_attribute('innerHTML')
data_si
#TEST END ==== #

tickersi = pd.read_excel(r"/US_JP_OTH/Singapore_Symbols.xlsx")
tickersi = pd.DataFrame(tickersi)
list(tickersi)

sicol = ['Symbol','Info']
sidf2 = pd.DataFrame(columns=uscol, index = tickersi.Code)
sidf2


def si_se(si_code):
    si_code=str(si_code)
    url = 'https://finance.yahoo.com/quote/'+str(si_code)+'.SI/profile?p='+str(si_code)+'.SI&.tsrc=fin-srch'
    driver.get(url)
    sleep=(0.01)
    tbl = driver.find_element_by_xpath("""//*[@id="Col1-0-Profile-Proxy"]/section/div[1]/div/div/p[2]""").get_attribute('innerHTML') 
    if len(tbl) >0: 
        return tbl
    else:
        return

for i in tickersi.Code:
    try:
        try: 
           df_i = si_se(i)        
        except NoSuchElementException:
            continue
    except TimeoutException:
        continue
    sidf2.loc[i].Info = df_i
    sidf2.loc[i].Symbol = i

sidf2.to_excel("/US_JP_OTH/Output/SES_Com_Sector.xlsx")



