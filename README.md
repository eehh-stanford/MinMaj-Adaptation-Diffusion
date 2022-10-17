# Social factors in community-based adaptation sustainability

This repository contains code and supporting documentation for Jones lab's work
identifying the effect of various social, cultural, and technological factors on
the sustainability of community-based adaptations. For more details on how the
model works, see the final section in this README.


## Quick start

To get started, clone this repository, e.g., execute the following in the
terminal: 

```
git clone https://github.com/mt-digital/SustainableCBA.git
```

After cloning the repository, install all dependencies by first starting the
[Julia REPL](https://docs.julialang.org/en/v1/stdlib/REPL/) then run

```
julia> using Pkg; Pkg.activate("."); Pkg.instantiate()
```

While still in the REPL, run the unit tests to make sure all is working well:

```
julia> include("src/test/model.jl")
```

This should print two "Test Summary" outputs where all tests are shown to pass.
The tests initialize specially-initialized models and checks that model outputs
are as expected. 

# Run the model and analyze results

The code is separated in two main components: (1) model runs over the model
parameter space; and (2) analyzing model outputs. Create a directory, `plots/outline`, in order to save output plots from the script run as follows.

To run the model with a given number of agents, group size, and fitness value of trait $a$, for
a given number of replicates and homophily values, you can use the `sustainability_vs_homophily`
function in the [scripts/outline_analysis.jl](/scripts/outline_analysis.jl) file. This function will 
run the `homophily_minority_experiment` in [/src/experiment.jl](/src/experiment.jl). This
function will automatically process output data from the `homophily_minority_experiment` for plotting
"sustainability" over each tested homophily value. Sustainability is calculated as the fraction of 
trials that had $a$ go to fixation (adopted by entire population) for the relevant parameter batch. 

Currently, one must manually run `sustainability_vs_homophily` over each desired value of $f(a)$, each 
minority size setting, and start the adaptive trait in both the minority and majority groups in each case
to reproduce the figures in our current outline. This process is in the process of being automated.

After that is done, however, one can use the `sustainability_comparison` function (also in [/scripts/outline_analysis.jl](/scripts/outline_analysis.jl)) to plot the data. The data currently are set by default to be saved to `data/outline`. Note in the `sustainability_function` that the four $f(a)$ values must match those currently presented in our outline.

## Computational experiments for a batch of parameters

A computational experiment involves running a model over many parameter settings, which we could call a batch of parameters. In this code we use the [`ensemblerun!` function provided by Agents.jl](https://juliadynamics.github.io/Agents.jl/stable/api/#Agents.ensemblerun!).

## Single-parameter setting model runs

We can run models one at a time, or in batches according to sets of parameters
to systematically vary to understand their effect on agent behavior and model
outcomes. To do this, initialize a model using the [`cba_model` function](https://github.com/mt-digital/SustainableCBA/blob/main/src/model.jl#L72) in [/src/model.jl](/src/model.jl).


# Model motivation and operation

We developed this model to understand how group structure might affect the
sustainability of community-based adaptations (CBAs). Community-based
adaptations seek to build grassroots adaptive capacity to environmental change,
especially in response to climate change. Group structure is operationalized 
as homophily and relative group size. We want to understand how group
structure affects the evolution of a beneficial
adaptation in a meta-population composed of two groups. 

## Model

We model people as computational _agents_ in this agent-based model.
The model assumes there are two groups of $N$ agents total. One group is the
minority with $mN$ agents, and the majority has $(1-m)N$ agents. The 
probability that agents interact with one another is determined via the 
global _homophily_, $h$. (More details to come; for now see model details by viewing [/src/model.jl](/src/model.jl).
