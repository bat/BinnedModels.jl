# This file is a part of BinnedModels.jl, licensed under the MIT License (MIT).

using BinnedModels
using Test

using Random, Statistics, StatsBase, DensityInterface
using IntervalSets
using StructArrays


@testset "binning" begin
    edges = [-0.7, 0.2, 0.1, 1.7, 4.9]

    @test @inferred(bin_intervals(edges)) isa StructVector
    @test bin_intervals(edges) == (b-> Interval{:closed, :open}(b[1], b[2])).([(-0.7, 0.2), (0.2, 0.1), (0.1, 1.7), (1.7, 4.9)])

    binning = bin_intervals(edges)

    @test @inferred(bin_leftedges(binning)) == [-0.7, 0.2, 0.1, 1.7]
    @test @inferred(bin_leftedges(collect(binning))) == [-0.7, 0.2, 0.1, 1.7]
    @test @inferred(bin_leftedges(edges)) == [-0.7, 0.2, 0.1, 1.7]

    @test @inferred(bin_rightedges(binning)) == [0.2, 0.1, 1.7, 4.9]
    @test @inferred(bin_rightedges(collect(binning))) == [0.2, 0.1, 1.7, 4.9]
    @test @inferred(bin_rightedges(edges)) == [0.2, 0.1, 1.7, 4.9]

    @test @inferred(bin_centers(binning)) ≈ [-0.25, 0.15, 0.9, 3.3]
    @test @inferred(bin_centers(edges)) ≈ [-0.25, 0.15, 0.9, 3.3]

    @test @inferred(bin_widths(binning)) ≈ [0.9, -0.1, 1.6, 3.2]
    @test @inferred(bin_widths(edges)) ≈ [0.9, -0.1, 1.6, 3.2]
end
