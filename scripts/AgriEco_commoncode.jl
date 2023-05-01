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
function param_ratio(ymax, y0, economicpar)
    return (ymax * economicpar.p) / (2 * sqrt(y0) * economicpar.c)
end

function param_absolute(ymax, y0, economicpar)
    return (ymax * economicpar.p) - (2 * sqrt(y0) * economicpar.c)
end

function calc_c(rev_exp_ratio, ymax, y0, economicpar)
    return (ymax * economicpar.p) / (2 * sqrt(y0) * rev_exp_ratio)
end

function calc_y0(rev_exp_ratio, ymax, economicpar)
    return ((ymax * economicpar.p) / (2 * economicpar.c * rev_exp_ratio) )^2
end

function calc_ymax(rev_exp_ratio, y0, economicpar)
    return (rev_exp_ratio * 2 * sqrt(y0) * economicpar.c) / economicpar.p
end

function calc_c_abs(rev_exp_val, ymax, y0, economicpar)
    return ( (ymax * economicpar.p) - rev_exp_val ) / (2 * sqrt(y0))
end

function calc_y0_abs(rev_exp_val, ymax, economicpar)
    return (((ymax * economicpar.p) - rev_exp_val ) / (2 * economicpar.c))^2
end


# ymax = 174.0 # yield per acre #budget summary field crops budgets 2022 corn conventional
# y0 = 9.9416

@with_kw mutable struct EconomicPar
    p = 6.70 # market price pert unit (not acre) #budget summary field crops budgets 2022 corn conventional
    c = 139
end

### Production and Parginal functions

function yieldIII(I, ymax, y0)
    return ymax * (I^2) / (y0 + (I^2))
end

function margprodIII(I, ymax, y0)
    return 2 * I * ymax * y0 / (( y0 + (I^2) )^2)
end

function margcostIII(I, ymax, y0, economicpar)
    return economicpar.c / margprodIII(I, ymax, y0)
end

function avvarcostIII(I, ymax, y0, economicpar)
    Y = yieldIII(I, ymax, y0)
    return economicpar.c * I / Y
end

### Input decision functions

function maxprofitIII_param(I, ymax, y0, economicpar)
    return 2 * I * ymax * y0 / (( y0 + (I^2) )^2) - economicpar.c/economicpar.p
end

function testIzeros_profit(testwidth, ymax, y0, economicpar)
    testIrange = 0.0:testwidth:y0
    dataI = zeros(length(testIrange))
    for Ii in eachindex(testIrange)
        try
        dataI[Ii] = find_zero(I -> maxprofitIII_param(I, ymax, y0, economicpar), testIrange[Ii])
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
        Y = yieldIII(I, ymax, y0)
        return [I, Y]
    else
        testIzeros_profit(testwidth*0.5, ymax, y0, economicpar)
    end
end

function maxprofitIII_vals(ymax, y0, economicpar)
    testwidth = trunc(y0/4, digits=0)
    Irange = 0.0:0.01:Int64(round(3*y0))
    MC = [margcostIII(I, ymax, y0, economicpar) for I in Irange]
    if minimum(MC) >= economicpar.p
        return [0,0]
    else
        return testIzeros_profit(testwidth, ymax, y0, economicpar)
    end
end

function d2Id2I(I, ymax, y0)
    return (2 * y0 * ymax * (-3 * (I^2) + y0))/(( y0 + (I^2) )^3)
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

#Revenue Expenses helper functions
# function profit(I, Y, par)
#     @unpack p, c = par
#     return p * Y - c * I
# end

function revenue_calc(yield, p)
    return yield * p
end

function expenses_calc(inputs, c)
    return inputs * c
end

# function distribution_prob_convert(histogramdata)
#     sumcounts = sum(histogramdata.weights)
#     probdata = zeros(length(histogramdata.weights))
#     for bini in eachindex(probdata)
#         probdata[bini] = histogramdata.weights[bini]/sumcounts
#     end
#     return probdata
# end

#Experiment set up functions
function find_yintercept(slope, ymax, y0)#takes y0 not reciprocal of y0 - but sets up yintercept for reciprocal
    return ymax - slope * 1/y0
end

function guess_revexpintercept(revexpval, economicpar, linslope, linint)#Returns y0 (not the reciprocal)
    ymaxrange = 120.0:2.0:170.0
    linerecipy0 = [(ymax - linint)/linslope for ymax in ymaxrange]
    curverecipy0 = 1 ./ [calc_y0(revexpval, ymax, economicpar) for ymax in ymaxrange]
    for i in eachindex(linerecipy0)
        for j in eachindex(curverecipy0)
            if isapprox(linerecipy0[i], curverecipy0[j], atol=0.05) == true
                return 1/curverecipy0[j]
            end
        end
    end
end

function find_revexpintercept(revexpval, economicpar, linslope, linint, guess) #Returns y0 (not the reciprocal)
    return find_zero(y0 -> linslope * (1/y0) + linint - (revexpval * 2 * economicpar.c * y0^(1/2))/economicpar.p, guess)
end

function calc_revexpintercept(origymax, origy0, rise, run, revexpval, economicpar) #Returns y0 (not the reciprocal)
    linslope = rise/run
    linint = find_yintercept(linslope, origymax, origy0)
    guess = guess_revexpintercept(revexpval, economicpar, linslope, linint)
    y0intercept = find_revexpintercept(revexpval, economicpar, linslope, linint, guess)
    return y0intercept
end

function calcymaxy0vals(constrain, origymax, revexpratios, rise, run, economicpar) #Returns y0 values (not the reciprocal)
    origy0 = calc_y0(minimum(revexpratios), origymax, economicpar)
    vals = zeros(length(revexpratios), 2)
    if constrain == "ymax"
        for i in eachindex(revexpratios)
            vals[i, 1] = origymax
            vals[i, 2] = calc_y0(revexpratios[i], origymax, economicpar)
        end
    elseif constrain =="y0"
        for i in eachindex(revexpratios)
            vals[i, 1] = calc_ymax(revexpratios[i], origy0, economicpar)
            vals[i, 2] = origy0
        end
    elseif constrain == "neither"
        vals[1,1] = origymax
        vals[1,2] = origy0
        for i in 2:length(revexpratios)
            newy0 = calc_revexpintercept(origymax, origy0, rise, run, revexpratios[i], economicpar)
            vals[i,1] = calc_ymax(revexpratios[i], newy0, economicpar)
            vals[i,2] = newy0
        end
    else
        error("constrain should be either ymax, y0, or neither")
    end
    return vals
end

#Variability amplification and muting functions
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

