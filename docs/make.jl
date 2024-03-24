# Inside make.jl
push!(LOAD_PATH,"../src/")
using MacroExpansion
using Documenter
makedocs(
         sitename = "MacroExpansion.jl",
         modules  = [MacroExpansion],
         pages=[
                "Home" => "index.md"
               ])
deploydocs(;
    repo="github.com/USERNAME/VegaGraphs.jl",
)