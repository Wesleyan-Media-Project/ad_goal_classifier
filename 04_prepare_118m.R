# Prepare the 128m data so it is in the same shape as the training data

library(data.table)
library(stringr)
library(stringi)
library(dplyr)
library(tidyr)

# Input data
path_input_data <- "../datasets/facebook/fb_2020_128m_text.csv.gz"
# Output data
path_output_data <- "data/128m_prepared.csv.gz"

# Read in text data
df <- fread(path_input_data, encoding = "UTF-8")

# concatenate them all together
# Order doesn't matter since we use a bag of words model
df <- df %>% unite(col = "text", 
                   c(ad_creative_body, ocr, asr, page_name, disclaimer, 
                     ad_creative_link_caption, ad_creative_link_title, 
                     ad_creative_link_description), 
                   sep = " ")

# Kick out empty ads
df <- df[df$text != "",]
df <- df[is.na(df$text) == F,]

# Replace newlines with spaces
df$text <- str_replace_all(df$text, "\\\n", " ")
# Remove extraneous spaces
df$text <- str_squish(df$text)

fwrite(df, path_output_data)
