require(ggplot2)
require(latex2exp)
require(dplyr)
require(reshape2)
require(stringr)

mytheme = theme(axis.line = element_line(), legend.key=element_rect(fill = NA),
                text = element_text(size=22),# family = 'PT Sans'),
                # axis.text.x = element_text(size=12),
                # axis.text.y=  element_text(size=12), 
                panel.background = element_rect(fill = "white"))


all_asymm_heatmaps <- function(csv_dir = "data/asymm_csv", write_dir = "figures/asymm_heatmap")
{
  for (csv_loc in list.files(csv_dir, full.names = TRUE)) {
    asymm_heatmap(csv_loc, write_dir)
  }
}


asymm_heatmap <- function(csv_loc, write_dir = "figures/asymm_heatmap") {
  
  asymm_df <- read.csv(csv_loc)
    
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
    coord_fixed() + labs(fill = "Sustainability") +
    mytheme
    
  save_path <- file.path(write_dir, str_replace(basename(csv_loc), ".csv", ".pdf"))
  
  ggsave(save_path, width = 6.75, height = 5)
}


plot_group_freq_series <- function(csv_loc, write_dir = "figures/group_prevalence") {

    df <- read.csv(csv_loc)
    names(df) <- c("step", "frac_a", "Minority", "Majority", "Trial")
    df <- df[c("step", "Majority", "Minority", "Trial")]
    enslim <- 10
    df <- filter(df, Trial <= enslim)
    df$Trial = factor(df$Trial, levels = 1:enslim)
  
  df <- melt(df, id=c("step", "Trial"), value.name = "Frequency", variable.name = "Group")

  ggplot(df, aes(x=step, y=Frequency)) + 
    geom_line(aes(color=Trial, linetype=Group), lwd=0.8) +
    # geom_line(aes(x=step, y=frac_a_max, color=Trial, linetype="Majority"), linetype=1, lwd=1.05) +
    xlab("Step") + ylab(TeX(r"(Adaptation prevalence)")) +
    # scale_linetype_manual(name = "Group", values=c("Majority", "Minority"), labels = c("Majority", "Minority")) +
    mytheme #+ guides(color=guide_legend(override.aes=list(fill=NA))) 
  
  save_path <- file.path(write_dir, str_replace(basename(csv_loc), ".csv", ".pdf"))
  
  ggsave(save_path, width = 7.5, height = 4.65)
}