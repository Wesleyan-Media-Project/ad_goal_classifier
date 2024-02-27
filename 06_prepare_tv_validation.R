library(haven)
library(dplyr)
library(data.table)


cr <- read_dta('../tv-datasets/tv/2020_creative_level_122120.dta') #this data is in tv-datasets and not available to users
cr <- cr %>% select(c(creative, PERSUADE, DONATE, LEGISLATOR, PURCHASE, OTHERGOAL))

text <- fread('../tv-datasets/tv/tv_2020_fed.csv', data.table = F) #this data is in tv-datasets and not available to users
text <- text %>% select(creative, google_asr_text)

# Merge and remove missings
df <- left_join(cr, text)
df <- df[(is.na(df$google_asr_text) == F) & (is.na(df$PERSUADE) == F),]

# Recode so that goal or primary goal is 1, 0 remains 0
df$PERSUADE[df$PERSUADE != 0] <- 1
df$DONATE[df$DONATE != 0] <- 1
df$LEGISLATOR[df$LEGISLATOR != 0] <- 1
df$PURCHASE[df$PURCHASE != 0] <- 1
df$OTHERGOAL[df$OTHERGOAL != 0] <- 1

fwrite(df, "data/tv_validation_data.csv.gz")
