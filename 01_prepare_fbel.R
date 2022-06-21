library(data.table)
library(stringr)
library(stringi)
library(dplyr)

# Input data
path_input_data <- "data/fbel_w_train.csv"
# Output data
path_output_data <- "data/fbel_prepared.csv"


df <- fread(path_input_data, encoding = 'UTF-8', data.table = F)

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
  mutate(across(c(page_name, disclaimer, ad_creative_body,
                  ad_creative_link_caption, ad_creative_link_title,
                  ad_creative_link_description),
                fix_unicode))

df$ad_creative_body <- str_remove(df$ad_creative_body,  '\\[\\"\\"')
df$ad_creative_body <- str_remove(df$ad_creative_body,  '\\"\\"\\]')
df$ad_creative_body <- str_replace_all(df$ad_creative_body,  '\\"\\"', '\\"')

# Exclude ads that having nothing for PRIMARY_PERSUADE
# Because those ads also weren't coded for DONATE etc. and would be incorrectly assigned a 0
df <- df[df$PRIMARY_PERSUADE != "",]

df <- df %>% select(ad_id, ad_creative_body, DONATE, CONTACT, PURCHASE, GOTV, EVENT, POLL, GATHERINFO, LEARNMORE, PRIMARY_PERSUADE)
df$PRIMARY_PERSUADE[df$PRIMARY_PERSUADE == "No, primary goal is something else"] <- ""

df <- df %>%
  mutate(across(c(DONATE, CONTACT, PURCHASE, GOTV, EVENT, POLL, GATHERINFO, LEARNMORE, PRIMARY_PERSUADE),
                function(x){ifelse(x == "", 0, 1)}))

df <- rename(df, text = ad_creative_body)

df <- df[df$text != "",]

df$text <- str_replace_all(df$text, "\\\n", " ")

fwrite(df, path_output_data)
