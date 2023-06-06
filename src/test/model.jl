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


@testset verbose = true "Calculation of perceived fitness as expected" begin


    @testset "fitness adjustment calculated as expected" begin

        # Basic.
        @test fitness_adjustment(0) == 0
        @test fitness_adjustment(1) == 1
        @test fitness_adjustment(0.5) == 0.5

        # Test use of group_freq_midpoint.
        @test fitness_adjustment(0; group_freq_midpoint = 0.25) == 0.0
        @test fitness_adjustment(1; group_freq_midpoint = 0.25) == 1.0
        @test fitness_adjustment(0.25; group_freq_midpoint = 0.25) == 0.5

        # Test use of b parameter.
        @test fitness_adjustment(0; b = 2) == 0
        @test fitness_adjustment(1; b = 2) == 1
        @test fitness_adjustment(0.5; b = 2) == 0.5

        # Test use of both kwargs.
        @test fitness_adjustment(0; group_freq_midpoint = 0.25, b = 5) == 0.0
        @test fitness_adjustment(1; group_freq_midpoint = 0.25, b = 5) == 1.0
        @test fitness_adjustment(0.25; group_freq_midpoint = 0.25, b = 5) == 0.5

    end
end
