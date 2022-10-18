library(data.table)
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)

# Load WMP entity file, restrict to senators and only keep pdid and senate state
ent <- fread("../datasets/wmp_entity_files/Facebook/2022/wmp_fb_2022_entities_v101722.csv")
ent <- filter(ent, wmp_spontype == "campaign") %>%
  filter(wmp_office == "us senate") %>%
  select(pd_id, sen_state) %>%
  mutate(sen_state = state.name[match(sen_state, state.abb)])

# Load FB 2022 masterfile, only keep id, pdid, delivery_by_region
fb22 <- fread("../datasets/facebook/fb2022_master_1002_1015.csv.gz", encoding = "UTF-8")
fb22$id <- paste0("x_", fb22$id)
fb22 <- fb22 %>% select(id, pd_id, delivery_by_region)

# Merge with WMP entities file
fb22 <- left_join(fb22, ent, by = "pd_id")
# Keep only senators
fb22 <- fb22 %>% filter(is.na(sen_state) == F)
# Remove ads without a regional distribution
fb22 <- fb22 %>% filter(is.na(delivery_by_region) == F)


# Extract regional impressions (state & percentage)
# Start extracting the state from region distribution
fb22$delivery_by_region <- 
  fb22$delivery_by_region %>%
  str_replace_all("Washington, District of Columbia", "Washington District of Columbia") %>% 
  str_remove_all('\\"') %>% 
  str_remove_all('percentage:') %>% 
  str_remove_all(',region') %>% 
  str_remove_all('\\[|\\]|\\{|\\}')

# Then split individual values
delivery_by_region_split <- str_split(fb22$delivery_by_region, ",")

# Then separate the regions part from the percentages part
separate_region_from_pct <- function(x){
  out <- str_split(x, ":")
  regions <- unlist(lapply(out, function(x){x[2]}))
  regions_pct <- unlist(lapply(out, function(x){x[1]}))
  df_regions <- list(regions, regions_pct)
  return(df_regions)
}

separated_region_from_pct = lapply(delivery_by_region_split, separate_region_from_pct)
regions_l = lapply(separated_region_from_pct, function(x){x[1]}) %>% lapply(unlist)
regions_pct_l = lapply(separated_region_from_pct, function(x){x[2]}) %>% lapply(unlist)

fb22$delivery_by_region <- regions_l
fb22$region_pct <- regions_pct_l

# Find the proportion of the senator's state; if it isn't present, set it to 0
fb22$instate_pct <- 0
for(i in 1:nrow(fb22)){
    # Check which, if any of the targeted states is the senator's
    state_ind <- which(fb22$delivery_by_region[[i]] == fb22$sen_state[i])
    # If any
    if(length(state_ind) != 0){
      # Assign as ad's proportion
      fb22$instate_pct[i] <- fb22$region_pct[[i]][state_ind]
    }
  }

fwrite(fb22, "data/fb2022_instate_senators.csv")
