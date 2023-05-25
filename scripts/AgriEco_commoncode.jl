### Helper functions

function abpath()
    replace(@__DIR__, "scripts" => "")
end 

function isapprox_index(data, val)
    for i in 1:length(data)
        if isapprox(data[i], val, atol=0.05) == true
            return i
        end
    end
end

# function cv_calc(data)
#     stddev = std(data)
#     mn = mean(data)
#     return stddev/mn
# end

function prepDataFrame(array)
    return DataFrame(corrrange = array[:,1], wNL = array[:,2], woNL = array[:,3])
end

function CSVstringtoArrayVector(CSVstring)
    parsedCSVstring = map(split.(strip.(CSVstring, Ref(['[', ']'])), ',')) do nums
    parse.(Float64, nums)
    end
    return parsedCSVstring
end

function CSVtoArrayVector(CSVfile)
    corrangecol = CSVfile.corrrange
    wNLcol = CSVstringtoArrayVector(CSVfile.wNL)
    woNLcol = CSVstringtoArrayVector(CSVfile.woNL)
    return hcat(corrangecol, wNLcol, woNLcol )
end

### Parameters

#Useful functions for setting up parameters
function param_ratio(Ymax, I0, economicpar)
    return (0.8 * Ymax * economicpar.p) / (2 * sqrt(I0) * economicpar.c)
end

function param_absolute(Ymax, I0, economicpar)
    return (0.8 * Ymax * economicpar.p) - (2 * sqrt(I0) * economicpar.c)
end

function calc_c(rev_exp_ratio, Ymax, I0, economicpar)
    return (0.8 * Ymax * economicpar.p) / (2 * sqrt(I0) * rev_exp_ratio)
end

function calc_I0(rev_exp_ratio, Ymax, economicpar)
    return ((0.8 * Ymax * economicpar.p) / (2 * economicpar.c * rev_exp_ratio) )^2
end

function calc_Ymax(rev_exp_ratio, I0, economicpar)
    return (rev_exp_ratio * 2 * sqrt(I0) * economicpar.c) / (0.8 * economicpar.p)
end

function calc_c_abs(rev_exp_val, Ymax, I0, economicpar)
    return ( (0.8 * Ymax * economicpar.p) - rev_exp_val ) / (2 * sqrt(I0))
end

function calc_I0_abs(rev_exp_val, Ymax, economicpar)
    return (((0.8 * Ymax * economicpar.p) - rev_exp_val ) / (2 * economicpar.c))^2
end


# Ymax = 174.0 # yield per acre #budget summary field crops budgets 2022 corn conventional
# I0 = 9.9416

@with_kw mutable struct EconomicPar
    p = 6.70 # market price pert unit (not acre) #budget summary field crops budgets 2022 corn conventional
    c = 139
end

### Production and Parginal functions

function yieldIII(I, Ymax, I0)
    return Ymax * (I^2) / (I0 + (I^2))
end

function margprodIII(I, Ymax, I0)
    return 2 * I * Ymax * I0 / (( I0 + (I^2) )^2)
end

function margcostIII(I, Ymax, I0, economicpar)
    return economicpar.c / margprodIII(I, Ymax, I0)
end

function avvarcostIII(I, Ymax, I0, economicpar)
    Y = yieldIII(I, Ymax, I0)
    return economicpar.c * I / Y
end

### Input decision functions

function maxprofitIII_param(I, Ymax, I0, economicpar)
    return 2 * I * Ymax * I0 / (( I0 + (I^2) )^2) - economicpar.c/economicpar.p
end

function testIzeros_profit(testwidth, Ymax, I0, economicpar)
    testIrange = 0.0:testwidth:I0
    dataI = zeros(length(testIrange))
    for Ii in eachindex(testIrange)
        try
        dataI[Ii] = find_zero(I -> maxprofitIII_param(I, Ymax, I0, economicpar), testIrange[Ii])
        catch err
            if isa(err, Roots.ConvergenceFailed)
                dataI[Ii]  = NaN
            end
        end
    end
    
    intersects = unique(round.(filter(!isnan, dataI), digits=7))
    if length(intersects) > 2 || length(intersects) < 1
        error("Something is wrong with finding zeros function")
    elseif length(intersects) == 2
        I = maximum(intersects)
        Y = yieldIII(I, Ymax, I0)
        return [I, Y]
    else
        testIzeros_profit(testwidth*0.5, Ymax, I0, economicpar)
    end
end

function maxprofitIII_vals(Ymax, I0, economicpar)
    testwidth = trunc(I0/4, digits=0)
    Irange = 0.0:0.01:Int64(round(3*I0))
    MC = [margcostIII(I, Ymax, I0, economicpar) for I in Irange]
    if minimum(MC) >= economicpar.p
        return [0,0]
    else
        return testIzeros_profit(testwidth, Ymax, I0, economicpar)
    end
end

function d2Id2I(I, Ymax, I0)
    return (2 * I0 * Ymax * (-3 * (I^2) + I0))/(( I0 + (I^2) )^3)
end

### Yield disturbance function
function avvarcostkickIII(inputs, Y, economicpar)
    return economicpar.c * inputs / Y
end 

### Noise creation
@with_kw mutable struct NoiseParCV
    yielddisturbed_CV = 0.15
    yielddisturbed_r = 0.0
end

function noise_creation(μ, σ, corr, len, seed)
    Random.seed!(seed)
    white = rand(Normal(0.0, σ), Int64(len))
    intnoise = [white[1]]
    for i in 2:Int64(len)
        intnoise = append!(intnoise, corr * intnoise[i-1] + white[i] )
    end
    recentrednoise = zeros(Int64(len))
    for i in 1:Int64(len)
        recentrednoise[i] = intnoise[i]+μ
    end
    return recentrednoise
end

function convert_neg_zero(paramdata)
    newparamdata = zeros(length(paramdata))
    for i in 1:length(paramdata)
        if paramdata[i] <= 0.0
            newparamdata[i] = 0.0
        else
            newparamdata[i] = paramdata[i]
        end
    end
    return newparamdata
end

function yielddisturbed_CV(inputsyield, noiseparCV, maxyears, seed)
    sd = noiseparCV.yielddisturbed_CV * inputsyield[2]
    yieldnoise = noise_creation(inputsyield[2], sd, noiseparCV.yielddisturbed_r, maxyears, seed)
    convert_neg_zero(yieldnoise)
    return yieldnoise
end

function yieldnoise_createdata_CV(inputsyield, economicpar, noiseparCV, maxyears, seed)
    return hcat(1:1:maxyears, yielddisturbed_CV(inputsyield, noiseparCV, maxyears, seed), repeat([inputsyield[1]], maxyears), repeat([economicpar.p],maxyears), repeat([economicpar.c],maxyears))
end

function revenue_calc(yield, p)
    return yield * p
end

function expenses_calc(inputs, c)
    return inputs * c
end

#Experiment set up functions
function find_yintercept(slope, Ymax, I0)#takes I0 not reciprocal of I0 - but sets up yintercept for reciprocal
    return Ymax - slope * 1/I0
end

function guess_revexpintercept(revexpval, economicpar, linslope, linint)#Returns I0 (not the reciprocal)
    Ymaxrange = 100.0:2.0:170.0
    linerecipI0 = [(Ymax - linint)/linslope for Ymax in Ymaxrange]
    curverecipI0 = 1 ./ [calc_I0(revexpval, Ymax, economicpar) for Ymax in Ymaxrange]
    for i in eachindex(linerecipI0)
        for j in eachindex(curverecipI0)
            if isapprox(linerecipI0[i], curverecipI0[j], atol=0.05) == true
                return 1/curverecipI0[j]
            end
        end
    end
end

function find_revexpintercept(revexpval, economicpar, linslope, linint, guess) #Returns I0 (not the reciprocal)
    return find_zero(I0 -> linslope * (1/I0) + linint - (revexpval * 2 * economicpar.c * I0^(1/2))/economicpar.p, guess)
end

function calc_revexpintercept(origYmax, origI0, rise, run, revexpval, economicpar) #Returns I0 (not the reciprocal)
    linslope = rise/run
    linint = find_yintercept(linslope, origYmax, origI0)
    guess = guess_revexpintercept(revexpval, economicpar, linslope, linint)
    I0intercept = find_revexpintercept(revexpval, economicpar, linslope, linint, guess)
    return I0intercept
end

function calcYmaxI0vals(constrain, origYmax, revexpratios, rise, run, economicpar, startrevexpval::Float64=1.08) #Returns I0 values (not the reciprocal)
    origI0 = calc_I0(startrevexpval, origYmax, economicpar)
    vals = zeros(length(revexpratios), 2)
    if constrain == "Ymax"
        for i in eachindex(revexpratios)
            vals[i, 1] = origYmax
            vals[i, 2] = calc_I0(revexpratios[i], origYmax, economicpar)
        end
    elseif constrain =="I0"
        for i in eachindex(revexpratios)
            vals[i, 1] = calc_Ymax(revexpratios[i], origI0, economicpar)
            vals[i, 2] = origI0
        end
    elseif constrain == "neither"
        vals[1,1] = origYmax
        vals[1,2] = origI0
        for i in 2:length(revexpratios)
            newI0 = calc_revexpintercept(origYmax, origI0, rise, run, revexpratios[i], economicpar)
            vals[i,1] = calc_Ymax(revexpratios[i], newI0, economicpar)
            vals[i,2] = newI0
        end
    else
        error("constrain should be either Ymax, I0, or neither")
    end
    return vals
end

#Variability amplification and muting functions
function variabilityterminalassets(distributiondata)
    meandata = abs(mean(distributiondata))
    sddata = std(distributiondata)
    return sddata/meandata
end

function variabilityterminalassets_rednoise(dataset)
    corrrange = dataset[:,1]
    data=zeros(length(corrrange), 4)
    @threads for ri in eachindex(corrrange)
        variabilityassetsdata_NL = variabilityterminalassets(dataset[ri,2])
        variabilityassetsdata_woNL = variabilityterminalassets(dataset[ri,3])
        data[ri,1] = corrrange[ri]
        data[ri,2] = variabilityassetsdata_NL
        data[ri,3] = variabilityassetsdata_woNL
        data[ri,4] = variabilityassetsdata_NL/variabilityassetsdata_woNL
    end
    return data
end

function variabilityterminalassets_breakdown(dataset)
    corrrange = dataset[:,1]
    data=zeros(length(corrrange), 5)
    @threads for ri in eachindex(corrrange)
        data[ri,1] = corrrange[ri]
        data[ri,2] = std(dataset[ri,2])
        data[ri,3] = mean(dataset[ri,2])
        data[ri,4] = std(dataset[ri,3])
        data[ri,5] = mean(dataset[ri,3])
    end
    return data
end

#Resistance to yield disturbance - "bifurcation" point
function AVCK_MR(inputs, Ymax, economicpar)
    Yrange = 0.0:0.01:Ymax
    data = [avvarcostkickIII(inputs, Y, economicpar) for Y in Yrange]
    Yindex = isapprox_index(data, economicpar.p)
    return Yrange[Yindex]
end

function AVCK_MC_distance_revexp_data(constrain, origYmax, revexpratiorange, rise, run, economicpar)
    YmaxI0vals = calcYmaxI0vals(constrain, origYmax, revexpratiorange, rise, run, economicpar)
    data = zeros(length(revexpratiorange), 2)
    Irange = 0.0:0.1:30.0
    @threads for revexpi in eachindex(revexpratiorange)
        inputsyield = maxprofitIII_vals(YmaxI0vals[revexpi,1], YmaxI0vals[revexpi,2], economicpar)
        if minimum(filter(!isnan, [margcostIII(I, YmaxI0vals[revexpi,1], YmaxI0vals[revexpi,2], economicpar) for I in Irange])) >= economicpar.p #|| minimum(filter(!isnan, [avvarcostIII(I, par) for I in Irange])) >= par.p
            data[revexpi, 2] = NaN
        else
            data[revexpi, 1] = revexpratiorange[revexpi]
            data[revexpi, 2] = inputsyield[2] - AVCK_MR(inputsyield[1], YmaxI0vals[revexpi,1], economicpar)
        end
    end
    return data
end

# Resistance to error
function AVCmin(Ymax, I0, economicpar)
    Irange = 0.0:0.01:I0
    AVC = [avvarcostIII(I, Ymax, I0, economicpar) for I in Irange]
    return minimum(filter(!isnan,AVC))
end

function AVCmin_MR_distance_revexp_data(constrain, origYmax, revexpratiorange, Irange, rise, run, economicpar)
    YmaxI0vals = calcYmaxI0vals(constrain, origYmax, revexpratiorange, rise, run, economicpar)
    data = zeros(length(revexpratiorange), 2)
    @threads for revexpi in eachindex(revexpratiorange)
        if minimum(filter(!isnan, [margcostIII(I, YmaxI0vals[revexpi,1], YmaxI0vals[revexpi,2], economicpar) for I in Irange])) >= economicpar.p #|| minimum(filter(!isnan, [avvarcostIII(I, par) for I in Irange])) >= par.p
            data[revexpi, 2] = NaN
        else
            data[revexpi, 1] = revexpratiorange[revexpi]
            data[revexpi, 2] = economicpar.p - AVCmin(YmaxI0vals[revexpi,1], YmaxI0vals[revexpi,2], economicpar)
        end
    end
    return data
end
