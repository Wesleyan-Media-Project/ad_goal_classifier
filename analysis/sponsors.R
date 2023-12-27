library(data.table)
library(stringr)
library(stringi)
library(dplyr)
library(tidyr)
library(ggplot2)
# library(GGally)
# library(plotly)
library(xtable)

fb22 <- fread("../data/ad_goal_rf_fb2022.csv.gz", data.table = F)

# Select only ad_id and prediction columns, simplify column names
fb22_pred <- fb22 %>% select(ad_id, ends_with("prediction"))
names(fb22_pred) <- str_remove(names(fb22_pred), "goal_")
names(fb22_pred) <- str_remove(names(fb22_pred), "_prediction")

# Combine relevant vars from multiple datasets
fb22_vars <- fread("../../data-post-production/fb_2022/fb_2022_adid_var1.csv.gz", data.table = F)
fb22_vars <- fb22_vars %>% select(ad_id, page_id, pd_id, spend)
fb22_vars$spend <- str_split_fixed(fb22_vars$spend, ",", 2) %>%
  apply(., 2, function(x){str_extract(x, "[0-9]+")}) %>%
  apply(., 1, function(x){mean(as.numeric(x))})

fb22_vars2 <- fread("../../data-post-production/fb_2022/fb_2022_adid_text.csv.gz", data.table = F)
fb22_vars2 <- fb22_vars2 %>% select(ad_id, page_name)

fb22 <- left_join(fb22_vars, fb22_vars2, by = "ad_id")
fb22 <- left_join(fb22, fb22_pred, by = "ad_id")

rm(list = ls()[ls() != "fb22"])

#----

# Sponsors who run GOTV ads without calling for the election of a specific candidates
# Mostly seem to be nonpartisan groups, but a few Dem ads are in there
non_persuade_sponsors <- fb22$page_name[(fb22$GOTV == 1 & fb22$PRIMARY_PERSUADE == 0)]
non_persuade_sponsors <- data.frame(table(non_persuade_sponsors))
names(non_persuade_sponsors) <- c("Sponsor", "Ads")
non_persuade_sponsors <- non_persuade_sponsors[order(non_persuade_sponsors$Ads, decreasing = T),]
non_persuade_sponsors <- non_persuade_sponsors[1:15,]
print(xtable(non_persuade_sponsors, 
             caption = "Sponsors who run ads that are GOTV without also being Persuade.",
             label = "tab:non_persuade_gotv_sponsors"),
      "latex",
      "tables/non_persuade_gotv_sponsors.tex",
      include.rownames = F)

# sponsor % of spend by goal
# purchase
fb22_purchase <- fb22[fb22$PURCHASE == 1,]
purchase_spenders <- aggregate(fb22_purchase$spend, by = list(fb22_purchase$page_name), sum)
names(purchase_spenders) <- c("page_id", "spend")
purchase_spenders$percent <- purchase_spenders$spend/sum(purchase_spenders$spend)
purchase_spenders <- purchase_spenders[order(purchase_spenders$percent, decreasing = T),]
purchase_spenders$percent <- round(purchase_spenders$percent, 2)
names(purchase_spenders) <- c("Page", "Spend", "Proportion Spend")
purchase_spenders <- purchase_spenders[1:15,]
print(xtable(purchase_spenders, 
             caption = "Purchase ad sponsors, sorted by their spend.",
             label = "tab:purchase_sponsors"),
      "latex",
      "tables/purchase_sponsors.tex",
      include.rownames = F)

# % of sponsor's spend by goal
# If an ad has multiple goals, spread the spend between them equally
ngoals <- fb22 %>% select(DONATE:PRIMARY_PERSUADE) %>% apply(., 1, sum)
spenddistr <- fb22$spend/ngoals
spend_by_goal <- fb22 %>% select(DONATE:PRIMARY_PERSUADE)
spend_by_goal <- spend_by_goal * spenddistr
spend_by_goal[is.na(spend_by_goal)] <- 0

fb22_spend_by_goal <- fb22
fb22_spend_by_goal[,names(fb22_spend_by_goal %>% select(DONATE:PRIMARY_PERSUADE))] <- spend_by_goal
goal_by_sponsor <- fb22_spend_by_goal %>%
  group_by(page_name) %>%
  summarise(across(c(DONATE:PRIMARY_PERSUADE), sum))

topspenders <- data.frame(spend = goal_by_sponsor %>% select(DONATE:PRIMARY_PERSUADE) %>% apply(., 1, sum),
                          sponsor = goal_by_sponsor$page_name)
topspenders <- topspenders[order(topspenders$spend, decreasing = T),]
goal_by_sponsor <- goal_by_sponsor %>% pivot_longer(-page_name)
topsponsors <- topspenders$sponsor[1:30]
goal_by_topsponsor <- goal_by_sponsor[goal_by_sponsor$page_name %in% topsponsors,]
names(goal_by_topsponsor) <- c("Page Name", "Goal", "Spend")
goal_by_topsponsor$`Page Name` <- factor(goal_by_topsponsor$`Page Name`, rev(topsponsors))
levels(goal_by_topsponsor$`Page Name`)[levels(goal_by_topsponsor$`Page Name`) == "NO on Prop 29 - Stop Yet Another Dangerous Dialysis Proposition"] <- "NO on Prop 29"

ggplot(goal_by_topsponsor, aes(Spend, `Page Name`)) + geom_col(aes(fill = Goal)) + theme(legend.position = "bottom")
ggsave("figures/goal_by_sponsor.pdf", height = 10, width = 12)

# Top sponsors by goal
goals <- unique(goal_by_sponsor$name)
for(i in 1:length(goals)){
  top_sponsors_by_goal <- goal_by_sponsor[goal_by_sponsor$name == goals[i],]
  top_sponsors_by_goal <- top_sponsors_by_goal[order(top_sponsors_by_goal$value, decreasing = T),]
  top_sponsors_by_goal <- top_sponsors_by_goal[1:30,]
  top_sponsors_by_goal <- top_sponsors_by_goal[top_sponsors_by_goal$value>0,]
  names(top_sponsors_by_goal) <- c("Page Name", "Goal", "Spend")
  top_sponsors_by_goal$`Page Name` <- factor(top_sponsors_by_goal$`Page Name`, rev(top_sponsors_by_goal$`Page Name`))
  ggplot(top_sponsors_by_goal, aes(Spend, `Page Name`)) + geom_col() + theme(legend.position = "bottom") + labs(title = goals[i])
  ggsave(paste0("figures/top_sponsors_by_goal_", goals[i],".pdf"), height = 10, width = 12)
}


# Do any of the top 100 spenders spread their spend more evenly between goals?
# Not really, there are none with low gini or low variance within the sponsor
top100sponsors <- topspenders$sponsor[1:100]
goal_by_top100sponsor <- goal_by_sponsor[goal_by_sponsor$page_name %in% top100sponsors,]
goal_gini <- aggregate(goal_by_top100sponsor$value, by = list(goal_by_top100sponsor$page_name), DescTools::Gini)
goal_var <- aggregate(goal_by_top100sponsor$value, by = list(goal_by_top100sponsor$page_name), var)

#----
# Age
load("age.rdata")
fb22_age <- right_join(fb22, age, by = "ad_id")

ggplot(fb22_age, aes(age)) + geom_density()
ggplot(fb22_age[fb22_age$DONATE == 1,], aes(age)) + geom_density()
ggplot(fb22_age[fb22_age$CONTACT == 1,], aes(age)) + geom_density()
ggplot(fb22_age[fb22_age$PURCHASE == 1,], aes(age)) + geom_density()
ggplot(fb22_age[fb22_age$GOTV == 1,], aes(age)) + geom_density()
ggplot(fb22_age[fb22_age$EVENT == 1,], aes(age)) + geom_density()
ggplot(fb22_age[fb22_age$POLL == 1,], aes(age)) + geom_density()
ggplot(fb22_age[fb22_age$GATHERINFO == 1,], aes(age)) + geom_density()
ggplot(fb22_age[fb22_age$LEARNMORE == 1,], aes(age)) + geom_density()
ggplot(fb22_age[fb22_age$PRIMARY_PERSUADE == 1,], aes(age)) + geom_density()

mean(fb22_age$age[fb22_age$DONATE == 1])
mean(fb22_age$age[fb22_age$GOTV == 1])
mean(fb22_age$age[fb22_age$LEARNMORE == 1], na.rm = T)

fb22_age_df <- fb22_age %>% select(DONATE:PRIMARY_PERSUADE) %>% as.matrix(.) * fb22_age$age
fb22_age_df <- as.data.frame(fb22_age_df)
fb22_age_df$ad_id <- fb22_age$ad_id
fb22_age_df <- fb22_age_df %>% pivot_longer(-ad_id, names_to = "Goal", values_to = "Age")
fb22_age_df <- fb22_age_df[fb22_age_df$Age != 0,]
fb22_age_df <- fb22_age_df[is.na(fb22_age_df$Age) == F,]

#ggplot(fb22_age_df, aes(Age, color = Goal)) + geom_density()
ggplot(fb22_age_df, aes(Age)) + 
  geom_density() + 
  stat_summary(aes(xintercept = ..x.., y = 0), fun = mean, geom = "vline", orientation = "y", color = "darkgray") +
  stat_summary(aes(label = ..x.., y = 0), fun = function(x){round(mean(x), 2)}, geom = "text", orientation = "y", color = "darkgray", hjust = -0.2) +
  facet_wrap(~Goal) +
  theme_bw() +
  labs(y = "")
ggsave("figures/age_by_goal.pdf", width = 8, height = 8)

#----
# The reason the following doesn't match topspenders
# is because some ads have no goals, and so they get excluded from topspenders
# topspenders2 <- aggregate(fb22$spend, by = list(fb22$page_name), sum)
