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
import StatsBase
using StatsBase: Histogram, fit
using StructArrays: StructArray, StructVector

include("binning.jl")
include("binning_algorithm.jl")
include("binned_model.jl")

end # module
