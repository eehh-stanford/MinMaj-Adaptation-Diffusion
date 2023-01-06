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


function homophily_minority_experiment(nagents=100; a_fitness = 2.0, 
                                       homophily = [
                                        collect(0.0:0.05:0.95)..., 0.99
                                       ],
                                       group_1_frac = collect(0.05:0.05:0.5), 
                                       nreplicates=10, group_w_innovation = 1,
                                       allsteps = false
    )

    rep_idx = collect(1:nreplicates)

    homophily_1 = homophily
    homophily_2 = homophily

    params_list = dict_list(
        @dict homophily_1 homophily_2 group_1_frac a_fitness rep_idx
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

    mdata = [:a_fitness, :group_1_frac, :rep_idx, :homophily_1, :homophily_2]

    function stopfn_fixated(model, step)
        agents = allagents(model)

        return (
            all(agent.curr_trait == a for agent in agents) ||
            all(agent.curr_trait == A for agent in agents)
        )
    end

    # For now ignore non-extremal time steps.
    if allsteps
        when(model, step) = true
    else
        when(model, step) = stopfn_fixated(model, step)
    end

    adf, mdf = ensemblerun!(models, agent_step!, model_step!, stopfn_fixated;
                            adata, mdata, when, parallel = true, 
                            showprogress = true)
    
    res = innerjoin(adf, mdf, on = [:step, :ensemble])

    # Confirm that all runs fixated.
    @assert sort(unique(res.frac_a_curr_trait)) == [0.0, 1.0]

    return res
end


function reproduce_KF_Figure1(nagents = 100;
                              a_fitness_low = 1.0, a_fitness_high = 2.0, 
                              d_a_fitness = 0.1, nreplicates = 10)
    # Initialize models with one group and set homophily to zero (though it
    # doesn't matter what value it is with just one group).
    a_fitness_vals = collect(a_fitness_low:d_a_fitness:a_fitness_high)

    models = [cba_model(nagents; a_fitness, A_fitness=1.0, group_1_frac = 1.0, 
                        homophily = 1.0, group_w_innovation = 1) 
              for a_fitness in a_fitness_vals
              for _ in 1:nreplicates] 

    frac_a(v) = sum(v .== a) / length(v)

    adata = [(:curr_trait, frac_a)]
    mdata = [:a_fitness, :homophily_1, :homophily_2]

    # For now ignore non-extremal time steps.
    when(model, step) = stopfn_fixated(model, step)

    adf, mdf = ensemblerun!(collect(models), agent_step!, model_step!, stopfn_fixated;
                            adata, mdata, when, parallel = true, 
                            showprogress = true)
    
    res = innerjoin(adf, mdf, on = [:ensemble, :step])

    # Don't know why this is happening, but I'll hack this and figure it out
    # later.
    # rename!(res, "fixated_nagents=$(nagents)_curr_trait" => "fixated")

    # Confirm that all runs fixated.
    @assert sort(unique(res.frac_a_curr_trait)) == [0.0, 1.0]

    return res
end
