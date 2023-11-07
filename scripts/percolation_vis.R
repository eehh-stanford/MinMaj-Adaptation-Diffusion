
load_data <- function(adjacency_matrix_csv = "data/percolation/adjacency.csv",
                      adaptation_series_csv = "data/percolation/series.csv") {

  adjacency_matrix = NULL
  adaptation_series = NULL

  return (adjacency_matrix, adaptation_series)
}


node_matrix_from_row <- function(adaptation_matrix, step) {

  # Extract node matrix with columns id, group, has_adaptation, n_neighbors.
  # node size scales with n_neighbors 
  # node color or node edge color set based on group and wether has_adaptation.

}
