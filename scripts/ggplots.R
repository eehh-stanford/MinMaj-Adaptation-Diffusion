
mytheme = theme(axis.line = element_line(), 
                text = element_text(size=16),# family = 'PT Sans'),
                panel.background = element_rect(fill = "white"))

asymm_heatmap <- function(asymm_df) {
  
  asymm_lim <- 
    asymm_df %>% 
      filter(homophily_1 != 0.99) %>% 
      filter(homophily_2 != 0.99)
  
  asymm_max_line <-
    asymm_lim %>% 
      group_by(homophily_1) %>% 
      filter(sustainability == max(sustainability))
  
  print(asymm_max_line)
  max_sustainability <- 
    asymm_max_line[asymm_max_line$sustainability == 
                     max(asymm_max_line$sustainability), ]
  
  h1max <- max_sustainability$homophily_1
  h2max <- max_sustainability$homophily_2
  
  print(paste("Maximum sustainability ", max_sustainability$sustainability[1], ", at h1 = ", h1max, " h2 = ", h2max))
  
  ggplot(asymm_lim, aes(x = homophily_1, y = homophily_2, fill = sustainability)) + 
    geom_tile() +
    scale_fill_gradient2(low = "#000000", mid = "#010101", high = "#FFFFFF") +
    geom_point(data = asymm_max_line, aes(x = homophily_1, y = homophily_2)) +
    geom_smooth(data = asymm_max_line, aes(x = homophily_1, y = homophily_2), se=FALSE) +
    geom_point(data = max_sustainability, aes(x=homophily_1, y=homophily_2), 
               shape='diamond', size=5, color='red') +
    labs(x = "Minority group homophily", y = "Majority group homophily") +
    coord_fixed() +
    mytheme
    
}