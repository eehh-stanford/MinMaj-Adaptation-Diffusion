using Distributed
using Dates
using UUIDs: uuid4

using DrWatson
quickactivate("..")

# Set up DrWatson to include vectors in autogen save names.
da = DrWatson.default_allowed(Any)
DrWatson.default_allowed(c) = (da..., Vector)

using ArgParse
using CSV
using Comonicon
using JLD2

include("../src/experiment.jl")


s = ArgParseSettings()


function parse_cli()

    @add_arg_table s begin
        "datadirname"
            help = "Subdirectory of data/, where to save output data"
            arg_type = String
            required = true

        "--nreplicates"
            help = "Number of trial simulations to run for this experiment"
            arg_type = Int
            default = 100

        "--min_group_frac", "-m"
            help = "Fraction of population that is in minority"
            arg_type = Float64
            default = 0.05

        "--a_fitness", "-f"
            help = "Fitness value of the adaptive trait; non-adaptive trait has fitness 1"
            arg_type = Float64
            default = 1.2

        "--group_w_innovation"
            help = "Group that should start with the innovation: 1, 2, or 'Both'"
            required = true

        "--nagents", "-N"
            help = "Population size, N"
            default = 100
            arg_type = Int

        "--use_network"
            help = "Use network?"
            default = false
            arg_type = Bool

        "--mean_degree"
            help = "Mean degree of random network"
            default = 6
            arg_type = Int
    end

    return parse_args(s)
end



function run_trials(nreplicates = 20; 
                    outputfilename = "trials_output.jld2", 
                    experiment_kwargs...)

    tic = now()

    println("Starting trials at $(replace(string(tic), "T" => " "))")

    # XXX Awkward stuff due to mixing around positional argument as either
    # nagents or nreplicates.
    kwargs_dict = Dict(experiment_kwargs)
    nagents = pop!(kwargs_dict, :nagents)
    kwargs_dict[:nreplicates] = nreplicates

    result_df = adaptation_diffusion_experiment(nagents; kwargs_dict...)

    CSV.write(outputfilename, result_df)

    trialstime = Dates.toms(now() - tic) / (60.0 * 1000.0)

    println("Ran expected payoffs trials in $trialstime minutes")
end


function main()
    parsed_args = parse_cli()

    # Create job id for unique filename.
    parsed_args["jobid"] = string(uuid4())
    println(parsed_args)

    datadirname = pop!(parsed_args, "datadirname")
    nameargs = copy(parsed_args)

    outputfilename = joinpath("data", datadirname, savename(nameargs, "csv"))

    nreplicates = pop!(parsed_args, "nreplicates")

    # Don't need to pass this job ID to experiment.
    pop!(parsed_args, "jobid")

    # Need keys to be symbols for passing to run_trials function.
    pa_symbkeys = Dict(Symbol(key) => value for (key, value) in parsed_args)

    run_trials(nreplicates; outputfilename, pa_symbkeys...)
end


main()
