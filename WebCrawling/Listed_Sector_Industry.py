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
2. US Market
"""
tickerus = pd.read_excel(r"/US_JP_OTH/Ticker_US_new.xlsx")
tickerus = pd.DataFrame(tickerus)
list(tickerus)

uscol = ['Symbol','Com_Name','Info']
usdf2 = pd.DataFrame(columns=uscol, index = tickerus.Ticker)

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
usdf2.to_excel("/NYSE_Com_Sector.xlsx")
