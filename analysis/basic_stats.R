library(data.table)
library(stringr)
library(stringi)
library(dplyr)
library(tidyr)
library(xtable)

fb22 <- fread("../data/ad_goal_rf_fb2022.csv.gz", data.table = F)

# Select only ad_id and prediction columns, simplify column names
fb22_pred <- fb22 %>% select(ad_id, ends_with("prediction"))
names(fb22_pred) <- str_remove(names(fb22_pred), "goal_")
names(fb22_pred) <- str_remove(names(fb22_pred), "_prediction")
names(fb22_pred) <- str_replace(names(fb22_pred), "PRIMARY_PERSUADE", "PERSUADE")
fb22_pred$NOGOALS <- fb22_pred %>% select(-ad_id) %>% apply(., 1, function(x){all(x == 0)}) %>% as.numeric()


# Goal count
# Ignore warning
goal_count = fb22_pred %>%
  summarise(across(c(DONATE:NOGOALS), list(mean = mean, sum = sum))) %>%
  pivot_longer(cols = everything(), names_to = c(".value", "variable"), names_sep = "_") %>%
  t() %>%
  as.data.frame()
names(goal_count) <- c("Proportion", "Sum")
goal_count <- goal_count[-1,]
goal_count$Proportion <- round(as.numeric(goal_count$Proportion), 2)
goal_count$Sum <- as.numeric(goal_count$Sum)


# Goal spend
fb22_vars <- fread("../../fb_2022/fb_2022_adid_var1.csv.gz", data.table = F)
fb22_vars <- fb22_vars %>% select(ad_id, page_id, pd_id, spend)
fb22_vars$spend <- str_split_fixed(fb22_vars$spend, ",", 2) %>%
  apply(., 2, function(x){str_extract(x, "[0-9]+")}) %>%
  apply(., 1, function(x){mean(as.numeric(x))})
fb22 <- left_join(fb22_pred, fb22_vars, by = "ad_id")

ngoals <- fb22 %>% select(DONATE:NOGOALS) %>% apply(., 1, sum)
spenddistr <- fb22$spend/ngoals
spend_by_goal <- fb22 %>% select(DONATE:NOGOALS)
spend_by_goal <- spend_by_goal * spenddistr
spend_by_goal[is.na(spend_by_goal)] <- 0

goal_total_spend <- apply(spend_by_goal, 2, sum)
goal_total_spend = spend_by_goal %>%
  summarise(across(c(DONATE:NOGOALS), list(sum = sum)))

goal_total_spend <- t(goal_total_spend) %>% as.data.frame(.)
names(goal_total_spend) <- "Spend"
goal_total_spend$Proportion <- round(goal_total_spend$Spend/sum(goal_total_spend), 2)


# Combine everything and save
final_table <- cbind(goal_count, goal_total_spend)
names(final_table) <- c("Proportion Ads", "Ad Count", "Spend", "Proportion Spend")
final_table <- final_table %>% select(`Ad Count`, `Proportion Ads`, Spend, `Proportion Spend`)
print(xtable(final_table, 
             caption = "Ad count and spend, by goal.",
             label = "tab:basic_stats"),
      "latex",
      "tables/basic_stats.tex",
      include.rownames = T)
