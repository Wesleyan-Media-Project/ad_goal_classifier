library(data.table)
library(stringr)
library(stringi)
library(dplyr)
library(tidyr)
library(ggplot2)
library(GGally)
library(plotly)
library(xtable)

fb22 <- fread("../data/ad_goal_rf_fb2022.csv.gz", data.table = F)

# Select only prediction columns, only rows with more than one prediction
fb22_pred <- fb22 %>% select(ends_with("prediction"))
fb22_multigoal <- fb22_pred[apply(fb22_pred, 1, sum) > 1,]

#----
# Co-occurrence table of predictions, using crossproduct
names(fb22_multigoal) <- str_replace_all(names(fb22_multigoal), "goal_", "")
names(fb22_multigoal) <- str_replace_all(names(fb22_multigoal), "_prediction", "")
cooccurrences <- as.data.frame(crossprod(as.matrix(fb22_multigoal)))
names(cooccurrences) <- str_replace(names(cooccurrences), "PRIMARY_PERSUADE", "PERSUADE")
rownames(cooccurrences) <- str_replace(rownames(cooccurrences), "PRIMARY_PERSUADE", "PERSUADE")
print(xtable(cooccurrences,
             digits = 0,
             caption = "Goal co-occurrences.",
             label = "tab:cooccurrences"),
      "latex",
      "tables/cooccurrences.tex",
      size = "scriptsize",
      include.rownames = T)


# Scatterplot matrix of predicted probabilities
# Sampling 30k ads only, otherwise too big for ggplot
fb22_prob <- fb22 %>% select(ends_with("prob"))
fb22_prob_sample <- fb22_prob[sample(1:nrow(fb22_prob), 30000),]
names(fb22_prob_sample) <- str_replace_all(names(fb22_prob_sample), "goal_", "")
names(fb22_prob_sample) <- str_replace_all(names(fb22_prob_sample), "_predicted_prob", "")
fb22_prob_sample <- fb22_prob_sample %>% select(-highest_prob)
p2 <- ggpairs(fb22_prob_sample,
              lower = list(continuous = wrap("smooth", alpha = 0.1, size=0.05, color = 'coral1'),
                           discrete = "blank", combo="blank")) 
p2
ggsave("figures/scatterplot_matrix.png", width = 15, height = 15)

#----
# Training set
train <- fread("../data/train.csv", data.table = F)
names(train)[3:11] <- names(fb22_prob_sample)[1:9]

# Co-occurrence matrix
# Even here - when Learn More is a goal, Persuade usually is too
cooccurrences_train <- as.data.frame(crossprod(as.matrix(train[,3:11])))
names(cooccurrences_train) <- str_replace(names(cooccurrences_train), "PRIMARY_PERSUADE", "PERSUADE")
rownames(cooccurrences_train) <- str_replace(rownames(cooccurrences_train), "PRIMARY_PERSUADE", "PERSUADE")
print(xtable(cooccurrences_train,
             digits = 0,
             caption = "Goal co-occurrences, training set.",
             label = "tab:cooccurrences_train"),
      "latex",
      "tables/cooccurrences_train.tex",
      size = "scriptsize",
      include.rownames = T)


#----
# Pearson's R between persuade and learnmore
# Inference set
cor(fb22$goal_LEARNMORE_predicted_prob, fb22$goal_PRIMARY_PERSUADE_predicted_prob)

# Training set
# The correlation is not that crazy high in the training data
# But that may just be because there are no values between 0 and 1
cor(train$LEARNMORE, train$PRIMARY_PERSUADE)









#-------------------------------------------------------------------------------
# List of permutations; only point over the above is triplets, etc.
# Loop over rows, for each find the column names corresponding to the 1s
multigoal <- list()
for(i in 1:nrow(fb22_multigoal)){
  multigoal[[i]] <- names(fb22_multigoal)[which(unlist(fb22_multigoal[i,]) == 1)]
}
multigoal <- lapply(multigoal, paste, collapse = " ")
multigoal <- unlist(multigoal)
# Count combinations
df_multigoal <- data.frame(sort(table(multigoal), decreasing = T))
df_multigoal$multigoal <- str_remove_all(df_multigoal$multigoal, "goal_")
df_multigoal$multigoal <- str_remove_all(df_multigoal$multigoal, "_prediction")

fwrite(df_multigoal, "tables/multigoal_combinations.csv")


#----
# Plots, largely redundant due to scatterplot matrix
# Persuasion and GOTV
# Persuasion and gotv are similar
ggplot(fb22, aes(goal_PRIMARY_PERSUADE_predicted_prob, color = factor(goal_GOTV_prediction))) + geom_density()

# More similar than others
ggplot(fb22, aes(goal_PRIMARY_PERSUADE_predicted_prob, color = factor(goal_DONATE_prediction))) + geom_density()
ggplot(fb22, aes(goal_PRIMARY_PERSUADE_predicted_prob, color = factor(goal_EVENT_prediction))) + geom_density()

# The correlation is lopsided though -- high prob on gotv basically guarantees a high prob
# of persuade, but a high persuade prob doesn't guarantee high gotv
ggplot(fb22, aes(goal_PRIMARY_PERSUADE_predicted_prob, goal_GOTV_predicted_prob)) + geom_point(alpha=0.1)

# which is also why this one looks completely unremarkable
ggplot(fb22, aes(goal_GOTV_predicted_prob, color = factor(goal_PRIMARY_PERSUADE_prediction))) + geom_density()

# Persuasion and Learn More
# Predicted prob of persuade, contingent on learn more
ggplot(fb22, aes(goal_PRIMARY_PERSUADE_predicted_prob, color = factor(goal_LEARNMORE_prediction))) + geom_density()

# Scatterplot
ggplot(fb22, aes(goal_PRIMARY_PERSUADE_predicted_prob, goal_LEARNMORE_predicted_prob)) + geom_point(alpha=0.1)


