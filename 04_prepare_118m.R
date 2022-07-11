# Prepare the 118m data so it is in the same shape as the training data

library(data.table)
library(stringr)
library(stringi)
library(dplyr)
library(tidyr)

# Input data
path_input_data <- "../118m/all_ads.rdata"
# Output data
path_output_data <- "data/118m_prepared.csv.gz"

# Load data
load(path_input_data)
df <- text
rm(text)

# Clean up unicode
fix_unicode <- function(text){
  
  Encoding(text) <- "UTF-8"
  # remove trailing backslashes
  # this is necessary, otherwise the unicode unescaping will break some texts
  text <- str_remove(text, "[\\\\]+$")
  # unescaping has to be done twice
  text <- stri_unescape_unicode(text)
  text <- stri_unescape_unicode(text)
  # Convert unicode-based characters
  # this takes care of things like boldface characters, etc.
  text <- stri_trans_nfkd(text)
  
  return(text)
}
# Apply the function to all text columns
df <- df %>%
  mutate(across(c(ad_creative_body, ocr, asr, page_name, disclaimer, 
                  ad_creative_link_caption, ad_creative_link_title, 
                  ad_creative_link_description),
                fix_unicode))

# Clean up brackets
clean_brackets <- function(x){
  x <- str_remove(x,  '\\[\\"\\"')
  x <- str_remove(x,  '\\"\\"\\]')
  x <- str_replace_all(x,  '\\"\\"', '\\"')
}
# Apply the function to all text columns
df <- df %>%
  mutate(across(c(ad_creative_body, ocr, asr, page_name, disclaimer, 
                  ad_creative_link_caption, ad_creative_link_title, 
                  ad_creative_link_description),
                clean_brackets))

# Clean up semicolons in ocr have already been cleaned up
# df$ocr <- str_replace_all(df$ocr, ';', ' ')

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

fwrite(df, path_output_data)
