library(tidyverse)
library(academictwitteR)

dirs = list.dirs("data/")[-1]
dirs = dirs[sapply(dirs, 
                   function(x) 
                     length(list.files(x, 
                                       pattern = "^data_[0-9]"))) > 0]

all_tw = data.frame()

# define columns
cols = c("author_id", "word", "text", "id", "created_at", "place_id")

for (i in 1:length(dirs)) {
  tweets = bind_tweets(dirs[i]) %>% 
    mutate(word = gsub("data//", "", dirs[i]))
  
  if ("geo" %in% colnames(tweets)) {
    tweets = tweets %>% 
      unnest(geo) %>%
      select(all_of(cols))
  } else {
    tweets = tweets %>% 
      mutate(place_id = NA) %>%
      select(all_of(cols))
  }
  
  all_tw = bind_rows(all_tw, tweets)
  
  rm(tweets)
  message(i, " done")
}
