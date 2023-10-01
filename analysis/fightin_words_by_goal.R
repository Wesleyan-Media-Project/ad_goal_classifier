library(data.table)
library(stringr)
library(stringi)
library(dplyr)
library(tidyr)
library(SpeedReader)
library(quanteda)
library(slam)
library(xtable)

fb22 <- fread("../data/ad_goal_rf_fb2022.csv.gz", data.table = F)
fb22_text <- fread("../data/fb2022_prepared.csv.gz", data.table = F)

# Top Fightin Words associated with each goal
# Tokenize the text
tks <- tokens(fb22_text$text, remove_punct = T)

# Assign goal variables to the token object
docvars(tks, "donate") <- fb22$goal_DONATE_prediction
docvars(tks, "contact") <- fb22$goal_CONTACT_prediction
docvars(tks, "purchase") <- fb22$goal_PURCHASE_prediction
docvars(tks, "gotv") <- fb22$goal_GOTV_prediction
docvars(tks, "event") <- fb22$goal_EVENT_prediction
docvars(tks, "poll") <- fb22$goal_POLL_prediction
docvars(tks, "gatherinfo") <- fb22$goal_GATHERINFO_prediction
docvars(tks, "learnmore") <- fb22$goal_LEARNMORE_prediction
docvars(tks, "persuade") <- fb22$goal_PRIMARY_PERSUADE_prediction
fb22$nogoals <- fb22 %>% select(ends_with("_prediction")) %>% apply(., 1, function(x){all(x == 0)}) %>% as.numeric()
docvars(tks, "nogoals") <- fb22$nogoals # mostly about Ukraine

#Remove stopwords
stopw <- quanteda::stopwords()
tks <- tokens_remove(tks, stopw)

#Convert to document-feature-matrix, make a dataframe with the covariates
dtm <- dfm(tks)
df_vars <- docvars(dtm)
dtm <- slam::as.simple_triplet_matrix(dtm)

# Loop over goals, do fightin words for each
goals <- c("donate",
           "contact",
           "purchase",
           "gotv",
           "event",
           "poll",
           "gatherinfo",
           "learnmore",
           "persuade",
           "nogoals")

dfg <- matrix("", nrow = 20, ncol = length(goals))
dfg <- as.data.frame(dfg)
names(dfg) <- goals

for(i in 1:length(goals)){
  # Fightin Words
  cgt <- contingency_table(df_vars, dtm, variables_to_use = goals[i])
  fs <- feature_selection(cgt,
                          method = "informed Dirichlet")
  dfg[goals[i]] <- fs[['1']]$term[1:20]
}

dfg

fwrite(dfg, "tables/fightin_words_goal_top_20.csv")
print(xtable(dfg, 
             caption = "Top 20 words most associated with a given goal.",
             label = "tab:fightin_words"),
      "latex",
      "tables/fightin_words.tex",
      include.rownames = F)
