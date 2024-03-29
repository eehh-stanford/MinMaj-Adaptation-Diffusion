## Summary

This repository contains code and supporting documentation for the agent-based model analyzed in our paper, "Minority-group incubators and majority-group reservoirs for climate change adaptation". We performed and analyzed a suite of agent-based models that simulated the spread of an _adaptation_, i.e., a beneficial behavior, in a population with a minority and majority group, defined by group size and tendency to interact with others from one's own group versus another group (_homophily_). We ran 1000 trials per parameter setting, where parameters were systematically varied to test different homophily levels in each group, and the effect of whether the minority group, majority group, or both groups start with one member knowing the adaptation. The adaptation either spread from one agent in one or both groups to the rest of the members of both groups in the case of adaptation success, or the adaptation disappeared from the entire population (adaptation failure). We then calculated the success rate across all 1000 trials. We also measured the mean time to either adaptive success or failure.


## Description of the data and file structure

The data is broken out into several CSV files that were each the result of one
cluster node's simulations. There are two main archives of CSV files: (1) `main_parts.zip` contains 30 CSV output files used in the main text analysis; and (2) `supp.zip` contains 270 CSV output files used in the supplemental analyses. The R analysis code (`scripts/plot.R`) contains utilities for combining and processing this raw output. See the `Analysis` subsection below for more information on the data combination and processing steps.


## Sharing/access information

The model and analysis code is also hosted as an active GitHub repository:
https://github.com/eehh-stanford/MinMaj-Adaptation-Diffusion. The data is also
available via OSF: https://osf.io/cd9hx/.


## Code/Software

### Quick start

To get started, clone this repository, e.g., execute the following in the
terminal: 

```
git clone https://github.com/eehh-stanford/SustainableCBA.git
```

After cloning the repository, install all dependencies by first starting the
[Julia REPL](https://docs.julialang.org/en/v1/stdlib/REPL/) then run

```
julia> using Pkg; Pkg.activate("."); Pkg.instantiate()
```

### Unit tests

We developed our model using test-driven development, which uses small, executable code snippets to confirm the model works as expected and to document model mechanics; see [`src/test/model.jl`](https://github.com/eehh-stanford/SustainableCBA/blob/main/src/test/model.jl) to view the test suite.

While still in the REPL, run the unit tests to make sure all is working well:

```
julia> include("src/test/model.jl")
```

This should print two "Test Summary" outputs where all tests are shown to pass.
The tests initialize specially-initialized models and checks that model outputs
are as expected. 

### Run the model and analyze results

#### Model and computational experiments

The model is implemented in [`src/model.jl`](src/model.jl) and the computational experiments that run the model over all parameter settings for the desired number of trials and used by the Slurm scripts (below) is in [`src/experiment.jl`](src/experiment.jl).

#### Run all simulations on Slurm cluster

To run simulations on a Slurm cluster, log in to the cluster then execute the following commands from the project directory, first
```
./scripts/slurm/main.sh
```
to run the main analyses, and
```
./scripts/slurm/supplement.sh
```
to run the supplemental analyses. This creates a fresh, distinct version of simulation results that can be analyzed as we explain below, using archived data of the simulations used to create our results in the submitted version of the paper.

### Analysis

Use `main_asymm_heatmaps` to create the main heatmap results of _success rate_ as a function of $h_\mathrm{min}$ and $h_\mathrm{maj}$, which can be found in [`scripts/plot.R`](https://github.com/eehh-stanford/SustainableCBA/blob/main/scripts/plot.R#L72). For creating the heatmaps of average time to model fixation, pass the keyword argument `measure = "step"` to `main_asymm_heatmaps`. Similarly, to create supplemental analyses use the `supp_asymm_heatmaps` function in [`scripts/plot.R`](https://github.com/eehh-stanford/SustainableCBA/blob/main/scripts/plot.R#L15).

To create the heatmaps you need the output data from the simulations presented in our journal article, stored in the `data` folder in the root project directory. To get the data in the right place, first create a `data` directory, then download and unzip the two zip files in our OSF repository: https://osf.io/cd9hx/. 

To create time series of individual model runs, use the `make_all_group_prevalence_comparisons` function in [`scripts/analysis.jl`](https://github.com/eehh-stanford/SustainableCBA/blob/main/scripts/analysis.jl#L290).
