library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(plotly)
library(lubridate)
library("RColorBrewer")

aa_changes <- read_csv("data/combined_aa.csv")

b117 <- aa_changes %>% 
  # filter(lineage=="B.1.1.7") %>% 
  group_by(phylotype, sample_date, lineage) %>% 
  summarise(count = n()) %>% 
  ungroup() %>% 
  arrange(sample_date) %>% 
  group_by(phylotype) %>% 
  mutate(cumsum = cumsum(count)) %>% 
  mutate(days = n()) %>% 
  filter(days > 7)

b117 %>% 
  summarise(count = n()) %>% 
  arrange(desc(count))

p <- ggplot(b117,aes(x = sample_date, y = cumsum, color = phylotype, group=days)) +
  geom_line() +
  geom_point() +
  xlab("Collection date") +
  ylab("Cum sum of sequences") +
  scale_x_date(date_breaks = "1 week", date_labels = "%Y-%b-%d/%W") +
  scale_y_continuous(position = "right")

ggplotly(p)


# full_snp <- aa_changes %>% 
#   # filter(lineage=="B.1.1.7") %>% 
#   group_by(phylotype) %>%  
#   filter(variant_counts == max(variant_counts))
#   
test <- aa_changes %>% 
  filter(sample_date > ymd("2020-10-10"))

filtered_phylotype <- unique(test$phylotype)

filtered_data <- aa_changes %>%
  filter(!is.na(phylotype)) %>% 
  filter(phylotype %in% filtered_phylotype) %>%
  separate_rows(variants, convert = TRUE, sep = "\\|") %>%
  distinct_all() %>%
  filter(grepl("S:",variants)) %>%
  mutate(variants = gsub("S:","",variants)) %>% 
  filter(!is.na(phylotype)) %>% 
  group_by(variants) %>% 
  summarise(count = n()) %>% 
  arrange(desc(count))

plot_ly(filtered_data) %>% 
  add_bars(y = ~reorder(variants, desc(count)),
           x = ~count,
           orientation = 'h')


ggplot(data = filtered_data, aes(
  label = variants,
  size = count,
  color = variants,
)) +
  geom_text_wordcloud_area()  +
  scale_size_area(max_size = 24) +
  theme_minimal() 

wordcloud::wordcloud(filtered_data$variants,
                     filtered_data$count,min.freq = 4,
                     max.words=60,
                     random.order=FALSE,
                     rot.per=0.35, 
                     colors=brewer.pal(8, "Dark2"))

data("love_words_small")
set.seed(42)

love_words_small <- love_words_small %>%
  mutate(angle = 90 * sample(c(0, 1), n(), replace = TRUE, prob = c(60, 40)))

ggplot(
  love_words_small,
  aes(
    label = word, size = speakers,
    color = speakers, angle = angle
  )
) +
  geom_text_wordcloud_area() +
  scale_size_area(max_size = 24) +
  theme_minimal() +
  scale_color_gradient(low = "darkred", high = "red")


ggplot(filtered_data, aes(reorder(variants, -count), count)) +
  geom_bar(stat = "identity", position = "stack",show.legend = F) +
  coord_flip() +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5)
  )

p <- ggplot(data = spike, aes(reorder(variants, -count), count)) +
  geom_bar(stat = "identity", position = "stack",show.legend = F) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5)
  ) 

ggplotly(p)




summary_aa <- aa_data %>% 
  filter(!is.na(phylotype)) %>% 
  group_by(phylotype) %>% 
  filter(variant_counts == max(variant_counts)) %>% 
  separate_rows(variants, convert = TRUE, sep = "\\|") %>% 
  mutate(aa_gene = gsub(":[A-Z0-9]*", "", variants)) %>% 
  select(phylotype, aa_gene, variant_counts) %>% 
  ungroup() %>% 
  group_by(phylotype, variant_counts, aa_gene) %>% 
  summarise(count = n()) %>% 
  pivot_wider(names_from = aa_gene, values_from = count, values_fill = 0) %>% 
  select(phylotype, variant_counts, sort(colnames(.), decreasing = TRUE))

datatable(summary_aa)



phylotype_collecting_org <- aa_data %>% 
  group_by(phylotype, collecting_org) %>% 
  summarise(count = n()) %>% 
  mutate(collecting_org = if_else(is.na(collecting_org), "Missing", collecting_org))

ggplot(data = phylotype_collecting_org, aes(x = collecting_org, y = count)) +
  geom_bar(stat = "identity", aes(fill = collecting_org)) +
  theme_minimal()
