### First Time Setup
library("googleAuthR")
library("googleAnalyticsR")
my_client_id <- "Your Client ID"
my_client_secret <- "Your Client Secret"
options(googleAuthR.client_id=my_client_id)
options(googleAuthR.client_secret=my_client_secret)
options(googleAuthR.httr_oauth_cache = FALSE)
devtools::reload(pkg=devtools::inst("googleAnalyticsR"))
library(httr)
oauth_endpoints("google")
myapp <- oauth_app("google",
  key = "Your Key",
  secret = "Your Secret")
google_token <- oauth2.0_token(oauth_endpoints("google"), myapp,
  scope = "https://www.googleapis.com/auth/userinfo.profile")
req <- GET("https://www.googleapis.com/oauth2/v1/userinfo",
  config(token = google_token))
stop_for_status(req)
content(req)
ga_auth()
### After First Time Setup, Second Time Use R Connect GA API, Token Cached file:httr-oauth
library("googleAuthR")
library("googleAnalyticsR")
my_client_id <- "Your Client ID"
my_client_secret <- "Your Client Secret"
library(httr)
ga_auth()
#GA ID
ga_id <- your ga id here
########### Data Retreival Example: GA Users and Sessions Data 
ga_id <- your ga id here
df <- google_analytics(id = ga_id, 
                       start="start date", 
                       end="end date", 
                       metrics = "ga:users,ga:sessions",   
                       dimensions = "ga:date", 
                       max=10000)
