# Test that extremal group fraction, homophily, and fitness values result in 
# expected trait prevalences, see below for example:

m = cba_model(100; a_fitness = 1.75, A_fitness=1.0, 
              group_1_frac = 0.2, homophily = 1.0, group_w_innovation = 2)

adata = [(:curr_trait, countmap), 
         (:curr_trait, v -> sum(v .== a) / length(v))]

adf, mdf = run!(m, agent_step!, model_step!, 50; adata)

# Final step of first adf col should be A=>20, a=>80; last adf col should be 0.8.
