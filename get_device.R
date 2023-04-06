library(tidyverse)
library(rtweet)
# provide user-specific keys and tokens below

api_key = ""
api_secret_key = ""
access_token = ""
access_token_secret = ""

token = rtweet::create_token(
  app = "", # provide name of app
  consumer_key = api_key,
  consumer_secret = api_secret_key,
  access_token = access_token,
  access_secret = access_token_secret
)

statuses = all$id

##### short version #####
temp = lookup_tweets(statuses)

source = temp %>% 
  select(id_str, source) %>% 
  rename(id = id_str)

source = source %>% 
  mutate(source = gsub("^<.+?>(.*)</a>", "\\1", source))

##### long version #####
rows = length(statuses)

vec = c(seq(1,rows, by=500), rows)

lang = "" # provide language abbreviation

for (i in 1:(length(vec)-1)) {
  step = lookup_tweets(statuses[vec[i]:vec[i+1]],
                      retryonratelimit = TRUE) %>% 
    select(id_str, source) %>% 
    rename(id = id_str) %>%
    mutate(source = gsub("^<.+?>(.*)</a>", "\\1", source))
  
  write_csv(step, paste0("devices/", lang, "_devices_", vec[i], "_", vec[i+1], ".csv"))
  
  message("done with ", i, " of ", length(vec), ". baby sleep")
  Sys.sleep(10)
  
  if (i %% 100 == 0) {
    message("long sleep")
    Sys.sleep(60*15)
  }
}

# NOTE: the very last ID in `statuses` may need to be gathered manually with:
# lookup_tweets(statuses[length(statuses)],
#               retryonratelimit = TRUE) %>% 
#   select(id_str, source) %>% 
#   rename(id = id_str) %>%
#   mutate(source = gsub("^<.+?>(.*)</a>", "\\1", source))
