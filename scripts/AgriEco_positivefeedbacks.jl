include("packages.jl")
include("AgriEco_commoncode.jl")

@with_kw mutable struct YieldInputsPar
    yield_r = 0.0
    yield_prices_r = 0.0
    inputs_r = 0.0
    inputs_prices_r = 0.0
    yield_σ = 3.0
    yield_prices_σ = 3.0
    inputs_σ = 3.0
    inputs_prices_σ = 3.0
    yield_μ = 200.0
    yield_prices_μ = 30.0
    inputs_μ = 100.0
    inputs_prices_μ = 30.0
end

@with_kw mutable struct InterestPar
    operatinginterest = 4
    debtinterest = 4
    savingsinterest = 2
end

function yieldinputs_createdata(par, maxyears, seed)
    @unpack yield_r, yield_prices_r, yield_prices_r, inputs_r, inputs_prices_r, yield_σ, yield_prices_σ, inputs_σ, inputs_prices_σ, yield_μ, yield_prices_μ, inputs_μ, inputs_prices_μ = par
    yield_data = noise_creation(yield_μ, yield_σ, yield_r, maxyears, seed)
    yield_prices_data = noise_creation(yield_prices_μ, yield_prices_σ, yield_prices_r, maxyears, seed)
    inputs_data = noise_creation(inputs_μ, inputs_σ, inputs_r, maxyears, seed)
    inputs_prices_data = noise_creation(inputs_prices_μ, inputs_prices_σ, inputs_prices_r, maxyears, seed)
    return hcat(1:1:maxyears, yield_data, yield_prices_data, inputs_data, inputs_prices_data)
end


yieldinputs_createdata(YieldInputsPar(), 10, 125)

function yieldinputs_staticdata(par, maxyears)
    @unpack yield_μ, yield_prices_μ, inputs_μ, inputs_prices_μ = par
    yield_data = repeat([yield_μ], maxyears)
    yield_prices_data = repeat([yield_prices_μ], maxyears)
    inputs_data = repeat([inputs_μ], maxyears)
    inputs_prices_data = repeat([inputs_prices_μ], maxyears)
    return hcat(1:1:maxyears, yield_data, yield_prices_data, inputs_data, inputs_prices_data)
end

function revenue_calc(yield, yield_price)
    return yield * yield_price
end

function expenses_calc(inputs, inputs_price)
    return inputs * inputs_price
end

function operatingloan(expenses, interestpar)
    @unpack operatinginterest = interestpar
    return expenses * (1 + operatinginterest/100)
end

function assetsdebtupdate(assetsdebt, interestpar)
    @unpack debtinterest, savingsinterest = interestpar
    if assetsdebt > 0.0
        return assetsdebt * (1 + savingsinterest/100)
    else
        return assetsdebt * (1 + debtinterest/100)
    end
end

function simulation(yieldinputspar, interestpar, maxyears, seed)
    yieldinputsdata = yieldinputs_createdata(yieldinputspar, maxyears, seed)
    assetsdebt = zeros(maxyears+1)
    for yr in 2:maxyears+1
        expenses = expenses_calc(yieldinputsdata[yr-1,4], yieldinputsdata[yr-1,4])
        revenue = revenue_calc(yieldinputsdata[yr-1,2], yieldinputsdata[yr-1,3])
        assetsdebtafterfarming = assetsdebt[yr-1] + (revenue - operatingloan(expenses, interestpar))
        assetsdebt[yr] = assetsdebtupdate(assetsdebtafterfarming, interestpar)
    end
    return assetsdebt
end

function distribution(yieldinputspar, interestpar, maxyears, reps)
    assetsdebtdata =  zeros(reps)
    @threads for i in 1:reps
        simdata = simulation(yieldinputspar, interestpar, maxyears, i)
        assetsdebtdata[i] = simdata[end]
    end
    return assetsdebtdata
end

## Determining yield, input, prices midpoints ##
# abstract parameter free version (relationship of parameters)
#(match more closely the abstract geometry approach previous model)
# profit is maximised

#specific parameters to match real world
# set profit as per acre profit
# set revenue and expenses as 2019 averages
# set ymax to average yield of corn