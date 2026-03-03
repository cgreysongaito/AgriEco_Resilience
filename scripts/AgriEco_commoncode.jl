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
function param_OERatio(Ymax, I0, economicpar)
    return (2 * sqrt(I0) * economicpar.c)/ (0.8 * Ymax * economicpar.p)
end

function param_absolute(Ymax, I0, economicpar)
    return (0.8 * Ymax * economicpar.p) - (2 * sqrt(I0) * economicpar.c)
end

function calc_c(OEratio, Ymax, I0, economicpar)
    return (OEratio * 0.8 * Ymax * economicpar.p) / (2 * sqrt(I0) )
end

function calc_I0(OEratio, Ymax, economicpar)
    return ((OEratio * 0.8 * Ymax * economicpar.p) / (2 * economicpar.c ) )^2
end

function calc_Ymax(OEratio, I0, economicpar)
    return (2 * sqrt(I0) * economicpar.c) / (OEratio * 0.8 * economicpar.p)
end

function calc_c_abs(profits, Ymax, I0, economicpar)
    return ( (0.8 * Ymax * economicpar.p) - profits ) / (2 * sqrt(I0))
end

function calc_I0_abs(profits, Ymax, economicpar)
    return (((0.8 * Ymax * economicpar.p) - profits ) / (2 * economicpar.c))^2
end

@with_kw mutable struct EconomicPar
    p = 6.70 # market price per unit (not acre) #budget summary field crops budgets 2022 corn conventional
    c = 662.1744 #666.1714285714287
end

### Production and Marginal functions

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
    testIrange = 0.0:testwidth:2*sqrt(I0)
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
    testwidth = trunc(I0/4, digits=3)
    Irange = 0.0:0.01:Int64(round(5*I0))
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
# function find_yintercept(slope, Ymax, I0)#takes I0 not reciprocal of I0 - but sets up yintercept for reciprocal
#     return Ymax - slope * 1/I0
# end

# function guess_revexpintercept(OERatio, economicpar, linslope, linint)#Returns I0 (not the reciprocal)
#     Ymaxrange = 100.0:2.0:170.0
#     linerecipI0 = [(Ymax - linint)/linslope for Ymax in Ymaxrange]
#     curverecipI0 = 1 ./ [calc_I0(OERatio, Ymax, economicpar) for Ymax in Ymaxrange]
#     for i in eachindex(linerecipI0)
#         for j in eachindex(curverecipI0)
#             if isapprox(linerecipI0[i], curverecipI0[j], atol=0.05) == true
#                 return 1/curverecipI0[j]
#             end
#         end
#     end
# end

# function find_revexpintercept(OERatio, economicpar, linslope, linint, guess) #Returns I0 (not the reciprocal)
#     return find_zero(I0 -> linslope * (1/I0) + linint - (2 * economicpar.c * I0^(1/2))/(economicpar.p * OERatio), guess)
# end

# function calc_revexpintercept(origYmax, origI0, rise, run, OERatio, economicpar) #Returns I0 (not the reciprocal)
#     linslope = rise/run
#     linint = find_yintercept(linslope, origYmax, origI0)
#     guess = guess_revexpintercept(OERatio, economicpar, linslope, linint)
#     I0intercept = find_revexpintercept(OERatio, economicpar, linslope, linint, guess)
#     return I0intercept
# end

function calcYmaxI0vals_YmaxOERatio(Ymaxval, OERatios, economicpar) #Returns I0 values (not the reciprocal)
    vals = zeros(length(OERatios), 2)
    for i in eachindex(OERatios)
        vals[i, 1] = Ymaxval
        vals[i, 2] = calc_I0(OERatios[i], Ymaxval, economicpar)
    end
    return vals
end

function calcYmaxI0vals_OERatiocurve_prep(OERatio, Ymaxvals, economicpar) #Returns I0 values (not the reciprocal)
    vals = zeros(length(Ymaxvals),2)
    for i in eachindex(Ymaxvals)
        vals[i,1] = Ymaxvals[i]
        vals[i,2] = calc_I0(OERatio, Ymaxvals[i], economicpar)
    end
    return vals
end

function calcYmaxI0vals_OERatiocurve_final(OERatios, Ymaxvals, economicpar) #Returns I0 values (not the reciprocal)
    vals = Array{Array{Float64}}(undef,length(OERatios))
    for i in eachindex(OERatios)
        vals[i] = calcYmaxI0vals_OERatiocurve_prep(OERatios[i], Ymaxvals, economicpar)
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
    data=zeros(length(corrrange), 7)
    @threads for ri in eachindex(corrrange)
        data[ri,1] = corrrange[ri]
        data[ri,2] = std(dataset[ri,2])
        data[ri,3] = mean(dataset[ri,2])
        data[ri,4] = std(dataset[ri,3])
        data[ri,5] = mean(dataset[ri,3])
        data[ri,6] = std(dataset[ri,2])/mean(dataset[ri,2])
        data[ri,7] = std(dataset[ri,3])/mean(dataset[ri,3])
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

function AVCK_MC_distance_ymaxOERatiocurve_data(Ymaxval, OERatiorange, noiseCV, economicpar)
    YmaxI0vals = calcYmaxI0vals_YmaxOERatio(Ymaxval, OERatiorange, economicpar)
    data = zeros(length(OERatiorange), 3)
    Irange = 0.0:0.1:20.0
    @threads for oeri in eachindex(OERatiorange)
        inputsyield = maxprofitIII_vals(YmaxI0vals[oeri,1], YmaxI0vals[oeri,2], economicpar)
        if minimum(filter(!isnan, [margcostIII(I, YmaxI0vals[oeri,1], YmaxI0vals[oeri,2], economicpar) for I in Irange])) >= economicpar.p #|| minimum(filter(!isnan, [avvarcostIII(I, par) for I in Irange])) >= par.p
            data[oeri, 2] = NaN
        else
            data[oeri, 1] = OERatiorange[oeri]
            data[oeri, 2] = inputsyield[2] - AVCK_MR(inputsyield[1], YmaxI0vals[oeri,1], economicpar)
            data[oeri, 3] = data[oeri, 2]/(noiseCV*inputsyield[2])
        end
    end
    return data
end

# Resistance to error
function AVCmin(Ymax, I0, economicpar)
    Irange = 0.0:0.01:100*I0
    AVC = [avvarcostIII(I, Ymax, I0, economicpar) for I in Irange]
    return minimum(filter(!isnan,AVC))
end

function AVCmin_MR_distance_ymaxOERatiocurve_data(Ymaxval, OERatiorange, Irange, economicpar)
    YmaxI0vals = calcYmaxI0vals_YmaxOERatio(Ymaxval, OERatiorange, economicpar)
    data = zeros(length(OERatiorange), 2)
    @threads for oeri in eachindex(OERatiorange)
        if minimum(filter(!isnan, [margcostIII(I, YmaxI0vals[oeri,1], YmaxI0vals[oeri,2], economicpar) for I in Irange])) >= economicpar.p #|| minimum(filter(!isnan, [avvarcostIII(I, par) for I in Irange])) >= par.p
            data[oeri, 2] = NaN
        else
            data[oeri, 1] = OERatiorange[oeri]
            data[oeri, 2] = economicpar.p - AVCmin(YmaxI0vals[oeri,1], YmaxI0vals[oeri,2], economicpar)
        end
    end
    return data
end

function marginalcurves(ymaxval, I0val, par)
    inputsyield = maxprofitIII_vals(ymaxval, I0val, par)
    Irange = 0.0:0.0001:20.0
    Yield = [yieldIII(I, ymaxval, I0val) for I in Irange]
    MC = [margcostIII(I, ymaxval, I0val, par) for I in Irange]
    AVC = [avvarcostIII(I, ymaxval, I0val, EconomicPar()) for I in Irange]
    data = Array{Array{Float64}}(undef,2)
    data[1] = inputsyield
    data[2] = hcat(Yield, MC, AVC)
    return data
end


## Expected Terminal Assets
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

function expectedterminalassets_absolute(dataset)
    corrrange = dataset[:,1]
    data=zeros(length(corrrange), 2)
    @threads for ri in eachindex(corrrange)
        expectedtermassetsdata = expectedterminalassets(dataset[ri,2], 30)
        data[ri,1] = corrrange[ri]
        data[ri,2] = expectedtermassetsdata
    end
    return data
end

function expectedterminalassets_residual(dataset)
    corrrange = dataset[:,1]
    data=zeros(length(corrrange), 2)
    @threads for ri in eachindex(corrrange)
        expectedtermassetsdata_wNL = expectedterminalassets(dataset[ri,2], 30)
        expectedtermassetsdata_woNL = expectedterminalassets(dataset[ri,3], 30)
        data[ri,1] = corrrange[ri]
        data[ri,2] = expectedtermassetsdata_wNL-expectedtermassetsdata_woNL
    end
    return data
end

function expectedterminalassets_residualstand(dataset)
    corrrange = dataset[:,1]
    data=zeros(length(corrrange), 2)
    @threads for ri in eachindex(corrrange)
        expectedtermassetsdata_wNL = expectedterminalassets(dataset[ri,2], 30)
        expectedtermassetsdata_woNL = expectedterminalassets(dataset[ri,3], 30)
        data[ri,1] = corrrange[ri]
        data[ri,2] = (expectedtermassetsdata_wNL-expectedtermassetsdata_woNL)/expectedtermassetsdata_woNL
    end
    return data
end

function expectedterminalassets_residualstandyield(dataset, yield)
    corrrange = dataset[:,1]
    data=zeros(length(corrrange), 2)
    @threads for ri in eachindex(corrrange)
        expectedtermassetsdata_wNL = expectedterminalassets(dataset[ri,2], 30)
        expectedtermassetsdata_woNL = expectedterminalassets(dataset[ri,3], 30)
        data[ri,1] = corrrange[ri]
        data[ri,2] = (expectedtermassetsdata_wNL-expectedtermassetsdata_woNL)/yield
    end
    return data
end
