using CSV
using DataFrames
using JLD2
using RCall

include("../src/experiment.jl")

using Cairo, Fontconfig, Gadfly, Compose

using Colors
logocolors = Colors.JULIA_LOGO_COLORS
SEED_COLORS = [logocolors.purple, colorant"deepskyblue", 
               colorant"forestgreen", colorant"pink"] 

PROJECT_THEME = Theme(
    major_label_font="CMU Serif",minor_label_font="CMU Serif", 
    point_size=5.5pt, major_label_font_size = 18pt, 
    minor_label_font_size = 18pt, key_title_font_size=18pt, 
    line_width = 3.5pt, key_label_font_size=14pt, #grid_line_width = 1.5pt,
    panel_stroke = colorant"black", grid_line_width = 0pt
)


function minority_majority_comparison(nagents=100; 
                                      group_1_frac = 0.05, a_fitness = 1.2, 
                                      diagnostic_dir = "plots/minmaj_compare",
                                      sync_dir = "data/minmaj_compare",
                                      nreplicates = 1000)

    # Set up diagnostic figure directory if it doesn't already exist.
    if !isdir(diagnostic_dir)
        mkpath(diagnostic_dir)
    end
    if !isdir(sync_dir)
        mkpath(sync_dir)
    end

    groups = [1, 2, "Both"]
    results = DataFrame(:group_w_innovation => [], 
                        :homophily => [], :sustainability => [])

    # Load or create data for all three cases: start in minortiy, start in majority.
    for group in groups
        result =  
            sustainability_vs_homophily(nagents; group_w_innovation = group,
                                        a_fitness, group_1_frac, nreplicates,
                                        sync_dir, figure_dir = diagnostic_dir)
        if group == 1
            group_label = "Minority"
        elseif group == 2
            group_label = "Majority"
        else
            group_label = group
        end

        result.group_w_innovation .= group_label

        append!(results, result)
    end

    figpath = joinpath(
        diagnostic_dir, 
        "nagents=$nagents-group_1_frac=$group_1_frac-a_fitness=$a_fitness.pdf"
    )

    p = plot(results, x=:homophily, y=:sustainability, 
             linestyle=:group_w_innovation, Geom.line)
    
    draw(
         PDF(figpath,
             6.25inch, 3.5inch), 
        p
    )

    return results
end

function plot_nagents_sensitivity(;
                                  figure_dir = "figure_scratch/nagents",
                                  data_dir = "data/sensitivity/nagents",
                                  nagents_vec = [200, 500, 1000],
                                  width = 7.0, height = 3.5, save_dir =
                                  "~/workspace/Writing/SustainableCBA/Figures/")

    # Get list of all files in the sensitivity/nagents directory.
    files = readdir(data_dir, join=true)
        
    # For each of the nagents values, make a CSV by concatenating the three
    # versions for minmaj compare: innovation starts in min, maj, and min+maj.
    for nagents in nagents_vec

        these_files = 
            collect(filter(file -> occursin("nagents=$nagents", file), files))

        println(these_files)
        
        # XXX TODO Awkward hack to add starting group before concat.
        dfs = [JLD2.load(file)["agg"] for file in these_files] 
        for (idx, df) in enumerate(dfs)

            if occursin("1.jld2", these_files[idx])
                group = "Minority"
            elseif occursin("2.jld2", these_files[idx])
                group = "Majority"
            elseif occursin("Both.jld2", these_files[idx])
                group = "Both"
            else
                error("Not a valid group")
            end

            df[!, :group_w_innovation] .= group
        end

        # Result dataframe is 
        res = vcat(dfs...)

        save_path = joinpath(figure_dir, "nagents=$(nagents)_minmaj_compare.pdf")
        plot_minmaj_compare(res; save_path, width, height)
    end

end


function plot_minmaj_compare(data_frame; csv_path = "tmp_R.csv", 
                             width = 7.0, height = 3.5,
                             save_path = 
                                "~/workspace/Writing/SustainableCBA/Figures/minmaj_compare.pdf")

    # Need to write dataframe to file then reload in R because it wasn't 
    # working to pass dataframe to R string. 
    CSV.write(csv_path, data_frame)

    # Use the R macro to execute this chunk of R code for plotting.
R"""
    library(ggplot2)  

    mytheme = theme(
        panel.border = element_blank(), axis.line = element_line(),  
        text = element_text(size=16),  #, family = "Gill Sans"), 
        panel.background = element_rect(fill = "white"),
        legend.key = element_rect(fill = "white"),
        axis.text=element_text(color="black"),
        legend.key.width = unit(0.6,"in") 
    ) 
    data_frame <- read.csv($csv_path); 

    p <- ggplot(data_frame, aes(x=homophily, y=sustainability, 
                group = group_w_innovation, linetype = group_w_innovation, 
                shape = group_w_innovation)) + 

                geom_point(size=3.0, color="#6A6A6A") + 
                geom_smooth(se=FALSE) + #geom_line(lwd=1.10) + 

    labs(x='Homophily', y = 'Sustainability', 
        linetype = 'Group with innovation', 
        shape = 'Group with innovation') + 
        
    scale_linetype_discrete(breaks=c('Minority', 'Majority', 'Both')) + 
    
    scale_shape_manual(values=c(0,2,1), 
        breaks=c('Minority', 'Majority', 'Both')) + 

    scale_x_continuous(breaks=seq(0, 1, 0.2)) + 

    mytheme

    ggsave(filename = $save_path, device = cairo_pdf, p, 
           width=$width, height=$height, units="in")
"""

end


function reproduce_FK(sync_file="data/outline/FK_Figure1.jld2",
                      figure_dir="plots/outline/")

end


function sustainability_comparison(group_1_frac = 0.05, group_w_innovation = 1)
    afit105 = load("data/outline/a_fitness=1.05__group_1_frac=$(group_1_frac)__group_w_innovation=$(group_w_innovation).jld2")["agg"] 
    afit12 = load("data/outline/a_fitness=1.2__group_1_frac=$(group_1_frac)__group_w_innovation=$(group_w_innovation).jld2")["agg"] 
    afit14 = load("data/outline/a_fitness=1.4__group_1_frac=$(group_1_frac)__group_w_innovation=$(group_w_innovation).jld2")["agg"] 
    afit20 = load("data/outline/a_fitness=2.0__group_1_frac=$(group_1_frac)__group_w_innovation=$(group_w_innovation).jld2")["agg"] 

    yticks = 0.0:0.2:1.0
    p = plot(

        layer(afit105, x=:homophily, y=:sustainability, 
              Geom.line, Geom.point, Theme(point_size=2.5pt, line_width=1.5pt, default_color=SEED_COLORS[1])), 
        layer(afit12, x=:homophily, y=:sustainability, 
              Geom.line, Geom.point, Theme(point_size=2.5pt, line_width=1.5pt, default_color=SEED_COLORS[2])), 
        layer(afit14, x=:homophily, y=:sustainability, 
              Geom.line, Geom.point, Theme(point_size=2.5pt, line_width=1.5pt, default_color=SEED_COLORS[3])), 
        layer(afit20, x=:homophily, y=:sustainability, 
              Geom.line, Geom.point, Theme(point_size=2.5pt, line_width=1.5pt, default_color=SEED_COLORS[4])),

         Guide.manual_color_key(
            "<i>a</i> fitness",
            ["1.05", "1.2", "1.4", "2.0"], 
            [SEED_COLORS[1], SEED_COLORS[2], SEED_COLORS[3], SEED_COLORS[4]],
        ),
        
        Guide.xlabel("Homophily"),
        Guide.yticks(ticks=yticks),
        Guide.ylabel("Sustainability"),
        PROJECT_THEME
    )

    draw(
         PDF("plots/outline/comparison_minsize=$(group_1_frac)_group_w_innovation=$(group_w_innovation).pdf",
             5.25inch, 3.5inch), 
        p
    )
end


function sustainability_vs_homophily(nagents = 100;
        a_fitness=1.4, group_1_frac = 0.05, nreplicates = 1000, 
        sync_dir = "data/outline", group_w_innovation = 1, 
        figure_dir = "plots/outline")

    # Build base file name.
    fbase = "a_fitness=$(a_fitness)__group_1_frac=$(group_1_frac)__group_w_innovation=$(group_w_innovation)"
    # Set path to which aggregated data will be synced.
    aggpath = joinpath(sync_dir, fbase * ".jld2")

    if isfile(aggpath)
        agg = load(aggpath)["agg"]
    else
        res = homophily_minority_experiment(nagents; 
                                            nreplicates, group_1_frac, 
                                            a_fitness, group_w_innovation)
        println(first(res, 10))

        # Group by homophily, calculate the mean sustainability and 
        # time to convergence across replicates for each homophily value.
        agg = combine(groupby(res, :homophily), 
                      :frac_a_curr_trait => mean => :sustainability,
                      :step => mean => :step
                      )

        @save aggpath agg
    end
    
    xdata = agg.homophily
    ydata = agg.sustainability

    p = plot(layer(agg, x=:homophily, y=:sustainability, Geom.line, Geom.point))

    figpath = joinpath(figure_dir, fbase * ".pdf")

    draw(
         PDF(figpath,
             6.25inch, 3.5inch), 
        p
    )

    return agg
end


