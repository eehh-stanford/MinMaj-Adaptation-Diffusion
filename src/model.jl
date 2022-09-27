using Agents
using DrWatson: @dict
using StatsBase


@enum Trait a A


mutable struct CBA_Agent <: AbstractAgent
    
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

    model.agent_fitnesses = 
        map(agent -> model.trait_fitness_dict[agent.curr_trait], agents)
end


function agent_step!(focal_agent::CBA_Agent, model::ABM)

    # Agent samples randomly from one of the groups, weighted by homophily.
    # XXX Only works for ngroups = 2.
    weights = zeros(2)

    agent_group_weight = (1 + focal_agent.homophily) / 2.0

    weights[focal_agent.group] = agent_group_weight
    weights[1:end .!= focal_agent.group] .= 1 - agent_group_weight

    group = sample(Weights(weights)) 

    ## Begin payoff-biased social learning from teacher within selected group.
    prospective_teachers = 
        filter(agent -> (agent.group == group) && (agent != focal_agent), 
               collect(allagents(model)))

    # println(length(prospective_teachers))
    # println(group)
    teacher_weights = 
        map(agent -> model.trait_fitness_dict[agent.curr_trait], 
                              prospective_teachers)

    # # XXX Allowing self-learning. XXX
    # teacher_weights[focal_agent.id] = 0.0
    # println(teacher_weights)

    # Renormalize weights.
    denom = Float64(sum(teacher_weights))
    # println(teacher_weights)
    teacher_weights ./= denom

    # Select teacher.
    teacher = sample(prospective_teachers, Weights(teacher_weights))

    # Learn from teacher.
    focal_agent.next_trait = teacher.curr_trait 
end


function cba_model(nagents = 100; group_1_frac = 1.0, group_w_innovation = 1,
                                  A_fitness = 1.0, a_fitness = 10.0, 
                                  homophily = 1.0, rep_idx = nothing,
                                  model_parameters...)

    trait_fitness_dict = Dict(a => a_fitness, A => A_fitness)
    agent_fitnesses = zeros(nagents)
    ngroups = 2

    properties = @dict trait_fitness_dict agent_fitnesses ngroups a_fitness homophily group_1_frac rep_idx

    model = ABM(CBA_Agent, scheduler = Schedulers.fastest; properties)
    flcutoff = floor(group_1_frac * nagents)
    group1_cutoff = Int(flcutoff)
    
    for aidx in 1:nagents
        # For now we assume two groups and one agent has de novo innovation.
        if aidx ≤ group1_cutoff
            group = 1
            if (group_w_innovation == 1) && (aidx == 1)
                trait = a
            else
                trait = A
            end
        else
            group = 2
            if (group_w_innovation == 2) && (aidx == group1_cutoff + 1)
                trait = a
            else
                trait = A
            end
        end
        # println(aidx)
        agent_to_add = CBA_Agent(aidx, trait, trait, group, homophily)
        add_agent!(agent_to_add, model)
    end
    
    agents = collect(allagents(model))
    # println(length(agents))

    agents_group1 = filter(a -> a.group == 1, agents)
    agents_group2 = filter(a -> a.group == 2, agents)

    agentidxs_group_dict = Dict(
        1 => map(agent -> agent.id, agents_group1),
        2 => map(agent -> agent.id, agents_group2)
    )
    # println(agentidxs_group_dict)

    model.agent_fitnesses = 
        map(agent -> trait_fitness_dict[agent.curr_trait], agents)

    return model
end
