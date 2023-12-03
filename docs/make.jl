# Use
#
#     DOCUMENTER_DEBUG=true julia --color=yes make.jl local [nonstrict] [fixdoctests]
#
# for local builds.

using Documenter
using BinnedModels

# Doctest setup
DocMeta.setdocmeta!(
    BinnedModels,
    :DocTestSetup,
    :(using BinnedModels);
    recursive=true,
)

makedocs(
    sitename = "BinnedModels",
    modules = [BinnedModels],
    format = Documenter.HTML(
        prettyurls = !("local" in ARGS),
        canonical = "https://bat.github.io/BinnedModels.jl/stable/"
    ),
    pages = [
        "Home" => "index.md",
        "API" => "api.md",
        "LICENSE" => "LICENSE.md",
    ],
    doctest = ("fixdoctests" in ARGS) ? :fix : true,
    linkcheck = !("nonstrict" in ARGS),
    warnonly = ("nonstrict" in ARGS),
)

deploydocs(
    repo = "github.com/bat/BinnedModels.jl.git",
    forcepush = true,
    push_preview = true,
)
