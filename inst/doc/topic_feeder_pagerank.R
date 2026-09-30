## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
library(pagerankr)

## -----------------------------------------------------------------------------
edges <- data.frame(
  from = c(
    "/hub", "/hub", "/feeder", "/blog-ai", "/ai",
    "/footer", "/sports", "/footer"
  ),
  to = c(
    "/ai", "/ai-demo", "/ai", "/ai", "/ai-demo",
    "/ai", "/scores", "/sports"
  )
)

## -----------------------------------------------------------------------------
fr <- topic_feeder_pagerank(
  edges,
  seeds = c("/ai", "/ai-demo"),
  clean_edge_urls = FALSE,
  prior_verbose = FALSE
)
fr[, c("node_name", "pagerank", "prior_weight")]

## -----------------------------------------------------------------------------
feeders <- fr[fr$prior_weight == 0, c("node_name", "pagerank")]
feeders

## -----------------------------------------------------------------------------
auth <- topic_sensitive_pagerank(
  edges,
  topics = list(ai_agent = c("/ai", "/ai-demo")),
  clean_edge_urls = FALSE,
  prior_verbose = FALSE
)
auth[, c("node_name", "ai_agent")]

