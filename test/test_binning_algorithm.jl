# This file is a part of BinnedModels.jl, licensed under the MIT License (MIT).

using BinnedModels
using Test

using Random, LinearAlgebra, Statistics
using StatsBase, Distributions


@testset "binning_algorithm" begin
    data1 = randn(100)
    data2 = (randn(100), randn(100))

    binalg = FreedmanDiaconisBinning()

    fit_binedges(data1, binalg)

    fit_binedges(data2, binalg)

    for binalg in (
        FixedNBins(),
        FreedmanDiaconisBinning(),
        RiceBinning(),
        ScottBinning(),
        SquareRootBinning(),
        SturgesBinning(),
    )
        @testset "$(nameof(typeof(binalg)))" begin
            @test @inferred(fit_binedges(data1, binalg)) isa BinEdges
            @test @inferred(fit_binedges(data2, binalg)) isa NTuple{2,BinEdges}

            @test  @inferred(fit(Histogram, data1, fit_binedges(data1, binalg))) isa Histogram
            @test  @inferred(fit(Histogram, data2, fit_binedges(data2, binalg))) isa Histogram
            @test  @inferred(fit(Histogram{Float32}, data1, fit_binedges(data1, binalg))) isa Histogram{Float32}
            @test  @inferred(fit(Histogram{Float32}, data2, fit_binedges(data2, binalg))) isa Histogram{Float32}
        end
    end
end
