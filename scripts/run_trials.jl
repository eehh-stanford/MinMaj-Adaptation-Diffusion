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

function vecparse(T, s::AbstractString)

    if occursin(":", s)
        vals = split(s, ":")
        parseT(x) = parse(T, x)

        return parseT(vals[1]):parseT(vals[2]):parseT(vals[3])
        
    else
        s = replace(s, "[" => "")
        s = replace(s, "]" => "")

        return [parse(T, el) for el in split(s, ",")]
    end
end


# Define functions to parse vectors of floats...
function ArgParse.parse_item(::Type{Vector{Float64}}, s::AbstractString)
    vecparse(Float64, s) 
end


# ...and vectors of ints. Could not get templated version to work so had to dup.
function ArgParse.parse_item(::Type{Vector{Int64}}, s::AbstractString)
    vecparse(Int64, s)
end


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

        "--group_1_frac", "-m"
            help = "Fraction of population that is in minority"
            arg_type = Float64
            default = 0.05

        "--group_w_innovation"
            help = "Group that should start with the innovation: 1, 2, or 'Both'"
            # required = true
            default = 1

        "--nagents", "-N"
            help = "Population size, N"
            default = 100
            arg_type = Int

        "--f0_A"
            help = "Base fitness of the non-adaptive trait"
            default = 0.9
            arg_type = Float64

        "--f0_a"
            help = "Base fitness of the adaptive trait"
            default = 1.5
            arg_type = Float64

        "--sigmoid_slope"
            help = "Sigmoid parameter controlling sharpness of slope from 0 to 1"
            default = 5.0
            arg_type = Float64

        "--fitness_diff_coeff"
            help = "Maximum frequency-dependent fitness improvement"
            default = 0.2
            arg_type = Float64

        "--nstar_min_min"
            help = "Frequency at which 50% of full frequency-dependent difference attained when minority group observes minority group"
            default = [0.25, 0.5, 0.75]
            arg_type = Vector{Float64}

        "--nstar_min_maj"
            help = "Frequency at which 50% of full frequency-dependent difference attained when minority group observes majority group"
            default = [0.25, 0.5, 0.75]
            arg_type = Vector{Float64}

        "--nstar_maj_min"
            help = "Frequency at which 50% of full frequency-dependent difference attained when majority group observes minority group"
            default = [0.25, 0.5, 0.75]
            arg_type = Vector{Float64}

        "--nstar_maj_maj"
            help = "Frequency at which 50% of full frequency-dependent difference attained when majority group observes majority group"
            default = [0.25, 0.5, 0.75]
            arg_type = Vector{Float64}
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

    result_df = homophily_minority_experiment(nagents; kwargs_dict...)

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

    outputfilename = 
        replace(
            joinpath("data", datadirname, savename(nameargs, "csv")),
            "fitness_diff_coeff" => "fdiff_co"
        )
    outputfilename = replace(outputfilename, "sigmoid_slope" => "sigslpe")
    outputfilename = replace(outputfilename, "nstar" => "n")
    

    nreplicates = pop!(parsed_args, "nreplicates")

    # Don't need to pass this job ID to experiment.
    pop!(parsed_args, "jobid")

    # Need keys to be symbols for passing to run_trials function.
    pa_symbkeys = Dict(Symbol(key) => value for (key, value) in parsed_args)

    run_trials(nreplicates; outputfilename, pa_symbkeys...)
end


main()
