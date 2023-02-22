include("packages.jl")
include("AgriEco_commoncode.jl")

@with_kw mutable struct NoisePar
    yielddisturbed_CV = 0.2
    p_CV = 0.1
    c_CV = 0.1
    yielddisturbed_r = 0.0
    p_r = 0.0
    c_r = 0.0
end

@with_kw mutable struct InterestPar
    operatinginterest = 4
    debtinterest = 4
    savingsinterest = 2
end

function checkcreatedparams(paramdata)
    for i in 1:length(paramdata)
        if paramdata[i] <= 0.0
            error("Parameters can't be <=0. Change your base parameters or CV")
        end
    end
end

# function param_createdata(basepar, maxyears, seed)
#     @unpack ymax, y0, p, c = basepar
#     @unpack ymax_CV, y0_CV, p_CV, c_CV, ymax_r, y0_r, p_r, c_r = noisepar
#     ymax_σ = ymax_CV * ymax
#     y0_σ = y0_CV * y0
#     p_σ = p_CV * p
#     c_σ = c_CV * c
#     ymax_data = noise_creation(ymax, ymax_σ, ymax_r, maxyears, seed)
#     y0_data = noise_creation(y0, y0_σ, y0_r, maxyears, seed)
#     p_data = noise_creation(p, p_σ, p_r, maxyears, seed)
#     c_data = noise_creation(c, c_σ, c_r, maxyears, seed)
#     checkcreatedparams(ymax_data)
#     checkcreatedparams(y0_data)
#     checkcreatedparams(p_data)
#     checkcreatedparams(c_data)
#     return hcat(1:1:maxyears, ymax_data, y0_data, p_data, c_data)
# end

# function yieldinputs_createdata(param_data, maxyears)
#     inputs = zeros(maxyears)
#     yield = zeros(maxyears)
#     for i in 1:maxyears
#         par = FarmBasePar(ymax = param_data[i,2], y0 = param_data[i,3], p = param_data[i,4], c = param_data[i,5])
#         yieldinputs = maxprofitIII_vals(par)
#         inputs[i] = yieldinputs[1]
#         yield[i] = yieldinputs[2]
#     end
#     return hcat(1:1:maxyears, yield, inputs, param_data[:,4], param_data[:,5])
# end

function yielddisturbed_white(inputsyield, noisepar, maxyears, seed)
    yielddisturbed_σ = inputsyield[2] * noisepar.yielddisturbed_CV
    yieldnoise = noise_creation(inputsyield[2], yielddisturbed_σ, noisepar.yielddisturbed_r, maxyears, seed)
    checkcreatedparams(yieldnoise)
    return yieldnoise
end

function pricedisturbed_white(basepar, noisepar, maxyears, seed)
    p_σ = basepar.p * noisepar.p_CV
    pricenoise = noise_creation(basepar.p, p_σ, noisepar.p_r, maxyears, seed)
    checkcreatedparams(pricenoise)
    return pricenoise
end

function costdisturbed_white(basepar, noisepar, maxyears, seed)
    c_σ = basepar.c * noisepar.c_CV
    costnoise = noise_creation(basepar.c, c_σ, noisepar.c_r, maxyears, seed)
    checkcreatedparams(costnoise)
    return costnoise
end

function whitenoise_createdata(noiselocation, basepar, noisepar, maxyears, seed)
    inputsyield = maxprofitIII_vals(basepar)
    if noiselocation == "yield"
        return hcat(1:1:maxyears, yielddisturbed_white(inputsyield, noisepar, maxyears, seed), repeat([inputsyield[1]], maxyears), repeat([basepar.p],maxyears), repeat([basepar.c],maxyears))
    elseif noiselocation == "price"
        return hcat(1:1:maxyears, repeat([inputsyield[2]],maxyears), repeat([inputsyield[1]],maxyears), pricedisturbed_white(basepar, noisepar, maxyears, seed), repeat([basepar.c],maxyears))
    elseif noiselocation == "cost"
        return hcat(1:1:maxyears, repeat([inputsyield[2]],maxyears), repeat([inputsyield[1]],maxyears), repeat([basepar.p],maxyears), costdisturbed_white(basepar, noisepar, maxyears, seed))
    elseif noiselocaiton == "all"
        return hcat(1:1:maxyears, yielddisturbed_white(inputsyield, noisepar, maxyears, seed), repeat([inputsyield[1]],maxyears), pricedisturbed_white(basepar, noisepar, maxyears, seed), costdisturbed_white(basepar, noisepar, maxyears, seed))
    else
        error("Check the variable noiselocation")
    end
end

function revenue_calc(yield, p)
    return yield * p
end

function expenses_calc(inputs, c)
    return inputs * c
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

function simulation(basedata, interestpar)
    maxyears = size(basedata,1)
    assetsdebt = zeros(maxyears+1)
    for yr in 2:maxyears+1
        expenses = expenses_calc(basedata[yr-1,3], basedata[yr-1,5])
        revenue = revenue_calc(basedata[yr-1,2], basedata[yr-1,4])
        assetsdebtafterfarming = assetsdebt[yr-1] + (revenue - operatingloan(expenses, interestpar))
        assetsdebt[yr] = assetsdebtupdate(assetsdebtafterfarming, interestpar)
    end
    return assetsdebt
end

function whitenoise_distribution(noiselocation, basepar, noisepar, interestpar, maxyears, reps)
    assetsdebtdata =  zeros(reps)
    @threads for i in 1:reps
        basedata = whitenoise_createdata(noiselocation, basepar, noisepar, maxyears, i)
        simdata = simulation(basedata, interestpar)
        assetsdebtdata[i] = simdata[end]
    end
    return assetsdebtdata
end

calc_y0(1.33,174.0,139,6.70)

whitenoise_createdata("yield", FarmBasePar(), NoisePar(), 50, 1)

let 
    data = whitenoise_distribution("yield", FarmBasePar(), NoisePar(), InterestPar(), 50, 1000)
    test = figure()
    plt.hist(data,25)
    return test
end


let
    data = distribution("yield_disturbance", FarmBasePar(ymax=174.0, y0=15.0), NoisePar(yielddisturbed_CV=0.05, yielddisturbed_r=0.9), InterestPar(), 50, 50)
    test = figure()
    plt.hist(data, 25)
    return test
end


let
    data = distribution("price_disturbance", FarmBasePar(), NoisePar(p_CV=0.2,p_r=0.9), InterestPar(), 50, 50)
    test = figure()
    plt.hist(data, 25)
    return test
end
