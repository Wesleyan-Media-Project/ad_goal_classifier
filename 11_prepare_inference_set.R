library(data.table)
library(dplyr)

# Google
#df <- fread("../../../../Cross-platform comparison/Data/google_2020_fed_cand_ads_03082022.csv")
df <- fread("../../../../Cross-platform comparison/Data/google_2020_fed_cand_ads_03282022.csv")
df <- df %>% select(ad_id, ad_combined_text)
df <- df[!duplicated(df$ad_id),]
df <- df[df$ad_combined_text != "",]
df <- df %>% rename(text = ad_combined_text)

fwrite(df, "data/google_inference_set.csv")

# Facebook
df <- fread("../../../../Cross-platform comparison/Data/fb_2020_fed_cand_ads_03082022.csv", encoding = 'UTF-8')
df <- df %>% select(ad_id, ad_creative_body)
df <- df[!duplicated(df$ad_id),]
df <- df[df$ad_creative_body != "",]
df <- df %>% rename(text = ad_creative_body)

fwrite(df, "data/fb_inference_set.csv")
