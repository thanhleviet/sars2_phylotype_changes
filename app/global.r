library(readr)
library(dplyr, warn.conflicts = FALSE)
library(tidyr)
library(ggplot2)
library(lubridate)
library(stringr)

plotly_height <- 800

aa_changes <- read_rds("data/data.rds")

phylotype_collecting_org <- aa_changes %>% 
  mutate(phylotype = paste0(lineage,"-",phylotype))

spike <- aa_changes %>% 
  mutate(phylotype = paste0(lineage, "-", phylotype))

input_data <- aa_changes %>%
  filter(!is.na(phylotype)) %>%
  mutate(phylotype = paste0(lineage,"-",phylotype)) %>%
  group_by(phylotype, sample_date) %>%
  summarise(count = n()) %>%
  ungroup() %>%
  arrange(sample_date) %>%
  group_by(phylotype) %>%
  mutate(cumsum = cumsum(count)) %>%
  mutate(days = n())

# Sort phylotype by their frequency
phylotypes <- input_data %>% 
  group_by(phylotype) %>% 
  summarise(count = n()) %>% 
  arrange(desc(count)) %>% 
  pull(phylotype)

#Collecting org
# 
collecting_org <- aa_changes %>%
  distinct(collecting_org) %>%
  pull(collecting_org) %>%
  sort()
# spike <- aa_changes %>%
#   group_by(phylotype, sample_date, variants) %>% 
#   summarise(count = n()) %>% 
#   ungroup() %>% 
#   arrange(sample_date) %>% 
#   group_by(phylotype) %>% 
#   mutate(cumsum = cumsum(count)) %>% 
#   mutate(days = n()) %>% 
#   ungroup() %>% 
#   separate_rows(variants, convert = TRUE, sep = "\\|") %>% 
#   distinct_all() %>% 
#   filter(grepl("S:",variants)) %>% 
#   mutate(variants = gsub("S:","",variants))

# phylotypes_update <- b117 %>%
#   filter(days >= 3) %>%
#   group_by(phylotype) %>%
#   summarise(count = n()) %>%
#   arrange(desc(count)) %>%
#   pull(phylotype)
