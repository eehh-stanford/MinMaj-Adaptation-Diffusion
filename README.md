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
parameter space; and (2) analyzing model outputs. 

## Model runs

We can run models one at a time, or in batches according to sets of parameters
to systematically vary to understand their effect on agent behavior and model
outcomes. First, to run the model one at a time


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
global _homophily_, $h$.
