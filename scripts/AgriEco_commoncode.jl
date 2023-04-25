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

function profit(I, Y, par)
    @unpack p, c = par
    return p * Y - c * I
end

function cv_calc(data)
    stddev = std(data)
    mn = mean(data)
    return stddev/mn
end

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
function param_ratio(par)
    @unpack y0, ymax, p, c = par
    return (ymax * p) / (2 * sqrt(y0) * c)
end

function param_absolute(par)
    @unpack y0, ymax, p, c = par
    return (ymax * p) - (2 * sqrt(y0) * c)
end

function calc_c(rev_exp_ratio, ymax, y0, p)
    return (ymax * p) / (2 * sqrt(y0) * rev_exp_ratio)
end

function calc_y0(rev_exp_ratio, ymax, c, p)
    return ((ymax * p) / (2 * c * rev_exp_ratio) )^2
end

function calc_c_abs(rev_exp_val, ymax, y0, p)
    return ( (ymax * p) - rev_exp_val ) / (2 * sqrt(y0))
end

function calc_y0_abs(rev_exp_val, ymax, c, p)
    return (((ymax * p) - rev_exp_val ) / (2 * c))^2
end

@with_kw mutable struct FarmBasePar
    ymax = 174.0 # yield per acre #budget summary field crops budgets 2022 corn conventional
    y0 = 9.9416
    p = 6.70 # market price pert unit (not acre) #budget summary field crops budgets 2022 corn conventional
    c = 139
end

### production and marginal functions

function yieldIII(I, par)
    @unpack ymax, y0 = par
    return ymax * (I^2) / (y0 + (I^2))
end

function margprodIII(I, par)
    @unpack ymax, y0 = par
    return 2 * I * ymax * y0 / (( y0 + (I^2) )^2)
end

function margcostIII(I, par)
    @unpack c = par
    return c / margprodIII(I, par)
end

function avvarcostIII(I,par)
    @unpack c = par
    Y = yieldIII(I, par)
    return c * I / Y
end

# function yieldII(I, par)
#     @unpack ymax, y0 = par
#     return ymax * I / (y0 + I)
# end

# function margprodII(I, par)
#     @unpack ymax, y0 = par
#     return ymax * y0 / (( y0 + I )^2)
# end

# function margcostII(I, par)
#     @unpack c = par
#     return c / margprodII(I, par)
# end

# function avvarcostII(I,par)
#     @unpack c = par
#     Y = yieldII(I, par)
#     return c * I / Y
# end

### Input decision functions

function maxprofitIII_param(I, par)
    @unpack y0, ymax, c, p = par
    return 2 * I * ymax * y0 / (( y0 + (I^2) )^2) - c/p
end

# function maxprofitIII_vals_original(par)
#     Irange = 0.0:0.01:Int64(round(3*par.y0))
#     MC = [margcostIII(I, par) for I in Irange]
#     if minimum(MC) >= par.p
#         return [0,0]
#     else
#         try
#         I = find_zero(I -> maxprofitIII_param(I, par), 2 * sqrt(par.y0))
#         Y = yieldIII(I, par)
#         [I, Y]
#         catch err
#             if isa(err, Roots.ConvergenceFailed)
#                 smallerguess = (sqrt(par.y0) + find_zero(I -> maxprofitIII_param(I, par), 0.0))/2
#                 I = find_zero(I -> maxprofitIII_param(I, par), smallerguess)
#                 Y = yieldIII(I, par)
#                 [I, Y]
#             end
#         end
#     end
# end


function testIzeros_profit(testwidth, par)
    testIrange = 0.0:testwidth:par.y0
    dataI = zeros(length(testIrange))
    for Ii in eachindex(testIrange)
        try
        dataI[Ii] = find_zero(I -> maxprofitIII_param(I, par), testIrange[Ii])
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
        Y = yieldIII(I, par)
        return [I, Y]
    else
        testIzeros_profit(testwidth*0.5, par)
    end
end

function maxprofitIII_vals(par)
    testwidth = trunc(par.y0/4, digits=0)
    Irange = 0.0:0.01:Int64(round(3*par.y0))
    MC = [margcostIII(I, par) for I in Irange]
    if minimum(MC) >= par.p
        return [0,0]
    else
        return testIzeros_profit(testwidth, par)
    end
end

function d2Id2I(I, par)
    @unpack y0, ymax = par
    return (2 * y0 * ymax * (-3 * (I^2) + y0))/(( y0 + (I^2) )^3)
end

# d2Id2I(9, FarmBasePar(ymax=174))

# let 
#     par = FarmBasePar(ymax=120)
#     Irange = 0.0:0.1:30.0
#     data = [d2Id2I(I, par) for I in Irange]
#     # test = figure()
#     # plot(Irange, data)
#     return data
# end

function maxyieldIII_param(I, slope, par)
    @unpack y0, ymax, c, p = par
    return 2 * I * ymax * y0 / (( y0 + (I^2) )^2) - slope
end

function testIzeros_yield(testwidth, slope, par)
    testIrange = 0.0:testwidth:par.y0
    dataI = zeros(length(testIrange))
    for Ii in eachindex(testIrange)
        try
        dataI[Ii] = find_zero(I -> maxyieldIII_param(I, slope, par), testIrange[Ii])
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
        Y = yieldIII(I, par)
        return [I, Y]
    else
        testIzeros_yield(testwidth*0.5, slope, par)
    end
end

function maxyieldIII_vals(slope, par)
    testwidth = trunc(par.y0/4, digits=0)
    Irange = 0.0:0.01:Int64(round(3*par.y0))
    MC = [margcostIII(I, par) for I in Irange]
    if minimum(MC) >= par.p
        return [0,0]
    else
        return testIzeros_yield(testwidth, slope, par)
    end
end

# function maxyieldIII_vals(slope, par)
#     try
#     I = find_zero(I -> maxyieldIII_param(I, slope, par), 2 * sqrt(par.y0))
#     Y = yieldIII(I, par)
#     [I, Y]
#     catch err
#         if isa(err, Roots.ConvergenceFailed)
#             smallerguess = (sqrt(par.y0) + find_zero(I -> maxyieldIII_param(I, slope, par), 0.0))/2
#             I = find_zero(I -> maxyieldIII_param(I, slope, par), smallerguess)
#             Y = yieldIII(I, par)
#             [I, Y]
#         end
#     end
# end

### Yield disturbance function
function avvarcostkickIII(inputs, Y, par)
    @unpack c = par
    return c * inputs / Y
end 

### Noise creation
@with_kw mutable struct NoisePar
    yielddisturbed_σ = 0.2
    p_σ = 0.2
    c_σ = 0.2
    yielddisturbed_r = 0.0
    p_r = 0.0
    c_r = 0.0
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

function yielddisturbed(inputsyield, noisepar, maxyears, seed)
    yieldnoise = noise_creation(inputsyield[2], noisepar.yielddisturbed_σ, noisepar.yielddisturbed_r, maxyears, seed)
    convert_neg_zero(yieldnoise)
    return yieldnoise
end

function yieldnoise_createdata(inputsyield, basepar, noisepar, maxyears, seed)
    return hcat(1:1:maxyears, yielddisturbed(inputsyield, noisepar, maxyears, seed), repeat([inputsyield[1]], maxyears), repeat([basepar.p],maxyears), repeat([basepar.c],maxyears))
end


function revenue_calc(yield, p)
    return yield * p
end

function expenses_calc(inputs, c)
    return inputs * c
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

function expectedterminalassets_rednoise(dataset)
    corrrange = dataset[:,1]
    data=zeros(length(corrrange), 4)
    @threads for ri in eachindex(corrrange)
        expectedtermassetsdata_NL = expectedterminalassets(dataset[ri,2], 30)
        expectedtermassetsdata_woNL = expectedterminalassets(dataset[ri,3], 30)
        data[ri,1] = corrrange[ri]
        data[ri,2] = expectedtermassetsdata_NL
        data[ri,3] = expectedtermassetsdata_woNL
        if expectedtermassetsdata_NL >= 0.0
            data[ri,4] = abs(expectedtermassetsdata_NL)/abs(expectedtermassetsdata_woNL)
        else
            data[ri,4] = -abs(expectedtermassetsdata_NL)/abs(expectedtermassetsdata_woNL)
        end
    end
    return data
end

function variabilityterminalassets(distributiondata) #I think you do want CV for here because NL will pull the mean quite far apart
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

function count_shortfall(distributiondata, shortfallval)
    number = 0
    for i in eachindex(distributiondata)
        if distributiondata[i] < shortfallval
            number +=1
        end
    end
    return number
end

function termassetsshortfall_rednoise(dataset, shortfallval)
    corrrange = dataset[:,1]
    data=zeros(length(corrrange), 4)
    @threads for ri in eachindex(corrrange)
        termassetsshortfalldata_NL = count_shortfall(dataset[ri,2], shortfallval)
        termassetsshortfalldata_woNL = count_shortfall(dataset[ri,3], shortfallval)
        data[ri,1] = corrrange[ri]
        data[ri,2] = termassetsshortfalldata_NL
        data[ri,3] = termassetsshortfalldata_woNL
        data[ri,4] = termassetsshortfalldata_NL/termassetsshortfalldata_woNL
    end
    return data
end
    

