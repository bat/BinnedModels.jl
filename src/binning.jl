# This file is a part of BinnedModels.jl, licensed under the MIT License (MIT).


#!!!!!!!!!!!!!!!!!!!!!!!
# ToDo: First create a package for sets. Then a "binning" will be represented
# by a partition (backed by edges, vectors of intervals, etc.). Products of
# partitions will handle the multi-dimensional case. Hexagonal and rhombic
# dodecahedron tessellation can be handled cleanly as well. Each partition
# comes with an index set, special indices like zero can be reserved for
# the complement of a partition of a subspace (out of bounds, over/underflow).
# A partition automatically enables a binning function that maps from a
# point to the bin index, e.g. `findbin(partition, x)` with curried for
# `findbin(partition)`.


"""
    BinEdges{T<:Number} = AbstractVector{T}

Representation of a binning with n bins as n+1 edge points.
"""
const BinEdges{T<:Number} = AbstractVector{T}
export BinEdges


"""
    BinIntervals{T<:Number} = AbstractVector{<:AbstractInterval{T}}

Representation of a binning as a vector of intervals.
"""
const BinIntervals{T<:Number} = AbstractVector{<:AbstractInterval{T}}
export BinIntervals


"""
    BinningLike = Union{Tuple{Vararg{Union{BinEdges,BinIntervals}}}, Union{BinIntervals,BinEdges}}

Anything that can be used as a binning, bin intervals or bin edges, single-
or multi-dimensional.
"""
const BinningLike = Union{Tuple{Vararg{Union{BinEdges,BinIntervals}}}, Union{BinIntervals,BinEdges}}
export BinningLike


"""
    function bin_intervals(edges::BinEdges, closed::Val = Val(:closedleft))::BinIntervals

Returns a vector of bin intervals, derived from a vector of n+1 bin edges.
"""
function bin_intervals end
export bin_intervals

bin_intervals(edges::BinEdges) = bin_intervals(edges, Val(:closedleft))

function bin_intervals(edges::BinEdges, ::Val{:closedleft})
    StructArray{Interval{:closed, :open, eltype(edges)}}((
        bin_leftedges(edges), bin_rightedges(edges)
    ))
end


"""
    bin_edges(intervals::BinIntervals)::BinEdges

Returns the bin edges of a binning defined by a vector of bin intervals.
"""
function bin_leftedges end
export bin_leftedges

function bin_edges(intervals::BinIntervals)
    edges_l =bin_leftedges(intervals)
    edges_r = bin_rightedges(intervals)
    if @view !(edges_l[begin+1, end] ≈ edges_r[begin, end-1])
        throw(ArgumentError("Left and right edges of bin intervals do not match."))
    end
    edges = similar(edges_r, length(edges_l) + 1)
    edges[begin:end-1] = edges_l
    edges[end:end] = @view edges_r[end:end]
    return edges
end


"""
    bin_leftedges(edges::BinEdges)
    bin_leftedges(binnig::BinIntervals)

Returns the left edges of a binning defined by a vector of edges.
"""
function bin_leftedges end
export bin_leftedges

bin_leftedges(edges::BinEdges) = edges[begin:end-1]
bin_leftedges(binning::BinIntervals) = leftendpoint.(binning)
bin_leftedges(binning::StructVector{<:AbstractInterval{<:Number}}) = binning.left


"""
    bin_rightedges(edges::BinEdges)
    bin_rightedges(binnig::BinIntervals)

Returns the right edges of a binning defined by a vector of edges.
"""
function bin_rightedges end
export bin_rightedges

bin_rightedges(edges::BinEdges) = edges[begin+1:end]
bin_rightedges(binning::BinIntervals) = rightendpoint.(binning)
bin_rightedges(binning::StructVector{<:AbstractInterval{<:Number}}) = binning.right


"""
    bin_centers(binnig::BinIntervals)
    bin_centers(edges::BinEdges)

Returns the bin centers of a binning defined by a vector of edges.
"""
function bin_centers end
export bin_centers

bin_centers(binning::Union{BinIntervals,BinEdges}) = (bin_leftedges(binning) + bin_rightedges(binning)) / 2


"""
    bin_widths(binnig::BinIntervals)
    bin_widths(binning::BinEdges)

Returns the bin widths of a binning defined by a vector of edges.
"""
function bin_widths end
export bin_widths

bin_widths(binning::Union{BinIntervals,BinEdges}) = bin_rightedges(binning) - bin_leftedges(binning)
