# twitter-mphon
Scripts relating to (1) generating queries from Wiktionary data (as provided by kaikki.org) and Sketch Engine frequency data and (2) gathering and processing Twitter data, including geospatial data and device information.

*Please note* that until indicated otherwise, the scripts provided here are in a preliminary state, in the interest of time. *Please also note* that eventually I will ask that any work using any of these scripts attributes the project by means of citation of an article, which is currently in preparation. Please check back here occasionally for updates.

**Date:** April 6, 2023<br>
**Author:** Michael Dow<br>
**Institution:** Université de Montréal

Questions, comments, etc. welcome via my institutional email.

## Background
Requirements:
- R and RStudio
- R packages `academictwitteR, tidyverse, jsonlite, pbapply` (also recommended or optional: `rtweet, stringi`)
- Academic API access key. This must be entered once into your `.Renviron` file once (see [here](https://cran.r-project.org/web/packages/academictwitteR/vignettes/academictwitteR-intro.html) for more information)
- A .json dictionary downloaded from [kaikki.org](https://kaikki.org/)

Project structure is generally assumed to include the .json dictionary in the same parent folder as R scripts, plus a folder named `data` and (optionally) a folder named `devices`.

## Scripts
The following scripts are included and explained here, in general imagined order of workflow. Minimal comments are included in the scripts themselves. Look here for full information.
- `gen_queries.R`: Imports dictionary in batches of 10,000 entries and extracts IPA transcriptions from the column `sounds`. Removes phonetic and phonemic transcription bracketing. Several entries are likely to have multiple IPA transcriptions; comment out (i.e., do not run) the line with `distinct(index, .keep_all = TRUE)` if you wish to keep *all* transcriptions. (This is not recommended, however.) Processing criteria and grouping variables unique to your project are assumed, as is cleaned-up word frequency data from [Sketch Engine](https://www.sketchengine.eu/) with the columns `word` (orthographic form) and `relfreq` (frequency per million words in corpus). Outputs the character vector named `queries`, which is used in scripts `get_counts.R` and `get_tweets.R`.
- `get_etymology.R`: Optional script if etymological information is necessary (e.g., if researching borrowings). Assumes Wiktionary data have already been imported as `all`. Extracts columns with etymology arguments indicated source language, which should correspond to columns with numbers as names. Note that there is no one standard column where this information is found; it may be in any of the extrdacted columns. An example of using this information to create a dataframe of all English-origin words is provided.
- `gather_counts.R`: Assumes character vector `queries`. Outputs a single dataframe `counts` for all queries for a given time frame, with a column `word` for each particular query. Language and country may be specified, but if not necessary, should be removed. Retweets are excluded. From this dataframe, sums can be calculated, grouped by word.
- `gather_tweets.R`: Assumes character vector `queries`. Gathers all tweets and user information within a given time frame. Language and country may be specified, but if not necessary, should be removed. Retweets are excluded. Outputs to subfolders within `data/` for each query. (The query in question can then be extracted from the path name when importing.)
- `get_devices.R`: Optional. Requires project with v1.1 access. Assumes a subfolder called `devices` the script's parent folder and a dataframe of all tweets imported as `all`, with column `id`. Note that there is a short version (not recommended for datasets longer than 5,000 tweets) and a long version which runs over batches of 500 and outputs a .csv file containing status id and device information (simplified). Note that sleeping periods are built in (10 seconds per iteration, 15 minutes per 100 iterations.) Output files are appended with custom language name, which should be provided. The very last id may need to be manually gathered. 
- `gen_coords.R`: Optional. Starting with 2 long-lat coordinates containing the entire geographical area meant to be investigated, generates 20x20 bounding boxes within the area. Output is dataframe `boxes`, in a format which can be provided to data-gathering scripts specific for this purpose.
- `merge_actw.R`: Collects all tweets and combines in one dataframe `all_tw`. Only user-provided columns are kept. Note that currently, of geospatial data, only `place_id` from the original `geo` field is kept. **It is assumed** that the ids in this column will be later merged with bounding boxes extracted from the user .json files provided by `academictwitteR`. Also note that this is one method of compiling data, using the `bind_tweets()` command from `academictwitteR`. As this command may leave out certain information, an alternative method using `jsonlite` will be uploaded soon.
- `get_all_places.R`: Extracts `id` (the same as `place_id` in tweet .json files) and bounding box coordinates for each tweet from the user .json files. Provides `all_places`, a dataframe with geospatial information for each unique `id` (not to be confused with the field `id` in the tweet .json files, which correspond to unique tweet id).
- `centroid.R`: Calculates the centroid of each box and merges with tweets by `place_id`. Assumes place ID's have already been gathered and imported as `all_places`, as well as all tweets compiled and imported as `all`. Data points should be ready to be plotted after running this script.
