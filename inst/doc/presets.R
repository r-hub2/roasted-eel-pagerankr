## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
library(pagerankr)

## -----------------------------------------------------------------------------
edges <- data.frame(
  from = c("A", "A", "B", "C"),
  to = c("B", "C", "A", "A")
)

pagerank(edges, preset = "raw")

## -----------------------------------------------------------------------------
pr_preset("raw")

## -----------------------------------------------------------------------------
identical(
  pagerank(edges, preset = "declared")$pagerank,
  pagerank(edges)$pagerank
)

## -----------------------------------------------------------------------------
pagerank(edges, preset = "reversed")

## -----------------------------------------------------------------------------
placed <- data.frame(
  from = c("A", "A", "B", "C"),
  to = c("B", "C", "A", "A"),
  region = c("content", "footer", "content", "content")
)

pagerank(placed, preset = "content", placement_col = "region")

## -----------------------------------------------------------------------------
# The raw bundle says nofollow_action = "keep"; the explicit argument wins.
attr(
  pagerank(edges, preset = "raw", nofollow_action = "drop"),
  "transition_audit"
)$config$nofollow_action

## -----------------------------------------------------------------------------
# Splice a bundle into a call
do.call(pagerank, c(list(edges), pr_preset("raw")))

# Start from a preset and adjust
my_view <- pr_preset("raw")
my_view$drop_isolates_flag <- TRUE
pagerank(edges, preset = my_view)

## -----------------------------------------------------------------------------
attr(pagerank(edges, preset = "raw"), "transition_audit")$config$preset

