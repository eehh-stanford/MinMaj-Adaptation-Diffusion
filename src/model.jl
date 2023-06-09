using Agents
using DrWatson: @dict
using StatsBase


@enum Trait a A

@enum Group Minority Majority Both


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
end


function agent_step!(focal_agent::CBA_Agent, model::ABM)

    # Agent samples randomly from one of the groups, weighted by homophily.
    group = sample_group(focal_agent, model)
    teacher = select_teacher(focal_agent, model, group)

    # Learn from teacher.
    focal_agent.next_trait = deepcopy(teacher.curr_trait) 
end


function cba_model(nagents = 100; group_1_frac = 1.0, group_w_innovation = 1,
                                  A_fitness = 1.0, a_fitness = 10.0, 
                                  homophily_1 = 1.0, homophily_2 = 1.0, 
                                  sigmoid_slope = 5.0, fitness_diff_coeff = 0.2,
                                  f0_A = 0.9, f0_a = 1.1, 
                                  nstar_min_min = 0.25, nstar_max_max = 0.25,
                                  nstar_min_max = 0.5, nstar_max_min = 0.5,
                                  rep_idx = nothing)

    trait_fitness_dict = Dict(a => a_fitness, A => A_fitness)
    ngroups = 2

    if typeof(group_w_innovation) == String
        if group_w_innovation != "Both"
            group_w_innovation = parse(Int, group_w_innovation)
        end
    end


    properties = @dict trait_fitness_dict ngroups a_fitness homophily_1 homophily_2 group_1_frac rep_idx nagents sigmoid_slope fitness_diff_coeff f0_A f0_a nstar_min_min nstar_max_max nstar_min_max nstar_max_min

    model = ABM(CBA_Agent, scheduler = Schedulers.fastest; properties)
    flcutoff = ceil(group_1_frac * nagents)
    group1_cutoff = Int(flcutoff)
    
    for aidx in 1:nagents

        # For now we assume two groups and one or two agents have de novo innovation.
        if aidx ≤ group1_cutoff 

            # Set group membership and homophily.
            group = 1 
            homophily = homophily_1

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
            homophily = homophily_2

            # Determine whether the agent should start with innovation or not.
            if (((group_w_innovation == 2) || (group_w_innovation == "Both")) 
                && (aidx == group1_cutoff + 1)) 

                trait = a
            else
                trait = A
            end 
        end
        
        agent_to_add = CBA_Agent(aidx, trait, trait, group, homophily)

        add_agent!(agent_to_add, model)
    end
    
    agents = collect(allagents(model))
    
    model.properties[:minority_group] = filter(a -> a.group == 1, agents)
    model.properties[:majority_group] = filter(a -> a.group == 2, agents)

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


function select_teacher(observing_agent, model, group)

    ## Begin payoff-biased social learning from teacher within selected group.
    prospective_teachers = 
        filter(agent -> (agent.group == group) && (agent != observing_agent), 
               collect(allagents(model)))

    # TODO here's where to edit teacher selection weighting
    # teacher_weights = 
    #     map(agent -> model.trait_fitness_dict[agent.curr_trait], 
    #                           prospective_teachers)
    teacher_weights = map(prospective_teacher -> 
                          fitness(observing_agent, prospective_teacher, prospective_teachers, model),
                          prospective_teachers)

    # Renormalize weights.
    denom = Float64(sum(teacher_weights))
    teacher_weights ./= denom

    # Select teacher.
    return sample(prospective_teachers, Weights(teacher_weights))
end


# Fitness of focal_agent in G' as perceived by observing_agent in G given model parameters.
function fitness(observing_agent, focal_agent, prospective_teachers, model)

    base_fitness = focal_agent.curr_trait == a ? model.f0_a : model.f0_A

    # Determine which nstar to use depending on group membership.
    if (observing_agent.group == 1) && (focal_agent.group == 1)

        nstar_G_Gprime = model.nstar_min_min

    elseif (observing_agent.group == 1) && (focal_agent.group == 2)

        nstar_G_Gprime = model.nstar_min_maj

    elseif (observing_agent.group == 2) && (focal_agent.group == 1)

        nstar_G_Gprime = model.nstar_maj_min

    else

        nstar_G_Gprime = model.nstar_maj_maj
    end

    # For the current frequency-dependent fitness adjustment, we use the
    # focal agent's current trait and the focal agent's group since these are
    # what matter to the observing_agent who is calculating weights for choosing
    # a teacher.
    this_adjustment = 
        fitness_adjustment(
            trait_frequency(focal_agent.curr_trait, prospective_teachers, model);
            nstar_G_Gprime, sigmoid_slope = model.sigmoid_slope
        )
    
    return base_fitness + this_adjustment

end


function fitness_adjustment(group_freq; nstar_G_Gprime = 0.5, sigmoid_slope = 1)

    r = -log10(2) / log10(nstar_G_Gprime)

    num = group_freq^(r*sigmoid_slope)
    den = num + (1 - (group_freq^r))^sigmoid_slope

    return num / den

end


function trait_frequency(trait::Trait, prospective_teachers, model)

    # group_key = group == 1 ? :minority_group : :majority_group
    # agents = model.properties[group_key]
    total_agents = length(prospective_teachers)

    numagents_w_trait = length(filter(a -> a.curr_trait == trait, prospective_teachers))

    return numagents_w_trait / total_agents

end
