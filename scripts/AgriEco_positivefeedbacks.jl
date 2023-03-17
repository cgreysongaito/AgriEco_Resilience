include("packages.jl")
include("AgriEco_commoncode.jl")

@with_kw mutable struct NoisePar
    yielddisturbed_CV = 0.1
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

function yielddisturbed(inputsyield, noisepar, maxyears, seed)
    yielddisturbed_σ = inputsyield[2] * noisepar.yielddisturbed_CV
    yieldnoise = noise_creation(inputsyield[2], yielddisturbed_σ, noisepar.yielddisturbed_r, maxyears, seed)
    checkcreatedparams(yieldnoise)
    return yieldnoise
end

function pricedisturbed(basepar, noisepar, maxyears, seed)
    p_σ = basepar.p * noisepar.p_CV
    pricenoise = noise_creation(basepar.p, p_σ, noisepar.p_r, maxyears, seed)
    checkcreatedparams(pricenoise)
    return pricenoise
end

function costdisturbed(basepar, noisepar, maxyears, seed)
    c_σ = basepar.c * noisepar.c_CV
    costnoise = noise_creation(basepar.c, c_σ, noisepar.c_r, maxyears, seed)
    checkcreatedparams(costnoise)
    return costnoise
end

function noise_createdata(noiselocation, inputsyield, basepar, noisepar, maxyears, seed)
    if noiselocation == "yield"
        return hcat(1:1:maxyears, yielddisturbed(inputsyield, noisepar, maxyears, seed), repeat([inputsyield[1]], maxyears), repeat([basepar.p],maxyears), repeat([basepar.c],maxyears))
    elseif noiselocation == "price"
        return hcat(1:1:maxyears, repeat([inputsyield[2]],maxyears), repeat([inputsyield[1]],maxyears), pricedisturbed(basepar, noisepar, maxyears, seed), repeat([basepar.c],maxyears))
    elseif noiselocation == "cost"
        return hcat(1:1:maxyears, repeat([inputsyield[2]],maxyears), repeat([inputsyield[1]],maxyears), repeat([basepar.p],maxyears), costdisturbed(basepar, noisepar, maxyears, seed))
    elseif noiselocation == "all"
        return hcat(1:1:maxyears, yielddisturbed(inputsyield, noisepar, maxyears, seed), repeat([inputsyield[1]],maxyears), pricedisturbed(basepar, noisepar, maxyears, seed), costdisturbed(basepar, noisepar, maxyears, seed))
    elseif noiselocation == "none"
        return hcat(1:1:maxyears, repeat([inputsyield[2]],maxyears), repeat([inputsyield[1]], maxyears), repeat([basepar.p],maxyears), repeat([basepar.c],maxyears))
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

function assetsdebt_NLposfeed(assetsdebt, interestpar)
    @unpack debtinterest, savingsinterest = interestpar
    if assetsdebt > 0.0
        return assetsdebt * (1 + savingsinterest/100)
    else
        return assetsdebt * (1 + debtinterest/100)
    end
end


function simulation_NLposfeed(NL, basedata, interestpar)
    maxyears = size(basedata,1)
    assetsdebt = zeros(maxyears+1)
    for yr in 2:maxyears+1
        expenses = expenses_calc(basedata[yr-1,3], basedata[yr-1,5])
        revenue = revenue_calc(basedata[yr-1,2], basedata[yr-1,4])
        assetsdebtafterfarming = assetsdebt[yr-1] + (revenue - operatingloan(expenses, interestpar))
        if NL == "with"
            assetsdebt[yr] = assetsdebt_NLposfeed(assetsdebtafterfarming, interestpar)
        elseif NL == "without"
            assetsdebt[yr] = assetsdebtafterfarming
        else
            error("NL should be either with or without")
        end
    end
    return assetsdebt
end

function terminalassets_distribution(NL, noiselocation, inputsyield, basepar, noisepar, interestpar, maxyears, reps)
    assetsdebtdata =  zeros(reps)
    for i in 1:reps
        basedata = noise_createdata(noiselocation, inputsyield, basepar, noisepar, maxyears, i)
        simdata = simulation_NLposfeed(NL, basedata, interestpar)
        assetsdebtdata[i] = simdata[end]
    end
    return assetsdebtdata
end

function distribution_prob_convert(histogramdata)
    sumcounts = sum(histogramdata.weights)
    probdata = zeros(length(histogramdata.weights))
    for bini in eachindex(probdata)
        probdata[bini] = histogramdata.weights[bini]/sumcounts
    end
    return probdata
end

function expectedterminalassets(distributiondata, numbins)
    histogramdata = fit(Histogram, distributiondata, nbins=numbins)
    probdata = distribution_prob_convert(histogramdata)
    expectedassets = 0
    for bini in eachindex(probdata)
        midpoint = histogramdata.edges[1][bini]+step(histogramdata.edges[1])/2
        expectedassets += midpoint*probdata[bini]
    end
    return expectedassets
end



function expectedterminalassets_yield_rednoise(ymaxval, revexpratio, interestpar, yieldCV, corrrange, maxyears, reps)
    y0val = calc_y0(revexpratio, ymaxval, FarmBasePar().c, FarmBasePar().p)
    newbasepar = FarmBasePar(ymax=ymaxval, y0=y0val)
    inputsyield = maxprofitIII_vals(newbasepar)
    data=zeros(length(corrrange), 4)
    @threads for ri in eachindex(corrrange)
        noisepar = NoisePar(yielddisturbed_CV = yieldCV, yielddisturbed_r = corrrange[ri])
        termassetsdata_NL = terminalassets_distribution("with", "yield", inputsyield, newbasepar, noisepar, interestpar, maxyears, reps)
        termassetsdata_woNL = terminalassets_distribution("without", "yield", inputsyield, newbasepar, noisepar, interestpar, maxyears, reps)
        expectedprofitsdata_NL = expectedterminalassets(termassetsdata_NL, 30)
        expectedprofitsdata_woNL = expectedterminalassets(termassetsdata_woNL, 30)
        data[ri,1] = corrrange[ri]
        data[ri,2] = expectedprofitsdata_NL
        data[ri,3] = expectedprofitsdata_woNL
        data[ri,4] = expectedprofitsdata_NL-expectedprofitsdata_woNL
    end
    return data
end

test1 = expectedterminalassets_yield_rednoise(170, 1.00, InterestPar(), 0.1, 0.1:0.1:0.9, 50, 10)
test2 = expectedterminalassets_yield_rednoise(120, 1.00, InterestPar(), 0.1, 0.1:0.1:0.9, 50, 10)


let 
    highymax_133 = expectedterminalassets_yield_rednoise(170, 1.33, InterestPar(), 0.1, 0.1:0.1:0.9, 50, 1000)
    highymax_115 = expectedterminalassets_yield_rednoise(170, 1.15, InterestPar(), 0.1, 0.1:0.1:0.9, 50, 1000)
    highymax_100 = expectedterminalassets_yield_rednoise(170, 1.00, InterestPar(), 0.1, 0.1:0.1:0.9, 50, 1000)
    medymax_133 = expectedterminalassets_yield_rednoise(140, 1.33, InterestPar(), 0.1, 0.1:0.1:0.9, 50, 1000)
    medymax_115 = expectedterminalassets_yield_rednoise(140, 1.15, InterestPar(), 0.1, 0.1:0.1:0.9, 50, 1000)
    medymax_100 = expectedterminalassets_yield_rednoise(140, 1.00, InterestPar(), 0.1, 0.1:0.1:0.9, 50, 1000)
    lowymax_133 = expectedterminalassets_yield_rednoise(120, 1.33, InterestPar(), 0.1, 0.1:0.1:0.9, 50, 1000)
    lowymax_115 = expectedterminalassets_yield_rednoise(120, 1.15, InterestPar(), 0.1, 0.1:0.1:0.9, 50, 1000)
    lowymax_100 = expectedterminalassets_yield_rednoise(130, 1.00, InterestPar(), 0.1, 0.1:0.1:0.9, 50, 1000)
    rednoise_exptermassets = figure()
    subplot(3,1,1)
    plot(highymax_133[:,1], highymax_133[:,2], color="blue", label="Rev/Exp = 1.33")
    plot(highymax_115[:,1], highymax_115[:,2], color="red", label="Rev/Exp = 1.15")
    plot(highymax_100[:,1], highymax_100[:,2], color="purple", label="Rev/Exp =1.00")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("Expected Terminal Assets")
    title("High ymax, low input eff")
    subplot(3,1,2)
    plot(medymax_133[:,1], medymax_133[:,2], color="blue", label="Rev/Exp = 1.33")
    plot(medymax_115[:,1], medymax_115[:,2], color="red", label="Rev/Exp = 1.15")
    plot(medymax_100[:,1], medymax_100[:,2], color="purple", label="Rev/Exp =1.00")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("Expected Terminal Assets")
    title("Med ymax, med input eff")
    subplot(3,1,3)
    plot(lowymax_133[:,1], lowymax_133[:,2], color="blue", label="Rev/Exp = 1.33")
    plot(lowymax_115[:,1], lowymax_115[:,2], color="red", label="Rev/Exp = 1.15")
    plot(lowymax_100[:,1], lowymax_100[:,2], color="purple", label="Rev/Exp =1.00")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("Expected Terminal Assets")
    title("Low ymax, high input eff")
    tight_layout()
    return rednoise_exptermassets
end #FOR THIS METHOD OF DIFFERENTIAL - WHAT is -50  - just less than original by 50 which is still fine

#### CAN"T COMPARE BETWEEN HIGH AND LOW YMAX BECAUSE OF RELATIVE VERSUS ABSOLUTE PROFITS


function variabilityterminalassets(distributiondata)
    meandata = abs(mean(distributiondata))
    sddata = std(distributiondata)
    return sddata/meandata
end

function variabilityterminalassets_yield_rednoise(ymaxval, revexpratio, interestpar, yieldCV, corrrange, maxyears, reps)
    y0val = calc_y0(revexpratio, ymaxval, FarmBasePar().c, FarmBasePar().p)
    newbasepar = FarmBasePar(ymax=ymaxval, y0=y0val)
    inputsyield = maxprofitIII_vals(newbasepar)
    data=zeros(length(corrrange), 4)
    @threads for ri in eachindex(corrrange)
        noisepar = NoisePar(yielddisturbed_CV = yieldCV, yielddisturbed_r = corrrange[ri])
        termassetsdata_NL = terminalassets_distribution("with", "yield", inputsyield, newbasepar, noisepar, interestpar, maxyears, reps)
        termassetsdata_woNL = terminalassets_distribution("without", "yield", inputsyield, newbasepar, noisepar, interestpar, maxyears, reps)
        variabilityassetsdata_NL = variabilityterminalassets(termassetsdata_NL)
        variabilityassetsdata_woNL = variabilityterminalassets(termassetsdata_woNL)
        data[ri,1] = corrrange[ri]
        data[ri,2] = variabilityassetsdata_NL
        data[ri,3] = variabilityassetsdata_woNL
        data[ri,4] = variabilityassetsdata_NL/variabilityassetsdata_woNL
    end
    return data
end
#SOMETHING IS WRONG without NL varaibility

let
    y0val = calc_y0(1.33, 170, FarmBasePar().c, FarmBasePar().p)
    newbasepar = FarmBasePar(ymax=170, y0=y0val)
    inputsyield = maxprofitIII_vals(newbasepar)
    basedata = noise_createdata("yield", inputsyield, newbasepar, NoisePar(yielddisturbed_r = 0.9), 20, 18)
    assets = simulation_NLposfeed("without", basedata, InterestPar())
    return assets
end

2540.3884768145867
2594.0320813135327
2684.4343837891356
2753.999401514481

#checking that integral of red noise and white noise is always the same
let 
    noise = noise_creation(10, 0.1, 0.1, 50, 150)
    println(sum(noise))
    test = figure()
    plot(1:1:50, noise)
    return test
end



variabilityterminalassets_yield_rednoise(170, 1.33, InterestPar(), 0.1, 0.1:0.1:0.9, 50, 10)
let 
    highymax_133 = variabilityterminalassets_yield_rednoise(170, 1.33, InterestPar(), 0.1, 0.1:0.1:0.9, 50, 1000)
    highymax_115 = variabilityterminalassets_yield_rednoise(170, 1.15, InterestPar(), 0.1, 0.1:0.1:0.9, 50, 1000)
    highymax_100 = variabilityterminalassets_yield_rednoise(170, 1.00, InterestPar(), 0.1, 0.1:0.1:0.9, 50, 1000)
    medymax_133 = variabilityterminalassets_yield_rednoise(140, 1.33, InterestPar(), 0.1, 0.1:0.1:0.9, 50, 1000)
    medymax_115 = variabilityterminalassets_yield_rednoise(140, 1.15, InterestPar(), 0.1, 0.1:0.1:0.9, 50, 1000)
    medymax_100 = variabilityterminalassets_yield_rednoise(140, 1.00, InterestPar(), 0.1, 0.1:0.1:0.9, 50, 1000)
    lowymax_133 = variabilityterminalassets_yield_rednoise(120, 1.33, InterestPar(), 0.1, 0.1:0.1:0.9, 50, 1000)
    lowymax_115 = variabilityterminalassets_yield_rednoise(120, 1.15, InterestPar(), 0.1, 0.1:0.1:0.9, 50, 1000)
    lowymax_100 = variabilityterminalassets_yield_rednoise(130, 1.00, InterestPar(), 0.1, 0.1:0.1:0.9, 50, 1000)
    rednoise_exptermassets = figure()
    # plot(highymax_133[:,1], highymax_133[:,2], color="blue", label="Rev/Exp = 1.33", linestyle="solid")
    # plot(highymax_115[:,1], highymax_115[:,2], color="red", label="Rev/Exp = 1.15", linestyle="solid")
    # plot(highymax_100[:,1], highymax_100[:,2], color="purple", label="Rev/Exp =1.00", linestyle="solid")
    plot(lowymax_133[:,1], lowymax_133[:,2], color="blue", label="Rev/Exp = 1.33", linestyle="dashed")
    plot(lowymax_115[:,1], lowymax_115[:,2], color="red", label="Rev/Exp = 1.15", linestyle="dashed")
    plot(lowymax_100[:,1], lowymax_100[:,2] , color="purple", label="Rev/Exp =1.00", linestyle="dashed")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("CV Terminal Assets")
    # title("High ymax, low input eff")
    
    # subplot(3,1,1)
    # plot(highymax_133[:,1], highymax_133[:,2], color="blue", label="Rev/Exp = 1.33")
    # plot(highymax_115[:,1], highymax_115[:,2], color="red", label="Rev/Exp = 1.15")
    # plot(highymax_100[:,1], highymax_100[:,2], color="purple", label="Rev/Exp =1.00")
    # # ylim(-90,40)
    # xlabel("Autocorrelation")
    # ylabel("CV Terminal Assets")
    # title("High ymax, low input eff")
    # subplot(3,1,2)
    # plot(medymax_133[:,1], medymax_133[:,2], color="blue", label="Rev/Exp = 1.33")
    # plot(medymax_115[:,1], medymax_115[:,2], color="red", label="Rev/Exp = 1.15")
    # plot(medymax_100[:,1], medymax_100[:,2], color="purple", label="Rev/Exp =1.00")
    # # ylim(-90,40)
    # xlabel("Autocorrelation")
    # ylabel("CV Terminal Assets")
    # title("Med ymax, med input eff")
    # subplot(3,1,3)
    # plot(lowymax_133[:,1], lowymax_133[:,2], color="blue", label="Rev/Exp = 1.33")
    # plot(lowymax_115[:,1], lowymax_115[:,2], color="red", label="Rev/Exp = 1.15")
    # plot(lowymax_100[:,1], lowymax_100[:,2], color="purple", label="Rev/Exp =1.00")
    # # ylim(-90,40)
    # xlabel("Autocorrelation")
    # ylabel("CV Terminal Assets")
    # title("Low ymax, high input eff")
    # tight_layout()
    return rednoise_exptermassets
end  #CV does not differ between high ymax and low ymax - WHY?



# function exptermassets_revexpcon_data(noiselocation, revexpratio, ymaxrange, noisepar, interestpar, maxyears, reps, numbins, pval::Float64 =  6.70, cval::Float64 = 139.0)
#     data=zeros(length(ymaxrange), 2)
#     @threads for ymaxi in eachindex(ymaxrange)
#         y0val = calc_y0(revexpratio, ymaxrange[ymaxi], cval, pval)
#         par = FarmBasePar(ymax = ymaxrange[ymaxi], y0 = y0val, c = cval, p = pval)
#         distributiondata = whitenoise_distribution(noiselocation, par, noisepar, interestpar, maxyears, reps)
#         data[ymaxi, 1] = ymaxrange[ymaxi]
#         data[ymaxi, 2] = expectedterminalassets(distributiondata, numbins)
#     end
#     return data
# end 
# #do I need if minimum(filter(!isnan, [margcostIII(I, par) for I in Irange])) >= par.p #|| minimum(filter(!isnan, [avvarcostIII(I, par) for I in Irange])) >= par.p

# let 
#     data133 = exptermassets_revexpcon_data("yield", 1.33, 120.0:1.0:180.0, NoisePar(), InterestPar(), 50, 100, 25)
#     data110 = exptermassets_revexpcon_data("yield", 1.10, 120.0:1.0:180.0, NoisePar(), InterestPar(), 50, 100, 25)
#     data100 = exptermassets_revexpcon_data("yield", 1.00, 120.0:1.0:180.0, NoisePar(), InterestPar(), 50, 100, 25)
#     data095 = exptermassets_revexpcon_data("yield", 0.95, 120.0:1.0:180.0, NoisePar(), InterestPar(), 50, 100, 25)
#     test = figure()
#     plot(data133[:,1], data133[:,2], color="blue", label="Rev/Exp = 1.33")
#     plot(data110[:,1], data110[:,2], color="red", label="Rev/Exp = 1.10")
#     plot(data100[:,1], data100[:,2], color="purple", label="Rev/Exp =1.00")
#     plot(data095[:,1], data095[:,2], color="orange", label="Rev/Exp = 0.95")
#     xlabel("Ymax")
#     ylabel("Expected terminal assets")
#     legend()
#     return test
# end

# let 
#     data133 = exptermassets_revexpcon_data("none", 1.33, 120.0:1.0:180.0, NoisePar(), InterestPar(), 50, 100, 25)
#     data110 = exptermassets_revexpcon_data("none", 1.10, 120.0:1.0:180.0, NoisePar(), InterestPar(), 50, 100, 25)
#     data100 = exptermassets_revexpcon_data("none", 1.00, 120.0:1.0:180.0, NoisePar(), InterestPar(), 50, 100, 25)
#     data095 = exptermassets_revexpcon_data("none", 0.95, 120.0:1.0:180.0, NoisePar(), InterestPar(), 50, 100, 25)
#     test = figure()
#     plot(data133[:,1], data133[:,2], color="blue", label="Rev/Exp = 1.33")
#     plot(data110[:,1], data110[:,2], color="red", label="Rev/Exp = 1.10")
#     plot(data100[:,1], data100[:,2], color="purple", label="Rev/Exp =1.00")
#     plot(data095[:,1], data095[:,2], color="orange", label="Rev/Exp = 0.95")
#     xlabel("Ymax")
#     ylabel("Expected terminal assets")
#     legend()
#     return test
# end

# #why is yield, price, and cost basically the same result?**** No noise anywhere makes the same figure
# #because along the gradient of low to high ymax we are changing the absolute profits but keeping the relative profits constant ***
 

# calc_y0(1.33, 174, 139.0, 6.70)
# calc_y0(1.33, 120, 139.0, 6.70)

# inputsyield1 = maxprofitIII_vals(FarmBasePar(ymax=174.0, y0=calc_y0(1.33, 174, 139.0, 6.70), p=6.70, c=139.0))
# rev1 = revenue_calc(inputsyield1[2], 6.70)
# exp1 = expenses_calc(inputsyield1[1], 139.0)
# rev1/exp1
# rev1-exp1

# inputsyield2 = maxprofitIII_vals(FarmBasePar(ymax=120.0, y0=calc_y0(1.33, 120.0, 139.0, 6.70), p=6.70, c=139.0))
# rev2 = revenue_calc(inputsyield2[2], 6.70)
# exp2 = expenses_calc(inputsyield2[1], 139.0)
# rev2/exp2
# rev2-exp2


# function revminusexp(profit, ymax, p::Float64=6.70, c::Float64=139.0)
#     return ((ymax*p - profit)/(2*c))^2
# end

# revminusexp(100, 120)

# let 
#     ymaxrange= 120.0:0.1:174.0
#     data100 = [revminusexp(100, ymax) for ymax in ymaxrange]
#     data150 = [revminusexp(150, ymax) for ymax in ymaxrange]
#     test = figure()
#     plot(data100, ymaxrange, color = "blue")
#     plot(data150, ymaxrange, color = "red")
#     return test
# end


## Relative version of positive feedbacks

function assetsdebtupdate_rel(assetsdebt, interestpar)
    @unpack debtinterest, savingsinterest = interestpar
    if assetsdebt > 1.0
        return assetsdebt * (1 + savingsinterest/100)
    else
        return assetsdebt * (1 - debtinterest/100)
    end
end

function simulation_rel(basedata, interestpar)
    maxyears = size(basedata,1)
    assetsdebt = zeros(maxyears+1)
    assetsdebt[1] = 1.0
    for yr in 2:maxyears+1
        expenses = expenses_calc(basedata[yr-1,3], basedata[yr-1,5])
        revenue = revenue_calc(basedata[yr-1,2], basedata[yr-1,4])
        assetsdebtafterfarming = assetsdebt[yr-1] * revenue/expenses
        assetsdebt[yr] = assetsdebtupdate_rel(assetsdebtafterfarming, interestpar)
    end
    return assetsdebt
end

function terminalassets_distribution_rel(noiselocation, inputsyield, basepar, noisepar, interestpar, maxyears, reps)
    assetsdebtdata =  zeros(reps)
    @threads for i in 1:reps
        basedata = noise_createdata(noiselocation, inputsyield, basepar, noisepar, maxyears, i)
        simdata = simulation_rel(basedata, interestpar)
        assetsdebtdata[i] = simdata[end]
    end
    return assetsdebtdata
end

function expectedterminalassets_yield_rednoise_rel(ymaxval, revexpratio, interestpar, yieldCV, corrrange, maxyears, reps)
    y0val = calc_y0(revexpratio, ymaxval, FarmBasePar().c, FarmBasePar().p)
    newbasepar = FarmBasePar(ymax=ymaxval, y0=y0val)
    inputsyield = maxprofitIII_vals(newbasepar)
    data=zeros(length(corrrange), 2)
    @threads for ri in eachindex(corrrange)
        noisepar = NoisePar(yielddisturbed_CV = yieldCV, yielddisturbed_r = corrrange[ri])
        termassetsdata = terminalassets_distribution_rel("yield", inputsyield, newbasepar, noisepar, interestpar, maxyears, reps)
        expectedprofitsdata = expectedterminalassets(termassetsdata, 25)
        data[ri,1] = corrrange[ri]
        data[ri,2] = expectedprofitsdata
    end
    return data
end

expectedterminalassets_yield_rednoise_rel(170, 1.33, InterestPar(), 0.1, 0.1:0.1:0.9, 50, 1000)
expectedterminalassets_yield_rednoise_rel(120, 1.33, InterestPar(), 0.1, 0.1:0.1:0.9, 50, 1000)
expectedterminalassets_yield_rednoise_rel(170, 1.00, InterestPar(), 0.1, 0.1:0.1:0.9, 50, 1000)
expectedterminalassets_yield_rednoise_rel(120, 1.00, InterestPar(), 0.1, 0.1:0.1:0.9, 50, 1000)

let 
    highymax_133 = expectedterminalassets_yield_rednoise_rel(170, 1.33, InterestPar(), 0.1, 0.1:0.1:0.9, 50, 1000)
    highymax_115 = expectedterminalassets_yield_rednoise_rel(170, 1.15, InterestPar(), 0.1, 0.1:0.1:0.9, 50, 1000)
    highymax_100 = expectedterminalassets_yield_rednoise_rel(170, 1.00, InterestPar(), 0.1, 0.1:0.1:0.9, 50, 1000)
    medymax_133 = expectedterminalassets_yield_rednoise_rel(140, 1.33, InterestPar(), 0.1, 0.1:0.1:0.9, 50, 1000)
    medymax_115 = expectedterminalassets_yield_rednoise_rel(140, 1.15, InterestPar(), 0.1, 0.1:0.1:0.9, 50, 1000)
    medymax_100 = expectedterminalassets_yield_rednoise_rel(140, 1.00, InterestPar(), 0.1, 0.1:0.1:0.9, 50, 1000)
    lowymax_133 = expectedterminalassets_yield_rednoise_rel(120, 1.33, InterestPar(), 0.1, 0.1:0.1:0.9, 50, 1000)
    lowymax_115 = expectedterminalassets_yield_rednoise_rel(120, 1.15, InterestPar(), 0.1, 0.1:0.1:0.9, 50, 1000)
    lowymax_100 = expectedterminalassets_yield_rednoise_rel(120, 1.00, InterestPar(), 0.1, 0.1:0.1:0.9, 50, 1000)
    rednoise_exptermassets = figure()
    subplot(3,1,1)
    # plot(highymax_133[:,1], highymax_133[:,2], color="blue", label="Rev/Exp = 1.33")
    plot(highymax_115[:,1], highymax_115[:,2], color="red", label="Rev/Exp = 1.15")
    plot(highymax_100[:,1], highymax_100[:,2], color="purple", label="Rev/Exp =1.00")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("Expected Terminal Assets")
    title("High ymax, low input eff")
    subplot(3,1,2)
    # plot(medymax_133[:,1], medymax_133[:,2], color="blue", label="Rev/Exp = 1.33")
    plot(medymax_115[:,1], medymax_115[:,2], color="red", label="Rev/Exp = 1.15")
    plot(medymax_100[:,1], medymax_100[:,2], color="purple", label="Rev/Exp =1.00")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("Expected Terminal Assets")
    title("Med ymax, med input eff")
    subplot(3,1,3)
    # plot(lowymax_133[:,1], lowymax_133[:,2], color="blue", label="Rev/Exp = 1.33")
    plot(lowymax_115[:,1], lowymax_115[:,2], color="red", label="Rev/Exp = 1.15")
    plot(lowymax_100[:,1], lowymax_100[:,2], color="purple", label="Rev/Exp =1.00")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("Expected Terminal Assets")
    title("Low ymax, high input eff")
    tight_layout()
    return rednoise_exptermassets
end


function variabilityterminalassets(distributiondata)
    meandata = abs(mean(distributiondata))
    sddata = std(distributiondata)
    return sddata/meandata
end