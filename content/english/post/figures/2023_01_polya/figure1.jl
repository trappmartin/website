using TikzGraphs
using Graphs
using TikzPictures
using LaTeXStrings

function generate_graph()
    g = DiGraph(31)
    names = ["X"]

    add_edge!(g, 1, 2)
    add_edge!(g, 1, 3)

    k = 1
    c = 3
    for p in 1:3
        for _ in 1:(2^p)
            k += 1
            for _ in 1:2
                c += 1
                add_edge!(g, k, c)
            end
        end
    end

    return g
end

g = generate_graph()

names = ["X",
         "A_0", "A_1",
         "A_{00}", "A_{01}", "A_{10}","A_{11}",
         "A_{000}", "A_{001}", "A_{010}", "A_{011}", "A_{100}", "A_{101}", "A_{110}", "A_{111}"]

labels = map(i -> L"\dots", 1:31)
labels[1:15] .= names

tp = TikzGraphs.plot(g,
                     latexstring.(labels),
                     node_style="draw",
                     graph_options="nodes={draw, rounded corners}",
                     node_styles=Dict( i => "opacity=0" for i in 16:31),
                     #edge_labels=Dict((1,2)=>L"\theta(A_0)", (1,3)=>L"\theta(A_1)")
                     )

#save(SVG("figure1"), tp)

using Distributions
using StatsBase
using LogarithmicNumbers
using Random
using Plots
pgfplotsx()
gr(leg = false)

# map obervation to A in jth layer
kfun(x::AbstractFloat, j::Int, base::Distribution) = min(floor(Int, 2^j * cdf(base, x)) + 1, 2^j)

# count observations in each A
ns(x::AbstractVector, J::Int; base = Uniform(0,1)) = map(j -> counts(kfun.(x, j, base), 1:2^j), 1:J)

# draw conditional probabilities
function thetas(n::Vector{Vector{Int}}; α = 1, ρ = (j) -> 2.0^(-j))
    θs = map(layer -> begin
                 j, nj = layer
                 m = reshape(nj, 2, 2^(j-1))
                 θl = map(i -> ULogarithmic.(rand(Beta( α * ρ(j) .+ m[:,i]...))), 1:2^(j-1))
                 mapreduce(θ -> [θ, one(θ) - θ], vcat, θl)
            end, enumerate(n))
    return θs
end

# compute probabilities
prob(x, θs, base) = mapreduce( ((j, θ),) -> θ[kfun.(x, j, base)], (a,b) -> a .* b, enumerate(θs) )

probmf(x, θs, base) = prob(x, θs, base)
probdf(x, θs, base) = 2^J * prob(x, θs, base) .* pdf.(base, x)




function plot_pt(x, base; T = 1, J = 10)

    n = ns(x, J; base = base)

    xtest = range(minimum(x) - 1, maximum(x) + 1, length=500)

    α = 1.0

    yprobs = map( _ -> prob(xtest, thetas(n; α = α, ρ = (j) -> 2.0^(-j)); base = base), 1:T )

    μytest = mean( yprobs )
    σytest = var( yprobs )

    p = Plots.scatter(x, zeros(length(x)), mc=:grey, ma=0.5, size=(400, 200))

    Plots.plot!(p, xtest, μytest; line = :solid, color = :black)
    Plots.plot!(p, xtest, pdf.(gt, xtest)/10 , line = :dash, color = :grey)

    savefig(p, "figure2_1.svg")



    yprobs = map( _ -> 2^J * prob(xtest, thetas(n; α = 0.2, ρ = (j) -> j*2^(2*j)); base = base) .* pdf.(base, xtest), 1:T )

    μytest = mean( yprobs )
    σytest = var( yprobs )

    p = Plots.scatter(x, zeros(length(x)), mc=:grey, ma=0.5, size=(400,200))

    Plots.plot!(p, xtest, μytest; ribbon = σytest, line = :solid, color = :black)
    Plots.plot!(p, xtest, pdf.(gt, xtest) , line = :dash, color = :grey)

    savefig(p, "figure2_2.svg")


end

Random.seed!(123)
mix = MixtureModel([Normal(-1,0.1), Normal(1, 0.5)], [0.2, 0.8])
x = rand(mix, 100)

minx, maxx = minimum(x)-1, maximum(x)+1
base = Uniform(minx, maxx)

J = 10


n = ns(x, J; base = base)

xtest = range(minimum(x) - 1, maximum(x) + 1, length=500)
ytest = probmf(xtest, thetas(n; ρ = (j) -> 2.0^(-j)), base)

p = Plots.scatter(x, zeros(length(x)), mc=:grey, ma=0.5, size=(400, 200))

Plots.plot!(p, xtest, ytest; line = :solid, color = :black)
Plots.plot!(p, xtest, pdf.(gt, xtest)/10 , line = :dash, color = :grey)

savefig(p, "figure2_1.svg")

xtest = range(minimum(x) - 1, maximum(x) + 1, length=500)
ytest1 = probdf(xtest, thetas(n, ρ = (j) -> j*2.0^(2*j*0.3)), base)
ytest2 = probdf(xtest, thetas(n, ρ = (j) -> j*2.0^(2*j*0.3)), base)

p = Plots.scatter(x, zeros(length(x)), mc=:grey, ma=0.5, size=(400, 200))

Plots.plot!(p, xtest, ytest1; line = :solid, color = :black)
Plots.plot!(p, xtest, ytest2; line = :dashdot, color = :black)
Plots.plot!(p, xtest, pdf.(gt, xtest) , line = :dash, color = :grey)

savefig(p, "figure2_2.svg")

#plot_pt(x, base)
