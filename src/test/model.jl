using Test
 
include("../model.jl")

@testset "Groups are initialized as expected" begin

    m = cba_model(4; group_1_frac = 0.5, homophily = 0.0, a_fitness = 2.0)

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

    m = cba_model(4; group_1_frac = 0.25, group_w_innovation = 2, 
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


@testset "Teacher selection and learning works as expected" begin

    m = cba_model(4; group_1_frac = 0.25, homophily = 1.0, a_fitness = 2.0)
    
    @test sample_group(m[1], m) == 1
    @test sample_group(m[2], m) == 2
    @test sample_group(m[3], m) == 2
    @test sample_group(m[4], m) == 2

    # m = cba_model(4; group_1_frac = 0.25, homophily = 0.0, a_fitness = 1e9)
    m = cba_model(4; group_1_frac = 0.25, homophily_1 = 0.0, homophily_2 = 0.0, a_fitness = 1e9)
    
    ntrials = 1e4
    for aidx in 1:4
        group_counts = Dict(1 => 0, 2 => 0)
        for _ in 1:ntrials
            group_counts[sample_group(m[aidx], m)] += 1
        end

        @test group_counts[1] ≈ ntrials/2.0 rtol=0.1
        @test group_counts[2] ≈ ntrials/2.0 rtol=0.1
    end

    ntrials = 100

    m[2].curr_trait = a
    m[3].curr_trait = A
    m[4].curr_trait = a
    for _ in 1:ntrials
        t = select_teacher(m[2], m, 2)
        @test t == m[4]
    end

    # TODO write tests of which agents are selected and whether learner learns
    # teacher's trait. Can use 3-person groups for extreme simplicity. 
    # GOAL: understand why majority group homophily seems to dominate, when 
    # it seems like minority group homophily is most important. 

end
