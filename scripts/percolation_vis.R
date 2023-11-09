library(igraph)

load_adjacency <- function(adjacency_matrix_csv = "data/percolation/adjacency.csv") {
  
  adjacency_matrix <- read.csv(adjacency_matrix_csv)
  names(adjacency_matrix) <- rownames(adjacency_matrix)
  
  # Need to transpose to make arrows point from teacher to learner; in Julia code
  # I made relationship "learns from" instead of "teaches". "Teaches", where
  # arrows point from teacher to learner, is preferred for visualization as it
  # signifies transfer.
  return(t(as.matrix(adjacency_matrix)))
}


load_diffusion <- function(adaptation_series_csv = "data/percolation/series.csv") {
    
  return (read.csv(adaptation_series_csv))
}


plot_all <- function(adjacency_matrix_csv = "data/percolation/adjacency.csv", 
                     diffusion_series_csv = "data/percolation/series.csv",
                     xvec = c(rep(0, 5), rep(2, 5), rep(3, 5)), 
                     yvec = rep(c(0, 1, 2, 3, 4), 3)) {
  
  adjacency_matrix <- load_adjacency(adjacency_matrix_csv)
  diffusion_series <- load_diffusion(diffusion_series_csv)
  
  network <- graph_from_adjacency_matrix(adjacency_matrix, mode = "directed")
  
  # TODO Add logic here to determine what color each graph should be:
  # use blue4 and magenta for outline of agent nodes; use red for the
  # adaptive, grey for non-adaptive.
  ds <- diffusion_series
  steps <- unique(ds$step)
  steps <- c(0,1,2,3)  # comment out for full run
  agents_ids <- unique(ds$id)
  nagents <- max(agents_ids)
  
  vertex_coords <- matrix(c(xvec, yvec), ncol=2)
  
  # Create and write a pdf for each plot.
  for (this_step in steps) {
    print(step)
    colors <- rep("grey", nagents)
    step_df <- filter(ds, step == this_step)
    print(step_df)
    print("")

    colors[step_df$curr_trait == "a"] = "red"

    plot(network, vertex.color = colors, edge.arrow.size=0.4, arrow.mode = 1, 
         edge.curved = 0.25, margin = rep(0, 4), layout = vertex_coords)
  }
  
  # return (network)
}
