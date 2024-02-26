using Random, Test

using Graphs: is_weakly_connected

using DrWatson
 
include("../model.jl")

# Somehow seed is constant if this is not included and tests are run through REPL,
# so we have to set a new one for each time tests are `include`d in REPL.
Random.seed!()


@testset "Groups are initialized as expected" begin

    m = adaptation_diffusion_model(4; min_group_frac = 0.5, homophily = 0.0, a_fitness = 2.0)

    agents = collect(allagents(m))
    @test length(agents) == 4

    ngroup1 = length(filter(agent -> agent.group == 1, agents))
    ngroup2 = length(filter(agent -> agent.group == 2, agents))

    @test ngroup1 == 2 
    @test ngroup1 == ngroup2 

    @test m[1].group == 1
    @test m[2].group == 1
    @test m[3].group == 2
    @test m[4].group == 2

    @test m[1].curr_trait == a
    @test m[2].curr_trait == A
@test m[3].curr_trait == A
    @test m[4].curr_trait == A

    m = adaptation_diffusion_model(4; min_group_frac = 0.25, group_w_innovation = 2, 
                  a_fitness = 2.0)

    @test m[1].group == 1
    @test m[2].group == 2
    @test m[3].group == 2
    @test m[4].group == 2

    @test m[1].curr_trait == A
    @test m[2].curr_trait == a
    @test m[3].curr_trait == A
    @test m[4].curr_trait == A
end


@testset verbose = true "Teacher selection and learning works as expected" begin

    ntrials = 5000

    @testset "Teacher-group and teacher selection works for extreme homophily values (non-networked)" begin
        m = adaptation_diffusion_model(4; min_group_frac = 0.25, min_homophily = 1.0, maj_homophily = 1.0,
                      a_fitness = 2.0)
        
        @test sample_group(m[1], m) == 1
        @test sample_group(m[2], m) == 2
        @test sample_group(m[3], m) == 2
        @test sample_group(m[4], m) == 2

        # m = adaptation_diffusion_model(4; min_group_frac = 0.25, homophily = 0.0, a_fitness = 1e9)
        m = adaptation_diffusion_model(4; min_group_frac = 0.25, min_homophily = 0.0, maj_homophily = 0.0, 
                         a_fitness = 1e9)
        
        for aidx in 1:4
            group_counts = Dict(1 => 0, 2 => 0)
            for _ in 1:ntrials
                group_counts[sample_group(m[aidx], m)] += 1
            end
            @test group_counts[1] ≈ ntrials/2.0 rtol=0.1
            @test group_counts[2] ≈ ntrials/2.0 rtol=0.1
        end
    end

    # Confirm groups are initialized as expected and that teacher selection 
    # works as expected for asymmetric, non-zero homophily. 
    m = adaptation_diffusion_model(4; min_group_frac = 0.5, min_homophily = 0.75, 
                     maj_homophily = 0.25, a_fitness = 1e2)

    agents = collect(allagents(m))

    @testset "Groups properly initialized according to min_group_frac" begin
        group1 = filter(a -> a.group == 1, agents)
        n_group1 = length(group1)

        group2 = filter(a -> a.group == 2, agents)
        n_group2 = length(group2)

        @test n_group1 == 2
        @test n_group2 == 2
    end

    @testset "Social networks properly initialized according to global mean degree and homophily settings" begin

        expected_E_min = 15; expected_E_maj = 30; 
        expected_E = expected_E_min + expected_E_maj
        
        N = 15; min_group_frac = 1.0/3.0; h_min = 1.0/3.0; h_maj = 2.0/3.0;

        expected_min_maj_edge_count = expected_maj_min_edge_count = 5

        model = adaptation_diffusion_model(N; min_group_frac = min_group_frac, 
                                           min_homophily = h_min, 
                                           maj_homophily = h_maj, 
                                           use_network = true,
                                           mean_degree = 3
                                          )

        agents = collect(allagents(model))

        # Still using group 1 to indicate Minority group, 2 for Majority.
        minority_agents = filter(agent -> agent.group == 1, agents)
        minoritys_teachers = 
            collect(Iterators.flatten([agent.teachers 
                                       for agent in collect(minority_agents)]))

        n_minoritys_teachers = length(minoritys_teachers)
        @test n_minoritys_teachers == expected_E_min

        majority_agents = filter(agent -> agent.group == 2, agents)
        majoritys_teachers = 
            collect(Iterators.flatten([agent.teachers 
                                       for agent in collect(majority_agents)]))

        n_majoritys_teachers = length(majoritys_teachers)
        @test n_majoritys_teachers == expected_E_maj
        
        # There should be 5 majority-group teachers for the minority group...
        n_cross_group_teachers = 5

        @test n_cross_group_teachers == 
            length(filter(teacher -> teacher > 5, 
                          collect(Iterators.flatten(map(a -> a.teachers, 
                              filter(a -> a.group == 1, agents)
                             )))
                         )
                  )
                                               
        # and 5 minority-group teachers for the majority group.
        @test n_cross_group_teachers == 
            length(filter(teacher -> teacher < 6, 
                          collect(Iterators.flatten(map(a -> a.teachers, 
                              filter(a -> a.group == 2, agents)
                             )))
                         )
                  )
    end

    @testset "Asymmetric homophily produces correct teacher selection stats, non-networked (Agent $ii)" for ii in 1:4

        teachers_selected = [
            select_teacher(m[ii], m, sample_group(m[ii], m))
            for _ in 1:ntrials
        ]

        @test ii ∉ map(a -> a.id, teachers_selected)

        # Contants below multiplying ntrials calculated
        # from homophily values given above.
        if ii ∈ [1, 2]
            @test length(filter(a -> a.group == 1, teachers_selected)) ≈ (0.875 * ntrials) rtol=0.1
            @test length(filter(a -> a.group == 2, teachers_selected)) ≈ (0.125 * ntrials) rtol=0.1
        else
            @test length(filter(a -> a.group == 1, teachers_selected)) ≈ (0.375 * ntrials) rtol=0.1
            @test length(filter(a -> a.group == 2, teachers_selected)) ≈ (0.625 * ntrials) rtol=0.1
        end

    end


    @testset "Adaptive trait always fixates when f(a)=1e6,f(A)=0.1" begin

        function stopfn_fixated(model, step)
            agents = allagents(model) 

            return (
                all(agent.curr_trait == a for agent in agents) || 
                all(agent.curr_trait == A for agent in agents)
            )
        end
        
        model = adaptation_diffusion_model(1000; 
                                           min_group_frac = 0.2, 
                                           group_w_innovation = 1,
                                           min_homophily = 0.5, 
                                           maj_homophily = 0.5, 
                                           use_network = true,
                                           a_fitness = 1e6,
                                           A_fitness = 0.1,
                                           mean_degree = 9.0
                                          )

        _, _ = run!(model, agent_step!, model_step!, stopfn_fixated)
        @test all(agent -> agent.curr_trait == a, allagents(model))

        model = adaptation_diffusion_model(1000; 
                                           min_group_frac = 0.5, 
                                           group_w_innovation = 2,
                                           min_homophily = 0.5, 
                                           maj_homophily = 0.5, 
                                           use_network = true,
                                           a_fitness = 1e6,
                                           A_fitness = 0.1,
                                           mean_degree = 9.0
                                          )

        _, _ = run!(model, agent_step!, model_step!, stopfn_fixated)
        @test all(agent -> agent.curr_trait == a, allagents(model))

        model = adaptation_diffusion_model(1000; 
                                           min_group_frac = 0.5, 
                                           group_w_innovation = "Both",
                                           min_homophily = 0.5, 
                                           maj_homophily = 0.5, 
                                           use_network = true,
                                           a_fitness = 1e6,
                                           A_fitness = 0.1,
                                           mean_degree = 9.0
                                          )

        _, _ = run!(model, agent_step!, model_step!, stopfn_fixated)
        @test all(agent -> agent.curr_trait == a, allagents(model))

    end
end


@testset verbose = true "Network initialized as expected" begin

    param_values = Dict(
        :min_group_frac => [0.05, 0.2, 0.35, 0.5],
        :a_fitness => [1.2],
        :nagents => [500, 1000, 2000],
        # :nagents => [50, 100, 1000],
        # :nagents => [100, 1000],
        :mean_degree => [3, 6, 9],
        :min_homophily => collect(0.0:0.1:0.9),
        :maj_homophily => collect(0.0:0.1:0.9),
        :use_network => [true]
    )

    param_dict_list = dict_list(param_values)

    @testset "Network is complete across a range of sensitivity param values" begin
        
        for param_setting in param_dict_list
        # for param_setting in param_dict_list[1:100] ## TODO remove for full test after harmonizing network construction in code with description
            nagents = pop!(param_setting, :nagents)
            models = [adaptation_diffusion_model(nagents; param_setting...)]
            @test all([is_weakly_connected(model.network) for model in models])
        end
    end
end
