# This file is a part of BinnedModels.jl, licensed under the MIT License (MIT).

using MeasureBase: Likelihood
using DensityInterface

@testset "binned_models" begin
    par_truth = (
        mu = [-1.0, 2.0],
        sigma = 0.5,
        rate = [500, 1000]
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

    @test @inferred(binned_model(f_expectation, data_hist.edges)) isa BinnedModels.BinnedModel
    m = binned_model(f_expectation, data_hist.edges)

    likelihood = Likelihood(m, data_hist.weights)
    @test @inferred(logdensityof(likelihood, par_truth)) == logpdf(m(par_truth), data_hist.weights)

    @test @inferred(binned_likelihood(f_expectation, data_hist)) isa DensityInterface.LogFuncDensity
    likelihood = binned_likelihood(f_expectation, data_hist)
    @test @inferred(logdensityof(likelihood, par_truth)) == logpdf(m(par_truth), data_hist.weights)
end
