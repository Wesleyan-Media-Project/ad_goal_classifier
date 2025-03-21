# Prepare the FB 2022 data so it is in the same shape as the training data
# Currently does not include ocr

library(data.table)
library(stringr)
library(stringi)
library(dplyr)
library(tidyr)

# Input data
path_input_data <- "fb_2022_adid_text.csv.gz"
# source : data-post-production/01-merge-results/01_merge_preprocessed_results
# Output data
path_output_data <- "data/fb2022_prepared.csv.gz"

# Load data
df <- fread(path_input_data, encoding = "UTF-8")

# concatenate them all together
# Order doesn't matter since we use a bag of words model
df <- df %>% unite(
  col = "text",
  c(
    ad_creative_body, google_asr_text, aws_ocr_text_img, aws_ocr_text_vid, page_name, disclaimer,
    ad_creative_link_caption, ad_creative_link_title,
    ad_creative_link_description
  ),
  sep = " ", na.rm = T
)

# Kick out empty ads
df <- df[df$text != "", ]
df <- df[is.na(df$text) == F, ]

# Replace newlines with spaces
df$text <- str_replace_all(df$text, "\\\\n", " ")

# Clean up extraneous spaces
df$text <- str_squish(df$text)

fwrite(df, path_output_data)
