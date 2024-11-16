# This file is a part of BinnedModels.jl, licensed under the MIT License (MIT).

"""
    abstract type BinningAlgorithm

Abstract type for for algorithms that determine a suitable binning for a
given set of data.
"""
abstract type BinningAlgorithm end
export BinningAlgorithm


"""
    fit_binedges(data::AbstractVector{<:Real})::BinEdges
    fit_binedges(data::NTuple{N,AbstractVector{<:Real}})::NTuple{N,BinEdges}

Return suitable bin edges for `data`, using `algorithm`.

`data` may be a real-valued vector, or a tuple of real-valued vectors
for multi-dimensional data.
"""
function fit_binedges end
export fit_binedges

function fit_binedges(data::AbstractVector{<:Real}, algorithm::BinningAlgorithm)
    only(fit_binedges((data,), algorithm))
end

function fit_binedges(data::NTuple{N,AbstractVector{<:Real}}, algorithm::BinningAlgorithm) where N
    vs = data

    n_samples = length(LinearIndices(first(vs)))

    # The nd estimator is the key to most automatic binning methods, and is modified for twodimensional histograms to include correlation
    nd = n_samples^(1/(2+N))
    nd = N == 2 ? min(n_samples^(1/(2+N)), nd / (1-cor(first(vs), last(vs))^2)^(3//8)) : nd # the >2-dimensional case does not have a nice solution to correlations

    edges = map(vs) do v
        nbins::Int = _get_bining_impl(algorithm, n_samples, nd, v)
        range(minimum(v), maximum(v), length = nbins + 1)
    end

    return edges
end

function StatsBase.fit(::Type{Histogram{T}}, data::NTuple{N,AbstractVector{<:Real}}, algorithm::BinningAlgorithm; closed::Symbol=:left) where {T,N}
    edges = fit_binedges(data, algorithm)
    fit(Histogram{T}, data, edges; closed = closed)
end

function StatsBase.fit(::Type{Histogram{T}}, data::AbstractVector{<:Real}, algorithm::BinningAlgorithm; closed::Symbol=:left) where T
    edges = fit_binedges(data, algorithm)
    fit(Histogram{T}, data, edges; closed = closed)
end

function StatsBase.fit(::Type{Histogram}, data::NTuple{N,AbstractVector{<:Real}}, algorithm::BinningAlgorithm; closed::Symbol=:left) where N
    edges = fit_binedges(data, algorithm)
    fit(Histogram, data, edges; closed = closed)
end

function StatsBase.fit(::Type{Histogram}, data::AbstractVector{<:Real}, algorithm::BinningAlgorithm; closed::Symbol=:left)
    edges = fit_binedges(data, algorithm)
    fit(Histogram, data, edges; closed = closed)
end


const _max_auto_n_bins = 10_000
_autobinning_cl(x) = min(ceil(Int, max(x, one(x))), _max_auto_n_bins)



"""
    FixedNBins(nbins::Int)

Selects a fixed number of bins.

Constructor: `$(FUNCTIONNAME)(; fields...)`

Fields:

$(TYPEDFIELDS)
"""
@kwdef struct FixedNBins <: BinningAlgorithm
    nbins::Int = 200
end
export FixedNBins

function _get_bining_impl(algorithm::FixedNBins, n_samples, nd, v)
    algorithm.nbins
end


"""
    struct SquareRootBinning <: BinningAlgorithm

Selects automatic binning based on the
[Square-root choice](https://en.wikipedia.org/wiki/Histogram#Square-root_choice).

Constructor: `SquareRootBinning()`
"""
struct SquareRootBinning <: BinningAlgorithm end
export SquareRootBinning

function _get_bining_impl(::SquareRootBinning, n_samples, nd, v)
    _autobinning_cl(sqrt(n_samples))
end


"""
    struct SturgesBinning <: BinningAlgorithm

Selects automatic binning based on
[Sturges' formula](https://en.wikipedia.org/wiki/Histogram#Sturges'_formula).

Constructor: `SturgesBinning()`
"""
struct SturgesBinning <: BinningAlgorithm end
export SturgesBinning

function _get_bining_impl(::SturgesBinning, n_samples, nd, v)
    _autobinning_cl(log2(n_samples) + 1)
end


"""
    struct RiceBinning <: BinningAlgorithm

Selects automatic binning based on the
[Rice rule](https://en.wikipedia.org/wiki/Histogram#Rice_Rule).

Constructor: `RiceBinning()`
"""
struct RiceBinning <: BinningAlgorithm end
export RiceBinning

function _get_bining_impl(::RiceBinning, n_samples, nd, v)
    _autobinning_cl(2 * nd)
end


"""
    struct ScottBinning <: BinningAlgorithm

Selects automatic binning based on
[Scott's normal reference rule](https://en.wikipedia.org/wiki/Histogram#Scott's_normal_reference_rule).

Constructor: `ScottBinning()`
"""
struct ScottBinning <: BinningAlgorithm end
export ScottBinning

function _get_bining_impl(::ScottBinning, n_samples, nd, v)
    _autobinning_cl((maximum(v) - minimum(v)) / (3.5 * std(v) / nd))
end


"""
    struct FreedmanDiaconisBinning <: BinningAlgorithm

Selects automatic binning based on the
[Freedman–Diaconis](https://en.wikipedia.org/wiki/Freedman%E2%80%93Diaconis_rule) rule.

Constructor: `FreedmanDiaconisBinning()`
"""
struct FreedmanDiaconisBinning <: BinningAlgorithm end
export FreedmanDiaconisBinning

# Freedman–Diaconis rule
function _get_bining_impl(::FreedmanDiaconisBinning, n_samples, nd, v)
    _iqr(v) = (q = quantile(v, 0.75) - quantile(v, 0.25); q > 0 ? q : oftype(q, 1))
    _autobinning_cl((maximum(v) - minimum(v)) / (2 * _iqr(v) / nd))
end
