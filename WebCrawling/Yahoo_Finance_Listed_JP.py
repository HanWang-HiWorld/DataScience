#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun May  5 19:37:21 2019

@author: hanwang
"""

from selenium import webdriver
import time
import pandas as pd
import os
import requests
import time
from time import sleep

import bs4
import requests

#options = webdriver.ChromeOptions()
#options.add_argument('headless')

abspath = os.path.abspath(r"/chromedriver")
driver = webdriver.Chrome(executable_path=abspath)


from selenium.common.exceptions import TimeoutException
from selenium.common.exceptions import NoSuchElementException

#Generate Japanese Company List

jpcolname = ['Code','Name']
jpdf2=pd.DataFrame(columns=jpcolname)

def jp_code(i):
    url = 'https://finance.yahoo.com/quote/'+str(i)+'.T?p='+str(i)+'.T'
    driver.get(url)
    sleep=(0.01)
    element = driver.find_element_by_xpath("""//*[@id="quote-header-info"]/div[2]/div[1]/div[1]/h1""")
    element.text
    if len(element.text) >0: 
        return element.text
    else:
        return
    
jp_code(1301)

jplist = []
for i in range(1300, 10000):
    try:
        try: 
            jpdf_i = jp_code(i)        
        except NoSuchElementException:
            continue
    except TimeoutException:
        continue
    jplist.append(jpdf_i)
 
jpnames = pd.DataFrame({'col':jplist})    
    
jpnames.to_excel("/JPX_Listed.xlsx") 


"""Map the company list to Nikkei"""

testjp = 'https://asia.nikkei.com/Companies/Obayashi-Corp'
driver.get(test111)

import bs4
import requests
r = requests.get(testjp).text
soup = bs4.BeautifulSoup(r, 'lxml')

def jp_name(code):
    
    c=str(code)  
    url = 'https://asia.nikkei.com/Companies/'+str(code)
    driver.get(url)
    sleep=(0.01)
    tbl = driver.find_element_by_xpath("""//*[@id="content"]/div[1]/div/div[4]/div[4]/div[2]/ul""").get_attribute('outerHTML')
    data = bs4.BeautifulSoup(tbl, 'lxml')
    title = []
    for i in data.find_all('li', class_='company__list-item'):
        title.append(i)
    if len(title) >0: 
        return title
    else:
        return


comjp = pd.read_excel(r"/JPX_Listed.xlsx")
comjp = pd.DataFrame(comjp)
list(comjp)


colname = ['Company','Name']
dfjp=pd.DataFrame(columns=colname)


"""DRY"""
for i in comjp.Company_cln:
    try:
        try:
            list_i = pd.DataFrame(jp_name(i))  
            list_i['Company'] = None
            list_i['Company'] = i
        except NoSuchElementException:
            continue
    except TimeoutException:
        continue

    dfjp=dfjp.append(list_i)            
dfjp.to_excel("/JPX_Names.xlsx")

