library(data.table)
library(stringr)
library(stringi)
library(dplyr)
library(tidyr)
library(ggplot2)

fb22 <- fread("../data/ad_goal_rf_fb2022.csv.gz")

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
