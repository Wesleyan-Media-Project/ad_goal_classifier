library(jsonlite)
library(parallel)

extract_age <- function(x) {
  json_str <- str_replace_all(x, "\"\"", "\"")
  df_demographic <- fromJSON(json_str)
  df_demographic$percentage <- as.numeric(df_demographic$percentage)
  df_demographic <- df_demographic %>%
    group_by(age) %>%
    summarize(percentage = sum(percentage))

  age_equivalents <- data.frame(
    age_group = c("13-17", "18-24", "25-34", "35-44", "45-54", "55-64", "65+"),
    age = c(15, 21, 29.5, 39.5, 49.5, 59.5, 69.5)
  )

  df_demographic$age <- age_equivalents$age[match(df_demographic$age, age_equivalents$age_group)]
  ad_demographic <- sum(df_demographic$age * df_demographic$percentage)

  return(ad_demographic)
}

fb22_vars <- fread("../../data-post-production/fb_2022/fb_2022_adid_var1.csv.gz", data.table = F)
test <- fb22_vars[fb22_vars$demographic_distribution != "", ]
ads_age <- sapply(test$demographic_distribution, extract_age)

cl <- makeCluster(12L)
clusterExport(cl, c("str_replace_all", "fromJSON", "%>%", "summarize", "group_by"))
ads_age <- pblapply(cl = cl, test$demographic_distribution, extract_age)
stopCluster(cl)

test$age <- unlist(ads_age)
age <- test %>% select(ad_id, age)
save(age, file = "age.rdata")
