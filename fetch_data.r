library(readr)
library(data.table)
library(gargle)
library(googlesheets4)
options(gargle_oauth_email = "***REMOVED***")

url <- c("***REMOVED***")
start_time <- Sys.time()
master_table <- read_sheet(url)
end_time <- Sys.time()
end_time - start_time
saveRDS(master_table, "data/master_metadata.rds")

#Join variants file with master metadata, fix collecting_org incosistence then.
aa_data <- fread("data/combined_aa.csv") %>% 
  left_join(., master_table %>% select(central_sample_id, collecting_org)) %>% 
  mutate(collecting_org = toupper(collecting_org)) %>% 
  mutate(collecting_org = case_when(
    collecting_org %in% c("IPSWICH", "COLCHESTER") ~ "IPSWICH",
    collecting_org %in% c("JPH","JPUH") ~ "JPUH",
    collecting_org %in% c("NCHC", "NCH&C") ~ "NCHC",
    !collecting_org %in% c("QEH","NNUH", "ECCH") ~ "Others",
    TRUE ~ collecting_org
  ))

# unique(master_table$`Sequencing date`) %>% sort()

non_climb <- master_table %>% 
  filter(`Sequencing date` %in% c("20210115", "20210120")) %>% 
  select(central_sample_id, sample_date = collection_date, 
         phylotype = civet_phylotype,
         lineage = civet_lineage) %>% 
  mutate(sample_date = as.character(sample_date) %>% ymd())


HERTFORDSHIRE <- master_table %>% 
  filter(adm2=="HERTFORDSHIRE") %>% 
  select(central_sample_id, adm2, `Sequencing date`, contains("lineage"), contains("phylotype"), contains("closet"),contains("QC"))
  

nextclade <- fread("data/nextclade.csv")


saveRDS(aa_data, "data/data.rds")

