library(data.table)
library(dplyr)

# Input
path_input <- "../datasets/google/google_2020_fed_cand_ads_03282022.csv"
# Output
path_output <- "data/google_2020_cands_inference_set.csv.gz"

# Google
df <- fread(path_input)
df <- df %>% select(ad_id, ad_combined_text)
df <- df[!duplicated(df$ad_id),]
df <- df[df$ad_combined_text != "",]
df <- df %>% rename(text = ad_combined_text)

fwrite(df, path_output)
