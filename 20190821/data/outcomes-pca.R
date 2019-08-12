library(openfda)

#generic_names <- fda_query("/drug/event.json") %>%
#  fda_count("patient.drug.openfda.generic_name") %>%
#  fda_exec() %>%
#  arrange(desc(count))

generic_names <- readRDS(here::here("data", "generic_names.rds"))
ndrugs <- nrow(generic_names)

##outcomes <- vector("list", ndrugs)
#idx <- min(which(sapply(outcomes, function(x) is.null(nrow(x)))))
#for (i in seq.int(idx, ndrugs)) {
#  drug <- generic_names$term[[i]]
#  # sleep every 9th request to avoid 429 errors
#  if (i %in% seq(idx, ndrugs, by = 8)) Sys.sleep(10)
#  outcomes[[i]] <- fda_query("/drug/event.json") %>%
#    fda_filter("patient.drug.openfda.generic_name", drug) %>%
#    fda_count("patient.reaction.reactionoutcome") %>%
#    fda_exec()
#}
#outcomes <- setNames(outcomes, generic_names$term)
#outcomes <- outcomes %>% 
#  bind_rows(.id = "drug") %>%
#  as_tibble() %>%
#  mutate(reaction = recode(term,
#                           `1` = "Recovered/resolved",
#                           `2` = "Recovering/resolving",
#                           `3` = "Not recovered/not resolved",
#                           `4` = "Recovered/resolved with sequelae",
#                           `5` = "Fatal", `6` = "Unknown")) 
#saveRDS(outcomes, "data/outcomes.rds")


outcomes <- readRDS(here::here("data", "outcomes.rds"))
all_outcomes <- unique(unlist(lapply(outcomes, "[[", "term")))
m <- matrix(
  0, nrow = ndrugs, ncol = length(all_outcomes),
  dimnames = list(generic_names$term, all_outcomes)
)

for (i in seq_len(ndrugs)) {
  drug_name <- generic_names$term[[i]]
  drug_info <- outcomes[[drug_name]]
  m[i, drug_info$term] <- drug_info$count
}

# drop rare outcomes
idx <- colSums(m) > 50000
summary(idx)
m <- m[, idx]

m <- m / rowSums(m)

# a look at the matrix
plot_ly(z = sqrt(m), y = row.names(m), x = colnames(m)) %>% add_heatmap()

# a look at principle components
pca <- princomp(m, cor = TRUE)
saveRDS(pca, here::here("data", "pca-outcomes.rds"))
pc_scores <- tibble::as_tibble(outcome_pca$scores) %>% 
  dplyr::mutate(drug = row.names(outcome_pca$scores))
saveRDS(pc_scores, here::here("data", "pca-scores.rds"))



# TODO: do a tour of this data!
# source("pca-plot.R")
# plot_pca(pca)
