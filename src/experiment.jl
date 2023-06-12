using DataFrames

using Distributed
using StatsBase


# Set up multiprocessing.
try
    num_cores = parse(Int, ENV["SLURM_CPUS_PER_TASK"])
    addprocs(num_cores)
catch
    desired_nprocs = length(Sys.cpu_info())

    if length(procs()) != desired_nprocs
        addprocs(desired_nprocs - 1)
    end
end


@everywhere using DrWatson
@everywhere quickactivate("..")
@everywhere include("model.jl")


function homophily_minority_experiment(nagents=100; 
                                       homophily = [
                                        collect(0.0:0.05:0.95)..., 0.99
                                       ],
                                       group_1_frac = collect(0.05:0.05:0.5), 
                                       nreplicates=10, group_w_innovation = 1,
                                       f0_A = 0.9, f0_a = 1.5, 
                                       sigmoid_slope = 5.0, fitness_diff_coeff = 0.2,
                                       nstar_min_min = [0.25,0.5,0.75], 
                                       nstar_maj_maj = [0.25,0.5,0.75],
                                       nstar_min_maj = [0.25,0.5,0.75], 
                                       nstar_maj_min = [0.25,0.5,0.75],
                                       allsteps = false
    )

    rep_idx = collect(1:nreplicates)

    homophily_1 = homophily
    homophily_2 = homophily

    params_list = dict_list(
        @dict homophily_1 homophily_2 group_1_frac rep_idx f0_A f0_a nstar_min_min nstar_maj_maj nstar_min_maj nstar_maj_min
    )

    models = [cba_model(nagents; group_w_innovation, params...) 
              for params in params_list]

    # adata = [(:curr_trait, fixated)]
    frac_a(v) = sum(v .== a) / length(v)

    is_minority(x) = x.group == 1
    frac_a_ifdata(v) = isempty(v) ? 0.0 : frac_a(collect(v))
    adata = [(:curr_trait, frac_a), 
             (:curr_trait, frac_a_ifdata, is_minority),
             (:curr_trait, frac_a_ifdata, !is_minority),
            ]

    mdata = [:group_1_frac, :nagents, :rep_idx, 
             :homophily_1, :homophily_2, :f0_A, :f0_a, 
             :nstar_min_min, :nstar_min_maj, :nstar_maj_min, :nstar_maj_maj]

    function stopfn_fixated(model, step)
        agents = allagents(model) 

        return (
            all(agent.curr_trait == a for agent in agents) || 
            all(agent.curr_trait == A for agent in agents)
        )
    end

    # For now ignore non-extremal time steps.
    when(model, step) = stopfn_fixated(model, step)
    adf, mdf = ensemblerun!(models, agent_step!, model_step!, stopfn_fixated;
                            adata, mdata, when, parallel = true, 
                            showprogress = true)
    
    res = innerjoin(adf, mdf, on = [:step, :ensemble])

    println(first(res, 15))

    # @assert sort(unique(res.frac_a_curr_trait)) == [0.0, 1.0]

    return res
end

