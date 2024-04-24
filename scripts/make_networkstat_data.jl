using CSV
using DataFrames
using Graphs

include("../src/model.jl")


function make_save_one_network(write_dir; 
                               nagents = 1000,
                               min_homophily = 0.5, 
                               maj_homophily = 0.5,
                               mean_degree = 6, min_group_frac = 0.05,
                               index = 1,
                               model_kw_args... 
                              )

    model = adaptation_diffusion_model(nagents; 
                                       use_network = true, mean_degree, 
                                       min_group_frac,
                                       min_homophily, maj_homophily, 
                                       group_w_innovation = 1, 
                                       model_kw_args...)

    adjacency_df = DataFrame(Matrix(adjacency_matrix(model.network; dir=:out)), 
                             map(aid -> string(aid), 1:nagents))

    filename = "adjacency_hmin=$(min_homophily)_hmaj=$(maj_homophily)_$index.csv"

    CSV.write(joinpath(write_dir, filename), adjacency_df)
end


function make_save_all_network_data(n_networks = 100,
                                    write_dir = "data/network_stats_base"; 
                                    nagents = 1000,
                                    min_homophilies = [0.0],
                                    maj_homophilies = collect(0.0:0.05:0.9),
                                    mean_degree = 6,
                                    min_group_frac = 0.05,
                                    index_start = 1,
                                    model_kw_args...
                                   )

    for min_homophily in min_homophilies
        for maj_homophily in maj_homophilies
            Threads.@threads for index in index_start:(index_start + n_networks)
                make_save_one_network(write_dir; min_homophily, maj_homophily, 
                                      mean_degree, min_group_frac, index)
            end
        end
    end

end
