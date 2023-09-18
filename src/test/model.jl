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

    @testset "Teacher-group and teacher selection works for extreme homophily values" begin
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

    @testset "Asymmetric homophily produces correct teacher selection stats (Agent $ii)" for ii in 1:4

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

end
