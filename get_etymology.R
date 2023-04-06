library(tidyverse)

all = all %>% 
  mutate(args = map(etymology_templates, "args")) 

nm = unique(unlist(apply(all, 1, 
                         function(x) names(x$args))))
nm = nm[grepl("[a-zA-Z]", nm)]
nm = paste0("args.", nm)

all = all %>% 
  unnest(args, names_sep = ".") %>% 
  select(-all_of(nm))

# get words of english origin, adapt for language(s) or needs
en = all %>% 
  filter(if_any(all_of(starts_with("args")),
                ~. == "en"))