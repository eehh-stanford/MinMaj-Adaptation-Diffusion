library(ggplot2)
library(data.table)
library(purrrlyr)


mytheme = theme(axis.line = element_line(), legend.key=element_rect(fill = NA),
                text = element_text(size=22),# family = 'PT Sans'),
                legend.key.width = unit(2, 'cm'),
                legend.key.size = unit(1.5, 'lines'),
                panel.background = element_rect(fill = "white"))


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


plot_over_N_homophily <- function(N = c(30, 100, 200), m = seq(0.05, 0.5, 0.05), kbar = 4, 
                                  homophily = c(0.0, 0.5), write_dir = "figures"){
  
  # Generate data to plot...
  plot_data <-
    # ...first create Cartesian product ("cross join") of parameters,...
    CJ(N, m, kbar, homophily) %>%
    # ...then calculate probability a given minority node teaches at least one majority agent.
    by_row(function (r) minmaj_model_probability_minority_has(r$N, r$m, r$kbar, r$homophily),
           .to = "prob", .collate = "cols")
  
  plot_data$N <- as.factor(plot_data$N)
  plot_data$homophily <- as.factor(plot_data$homophily)
  
  ggplot(plot_data, aes(x=m, y=prob)) + 
    geom_line(aes(linetype=N, color=homophily), size=1) +
    # geom_point(aes(color=h)) +
    scale_linetype_manual(values=c("twodash", "dashed", "solid")) +
    xlab("Minority fraction, " ~ italic("m")) + 
    ylab("Probability of edge to majority") +
    mytheme
  
  save_path <- file.path(write_dir, "prob_min_teaches_maj.pdf")
  
  ggsave(save_path, width = 7.5, height = 5.15)
}


minmaj_model_probability_majority_has <- function(N, m, kbar, hom) {
  
}