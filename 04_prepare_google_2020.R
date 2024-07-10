# Prepare the Google 2020 data so it is in the same shape as the training data

library(data.table)
library(stringr)
library(stringi)
library(dplyr)
library(tidyr)

# Input data
path_input_data <- "../datasets/google/google_2020_adid_text_clean.csv.gz"
# Output data
path_output_data <- "data/google_2020_prepared.csv.gz"

# Read in text data
df <- fread(path_input_data, encoding = "UTF-8")

# concatenate them all together
# Order doesn't matter since we use a bag of words model
df <- df %>% unite(
  col = "text",
  c(
    scraped_ad_content, aws_ocr_text, google_asr_text, advertiser_name,
    scraped_ad_url, scraped_ad_title
  ),
  sep = " "
)

# Kick out empty ads
df <- df[df$text != "", ]
df <- df[is.na(df$text) == F, ]

# Replace newlines with spaces
df$text <- str_replace_all(df$text, "\\\n", " ")
# Remove extraneous spaces
df$text <- str_squish(df$text)

fwrite(df, path_output_data)
