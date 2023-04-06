library(stringr)
# provide long-lat coordinates representing extremities of larger box
# coordinates for Tuscany provided as an example
# parts of code inspired by: https://gis.stackexchange.com/a/15572

long1 = 9.6832
lat1 = 43.9959
long2 = 12.6576
lat2 = 42.3571

r = 20 # length of each box side, in miles
df = r/69
dl = df / cos(lat1)

n_lat = ceiling((lat1-lat2)/dl)
n_long = -floor((long1-long2)/df)

long = round(cumsum(c(long1, rep(df, n_long))), 4)
lat = round(cumsum(c(lat1, rep(-dl, n_lat))), 4)

m = sapply(rev(lat), function (x) paste(long, x, sep = ","))

n = (nrow(m)-1)*(ncol(m)-1)
out = character(n)

con.fun = function(c,b,a) {
  paste(
      c[b, a], c[b+1, a+1], sep = ","
    )
}

out = con.fun(m, 1:(nrow(m)-1), 1:(ncol(m)-1))

boxes = as.data.frame(str_split_fixed(out, ",", 4))
