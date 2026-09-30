## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
library(pagerankr)

## ----load_package-------------------------------------------------------------
library(pagerankr)

## ----quick_start--------------------------------------------------------------
edges <- data.frame(
  from = c(
    "example.com/home", "example.com/about",
    "example.com/blog", "example.com/blog"
  ),
  to = c(
    "example.com/about", "example.com/home",
    "example.com/home", "example.com/about"
  )
)

pr <- pagerank(edges)
print(pr)

## ----screaming_frog_example, eval = FALSE-------------------------------------
# bundle <- screaming_frog_bundle(
#   internal = "internal_all.csv",
#   links = "all_outlinks.csv",
#   link_export_kind = "all_outlinks"
# )
# 
# pr <- pagerank_screaming_frog(bundle)
# 
# summary(bundle)
# attr(pr, "screaming_frog_import")
# attr(pr, "transition_audit")

## ----screaming_frog_policy, eval = FALSE--------------------------------------
# pagerank_screaming_frog(
#   bundle,
#   accepted_placements = c("nav", "content"),
#   link_origins = c("html", "html_rendered"),
#   placement_weights = c(nav = 2, content = 1)
# )

## ----placement_generic, eval = FALSE------------------------------------------
# pagerank(
#   edges,
#   placement_col = "region",
#   placement_weights = c(
#     content = 1, nav = 0.1, header = 0.1, footer = 0.1, aside = 0.1
#   )
# )

## ----redirects_basic----------------------------------------------------------
edges <- data.frame(
  from = c("A", "B", "C"),
  to = c("B", "C", "D")
)
redirects <- data.frame(
  from = c("B", "C"),
  to = c("B_new", "C_new")
)

# resolve_redirects() applies redirect rules to an edge list
resolved <- resolve_redirects(edges, redirects)
print(resolved)

## ----redirects_conflict-------------------------------------------------------
redirects_conflict <- data.frame(
  from = c("old", "old", "old"),
  to = c("target_A", "target_B", "target_B")
)

# "most_frequent" picks the most common target
edges_simple <- data.frame(from = "X", to = "old")
resolve_redirects(edges_simple, redirects_conflict,
  duplicate_from_policy = "most_frequent"
)

## ----redirects_loops----------------------------------------------------------
edges_loop <- data.frame(from = "X", to = "A")
redirects_loop <- data.frame(
  from = c("A", "B", "C", "D"),
  to = c("B", "C", "A", "E")
)

# "prune_loop" removes cycle edges; linear redirects still work
resolved <- resolve_redirects(edges_loop, redirects_loop,
  loop_handling = "prune_loop"
)
print(resolved)

## ----resolve_links_example----------------------------------------------------
edges <- data.frame(
  from = c("A", "A", "B"),
  to = c("B", "B", "C")
)
redirects <- data.frame(from = "B", to = "B_final")

resolve_links(edges, redirects, clean_urls = FALSE)

## ----nofollow-----------------------------------------------------------------
edges <- data.frame(
  from = c("Hub", "Hub", "Hub"),
  to = c("A", "B", "C"),
  nofollow = c(FALSE, FALSE, TRUE)
)

# "evaporate": PR splits 3 ways, C's share vanishes
pr_evap <- pagerank(edges,
  nofollow_col = "nofollow",
  nofollow_action = "evaporate",
  clean_edge_urls = FALSE
)
print(pr_evap)

# "drop": nofollow edges removed, PR splits only among followed links
pr_drop <- pagerank(edges,
  nofollow_col = "nofollow",
  nofollow_action = "drop",
  clean_edge_urls = FALSE
)
print(pr_drop)

## ----indexability_noindex-----------------------------------------------------
edges <- data.frame(
  from = c("Home", "NoindexPage", "NoindexPage"),
  to = c("NoindexPage", "A", "B")
)

idx_status <- data.frame(
  url = "NoindexPage",
  indexability_status = "noindex"
)

pr <- pagerank(edges,
  indexability_df = idx_status,
  clean_edge_urls = FALSE
)
print(pr)

## ----indexability_robots------------------------------------------------------
edges <- data.frame(
  from = c("Home", "Blocked", "A"),
  to = c("Blocked", "A", "Home")
)

idx_status <- data.frame(
  url = "Blocked",
  indexability_status = "Blocked by robots.txt"
)

# "show" (default): blocked page is shown with the authority it collects
pr_show <- pagerank(edges,
  indexability_df = idx_status,
  robots_blocked_action = "show",
  clean_edge_urls = FALSE
)
print(pr_show)

# "vanish": blocked page removed from results (its own mass booked as hidden)
pr_vanish <- pagerank(edges,
  indexability_df = idx_status,
  robots_blocked_action = "vanish",
  clean_edge_urls = FALSE
)
print(pr_vanish)

## ----weighted-----------------------------------------------------------------
edges <- data.frame(
  from = c("A", "A", "B"),
  to = c("B", "C", "C"),
  weight = c(3, 1, 1)
)

pr <- pagerank(edges, weight_col = "weight", clean_edge_urls = FALSE)
print(pr)

## ----domain_filter------------------------------------------------------------
edges <- data.frame(
  from = c(
    "example.com/a", "example.com/b",
    "other.com/c"
  ),
  to = c(
    "example.com/b", "other.com/d",
    "example.com/a"
  )
)

# Keep only internal links
internal <- filter_links_by_domain(edges, keep_domains = "example.com")
print(internal)

## ----hits---------------------------------------------------------------------
edges <- data.frame(
  from = c("A", "A", "B"),
  to = c("B", "C", "C")
)

# A only points out (pure hub); C is only pointed to (pure authority).
hits(edges, clean_edge_urls = FALSE)

## ----salsa--------------------------------------------------------------------
edges <- data.frame(
  from = c("A", "A", "B"),
  to = c("B", "C", "C")
)

# A only points out (pure hub); C is only pointed to (pure authority).
salsa(edges, clean_edge_urls = FALSE)

## ----compare------------------------------------------------------------------
edges <- data.frame(
  from = c("A", "B", "C", "D"),
  to = c("B", "C", "D", "A")
)

pr_85 <- pagerank(edges, damping = 0.85, clean_edge_urls = FALSE)
pr_90 <- pagerank(edges, damping = 0.90, clean_edge_urls = FALSE)

diff <- compare_pagerank(pr_85, pr_90, label_a = "d=0.85", label_b = "d=0.90")
print(diff)
cat("\nCorrelation summary:\n")
print(attr(diff, "summary"))

## ----grid---------------------------------------------------------------------
edges <- data.frame(
  from = c("A", "A", "B", "C"),
  to = c("B", "C", "C", "A")
)

grid <- auto_grid(damping = c(0.75, 0.85, 0.95))
results <- pagerank_grid(edges, params_grid = grid, clean_edge_urls = FALSE)

# Analyze distribution metrics across the grid
analysis <- analyze_pagerank_grid(results)
print(analysis)

## ----metrics------------------------------------------------------------------
pr <- pagerank(edges, clean_edge_urls = FALSE)
cat("Gini coefficient:", pr_gini(pr$pagerank), "\n")
cat("Entropy:", pr_entropy(pr$pagerank), "\n")
cat("Top-1 share:", pr_top_k_share(pr$pagerank, k = 1), "\n")

## ----simulate_add_link--------------------------------------------------------
site_links <- data.frame(
  from = c("Home", "Home", "About", "Blog"),
  to = c("About", "Blog", "Home", "Home")
)

impact <- simulate_changes(
  site_links,
  add_links_df = data.frame(
    from = "Blog", to = "About"
  ),
  clean_edge_urls = FALSE
)
print(impact)

## ----simulate_remove_link-----------------------------------------------------
impact_remove <- simulate_changes(
  site_links,
  remove_links_df = data.frame(
    from = "Home", to = "Blog"
  ),
  clean_edge_urls = FALSE
)
print(impact_remove)

## ----simulate_redirect--------------------------------------------------------
# OldPage is live: Blog links to it, and it links out to Home. Retire it
# behind a 301 to About. Its inbound authority (from Blog) passes to About;
# its outlink to Home is dropped; OldPage leaves the proposed graph.
extended_links <- rbind(site_links, data.frame(
  from = c("Blog", "OldPage"),
  to = c("OldPage", "Home")
))

impact_redirect <- simulate_changes(
  extended_links,
  redirect_urls_df = data.frame(
    from = "OldPage", to = "About"
  ),
  clean_edge_urls = FALSE
)
print(impact_redirect)

## ----simulate_redirect_manifest-----------------------------------------------
attr(impact_redirect, "manifest")$redirects_applied

## ----simulate_combined--------------------------------------------------------
impact_all <- simulate_changes(
  site_links,
  add_links_df = data.frame(
    from = "Blog", to = "About"
  ),
  remove_links_df = data.frame(
    from = "Home", to = "Blog"
  ),
  clean_edge_urls = FALSE
)
print(impact_all)

## ----convergence_stability----------------------------------------------------
toy_edges <- data.frame(
  from = c("A", "A", "B", "C", "C", "D", "E", "F"),
  to   = c("B", "C", "D", "D", "E", "F", "A", "A")
)

# Stability report: how sensitive are ranks to damping?
stab <- pagerank_stability(
  toy_edges,
  alphas            = c(0.75, 0.80, 0.85, 0.90, 0.95),
  reference         = 0.85,
  top_k             = 4,
  clean_edge_urls   = FALSE
)
print(stab)

# Drill into raw per-(url, alpha) scores
head(attr(stab, "sensitivity"))

## ----tspr_example-------------------------------------------------------------
library(pagerankr)

# Small synthetic site: 7 pages, two rough topic clusters
edges <- data.frame(
  from = c("Home", "Home", "Blog", "Blog", "Shop", "Shop", "Docs"),
  to   = c("Blog", "Shop", "Post1", "Post2", "Item1", "Item2", "Guide1")
)

# Define two topics as named lists of seed URL vectors
topics <- list(
  content = c("Blog", "Post1", "Post2"),
  commerce = c("Shop", "Item1", "Item2")
)

tspr <- topic_sensitive_pagerank(
  edge_list_df    = edges,
  topics          = topics,
  clean_edge_urls = FALSE
)

print(tspr)

## ----tspr_columns-------------------------------------------------------------
# Per-topic scores
tspr[, c("node_name", "content", "commerce")]

# Blended (equal topic weights by default)
tspr[, c("node_name", "blended")]

## ----ga4_transitions----------------------------------------------------------
library(pagerankr)

# Minimal synthetic GA4 events data frame (no BigQuery required)
events <- data.frame(
  user_pseudo_id  = c("u1", "u1", "u1", "u2", "u2"),
  ga_session_id   = c(1L,   1L,   1L,   2L,   2L),
  page_location   = c("/home", "/blog", "/contact", "/home", "/pricing"),
  event_timestamp = c(1000L,  2000L,  3000L,  1000L,  2000L)
)

transitions <- ga4_page_transitions(
  events,
  user_id_col   = "user_pseudo_id",
  session_id_col = "ga_session_id",
  page_col       = "page_location",
  timestamp_col  = "event_timestamp"
)
print(transitions)
# Returns a data frame with columns: from, to, n

## ----smooth_transitions_example-----------------------------------------------
# Build a minimal structural prior from the same pages
structural <- data.frame(
  from = c("/home",    "/home",    "/blog"),
  to   = c("/blog",   "/pricing", "/contact"),
  n    = c(50L,        30L,        40L)
)

smoothed <- smooth_transitions(
  empirical_df   = transitions,
  structural_df  = structural,
  k              = 10,
  min_support    = 5,
  count_col      = "n",
  from_col       = "from",
  to_col         = "to",
  prob_col       = "prob"
)
print(smoothed)
# empirical_df augmented with a `prob` column: smoothed per-source
# transition probabilities (each source sums to 1)

## ----ga4_teleport-------------------------------------------------------------
entrances <- data.frame(
  page_location = c("/home", "/blog", "/pricing", "/contact"),
  entrances     = c(120L,    80L,     40L,         10L)
)

prior <- ga4_entrance_teleport(
  entrances_df   = entrances,
  url_col        = "page_location",
  entrances_col  = "entrances",
  vertex_names   = NULL
)
print(prior)
# Returns: url + weight data frame, ready for pagerank(prior_df = .)

## ----ga4_end_to_end-----------------------------------------------------------
# 1. Extract transitions from synthetic events
trans <- ga4_page_transitions(
  events,
  user_id_col    = "user_pseudo_id",
  session_id_col = "ga_session_id",
  page_col       = "page_location",
  timestamp_col  = "event_timestamp"
)

# 2. Smooth against the structural prior
sm <- smooth_transitions(
  empirical_df  = trans,
  structural_df = structural,
  k             = 10,
  min_support   = 2,
  prob_col      = "prob"
)

# 3. Run PageRank using smoothed probabilities as edge weights
pr <- pagerank(
  sm,
  edge_from_col  = "from",
  edge_to_col    = "to",
  weight_col     = "prob",
  clean_edge_urls = FALSE
)
print(pr)

