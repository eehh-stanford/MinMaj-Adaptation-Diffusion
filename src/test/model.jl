using Random, Test
 
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
                  homophily = 0.0, a_fitness = 2.0)

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

    ntrials = 10000

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

        expected_K_min = 15; expected_K_maj = 30; 
        expected_K = expected_K_min + expected_K_maj
        
        N = 15; min_group_frac = 1./3.; h_min = 1./3.; h_maj = 2./3.;

        expected_min_maj_edge_count = expected_maj_min_edge_count = 5

        m = adaptation_diffusion_model(N; min_group_frac = min_group_frac, 
                                       min_homophily = h_min, 
                                       maj_homophily = h_maj, 
                                       network = true,
                                       mean_degree = 3
                                      )
        
        # Still using group 1 to indicate Minority group, 2 for Majority.
        minority_agents = filter(agent -> agent.group == 1, allagents(model))
        n_teachers_minority = sum([agent -> length(agent.teachers) for agent in
                                   filter(agent -> agent.group == 1, 
                                          allagents(model))
                                  ])

        majority_agents = filter(agent -> agent.group == 2, allagents(model))
        n_teachers_majority = sum([agent -> length(agent.teachers) for agent in
                                   majority_agents
                                  ])
        
        @test n_teachers_minority == expected_K_min
        @test n_teachers_majority == expected_K_maj

        minoritys_teachers = 
            collect(Iterators.flatten([agent.teachers for agent in minority_agents]))
        majoritys_teachers = 
            collect(Iterators.flatten([agent.teachers for agent in majority_agents]))

        # There should be 5 majority-group teachers for the minority group...

        # and 5 minority-group teachers for the majority group.
    end
    # @testset "Teacher-group and teacher selection works for extreme homophily values (networked)" begin
    
    #     m = adaptation_diffusion_model(4; min_group_frac = 0.5, 
    #                                    min_homophily = 0.75, 
    #                                    maj_homophily = 0.25, 
    #                                    a_fitness = 1e2,
    #                                    network = true
    #                                   )
    #     # @test false

    # end

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
    
    @testset "Asymmetric homophily produces correct teacher selection stats, non-networked (Agent $ii)" for ii in 1:4
        # @test false
    end

end
