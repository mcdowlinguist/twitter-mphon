library(tidyverse)
library(jsonlite)
library(pbapply) # for keeping track of progress

dirs = list.dirs("data/")[-1]

all_places = data.frame()

for (i in 1:length(dirs)) {
  files = list.files(dirs[i], pattern = "^users")[-1]
  listdf = lapply(files, 
               function(x) read_json(paste0(dirs[i], "/", x)))
  
  getbb = lapply(listdf, function(x) bind_rows(x$places))
  getbb = getbb[lengths(getbb)>0]
  getbb = pblapply(getbb, function(x) filter(x, names(geo) == "bbox"))
  getbb = pblapply(getbb, function(x) x %>% 
                    unnest_wider(geo) %>% 
                    suppressMessages)
  getbb = pblapply(getbb, function(x) x %>% 
                   rename(long.min = `...1`, 
                          lat.min = `...2`, 
                          long.max = `...3`, 
                          lat.max = `...4`))
  
  finaldf = do.call(bind_rows, getbb)
  
  all_places = bind_rows(all_places, finaldf)
  
  message(i, " done")
}
