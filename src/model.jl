using Agents
using DrWatson: @dict
using StatsBase


@enum Trait a A


mutable struct Person <: AbstractAgent
    
    id::Int
    curr_trait::Trait
    next_trait::Trait
    group::Int
    homophily::Float64

end


function model_step!(model)

    agents = allagents(model)

    for agent in agents
        agent.curr_trait = agent.next_trait
    end
end


function agent_step!(focal_agent::Person, model::ABM)

    # Agent samples randomly from one of the groups, weighted by homophily.
    group = sample_group(focal_agent, model)
    teacher = select_teacher(focal_agent, model, group)

    # Learn from teacher.
    focal_agent.next_trait = deepcopy(teacher.curr_trait) 
end


function adaptation_diffusion_model(nagents = 100; min_group_frac = 1.0, group_w_innovation = 1,
                                  A_fitness = 1.0, a_fitness = 10.0, 
                                  min_homophily = 1.0, maj_homophily = 1.0, 
                                  rep_idx = nothing, model_parameters...)

    trait_fitness_dict = Dict(a => a_fitness, A => A_fitness)
    ngroups = 2

    if typeof(group_w_innovation) == String
        if group_w_innovation != "Both"
            group_w_innovation = parse(Int, group_w_innovation)
        end
    end


    properties = @dict trait_fitness_dict ngroups a_fitness min_homophily maj_homophily min_group_frac rep_idx nagents 

    model = ABM(Person, scheduler = Schedulers.fastest; properties)
    flcutoff = ceil(min_group_frac * nagents)
    min_group_cutoff = Int(flcutoff)
    
    for aidx in 1:nagents

        # For now we assume two groups and one or two agents have de novo innovation.
        if aidx ≤ min_group_cutoff 

            # Set group membership and homophily.
            group = 1 
            homophily = min_homophily

            # Determine whether the agent should start with innovation or not.
            if (((group_w_innovation == 1) || (group_w_innovation == "Both")) 
                && (aidx == 1)) 

                trait = a
            else
                trait = A
            end
        else

            # Set group membership and homophily.
            group = 2
            homophily = maj_homophily

            # Determine whether the agent should start with innovation or not.
            if (((group_w_innovation == 2) || (group_w_innovation == "Both")) 
                && (aidx == min_group_cutoff + 1)) 

                trait = a
            else
                trait = A
            end 
        end
        
        agent_to_add = Person(aidx, trait, trait, group, homophily)

        add_agent!(agent_to_add, model)
    end
    
    agents = collect(allagents(model))

    return model
end


function sample_group(focal_agent, model)

    weights = zeros(2)

    # XXX a waste to calculate this every time.
    agent_group_weight = (1 + focal_agent.homophily) / 2.0

    weights[focal_agent.group] = agent_group_weight
    weights[1:end .!= focal_agent.group] .= 1 - agent_group_weight
    
    return sample(Weights(weights)) 
end


function select_teacher(focal_agent, model, group)

    ## Begin payoff-biased social learning from teacher within selected group.
    prospective_teachers = 
        filter(agent -> (agent.group == group) && (agent != focal_agent), 
               collect(allagents(model)))

    teacher_weights = 
        map(agent -> model.trait_fitness_dict[agent.curr_trait], 
                              prospective_teachers)

    # Renormalize weights.
    denom = Float64(sum(teacher_weights))
    teacher_weights ./= denom

    # Select teacher.
    return sample(prospective_teachers, Weights(teacher_weights))
end


