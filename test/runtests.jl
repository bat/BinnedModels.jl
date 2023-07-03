# This file is a part of BinnedModels.jl, licensed under the MIT License (MIT).

import Test

Test.@testset "Package BinnedModels" begin
    include("test_aqua.jl")
    include("test_binning.jl")
    include("test_binned_model.jl")
    include("test_docs.jl")
    isempty(Test.detect_ambiguities(BinnedModels))
end # testset
