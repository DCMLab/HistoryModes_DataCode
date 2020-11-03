module CompoundDistributions

using StatsFuns.RFunctions: betarand, gammarand
using SpecialFunctions: lbeta
using LogProbs

# distribution types
export BetaBern, DirMul, DirCat, UniCat, CatDist, ChineseRest

# conditional distribution type
export SimpleCond

# functions
export support, sample, logscore, add_obs!, rm_obs!

# helper function
export categorical_sample

abstract type Distribution{T} end

function categorical_sample(tokens, weights)
    T = eltype(weights)
    x = rand(T) * sum(weights)
    cum_weights = zero(T)
    for (t, w) in zip(tokens, weights)
        cum_weights += w
        if cum_weights > x
            return t
        end
    end
end

categorical_sample(d::Dict) = categorical_sample(keys(d), values(d))
categorical_sample(v::Vector) = categorical_sample(1:length(v), v)

############################
### Beta Bernoulli Class ###
############################

mutable struct BetaBern{T, C} <: Distribution{T}
    heads :: T
    tails :: T
    alpha :: C
    beta  :: C
end

BetaBern(a, b) = BetaBern(true, false, a, b)
BetaBern(support) = BetaBern(support..., 1, 1)

support(bb::BetaBern) = [bb.heads, bb.tails]

function sample(bb::BetaBern)
    p = betarand(bb.alpha, bb.beta)
    categorical_sample((bb.heads, bb.tails), (p, 1-p))
end

function logscore(bb::BetaBern, obs)
    k = obs == bb.heads
    LogProb(lbeta(k+bb.alpha, 1-k+bb.beta) - lbeta(bb.alpha, bb.beta), islog=true)
end

add_obs!(bb::BetaBern, obs) = obs == bb.heads ? bb.alpha += 1 : bb.beta += 1
rm_obs!(bb::BetaBern, obs)  = obs == bb.heads ? bb.alpha -= 1 : bb.beta -= 1

###################################
### Dirichlet Multinomial Class ###
###################################

mutable struct DirMul{T, C} <: Distribution{T}
    counts :: Dict{T, C}
end

DirMul(support) = DirMul(Dict(x => 1.0 for x in support))
support(dm::DirMul) = keys(dm.counts)

function sample(dm::DirMul, n)
    weights = [gammarand(c, 1) for c in values(dm.counts)]
    d = Dict(k=>0 for k in keys(dm.counts))
    for i in 1:n
        d[categorical_sample(keys(dm.counts), weights)] += 1
    end
    d
end

function logscore(dm::DirMul, obs::AbstractDict)
    n = sum(values(obs))
    LogProb(
        log(n) + lbeta(sum(values(dm.counts)), n) -
        sum(
            log(obs[x]) + lbeta(dm.counts[x], obs[x])
            for x in keys(dm.counts) if obs[x] > 0
        ),
        islog=true
    )
end

function add_obs!(dm::DirMul, obs::AbstractDict)
    for x in keys(obs)
        dm.counts[x] += obs[x]
    end
end

function rm_obs!(dm::DirMul, obs::AbstractDict)
    for x in keys(obs)
        dm.counts[x] -= obs[x]
    end
end

###################################
### Dirichlet Categorical Class ###
###################################

mutable struct DirCat{T, C} <: Distribution{T}
    counts :: Dict{T, C}
end

DirCat(support) = DirCat(Dict(x => 1.0 for x in support))
support(dc::DirCat) = keys(dc.counts)

function sample(dc::DirCat)
    weights = [gammarand(c, 1) for c in values(dc.counts)]
    categorical_sample(keys(dc.counts), weights)
end

function logscore(dc::DirCat, obs)
    LogProb(lbeta(sum(values(dc.counts)), 1) - lbeta(dc.counts[obs], 1), islog=true)
end

add_obs!(dc::DirCat, obs) = dc.counts[obs] += 1
rm_obs!(dc::DirCat, obs) = dc.counts[obs] -= 1

######################################
### Categorical Distribution Class ###
######################################

struct CatDist{T} <: Distribution{T}
    probs :: Dict{T, LogProb}
end

support(cd::CatDist) = keys(cd.probs)

logscore(cd::CatDist, x) = cd.probs[x]
sample(cd::CatDist) = categorical_sample(cd.probs)
add_obs!(cd::CatDist, obs, context) = nothing
remove_obs!(cd::CatDist, obs, context) = nothing

#################################
### Uniform Categorical Class ###
#################################

struct UniCat{T} <: Distribution{T}
    support :: Vector{T}
end

UniCat(support) = UniCat(collect(support))
support(uc::UniCat) = uc.support

sample(uc::UniCat) = uc.support[rand(1:length(uc.support))]
logscore(uc::UniCat, obs) = obs in uc.support ? LogProb(1 / length(uc.support)) : zero(LogProb)
add_obs!(uc::UniCat, obs, context) = nothing
rm_obs!(uc::UniCat, obs, context) = nothing

################################
### Chinese Restaurant Class ###
################################

mutable struct ChineseRest{Dish, Dist <: Distribution{Dish}} <: Distribution{Dish}
    a :: Float64 # discount parameter
    b :: Float64 # crp parameter
    basedist :: Dist
    tables :: Dict{Dish, Vector{Int}}
    num_tables :: Int
    num_customers :: Int
end

ChineseRest(a, b, basedist::Distribution{T}) where T =
    ChineseRest(a, b, basedist, Dict{T, Vector{Int}}(), 0, 0)
ChineseRest(support) = ChineseRest(0.0, 0.1, UniCat(support))
support(r::ChineseRest) = support(r.basedist)

function sample(r::ChineseRest)
    if flip((r.num_tables * r.a + r.b) / (r.num_customers + r.b))
        sample(r.basedist)
    else
        categorical_sample(
            Dict(dish => sum(r.tables[dish]) for dish in keys(r.tables))
        )
    end
end

function new_table_logscore(r::ChineseRest, dish)
    new_table_prob = LogProb(
        log(r.num_tables * r.a + r.b) - log(r.num_customers + r.b)
    )
    base_dist_prob = logscore(r.basedist, dish)
    new_table_prob * base_dist_prob
end

function logscore(r::ChineseRest, dish)
    if haskey(r.tables, dish)
        numerator = sum(n - r.a for n in r.tables[dish])
        LogProb(log(numerator) - log(r.num_customers + r.b), islog=true) + new_table_logscore(r, dish)
    else
        new_table_logscore(r, dish)
    end
end

function add_obs!(r::ChineseRest, dish)
    r.num_customers += 1
    if !haskey(r.tables, dish)
        r.num_tables += 1
        r.tables[dish] = [1]
    else
        r.tables[dish][1] += 1
    end
    nothing
end

function rm_obs!(r::ChineseRest, dish)
    r.num_customers -= 1
    r.tables[dish][1] -= 1
    if r.tables[dish][1] == 0
        r.num_tables -= 1
        delete!(r.tables, dish)
    end
    nothing
end

################################
### Simple Conditional Class ###
################################

mutable struct SimpleCond{C, D, S} # context, distribution, support
    dists   :: Dict{C, D}
    support :: S
end

SimpleCond(dists::AbstractDict) = SimpleCond(
    dists,
    vcat([collect(support(dist)) for dist in values(dists)]...)
)

SimpleCond(g::Union{Base.Generator, Base.Iterators.Flatten}) = SimpleCond(Dict(g))

sample(sc::SimpleCond, context, args...) = sample(sc.dists[context], args...)
logscore(sc::SimpleCond, obs, context) = logscore(sc.dists[context], obs)
rm_obs!(sc::SimpleCond, obs, context) = rm_obs!(sc.dists[context], obs)

function add_obs!(cond::SimpleCond{C,D,S}, obs, context) where {C,D,S}
    if !haskey(cond.dists, context)
        cond.dists[context] = D(cond.support)
    end
    add_obs!(cond.dists[context], obs)
end

end # module
