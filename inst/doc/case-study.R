## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
library(pagerankr)

## ----load---------------------------------------------------------------------
crawl <- function(phase) {
  dir <- system.file(
    "extdata", paste0("reviews-microsite-", phase),
    package = "pagerankr"
  )
  screaming_frog_bundle(
    internal = file.path(dir, "internal_all.csv"),
    links    = file.path(dir, "all_inlinks.csv"),
    link_export_kind = "all_inlinks"
  )
}

before <- crawl("before")
after  <- crawl("after")

c(before = nrow(before$edges), after = nrow(after$edges))

## ----views--------------------------------------------------------------------
score <- function(bundle, ...) pagerank_screaming_frog(bundle, ...)

ed_before <- score(before, accepted_placements = "Content")
ed_after  <- score(after,  accepted_placements = "Content")

full_before <- score(before)
full_after  <- score(after)

## ----internal-----------------------------------------------------------------
internal <- function(x) {
  x[grepl("reviews-microsite", x$node_name, fixed = TRUE), ]
}

c(
  editorial_before = nrow(internal(ed_before)),
  editorial_after  = nrow(internal(ed_after)),
  full_before      = nrow(internal(full_before)),
  full_after       = nrow(internal(full_after))
)

## ----mass---------------------------------------------------------------------
c(
  editorial_before = sum(internal(ed_before)$pagerank),
  editorial_after  = sum(internal(ed_after)$pagerank)
)

## ----concentration------------------------------------------------------------
top_n_share <- function(x, n = 5) {
  sum(sort(x, decreasing = TRUE)[seq_len(n)]) / sum(x)
}

concentration <- function(x) {
  pr <- internal(x)$pagerank
  c(
    n           = length(pr),
    gini        = round(pr_gini(pr), 3),
    entropy     = round(pr_entropy(pr), 2),
    top5_share  = round(100 * top_n_share(pr), 1)
  )
}

rbind(
  before = concentration(ed_before),
  after  = concentration(ed_after)
)

## ----deltas-------------------------------------------------------------------
ranked <- function(x) {
  d <- data.frame(
    url  = x$node_name,
    pr   = x$pagerank,
    stringsAsFactors = FALSE
  )
  d$rank <- rank(-d$pr, ties.method = "min")
  d
}

moves <- merge(
  ranked(ed_before), ranked(ed_after),
  by = "url", suffixes = c("_before", "_after")
)
moves$change <- round(100 * (moves$pr_after / moves$pr_before - 1))

# Rank over everything scored; report internal pages only.
moves <- moves[grepl("reviews-microsite", moves$url, fixed = TRUE), ]
nrow(moves)

## ----losers-------------------------------------------------------------------
show <- function(d) {
  d$page <- sub("^https://[^/]+", "", d$url)
  cols <- c(
    "page", "pr_before", "pr_after", "change",
    "rank_before", "rank_after"
  )
  out <- d[, cols]
  out$pr_before <- round(out$pr_before, 3)
  out$pr_after  <- round(out$pr_after, 3)
  print(out, row.names = FALSE)
}

show(head(moves[order(moves$change), ], 4))

## ----gainers------------------------------------------------------------------
show(head(moves[order(-moves$change), ], 6))

## ----reclassification---------------------------------------------------------
content_edges <- function(bundle) {
  e <- bundle$edges
  e <- e[!is.na(e$link_position) & e$link_position == "Content", ]
  keep <- grepl("reviews-microsite", e$from, fixed = TRUE) &
    grepl("reviews-microsite", e$to, fixed = TRUE)
  nrow(unique(e[keep, c("from", "to")]))
}

c(before = content_edges(before), after = content_edges(after))

## ----fullgraph----------------------------------------------------------------
full <- merge(
  ranked(full_before), ranked(full_after),
  by = "url", suffixes = c("_before", "_after")
)
full <- full[grepl("reviews-microsite", full$url, fixed = TRUE), ]

c(
  pages       = nrow(full),
  gini_before = round(pr_gini(internal(full_before)$pagerank), 3),
  gini_after  = round(pr_gini(internal(full_after)$pagerank), 3),
  pearson     = round(cor(full$pr_before, full$pr_after), 4)
)

