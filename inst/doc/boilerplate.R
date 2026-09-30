## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
library(pagerankr)

## -----------------------------------------------------------------------------
posts <- sprintf("/post-%02d", 1:12)

edges <- rbind(
  # The byline: same component, same target, every single page.
  data.frame(from = posts, to = "/author/dana", container = "byline"),
  # Related posts: same component, a different target on each page.
  data.frame(from = posts, to = rev(posts), container = "related"),
  # A CTA that mostly, but not always, points at pricing.
  data.frame(
    from = posts,
    to = c(rep("/pricing", 7), sprintf("/guide-%02d", 1:5)),
    container = "cta"
  )
)

scored <- pagerank(edges, container_col = "container")
head(scored[order(-scored$pagerank), ], 4)

## -----------------------------------------------------------------------------
attr(scored, "transition_audit")$config$boilerplate

## -----------------------------------------------------------------------------
discounted <- function(threshold) {
  run <- pagerank(edges, container_col = "container",
                  boilerplate_threshold = threshold)
  attr(run, "transition_audit")$config$boilerplate$n_edges_discounted
}

c(default = discounted(0.5), strict = discounted(0.9))

## -----------------------------------------------------------------------------
mixed <- data.frame(
  from = rep(posts, each = 2),
  to = rep(c("/home", "/author/dana"), times = 12),
  region = rep(c("nav", "content"), times = 12),
  container = rep(c("mainnav", "byline"), times = 12)
)

both <- pagerank(
  mixed,
  placement_col = "region",
  placement_weights = c(content = 1, nav = 0.1, header = 0.1,
                        footer = 0.1, aside = 0.1),
  container_col = "container"
)
head(both[order(-both$pagerank), ], 3)

## -----------------------------------------------------------------------------
sf_container_from_path(c(
  "//body/div/main/article/div[@class='byline']/a[1]",
  "//body/div/main/article/div[@class='byline']/a[3]",
  "//body/div/main/article/p[5]/a"
))

## ----eval = FALSE-------------------------------------------------------------
# links <- screaming_frog_links("all_inlinks.csv")
# pagerank(links$edges, container_col = "container")

