# This file is a part of BinnedModels.jl, licensed under the MIT License (MIT).


"""
    struct BinnedModels.BinnedModel

Respresents a statistical model for binned data.

User code should not instantiate `BinnedModel` directly, but use
[`binned_model`](@ref) instead.
"""
struct BinnedModel{F<:Function, E<:Tuple{Vararg{Binning}}} <: Function
    f_expectation::F
    binning::E
end

function BinnedModel(f_expectation, edges::Tuple{Vararg{Binning}})
    BinnedModel{Core.Typeof(f_expectation),Core.Typeof(edges)}(f_expectation, edges)
end

function BinnedModel(f_expectation, edges::Tuple{Vararg{BinEdges}})
    BinnedModel(f_expectation, bin_intervals.(edges))
end


_get_f_density(m_at_params, ::HasDensity) = Base.fix1(Base.densityof, m_at_params)
_get_f_density(m_at_params, ::NoDensity) = m_at_params

function _m_params_densityfunc(::Any, ::HasDensity)
    throw(ArgumentError("Model evaluated at parameters returns a density, but must be measure/distribution-like instead."))
end

# For 1-dim data only:
function (m::BinnedModel{F,<:Tuple{<:Binning}})(params) where F
    m_at_params = m.f_expectation(params)
    f_density = _get_f_density(m_at_params, DensityKind(m_at_params))
    binning = only(m.binning)
    # ToDo: Offer more advanced integration methods than midpoint-rule:
    product_distribution(Poisson.(bin_widths(binning) .* f_density.(bin_centers(binning))))
end


"""
    binned_model(f_expectation, edges::Tuple{AbstractVector,...})

Create a staticstical binned model from an density expectation function
`f_expectation` and a tuple of bin edges `edges`.

See also [`binned_likelihood`](@ref).
"""
function binned_model end
export binned_model

binned_model(f_expectation, edges::Tuple{Vararg{AbstractVector}}) = BinnedModel(f_expectation, edges)



"""
    binned_likelihood(f_expectation, edges::Tuple{AbstractVector,...}, data::AbstractVector{<:Integer})
    binned_likelihood(f_expectation, h::StatsBase.Histogram{<:Integer})

Constructs a binned likelihood object that is compatible with the
[DensityInterface](https://github.com/JuliaMath/DensityInterface.jl) API.

See also [`binned_model`](@ref).
"""
function binned_likelihood end
export binned_likelihood

function binned_likelihood(f_expectation, edges::Tuple{Vararg{AbstractVector}}, data::AbstractVector{<:Integer})
    logfuncdensity(Base.Fix2(logdensityof, data) ∘ binned_model(f_expectation, edges))
end

function binned_likelihood(f_expectation, h::Histogram{<:Integer})
    binned_likelihood(f_expectation, h.edges, h.weights)
end
