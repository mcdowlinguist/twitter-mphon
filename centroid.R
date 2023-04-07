library(tidyverse)
library(sf)
# assume place data imported as `all_places`, tweets imported as `all`

all = all_places %>% 
  rename(place_id = id) %>% 
  distinct(place_id, .keep_all = TRUE) %>% 
  right_join(all)

bb = all %>% 
  select(long.min, lat.min, long.max, lat.max) %>% 
  distinct(long.min, lat.min, long.max, lat.max) %>%
  filter(!is.na(long.min))

xy.list = split(bb, 
                seq(nrow(bb)))

xy.list = lapply(xy.list, as.list)

boxes = lapply(xy.list, function(x) {
  st_bbox(c(xmin=x[[1]], xmax=x[[3]], 
            ymin=x[[2]], ymax=x[[4]]))
})

df = data.frame()

for (i in 1:length(boxes)) {
  temp = st_as_sfc(boxes[[i]]) %>% 
    st_centroid() %>% 
    st_coordinates() %>%
    as.data.frame() %>%
    rename(long.cent = X, lat.cent = Y)
  
  df = bind_rows(df, temp)
}

rownames(df) = NULL

bb = bind_cols(bb, df)

all = all %>% left_join(bb)
rm(bb, boxes, df, temp, xy.list)
