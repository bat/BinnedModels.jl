# This file is a part of BinnedModels.jl, licensed under the MIT License (MIT).

using Test
using BinnedModels
import Documenter

Documenter.DocMeta.setdocmeta!(
    BinnedModels,
    :DocTestSetup,
    :(using BinnedModels);
    recursive=true,
)
Documenter.doctest(BinnedModels)
