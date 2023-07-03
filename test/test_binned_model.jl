# This file is a part of BinnedModels.jl, licensed under the MIT License (MIT).

using BinnedModels
using Test

using Random, LinearAlgebra, Statistics
using StatsBase, Distributions


@testset "binned_models" begin
    par_truth = (
        mu = [-0.7, 1.5],
        sigma = 0.6,
        rate = [2389, 5923]
    )

    data_hist = let par=par_truth
        total_rate = sum(par.rate)
        d = MixtureModel(Normal.(par.mu, par.sigma), inv(total_rate) * par.rate)
        events = rand(d, rand(Poisson(total_rate)))
        fit(Histogram, events)
    end

    f_expectation = function (par)
        total_rate = sum(par.rate)
        d = MixtureModel(Normal.(par.mu, par.sigma), inv(total_rate) * par.rate)
        return x -> total_rate * pdf(d, x)
    end

    #=
    using Plots
    plot(-3:0.01:4, f_expectation(par_truth))
    plot!(normalize(data_hist, mode = :density), lt = :stepbins)
    =#

    likelihood = binned_likelihood(f_expectation, data_hist)
    
    # @test @inferred(logdensityof(likelihood, par_truth)) isa Real
    @test logdensityof(likelihood, par_truth) isa Real
end
