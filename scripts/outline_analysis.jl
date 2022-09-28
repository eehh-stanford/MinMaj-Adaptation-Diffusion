using DataFrames
using JLD2
using LsqFit

include("../src/experiment.jl")

import Cairo, Fontconfig

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

function sustainability_comparison()
    afit12_minhas = load("data/outline/a_fitness=1.2__group_1_frac=0.05__group_w_innovation=1.jld2")["agg"] 
    afit14_minhas = load("data/outline/a_fitness=1.4__group_1_frac=0.05__group_w_innovation=1.jld2")["agg"] 
    afit20_minhas = load("data/outline/a_fitness=2.0__group_1_frac=0.05__group_w_innovation=1.jld2")["agg"] 
    # afit12_p2 = load("data/outline/a_fitness=1.2__group_1_frac=0.2__group_w_innovation=1.jld2")["agg"] 
    # afit14_p2 = load("data/outline/a_fitness=1.4__group_1_frac=0.2__group_w_innovation=1.jld2")["agg"] 
    # afit20_p2 = load("data/outline/a_fitness=2.0__group_1_frac=0.2__group_w_innovation=1.jld2")["agg"] 


    p = plot(

        layer(afit12_minhas, x=:homophily, y=:sustainability, 
              Geom.line, Geom.point, Theme(point_size=2.5pt, line_width=1.5pt, default_color=SEED_COLORS[1])), 
        layer(afit14_minhas, x=:homophily, y=:sustainability, 
              Geom.line, Geom.point, Theme(point_size=2.5pt, line_width=1.5pt, default_color=SEED_COLORS[2])), 
        layer(afit20_minhas, x=:homophily, y=:sustainability, 
              Geom.line, Geom.point, Theme(point_size=2.5pt, line_width=1.5pt, default_color=SEED_COLORS[3])),

        # layer(afit12_p2, x=:homophily, y=:sustainability, 
        #       Geom.line, Geom.point, Theme(point_size=3.5pt, line_style=[:dash], line_width=1.5pt, point_shapes=[Shape.diamond], default_color=SEED_COLORS[1])), 
        # layer(afit14_p2, x=:homophily, y=:sustainability, 
        #       Geom.line, Geom.point, Theme(point_size=3.5pt, line_style=[:dash], line_width=1.5pt,point_shapes=[Shape.diamond], default_color=SEED_COLORS[2])), 
        # layer(afit20_p2, x=:homophily, y=:sustainability, 
        #        Geom.line, Geom.point, Theme(point_size=3.5pt, line_width=1.5pt, line_style=[:dash], point_shapes=[Shape.diamond], default_color=SEED_COLORS[3])),

         Guide.manual_color_key(
            "<i>a</i> fitness",
                                
            ["1.2", "1.4", "2.0"], #,"1.2, 20% minority", "1.4", "2.0",],

            [SEED_COLORS[1], SEED_COLORS[2], SEED_COLORS[3]],#SEED_COLORS[1], SEED_COLORS[2], SEED_COLORS[3]],

            shape=[Shape.circle, Shape.circle, Shape.circle],
                   # Shape.diamond, Shape.diamond, Shape.diamond]
        ),
        
        Guide.xlabel("Homophily"),
        Guide.ylabel("Sustainability"),
        PROJECT_THEME
    )

    draw(
         PDF("plots/outline/comparison_minsize=0.05.pdf",
             5.25inch, 3.5inch), 
        p
    )
end

function sustainability_vs_homophily(;
        a_fitness=1.4, group_1_frac = 0.05, sync_dir = "data/outline",
        group_w_innovation = 1, fit_quadratic = false, figure_dir = "plots/outline")

    # Run one where minority has adaptation with peak in middle for 
    # most sustainability as function of homophily.
    froot = "a_fitness=$(a_fitness)__group_1_frac=$(group_1_frac)__group_w_innovation=$(group_w_innovation)"
    aggpath = joinpath(sync_dir, froot * ".jld2")

    if isfile(aggpath)
        agg = load(aggpath)["agg"]
    else
        res = homophily_minority_experiment(100; 
                                            nreplicates=1000, group_1_frac, 
                                            a_fitness, group_w_innovation)

        agg = combine(groupby(res, :homophily), 
                      :frac_a_curr_trait => mean => :sustainability)

        @save aggpath agg
    end
    
    xdata = agg.homophily
    ydata = agg.sustainability

    # Fit a quadratic for giggles.
    if fit_quadratic
        @. quad_mod(x, p) = p[1] + (x * p[2]) + (p[3] * (x^2))
        p0 = [0.0, 0.5, -0.5]
        fit = curve_fit(quad_mod, xdata, ydata, p0)
        ydatafit = quad_mod(xdata, fit.param)
    end

    p = plot(layer(agg, x=:homophily, y=:sustainability, Geom.line, Geom.point))
             # layer(x=xdata, y=ydatafit, Geom.line))

    drawpath = joinpath(figure_dir, froot * ".pdf")

    draw(
         PDF(drawpath,
             6.25inch, 3.5inch), 
        p
    )

end


function reproduce_FK(sync_file="data/outline/FK_Figure1.jld2",
                      figure_dir="plots/outline/")

      

end
