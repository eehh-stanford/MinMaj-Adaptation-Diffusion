library(ggplot2)
library(data.table)
library(purrrlyr)
library(reshape2)
library(scales)


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
  
  total_min_edges <- round(n_min_nodes * kbar)
  
  hom_coeff = ((1 - hom)/2.0)
  n_outgroup_edges <- round(total_min_edges * hom_coeff)
  
  
  return (probability_node_has_edge(n_min_nodes, n_outgroup_edges))
}


minmaj_model_probability_majority_has <- function(N, m, kbar, hom) {
  n_maj_nodes <- round(N * (1 - m))
  
  total_maj_edges <- round(n_maj_nodes * kbar)
  
  hom_coeff = ((1 + hom)/2.0)
  n_outgroup_edges <- round(total_maj_edges * hom_coeff)
  
  
  return (probability_node_has_edge(n_maj_nodes, n_outgroup_edges))
}


plot_minmaj_over_m <- function(N = c(30, 100, 200), m = seq(0.05, 0.5, 0.05), kbar = 4, 
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

plot_majmaj_over_h <- function(N = c(100, 200, 300), m = 0.05, kbar = 4, 
                               homophily = seq(0.0, 0.90, 0.1), example_optimal_h = 0.7,
                               write_dir = "figures"){
  
  # Generate data to plot using dplyr ("third method" here: https://rpubs.com/euclid/343644)
  plot_data <-
    # ...first create Cartesian product ("cross join") of parameters,...
    CJ(N, m, kbar, homophily) %>%
    # ...then calculate probability a given minority node teaches at least one majority agent...
    by_row(function (r) minmaj_model_probability_minority_has(r$N, r$m, r$kbar, r$homophily),
           .to = "pminmaj", .collate = "cols") %>%
    # ...then calculate probability a given majority node teaches at least one majority agent...
    by_row(function (r) minmaj_model_probability_majority_has(r$N, r$m, r$kbar, r$homophily),
           .to = "pmajmaj", .collate = "cols") %>%
    # ...finally melt columns...
    melt(variable.name = "ProbType", measure=c("pminmaj", "pmajmaj"))
  
  plot_data$N <- as.factor(plot_data$N)
  # plot_data$homophily <- as.factor(plot_data$homophily)
  
  example_N = tail(N, n=1)
  prob_min_optimal = minmaj_model_probability_minority_has(example_N, m, kbar, example_optimal_h)
  prob_maj_optimal = minmaj_model_probability_majority_has(example_N, m, kbar, example_optimal_h)
  example_pallette <- hue_pal()(2)
  c1 <- example_pallette[1]
  c2 <- example_pallette[2]
  
  ggplot(plot_data, aes(x=homophily, y=value)) + 
    geom_vline(xintercept = example_optimal_h, linetype="dashed", color="grey") +
    geom_hline(yintercept = prob_maj_optimal, linetype="dashed", color=c2) +
    geom_hline(yintercept = prob_min_optimal, linetype="dashed", color=c1) +
    geom_line(aes(linetype=N, color=ProbType), size=1) +
    scale_linetype_manual(values=c("twodash", "dashed", "solid")) +
    xlab("Majority homophily, " ~ italic("h")) + 
    ylab("Probability") +
    mytheme
  
  save_path <- file.path(write_dir, "probs_maj_homophily_optimum.pdf")

  ggsave(save_path, width = 7.5, height = 5.15)
}