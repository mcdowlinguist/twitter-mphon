library(tidyverse)
library(jsonlite)

# set working directory to folder containing this script. 
# assumes .json file is also there
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

lang = "" # provide language here
file = paste0("kaikki.org-dictionary-", lang, ".json")

x = readLines(file)

vec = c(seq(1, length(x), by=10000), length(x))

all = data.frame()

for (i in 1:(length(vec)-1)) {
  temp = stream_in(textConnection(x[vec[i]:vec[i+1]]))
  all = bind_rows(all, temp)
}

##### get ipa transcriptions #####
# the line below may be sufficient if no errors are returned, otherwise
# all = all %>% unnest(sounds, keep_empty = TRUE)

all$sounds = apply(all, 1, function(x) as.data.frame(x$sounds))

all = all %>% 
  mutate(index = row_number()) %>%
  unnest(sounds, keep_empty = TRUE) %>%
  distinct(index, .keep_all = TRUE) %>%
  mutate(ipa = gsub("[/\\[\\]]", '', ipa, perl = T))

##### process according to sound, orthography, etc. #####
# your code here. output should be `all`

##### frequency #####
freqs = read_csv("") # insert file name here

all = all  %>% 
  left_join(freqs) %>% 
  filter(!is.na(relfreq))

# get n words by group (defined below as 20), assumes at least 1 column with grouping variable
size = 20

queries = all %>%
  group_by() %>% # variables
  top_n(relfreq, n = size) %>%
  pull(word)
