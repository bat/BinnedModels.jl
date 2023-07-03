# This file is a part of BinnedModels.jl, licensed under the MIT License (MIT).

"""
    BinnedModels

A Julia package for statistical modeling of binned data, e.g. histograms.
"""
module BinnedModels

using Statistics

using ArgCheck
using DocStringExtensions

using IntervalSets: AbstractInterval, Interval, leftendpoint, rightendpoint
using DensityInterface: logdensityof, logfuncdensity, DensityKind, IsDensity, HasDensity, NoDensity
using Distributions: product_distribution, Poisson
using StatsBase: Histogram
using StructArrays: StructArray, StructVector

include("binning.jl")
include("binned_model.jl")

end # module
