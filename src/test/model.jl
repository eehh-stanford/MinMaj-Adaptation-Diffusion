using Random, Test
 
include("../model.jl")

# Somehow seed is constant if this is not included and tests are run through REPL,
# so we have to set a new one for each time tests are `include`d in REPL.
Random.seed!()


# @testset "Groups are initialized as expected" begin

#     m = cba_model(4; group_1_frac = 0.5, homophily = 0.0, a_fitness = 2.0)

#     agents = collect(allagents(m))
#     @test length(agents) == 4

#     ngroup1 = length(filter(agent -> agent.group == 1, agents))
#     ngroup2 = length(filter(agent -> agent.group == 2, agents))

#     @test ngroup1 == 2 
#     @test ngroup1 == ngroup2 

#     @test m[1].group == 1
#     @test m[2].group == 1
#     @test m[3].group == 2
#     @test m[4].group == 2

#     @test m[1].curr_trait == a
#     @test m[2].curr_trait == A
#     @test m[3].curr_trait == A
#     @test m[4].curr_trait == A

#     m = cba_model(4; group_1_frac = 0.25, group_w_innovation = 2, 
#                   homophily = 0.0, a_fitness = 2.0)

#     @test m[1].group == 1
#     @test m[2].group == 2
#     @test m[3].group == 2
#     @test m[4].group == 2

#     @test m[1].curr_trait == A
#     @test m[2].curr_trait == a
#     @test m[3].curr_trait == A
#     @test m[4].curr_trait == A
# end


# @testset verbose = true "Teacher selection and learning works as expected" begin

#     ntrials = 10000

#     @testset "Teacher-group and teacher selection works for extreme homophily values" begin
#         m = cba_model(4; group_1_frac = 0.25, homophily_1 = 1.0, homophily_2 = 1.0,
#                       a_fitness = 2.0)
        
#         @test sample_group(m[1], m) == 1
#         @test sample_group(m[2], m) == 2
#         @test sample_group(m[3], m) == 2
#         @test sample_group(m[4], m) == 2

#         # m = cba_model(4; group_1_frac = 0.25, homophily = 0.0, a_fitness = 1e9)
#         m = cba_model(4; group_1_frac = 0.25, homophily_1 = 0.0, homophily_2 = 0.0, 
#                          a_fitness = 1e9)

#         for aidx in 1:4
#             group_counts = Dict(1 => 0, 2 => 0)
#             for _ in 1:ntrials
#                 group_counts[sample_group(m[aidx], m)] += 1
#             end
#             @test group_counts[1] ≈ ntrials/2.0 rtol=0.1
#             @test group_counts[2] ≈ ntrials/2.0 rtol=0.1
#         end
#     end

#     # Confirm groups are initialized as expected and that teacher selection 
#     # works as expected for asymmetric, non-zero homophily. 
#     m = cba_model(4; group_1_frac = 0.5, homophily_1 = 0.75, 
#                      homophily_2 = 0.25, a_fitness = 1e2)

#     agents = collect(allagents(m))

#     @testset "Groups properly initialized according to group_1_frac" begin
#         group1 = filter(a -> a.group == 1, agents)
#         n_group1 = length(group1)

#         group2 = filter(a -> a.group == 2, agents)
#         n_group2 = length(group2)

#         @test n_group1 == 2
#         @test n_group2 == 2
#     end

#     @testset "Asymmetric homophily produces correct teacher selection stats (Agent $ii)" for ii in 1:4

#         teachers_selected = [
#             select_teacher(m[ii], m, sample_group(m[ii], m))
#             for _ in 1:ntrials
#         ]

#         @test ii ∉ map(a -> a.id, teachers_selected)

#         # Contants below multiplying ntrials calculated
#         # from homophily values given above.
#         if ii ∈ [1, 2]
#             @test length(filter(a -> a.group == 1, teachers_selected)) ≈ (0.875 * ntrials) rtol=0.1
#             @test length(filter(a -> a.group == 2, teachers_selected)) ≈ (0.125 * ntrials) rtol=0.1
#         else
#             @test length(filter(a -> a.group == 1, teachers_selected)) ≈ (0.375 * ntrials) rtol=0.1
#             @test length(filter(a -> a.group == 2, teachers_selected)) ≈ (0.625 * ntrials) rtol=0.1
#         end

#     end

# end


@testset verbose = true "Calculation of perceived fitness calculations as expected" begin


    # @testset "fitness adjustment calculated as expected" begin

    #     # Basic.
    #     @test fitness_adjustment(0) == 0
    #     @test fitness_adjustment(1) == 1
    #     @test fitness_adjustment(0.5) == 0.5

    #     # Test use of group_freq_midpoint.
    #     @test fitness_adjustment(0; nstar_G_Gprime = 0.25) == 0.0
    # @test fitness_adjustment(1; nstar_G_Gprime = 0.25) == 1.0
    #     @test fitness_adjustment(0.25; nstar_G_Gprime = 0.25) == 0.5

    #     # Test use of b parameter.
    #     @test fitness_adjustment(0; sigmoid_slope = 2) == 0
    #     @test fitness_adjustment(1; sigmoid_slope = 2) == 1
    #     @test fitness_adjustment(0.5; sigmoid_slope = 2) == 0.5

    #     # Test use of both kwargs.
    #     @test fitness_adjustment(0; nstar_G_Gprime = 0.25, sigmoid_slope = 5) == 0.0
    #     @test fitness_adjustment(1; nstar_G_Gprime = 0.25, sigmoid_slope = 5) == 1.0
    #     @test fitness_adjustment(0.25; nstar_G_Gprime = 0.25, sigmoid_slope = 5) == 0.5
    # end

    @testset "frequency of each trait calculated as expected" begin

        model = cba_model(100; group_1_frac = 0.2)
        agents = collect(allagents(model))
        # Get minority group members, remove 
        minority_group = filter(a -> (a.id != 1 && a.group == 1), agents)
        majority_group = filter(a -> a.group == 2, agents)

        # Only initialize 9 since min group member w/ id=1 already has `a`.
        for agent in minority_group[1:9]
            agent.curr_trait = a
        end

        for agent in majority_group[1:10]
            agent.curr_trait = a
        end

        @test trait_frequency(a, minority_group, model) == 9.0/19.0
        @test trait_frequency(a, majority_group, model) == 1.0/8.0
        @test trait_frequency(A, minority_group, model) == 10.0/19.0
        @test trait_frequency(A, majority_group, model) == 7.0/8.0

    end

    @testset "teacher selection operates as expected" begin
        
        # Initialize model with small population for easy numbers.
        nagents = 100
        sigmoid_slope = 1
        fitness_diff_coeff = 0.2

        model_no_homophily = cba_model(nagents; 
                                       group_1_frac = 0.2, homophily_1 = 0.0, 
                                       homophily_2 = 0.0, sigmoid_slope)

        model_high_min_homophily = cba_model(nagents; 
                                       group_1_frac = 0.2, homophily_1 = 0.8, 
                                       homophily_2 = 0.2, sigmoid_slope)

        model_high_maj_homophily = cba_model(nagents; 
                                       group_1_frac = 0.2, homophily_1 = 0.2, 
                                       homophily_2 = 0.8, sigmoid_slope)

        models = [model_no_homophily, 
                  model_high_min_homophily, 
                  model_high_maj_homophily]

        # Initialize traits in each population 
        for model in models

            agents = collect(allagents(model))

            # Get minority group members, remove agent with id 1 since it
            # already has been initialized with adaptive behavior.
            minority_group = filter(a -> (a.id != 1 && a.group == 1), agents)
            majority_group = filter(a -> a.group == 2, agents)

            # Only initialize 9 since min group member w/ id=1 already has `a`.
            for agent in minority_group[1:9]
                agent.curr_trait = a
            end

            for agent in majority_group[1:10]
                agent.curr_trait = a
            end
        end

        # Test whether, for a given agent, teacher selection operates as expected.
        ## Minority group learner agent with adaptive trait, no homophily.
        model = model_no_homophily
        min_min_a_adjustment = 0.2 * ((10.0/19.0)^(-log10(2)/log10(0.25)))  # 
        adaptive_perceived_fitness_minority = 1.1 + min_min_a_adjustment

        min_min_A_adjustment = 0.2 * ((9.0/19.0)^(-log10(2)/log10(0.25)))  # 
        nonadaptive_perceived_fitness_minority = 0.9 + min_min_A_adjustment

        learner_agent = first(filter(agent -> agent.curr_trait == A, 
                                     model.properties[:minority_group])
                             )

        # If learner agent has non-adaptive trait there are 9 others with non-adaptive.
        total_fitness = (10 * adaptive_perceived_fitness_minority) + 
                        (9 * nonadaptive_perceived_fitness_minority) 

        ntrials = 10e3
        selected_teachers = [select_teacher(learner_agent, model, 1)
                             for _ in 1:ntrials]

        expected_adaptive_teacher_freq = 10 * (adaptive_perceived_fitness_minority / total_fitness)
        expected_nonadaptive_teacher_freq = 9 * (nonadaptive_perceived_fitness_minority / total_fitness)

        actual_adaptive_teacher_freq = 
            length(filter(teacher -> teacher.curr_trait == a, selected_teachers)) /
            ntrials

        actual_nonadaptive_teacher_freq = 
            length(filter(teacher -> teacher.curr_trait == A, selected_teachers)) /
            ntrials

        @test expected_adaptive_teacher_freq ≈ actual_adaptive_teacher_freq
        @test expected_nonadaptive_teacher_freq ≈ actual_nonadaptive_teacher_freq

        ## Minority group agent with adaptive trait, high min homophily.
        ### TODO

        ## Minority group agent with adaptive trait, high maj homophily.
        ### TODO
        

        ## Minority group agent with non-adaptive trait.
        ### TODO

        ## Majority group agent with adaptive trait.
        ### TODO

        ## Majority group agent with non-adaptive trait.
        ### TODO
    end
end
