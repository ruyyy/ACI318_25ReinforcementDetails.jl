using ACI318_25ReinforcementDetails
using Documenter

DocMeta.setdocmeta!(ACI318_25ReinforcementDetails, :DocTestSetup, :(using ACI318_25ReinforcementDetails); recursive=true)

makedocs(;
    modules=[ACI318_25ReinforcementDetails],
    authors="Eduardo Ruy",
    sitename="ACI318_25ReinforcementDetails.jl",
    format=Documenter.HTML(;
        canonical="https://ruyyy.github.io/ACI318_25ReinforcementDetails.jl",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/ruyyy/ACI318_25ReinforcementDetails.jl",
    devbranch="master",
)
