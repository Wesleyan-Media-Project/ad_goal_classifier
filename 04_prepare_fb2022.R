# Prepare the FB 2022 data so it is in the same shape as the training data
# Currently does not include ocr

library(data.table)
library(stringr)
library(stringi)
library(dplyr)
library(tidyr)

# Input data
path_input_data <- '../datasets/facebook/fb2022_master_0905_1108.csv.gz'
# The line above does not work, it should be either fb2022_master_0919_1001.csv.gz or fb2022_master_0904_1001.csv.gz

path_input_asr <- '../datasets/facebook/asr_fb2022_0905_1108.csv'
# Output data
path_output_data <- "data/fb2022_prepared.csv.gz"

# Load data
df <- fread(path_input_data, encoding = 'UTF-8')
df$id <- paste0("x_", df$id)
# Merge in ASR
asr <- fread(path_input_asr, colClasses = "character")
asr <- asr %>% 
  select(ad_id, google_asr_text) %>%
  rename(asr = google_asr_text)
df <- left_join(df, asr, by = c("id" = "ad_id"))
df$asr[df$asr == ""] <- NA

# Rename funding entity to disclaimer
df <- df %>% rename(disclaimer = funding_entity)


# Clean up brackets
clean_brackets <- function(x){
  x <- str_remove(x,  '\\[\\"\\"')
  x <- str_remove(x,  '\\"\\"\\]')
  x <- str_replace_all(x,  '\\"\\"', '\\"')
}
# Apply the function to all text columns
df <- df %>%
  mutate(across(c(ad_creative_body, asr, page_name, disclaimer,
                  ad_creative_link_caption, ad_creative_link_title, 
                  ad_creative_link_description),
                clean_brackets))

# concatenate them all together
# Order doesn't matter since we use a bag of words model
df <- df %>% unite(col = "text", 
                   c(ad_creative_body, asr, page_name, disclaimer,
                     ad_creative_link_caption, ad_creative_link_title, 
                     ad_creative_link_description), 
                   sep = " ", na.rm = T)

# Kick out empty ads
df <- df[df$text != "",]
df <- df[is.na(df$text) == F,]

# Replace newlines with spaces
df$text <- str_replace_all(df$text, "\\\\n", " ")

# Clean up extraneous spaces
df$text <- str_squish(df$text)

df <- df %>% select(id, text)

fwrite(df, path_output_data)
