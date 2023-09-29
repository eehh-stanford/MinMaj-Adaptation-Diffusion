using Agents
using DrWatson: @dict
using Graphs: SimpleDiGraph
using StatsBase


@enum Trait a A


mutable struct Person <: AbstractAgent
    
    id::Int
    curr_trait::Trait
    next_trait::Trait
    group::Int
    homophily::Float64
    teachers::Union{Nothing,Vector{Int}}  # In non-network case no pre-set teachers.

end


function model_step!(model)

    agents = allagents(model)

    for agent in agents
        agent.curr_trait = agent.next_trait
    end
end


function agent_step!(focal_agent::Person, model::ABM)

    # Agent samples randomly from one of the groups, weighted by homophily.
    if model.networked
        # continue
        # group = sample_group_networked(focal_agent, model)
        # teacher = select_teacher_networked(focal_agent, model, group)
    else
        group = sample_group(focal_agent, model)
        teacher = select_teacher(focal_agent, model, group)
    end

    # Learn from teacher.
    focal_agent.next_trait = deepcopy(teacher.curr_trait) 
end


function adaptation_diffusion_model(nagents = 100; min_group_frac = 1.0, 
                                    group_w_innovation = 1, 
                                    A_fitness = 1.0, a_fitness = 10.0, 
                                    min_homophily = 1.0, maj_homophily = 1.0, 
                                    rep_idx = nothing, use_network = false, 
                                    model_parameters...)

    trait_fitness_dict = Dict(a => a_fitness, A => A_fitness)
    ngroups = 2

    if typeof(group_w_innovation) == String
        if group_w_innovation != "Both"
            group_w_innovation = parse(Int, group_w_innovation)
        end
    end


    properties = @dict trait_fitness_dict ngroups a_fitness min_homophily maj_homophily min_group_frac rep_idx nagents 
    if use_network
        merge!(properties, model_parameters)
        network = SimpleDiGraph(nagents)
        merge!(properties, Dict(:network => network))
    end

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
        
        agent_to_add = Person(aidx, trait, trait, group, homophily, nothing)

        add_agent!(agent_to_add, model)
    end
    
    if use_network
        init_network!(model)
    end

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


function init_network!(model)
    @assert :mean_degree ∈ keys(model.properties) "Mean degree must be provided for social-networked model"

    # Access network; get minority and majority groups and ids.
    network = model.network

    minority_group = filter(a -> a.group == 1, allagents(model))
    minority_ids = map(a -> a.id, minority_group)

    majority_group = filter(a -> a.group == 2, allagents(model))
    majority_ids = map(a -> a.id, majority_group)

    # Calculate number of edges of different types to add to the network.
    E = model.nagents * model.mean_degree
    E_min = model.nagents * model.min_group_cutoff * model.mean_degree
    E_maj = E - E_min

    E_min_ingroup = round(Int, E_min * ((1 + model.min_homophily) / 2.0))
    E_min_outgroup = E_min - E_min_ingroup

    E_maj_ingroup = round(Int, E_maj * ((1 + model.maj_homophily) / 2.0))
    E_maj_outgroup = E_maj - E_maj_ingroup

    # Add a random 'learns-from' tie for each agent in minority group to another
    # in-group member to ensure fully-connected populations.
    for min_id in minority_ids
        possible_teacher_ids = filter!(a -> a.id ≠ min_id, minority_ids)
        selected_teacher = sample(possible_teacher_ids)
        add_edge!(network, min_id, selected_teacher)
    end
    # Add the remaining in-minority-group ties.
    remaining_min_ingroup = E_min_ingroup - length(minority_ids)
    for _ in 1:remaining_min_ingroup

        # Generate a new edge that may already exist in social network.
        new_edge = (sample(minority_ids), sample(minority_ids)) 

        # If edge already exists, re-sample until new edge is generated.
        while has_edge(network, new_edge)
            new_edge = (sample(minority_ids), sample(minority_ids)) 
        end
        
        # Add new edge to the network.
        add_edge!(network, new_edge)
    end

    # Add a random 'learns-from' tie for each agent in majority group to another
    # in-group member to ensure fully-connected populations.
    for maj_id in majority_ids
        possible_teacher_ids = filter!(a -> a.id ≠ maj_id, majority_ids)
        selected_teacher = sample(possible_teacher_ids)
        add_edge(network, maj_id, selected_teacher)
    end
    # Add the remaining in-majority-group ties.
    remaining_maj_ingroup = E_maj_ingroup - length(majority_ids)
    for _ in 1:remaining_maj_ingroup

        # Generate a new edge that may already exist in social network.
        new_edge = (sample(majority_ids), sample(majority_ids)) 

        # If edge already exists, re-sample until new edge is generated.
        while has_edge(network, new_edge)
            new_edge = (sample(majority_ids), sample(majority_ids)) 
        end
        
        # Add new edge to the network.
        add_edge!(network, new_edge)
    end

    ## Now add out-group edges.
    # Add minority-learns-from-majority edges.
    resample = true
    for _ in 1:E_min_outgroup
        while resample
            # Select random learner from minority group...
            learner = sample(minority_ids)
            # ...and a teacher from the majority group...
            teacher = sample(majority_ids)

            resample = !has_edge(network, learner, teacher)
        end
        # Add the edge to the network if it doesn't exist yet.
        add_edge!(network, learner, teacher) 
    end
    # Add majority-learns-from-minority edges.
    for _ in 1:E_maj_outgroup
        # Select random learner from majority group...
        learner = sample(majority_ids)
        # ...and a teacher from the minority group.
        teacher = sample(minority_ids)

        resample = !has_edge(network, learner, teacher)
    end

    # Update agents with their teachers to simplify teacher lookups.
    edges = network.fadjlist
    for (idx, agent) in enumerate(agents(model))
        agent.teachers = edges[idx]
    end
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

