# This file is a part of BinnedModels.jl, licensed under the MIT License (MIT).


"""
    BinEdges{T<:Number} = AbstractVector{T}

Representation of a binning with n bins as n+1 edge points.
"""
const BinEdges{T<:Number} = AbstractVector{T}
export BinEdges


"""
    Binning{T<:Number} = AbstractVector{<:AbstractInterval{T}}

Representation of a binning as a vector of intervals.
"""
const Binning{T<:Number} = AbstractVector{<:AbstractInterval{T}}
export Binning


"""
    bin_leftedges(edges::BinEdges)
    bin_leftedges(binnig::Binning)

Returns the left edges of a binning defined by a vector of edges.
"""
function bin_leftedges end
export bin_leftedges

bin_leftedges(edges::BinEdges) = edges[begin:end-1]
bin_leftedges(binning::Binning) = leftendpoint.(binning)
bin_leftedges(binning::StructVector{<:AbstractInterval{<:Number}}) = binning.left


"""
    bin_rightedges(edges::BinEdges)
    bin_rightedges(binnig::Binning)

Returns the right edges of a binning defined by a vector of edges.
"""
function bin_rightedges end
export bin_rightedges

bin_rightedges(edges::BinEdges) = edges[begin+1:end]
bin_rightedges(binning::Binning) = rightendpoint.(binning)
bin_rightedges(binning::StructVector{<:AbstractInterval{<:Number}}) = binning.right


"""
    function bin_intervals(edges::BinEdges, closed::Val = Val(:closedleft))::Binning

Returns a vector of n bin intervals, derived from a vector of n+1 bin edges.
"""
function bin_intervals end
export bin_intervals

bin_intervals(edges::AbstractVector) = bin_intervals(edges, Val(:closedleft))

function bin_intervals(edges::BinEdges, ::Val{:closedleft})
    StructArray{Interval{:closed, :open, eltype(edges)}}((
        bin_leftedges(edges), bin_rightedges(edges)
    ))
end


"""
    bin_centers(binnig::Binning)
    bin_centers(edges::BinEdges)

Returns the bin centers of a binning defined by a vector of edges.
"""
function bin_centers end
export bin_centers

bin_centers(binning::Union{Binning,BinEdges}) = (bin_leftedges(binning) + bin_rightedges(binning)) / 2


"""
    bin_widths(binnig::Binning)
    bin_widths(binning::BinEdges)

Returns the bin widths of a binning defined by a vector of edges.
"""
function bin_widths end
export bin_widths

bin_widths(binning::Union{Binning,BinEdges}) = bin_rightedges(binning) - bin_leftedges(binning)
