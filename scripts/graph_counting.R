library(ggplot2)
library(data.table)
library(purrrlyr)

choose_nodes_w_replacement <- function(n_nodes, n_edges) {
  return (choose(n_nodes + n_edges - 1, n_edges))
}


probability_node_hasnt_edge <- function(n_nodes, n_edges) {
  num <- choose_nodes_w_replacement(n_nodes - 1, n_edges)
  print(num)
  denom <- choose_nodes_w_replacement(n_nodes, n_edges)
  print(denom)
  
  return (num / denom)
}

probability_node_has_edge <- function(n_nodes, n_edges) {
  return (1.0 - probability_node_hasnt_edge(n_nodes, n_edges))
}

# Probability a minority group member teaches at least one majority group member.
minmaj_model_probability_minority_has <- function(N, m, kbar, hom) {
  n_min_nodes <- round(N * m)
  print(n_min_nodes)
  total_min_edges <- round(n_min_nodes * kbar)
  print(total_min_edges)
  hom_coeff = ((1 - hom)/2.0)
  n_outgroup_edges <- round(total_min_edges * hom_coeff)
  print(n_outgroup_edges)
  
  return (probability_node_has_edge(n_min_nodes, n_outgroup_edges))
}


plot_over_N_homophily <- function(N = c(30, 100), m = seq(0.05, 0.5, 0.05), kbar = 4, 
                                  h = c(0.0, 0.25, 0.5)){
  return (
    CJ(N, m, kbar, h) %>%
    by_row(function (r) minmaj_model_probability_minority_has(r$N, r$m, r$kbar, r$h),
           .to = "prob", .collate = "cols")
  )
}


minmaj_model_probability_majority_has <- function(N, m, kbar, hom) {
  
}