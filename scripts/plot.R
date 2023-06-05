require(ggplot2)
require(latex2exp)
require(dplyr)
require(readr)
require(purrr)
require(reshape2)
require(stringr)


mytheme = theme(axis.line = element_line(), legend.key=element_rect(fill = NA),
                text = element_text(size=22),# family = 'PT Sans'),
                legend.key.width = unit(2, 'cm'),
                legend.key.size = unit(1.5, 'lines'),
                panel.background = element_rect(fill = "white"))


group_start_remap <- function(group_start) {
  if (group_start == "1")
    return ("Minority")
  else if (group_start == "2")
    return ("Majority")
  else
    return ("Both")
}


success_over_groups_jitter <- function(
    csv_dirs = c("data/main_parts"),
    write_dir = "figures",
    write_filename = "success_over_groups_jitter.pdf"
  ) {
  
  full_df <- load_from_parts(csv_dirs, "data/success_over_groups_jitter.csv")
  write_path <- file.path(write_dir, write_filename)
  
  # Need each outcome for every homophily value separated.
  aggdf <- full_df %>%
    group_by(homophily_1, homophily_2, group_w_innovation, group_1_frac) %>%
    summarize(success_rate = mean(frac_a_curr_trait))
  
  aggdf$group_w_innovation <- map_chr(aggdf$group_w_innovation, group_start_remap)
  aggdf$group_1_frac <- factor(aggdf$group_1_frac)
  
  aggdf <- rename(aggdf, start_group = group_w_innovation, 
                  minority_group_size = group_1_frac,
                  h_min = homophily_1, h_maj = homophily_2)
  
  # Now create boxplot with start group on x-axis, success_rate on y-axis, 
  # and color-coded by minority group size.
  p <- ggplot(aggdf, aes(x = factor(start_group, 
                                    level=c("Majority", "Minority", "Both")), 
                         y = success_rate)) + 
    # geom_violin() + 
    geom_jitter(alpha=0.1, width=0.2) +
    stat_summary(fun=mean, geom="line", color="#02bec3", size=1.5, aes(group=1)) +
    stat_summary(fun=mean, geom="point", shape=23, size=4, fill="#02bec3", stroke=1.1) +
    xlab("Start group") + ylab("Success rate") + 
    # scale_color_discrete("Legend") +
    mytheme
  
  ggsave(write_path, width=6, height=3.75)
  
  return (p)
}

line_for_jitter_legend <- function(write_path = "figures/jitter_legend_line.pdf") {
  df <- data.frame(x=c(0, 1, 2), y=c(1, 1, 1))
  p <- ggplot(df, aes(x=x,y=y)) + 
    geom_line(color="#02bec3", size=1.5) + 
    geom_point(fill="#02bec3", shape=23, size=4) + 
    mytheme 
  
  ggsave(write_path, p)
  
  return (p)
}

point_for_jitter_legend <- function(write_path = "figures/jitter_legend_point.pdf") {
  df <- data.frame(x=c(0, 1, 2), y=c(1, 1, 1))
  p <- ggplot(df, aes(x=x,y=y)) + 
    geom_point(alpha=0.1, size=20) + 
    mytheme 
  
  ggsave(write_path, p)
  
  return (p)
}


steps_over_groups_success_failure <- function(csv_dirs = c("data/main_parts"), 
                                              write_dir = "figures/",
                                              write_filename = 
                                                "steps_over_groups_success_failure.pdf", 
                                              minority_pop_sizes = c(0.05)) {
  
  full_df <- load_from_parts(csv_dirs, "data/steps_over_groups.csv")
  
  write_path <- file.path(write_dir, write_filename)
  
  success_remap <- function(frac_a_curr_trait) {
    if (frac_a_curr_trait == 1.0)
      return ("Success")
    else
      return ("Failure")
  }
    full_df$success = factor(map_chr(full_df$frac_a_curr_trait, success_remap))
# full_df
    aggdf <- full_df %>%
      filter(group_1_frac %in% minority_pop_sizes) %>%
      group_by(group_w_innovation, success) %>%
      summarize(step = mean(step))
    
    aggdf$group_w_innovation <- map_chr(aggdf$group_w_innovation, group_start_remap)

      aggdf <- rename(aggdf, start_group = group_w_innovation)
    aggdf$Status <- factor(aggdf$success)
    
    color_values <- c("#1896ee", "#f0a0ad") 
    # color_values <- c("#56B4E9")
    p <- ggplot(aggdf, aes(x = factor(start_group,
                                level=c("Majority", "Minority", "Both")),
                      y=step, group=Status)) +
      geom_line(aes(color=Status), size=1.5) +
      geom_point(aes(fill=Status, shape=Status), color='black', size=5, stroke=1.1) +
      xlab("Start group") + ylab("Mean steps to\nsuccess/failure") + 
      # scale_color_discrete("Status") +
      scale_shape_manual(values = c(21,24), breaks=c("Success", "Failure")) +
      scale_color_discrete(limits=c("Success", "Failure"), type=color_values) +
      scale_fill_discrete(limits=c("Success", "Failure"), type = color_values) +
      mytheme
    
    ggsave(write_path, width=7, height=3.25)
    
    return(p)
}



main_asymm_heatmaps <- function(csv_dir = "data/main_parts", 
                                write_dir = "figures/heatmaps/main", 
                                measure = "sustainability")
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
  
  for (group_w_innovation in group_w_vals) {
    
    asymm_heatmap(tbl, group_w_innovation, 
                  file.path(write_dir, paste0(group_w_innovation, ".pdf")),
                  measure)
  }
}


load_from_parts <- function(csv_dirs = c("data/main_parts", "data/supp_parts"),
                            sync_file = NULL) {
  
  group_w_vals <- c("1", "2", "Both")
  
  if (!is_null(sync_file)) {
    if (file.exists(sync_file)) {
      return (read_csv(sync_file))
    }
  }
  
  for (group_w_innovation in group_w_vals) {
    
    dir_idx = 1
    
    for (dd in csv_dirs) {
      files_part <- list.files(dd, 
                               pattern = paste0("group_w_innovation=", group_w_innovation),
                               full.names = TRUE)
      if (dir_idx == 1) {
        files <- files_part 
      }
      else {
        files <- rbind(files, files_part)
      }
    }
    
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
  
  # If we got here and the sync_file is not null, then there was no sync_file
  # to read and we create it now to sync the full output dataframe.
  if (!is_null(sync_file)) {
    write_csv(tbl, sync_file)
  }
  
  return (tbl)
}




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
      if (this_a_fitness %in% c(1.4, 2.0)) {
        asymm_heatmap(this_tbl, group_w_innovation, write_path, cmap_limits = c(0.0, 1.0))
      }
      else {
        asymm_heatmap(this_tbl, group_w_innovation, write_path)
      }
    }
  }

  
  # 
}


asymm_heatmap <- function(asymm_tbl, this_group_w_innovation, write_path, 
                          measure = "sustainability", 
                          cmap_limits = c(0.0, 0.8)) {
  
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
  
  if (measure == "sustainability") {
    ggplotstart <- ggplot(asymm_lim_agg, aes(x = homophily_1, y = homophily_2, fill = sustainability))
    measure_label <- "Success\nrate"
    # cmap_limits <- c(0.0, 1.0)
  } else if (measure == "step") {
    ggplotstart <- ggplot(asymm_lim_agg, aes(x = homophily_1, y = homophily_2, fill = step))
    measure_label <- "Mean\nsteps"
    cmap_limits = c(0, 60)
  } else {
    stop("Measure not recognized.")
  }
  
   ggplotstart + 
    geom_tile() +
    scale_fill_gradient2(low = "#000000", mid = "#010101", high = "#FFFFFF", limits = cmap_limits) +
    geom_point(data = asymm_max_line, aes(x = homophily_1, y = homophily_2)) +
    geom_smooth(data = asymm_max_line, aes(x = homophily_1, y = homophily_2), se=FALSE, n = 5) +
    geom_point(data = max_sustainability, aes(x=homophily_1, y=homophily_2), 
               shape='diamond', size=5, color='red') +
    labs(x = TeX("Minority group homophily, $h_{min}$"), 
         y = TeX("Majority group homophily, $h_{maj}$")) +
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



# success_over_groups_boxplot <- function(
    #   csv_dirs = c("data/main_parts", "data/supp_parts"), 
#   write_path = "figures/success_over_groups_boxplot.pdf", 
#   minority_pop_sizes = c(0.05, 0.2, 0.5)) {
# 
#   full_df <- load_from_parts(csv_dirs, "data/success_over_groups_boxplot.csv")
#   print(full_df)
# 
#   # Need each outcome for every homophily value separated.
#   aggdf <- full_df %>%
#     filter(group_1_frac %in% minority_pop_sizes) %>%
#     group_by(homophily_1, homophily_2, group_w_innovation, group_1_frac) %>%
#     summarize(success_rate = mean(frac_a_curr_trait))
# 
#   aggdf$group_w_innovation <- map_chr(aggdf$group_w_innovation, group_start_remap)
#   aggdf$group_1_frac <- factor(aggdf$group_1_frac)
# 
#   aggdf <- rename(aggdf, start_group = group_w_innovation, 
#                          minority_group_size = group_1_frac,
#                          h_min = homophily_1, h_maj = homophily_2)
# 
#   # Now create boxplot with start group on x-axis, success_rate on y-axis, 
#   # and color-coded by minority group size.
#   p <- ggplot(aggdf, aes(x = factor(start_group, 
#                                     level=c("Majority", "Minority", "Both")), 
#                          y = success_rate)) + 
#          geom_boxplot(aes(color = minority_group_size)) +
#          xlab("Start group") + ylab("Success rate") + 
#          scale_color_discrete("Min. group size") +
#          mytheme
# 
#   ggsave(write_path)
# 
#   return (p)
# }


# steps_over_groups_success_failure <- function(csv_dirs = c("data/main_parts"), 
#                                               write_path = "figures/steps_over_groups_success_failure_boxplot.pdf", minority_pop_sizes = c(0.05)) {
# 
#   full_df <- load_from_parts(csv_dirs, "data/steps_over_groups_boxplot.csv")
# 
#   success_remap <- function(frac_a_curr_trait) {
#     if (frac_a_curr_trait == 1.0)
#       return ("Success")
#     else
#       return ("Failure")
#   }
# 
#   full_df$success = factor(map_chr(full_df$frac_a_curr_trait, success_remap))
#   
#   aggdf <- full_df %>%
#     filter(group_1_frac %in% minority_pop_sizes) %>%
#     group_by(homophily_1, homophily_2, group_w_innovation, success) %>%
#     summarize(step = mean(step))
# 
#   aggdf$group_w_innovation <- map_chr(aggdf$group_w_innovation, group_start_remap)
# 
#   aggdf <- rename(aggdf, start_group = group_w_innovation, 
#                          h_min = homophily_1, h_maj = homophily_2)
# 
#   p <- ggplot(aggdf, aes(x = factor(start_group, 
#                                     level=c("Majority", "Minority", "Both")),
#                          y = step)) +
#          # geom_boxplot(aes(color = success)) + 
#     # geom_violin(aes(color = success)) + 
#     geom_jitter(alpha=0.5, width=0.2, aes(color=success)) +
#     # stat_summary(fun=mean, geom="line", color="#02bec3", size=1.5, aes(group=1)) +
#     # stat_summary(fun=mean, geom="point", shape=23, size=4, fill="#02bec3") +
#          xlab("Start group") + ylab("Mean steps to success/failure") +
#          scale_color_discrete("Status") + 
#          guides(colour = guide_legend(override.aes = list(size=5))) +
#          mytheme
# 
#   ggsave(write_path, width=7, height=5)
# 
#   return (p)
# }
