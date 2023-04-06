library(academictwitteR)

start_tweets = "2006-04-01T00:00:00Z"
end_tweets = "2023-04-01T00:00:00Z"

for (i in 1:length(queries)) {
  get_all_tweets(
    query = build_query(
      query = queries[i],
      lang = "", # provide if necessary, else comment out
      country = "", # provide if necessary, else comment out
      exact_phrase = T,
      is_retweet = F
    ),
    start_tweets = start_tweets,
    end_tweets = end_tweets,
    n = Inf,
    bind_tweets = F,
    data_path = paste0("data/", sub(" ", "_", queries[i]))
  )
}
