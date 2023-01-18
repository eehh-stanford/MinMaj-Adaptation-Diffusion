require(ggplot2)
require(latex2exp)
require(dplyr)
require(readr)
require(purrr)
require(reshape2)
require(stringr)

mytheme = theme(axis.line = element_line(), legend.key=element_rect(fill = NA),
                text = element_text(size=22),# family = 'PT Sans'),
                # axis.text.x = element_text(size=12),
                # axis.text.y=  element_text(size=12), 
                panel.background = element_rect(fill = "white"))

supp_asymm_heatmaps <- function(csv_dir = "data/supp_parts", write_dir = "figures/supp") {
  group_w_vals <- c("1", "2", "Both")
  
  # group_w_vals <- c("1")
  for (group_w_innovation in group_w_vals) {
    
    files <- list.files(csv_dir, 
                        pattern = paste0("group_w_innovation=", group_w_innovation),
                        full.names = TRUE)
    
    tbl_part <- files %>%
      map_df(~read_csv(., show_col_types = FALSE))
    
    tbl_part$group_w_innovation = group_w_innovation
    
    if (group_w_innovation == "1") {
      tbl <- tbl_part
    }
    else {
      tbl <- rbind(tbl, tbl_part)
    }
  }
  
  for (group_w_innovation in group_w_vals) {
    # nagents sensitivity.
    for (this_nagents in c(50, 100, 200)) {
      
      this_tbl <- tbl[tbl$nagents == this_nagents, ]
      this_write_dir <- file.path(write_dir, "nagents", this_nagents)
      write_path <- file.path(this_write_dir, paste0(group_w_innovation, ".pdf"))
      
      asymm_heatmap(this_tbl, group_w_innovation, write_path)
    }
    # minority group size sensitivity.
    for (this_group_1_frac in c(0.2, 0.35, 0.5)) {
      
      this_tbl <- tbl[tbl$group_1_frac == this_group_1_frac, ]
      this_write_dir <- file.path(write_dir, "m", this_group_1_frac)
      write_path <- file.path(this_write_dir, paste0(group_w_innovation, ".pdf"))
      
      asymm_heatmap(this_tbl, group_w_innovation, write_path)
    }
    # f(a) sensitivity.
    for (this_a_fitness in c(1.05, 1.4, 2.0)) {
      
      this_tbl <- tbl[tbl$a_fitness == this_a_fitness, ]
      this_write_dir <- file.path(write_dir, "a_fitness", this_a_fitness)
      write_path <- file.path(this_write_dir, paste0(group_w_innovation, ".pdf"))
      
      asymm_heatmap(this_tbl, group_w_innovation, write_path)
    }
  }

  
  # 
}

main_asymm_heatmaps <- function(csv_dir = "data/main_parts", write_dir = "figures/heatmaps/main", measure = "sustainability")
{
  
  # for (group_w_innovation in c(1, 2, "Both")) {
  group_w_vals <- c("1", "2", "Both")
  # group_w_vals <- c("1")
  for (group_w_innovation in group_w_vals) {
    
    files <- list.files("data/main_parts", 
               pattern = paste0("group_w_innovation=", group_w_innovation),
               full.names = TRUE)
    
    tbl_part <- files %>%
      map_df(~read_csv(., show_col_types = FALSE))
    
    tbl_part$group_w_innovation = group_w_innovation
    
    if (group_w_innovation == "1") {
      tbl <- tbl_part
    }
    else {
      tbl <- rbind(tbl, tbl_part)
    }
  }
  
  
  
  # return (asymm_heatmap(tbl, group_w_innovation, file.path(write_dir, paste0(group_w_innovation, ".pdf"))))
  
  for (group_w_innovation in group_w_vals) {
    
    asymm_heatmap(tbl, group_w_innovation, 
                  file.path(write_dir, paste0(group_w_innovation, ".pdf")),
                  measure)
  }
  
  # for (csv_loc in list.files(csv_dir, full.names = TRUE)) {
  #   asymm_heatmap(csv_loc, write_dir)
  # }
}


asymm_heatmap <- function(asymm_tbl, this_group_w_innovation, write_path, measure = "sustainability") {
  
  asymm_agg <- asymm_tbl %>%
    filter(homophily_1 != 0.99) %>% 
    filter(homophily_2 != 0.99) %>%
    group_by(homophily_1, homophily_2, group_w_innovation) %>%
    summarize(sustainability = mean(frac_a_curr_trait),
              step = mean(step))
  # return (asymm_agg)
    # asymm_tbl %>% 
    #   subset(group_w_innovation == this_group_w_innovation)
  asymm_lim_agg <- asymm_agg[asymm_agg$group_w_innovation == this_group_w_innovation, ]
  
  print(unique(asymm_lim_agg$group_w_innovation))
  print(head(asymm_lim_agg))
  
  # asymm_lim_aggregated <- asymm_lim_aggregated %>%
  
  if (measure == "sustainability") {
  
    asymm_max_line <-
      asymm_lim_agg %>% 
        group_by(homophily_1) %>% 
        filter(sustainability == max(sustainability))
    
    print(asymm_max_line)
    max_sustainability <- 
      asymm_max_line[asymm_max_line$sustainability == 
                       max(asymm_max_line$sustainability), ]
  } else if (measure == "step") {
    asymm_max_line <-
      asymm_lim_agg %>% 
      group_by(homophily_1) %>% 
      filter(step == max(step))
    
    print(asymm_max_line)
    max_sustainability <- 
      asymm_max_line[asymm_max_line$step == 
                       max(asymm_max_line$step), ]
  } else {
    stop ("measure not recognized")
  }
  
  h1max <- max_sustainability$homophily_1
  h2max <- max_sustainability$homophily_2
  
  # print(paste("Maximum sustainability ", max_sustainability$sustainability[1], ", at h1 = ", h1max, " h2 = ", h2max))
  
  if (measure == "sustainability") {
    ggplotstart <- ggplot(asymm_lim_agg, aes(x = homophily_1, y = homophily_2, fill = sustainability))
    measure_label <- "Sweep frequency"
  } else if (measure == "step") {
    ggplotstart <- ggplot(asymm_lim_agg, aes(x = homophily_1, y = homophily_2, fill = step))
    measure_label <- "Mean steps"
  } else {
    stop("Measure not recognized.")
  }
  
   ggplotstart + 
    geom_tile() +
    scale_fill_gradient2(low = "#000000", mid = "#010101", high = "#FFFFFF") +
    geom_point(data = asymm_max_line, aes(x = homophily_1, y = homophily_2)) +
    geom_smooth(data = asymm_max_line, aes(x = homophily_1, y = homophily_2), se=FALSE) +
    geom_point(data = max_sustainability, aes(x=homophily_1, y=homophily_2), 
               shape='diamond', size=5, color='red') +
    labs(x = "Minority group homophily", y = "Majority group homophily") +
    coord_fixed() + labs(fill = measure_label) +
    mytheme
    
  # save_path <- file.path(write_dir, str_replace(basename(csv_loc), ".csv", ".pdf"))
  
  ggsave(write_path, width = 6.75, height = 5)
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