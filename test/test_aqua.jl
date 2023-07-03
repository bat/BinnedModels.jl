# This file is a part of BinnedModels.jl, licensed under the MIT License (MIT).

import Test
import Aqua
import BinnedModels

Test.@testset "Aqua tests" begin
    Aqua.test_all(
        BinnedModels,
        ambiguities = false,
        project_toml_formatting = VERSION≥v"1.7"
    )
end # testset
