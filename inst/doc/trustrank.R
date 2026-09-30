## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
library(pagerankr)

## -----------------------------------------------------------------------------
edges <- data.frame(
  from = c("/", "/", "/hub", "/hub", "/good", "/spam", "/spam"),
  to = c("/hub", "/good", "/good", "/deep", "/hub", "/sink", "/good")
)

## -----------------------------------------------------------------------------
prior <- seed_prior(c("/", "/hub"))
prior

## -----------------------------------------------------------------------------
pr_manual <- pagerank(edges, prior_df = prior, clean_edge_urls = FALSE)
pr_manual[order(-pr_manual$pagerank), c("node_name", "pagerank")]

## -----------------------------------------------------------------------------
tr <- trustrank(edges, c("/", "/hub"), clean_edge_urls = FALSE)
tr[order(-tr$pagerank), c("node_name", "pagerank", "prior_weight")]

## -----------------------------------------------------------------------------
uni <- pagerank(edges, clean_edge_urls = FALSE)
compare_pagerank(uni, tr)[, c("node_name", "pagerank_a", "pagerank_b", "delta")]

## -----------------------------------------------------------------------------
trustrank(
  edges,
  data.frame(url = c("/", "/hub"), weight = c(3, 1)),
  clean_edge_urls = FALSE
)[, c("node_name", "pagerank", "prior_weight")]

## -----------------------------------------------------------------------------
trustrank(
  edges, c("/", "/hub"),
  prior_alpha = 0.15, clean_edge_urls = FALSE
)[, c("node_name", "pagerank", "prior_weight")]

