library(data.table)
library(stringr)
library(stringi)
library(dplyr)
library(tidyr)
library(SpeedReader)
library(quanteda)

fb22 <- fread("../data/ad_goal_rf_fb2022.csv.gz")
fb22_text <- fread("../data/fb2022_prepared.csv.gz")

# Top Fightin Words assiciated with each goal
# Tokenize the text
tks <- tokens(fb22_text$text)

# Assign party variable to the token object
docvars(tks, "donate") <- fb22$goal_DONATE_prediction

#Remove stopwords
stopw <- quanteda::stopwords()
tks <- tokens_remove(tks, stopw)

#Convert to document-feature-matrix, make a dataframe with the covariates
dtm <- dfm(tks)
df_vars <- docvars(dtm)
dtm <- slam::as.simple_triplet_matrix(dtm)


# Fightin Words
cgt <- contingency_table(df_vars, dtm, variables_to_use = "party")
fs <- feature_selection(cgt,
                        method = "informed Dirichlet")