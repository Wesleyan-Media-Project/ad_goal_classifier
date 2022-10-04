library(data.table)
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)

# Load WMP entity file, restrict to senators and only keep pdid and senate state
ent <- fread("../datasets/wmp_entity_files/Facebook/2022/wmp_fb_2022_entities_v091922.csv")
ent <- filter(ent, wmp_spontype == "campaign") %>%
  filter(wmp_office == "us senate") %>%
  select(pd_id, sen_state)

# Load FB 2022 masterfile, only keep id, pdid, delivery_by_region
fb22 <- fread("../datasets/facebook/fb2022_master_0919_1001.csv.gz")
fb22$id <- paste0("x_", fb22$id)
fb22 <- fb22 %>% select(id, pd_id, delivery_by_region)

# Extract regional impressions (state & percentage)
# Start extracting the state from region distribution
fb22$delivery_by_region <- 
  fb22$delivery_by_region %>%
  str_replace_all("Washington, District of Columbia", "Washington District of Columbia") %>% 
  str_remove_all('\\"') %>% 
  str_remove_all('percentage:') %>% 
  str_remove_all(',region') %>% 
  str_remove_all('\\[|\\]|\\{|\\}')
# Extract the percentage
fb22$region_pct <- str_extract_all(fb22$delivery_by_region, "[0-9|\\.]+")
# Finish extracting the state
fb22$delivery_by_region <- 
  fb22$delivery_by_region %>%
  str_remove_all("[0-9|\\:|\\.]") %>%
  str_split(",") %>%
  lapply(function(x){state.abb[match(x, state.name)]}) %>%
  lapply(unique)

# Merge with WMP entities file
fb22 <- left_join(fb22, ent, by = "pd_id")
# Keep only senators
fb22 <- fb22 %>% filter(is.na(sen_state) == F)
# Remove ads without a regional distribution
fb22 <- fb22 %>% filter(is.na(delivery_by_region) == F)

# Determine in-state
fb22$instate <- F
thresholds <- c(0.25, 0.5, 0.75, 0.8, 0.85, 0.9, 0.95, 0.99, 1)
freqs <- list()

for (t in 1:length(thresholds)){
  fb22$instate <- F
  for(i in 1:nrow(fb22)){
    # Check which, if any of the targeted states is the senator's
    state_ind <- which(fb22$delivery_by_region[[i]] == fb22$sen_state[i])
    # If any
    if(length(state_ind) != 0){
      # Check if more or equal to threshold
      fb22$instate[i] <- fb22$region_pct[[i]][state_ind] >= thresholds[t]
    }
  }
  freqs[[t]] <- as.numeric(table(fb22$instate)[2]/nrow(fb22))
}

df_thresh <- data.frame(thresholds, unlist(freqs))
names(df_thresh) <- c("thresholds", "freqs")
ggplot(df_thresh, aes(thresholds, freqs)) + geom_point() + 
  xlim(0, 1) + ylim(0, 1) +
  labs(x = "Threshold", y = "Proportion of in-state ads")
ggsave("figures/instate_threshold.pdf")


# Final threshold = 0.95
fb22$instate <- F
threshold <- 0.95

for(i in 1:nrow(fb22)){
  # Check which, if any of the targeted states is the senator's
  state_ind <- which(fb22$delivery_by_region[[i]] == fb22$sen_state[i])
  # If any
  if(length(state_ind) != 0){
    # Check if more or equal to threshold
    fb22$instate[i] <- fb22$region_pct[[i]][state_ind] >= threshold
  }
}

fwrite(fb22, "data/fb2022_instate_senators.csv")
