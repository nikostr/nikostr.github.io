library(tidyverse)

orthogroups <- read_tsv(
  pipe(
    "awk 'BEGIN{print \"orthogroup\tprotein\"} {og=$1;for (i=2; i<=NF; i++) {print og \"\\t\" $i}}' Orthogroups.txt |sed 's/://'"
  )
)

expression_data <- read_tsv('salmon.merged.gene_counts.tsv') %>%
  select(-gene_name)

sinensis_expressed <- expression_data %>%
  mutate(across(where(is.numeric), \(x) x>0)) %>%
  transmute(
    protein=gene_id,
    is_expressed=rowSums(pick(where(is.logical))) > 0
  )

sinensis_expression_in_orthogroup <- orthogroups %>%
  left_join(sinensis_expressed) %>%
  summarize(is_expressed=sum(is_expressed, na.rm = T) > 0, .by = orthogroup)


orthogroups %>%
  left_join(sinensis_expression_in_orthogroup) %>%
  mutate(source=case_match(
    str_extract(protein, '^..'),
    'AT' ~ 'Arabidopsis',
    'Tc' ~ 'Cacao',
    'Sc' ~ 'Stellera',
    'ev' ~ 'A. sinensis',
    'AY' ~ 'A. yunnanensis',
    c('XP', 'NP', 'YP') ~ 'Cotton'
    )) %>%
  count(source, is_expressed) %>%
  pivot_wider(names_from = is_expressed, values_from = n) %>%
  rename(expressed=`TRUE`, not_expressed=`FALSE`) %>%
  mutate(
    total=expressed + not_expressed,
    expressed_out_of_total = expressed/total
    )
