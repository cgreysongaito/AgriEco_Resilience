include("packages.jl")
include("AgriEco_commoncode.jl")

@with_kw mutable struct InterestPar
    operatinginterest = 4
    debtinterest = 4
    savingsinterest = 2
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

function terminalassets_distribution(NL, inputsyield, basepar, noisepar, interestpar, maxyears, reps)
    assetsdebtdata =  zeros(reps)
    for i in 1:reps
        basedata = yieldnoise_createdata(inputsyield, basepar, noisepar, maxyears, i)
        simdata = simulation_NLposfeed(NL, basedata, interestpar)
        assetsdebtdata[i] = simdata[end]
    end
    return assetsdebtdata
end

function expectedterminalassets_posfeed_rednoise(ymaxval, revexpratio, interestpar, yielddisturbance_sd, corrrange, maxyears, reps)
    y0val = calc_y0(revexpratio, ymaxval, FarmBasePar().c, FarmBasePar().p)
    newbasepar = FarmBasePar(ymax=ymaxval, y0=y0val)
    inputsyield = maxprofitIII_vals(newbasepar)
    data=zeros(length(corrrange), 4)
    @threads for ri in eachindex(corrrange)
        noisepar = NoisePar(yielddisturbed_σ = yielddisturbance_sd, yielddisturbed_r = corrrange[ri])
        termassetsdata_NL = terminalassets_distribution("with", inputsyield, newbasepar, noisepar, interestpar, maxyears, reps)
        termassetsdata_woNL = terminalassets_distribution("without", inputsyield, newbasepar, noisepar, interestpar, maxyears, reps)
        expectedtermassetsdata_NL = expectedterminalassets(termassetsdata_NL, 30)
        expectedtermassetsdata_woNL = expectedterminalassets(termassetsdata_woNL, 30)
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

let
    sd = 20
    corrrange = 0.0:0.01:0.85
    reps = 2000
    highymax_133 = expectedterminalassets_posfeed_rednoise(170, 1.33, InterestPar(), sd, corrrange, 50, reps)
    highymax_115 = expectedterminalassets_posfeed_rednoise(170, 1.15, InterestPar(), sd, corrrange, 50, reps)
    highymax_100 = expectedterminalassets_posfeed_rednoise(170, 1.00, InterestPar(), sd, corrrange, 50, reps)
    medymax_133 = expectedterminalassets_posfeed_rednoise(140, 1.33, InterestPar(), sd, corrrange, 50, reps)
    medymax_115 = expectedterminalassets_posfeed_rednoise(140, 1.15, InterestPar(), sd, corrrange, 50, reps)
    medymax_100 = expectedterminalassets_posfeed_rednoise(140, 1.00, InterestPar(), sd, corrrange, 50, reps)
    lowymax_133 = expectedterminalassets_posfeed_rednoise(120, 1.33, InterestPar(), sd, corrrange, 50, reps)
    lowymax_115 = expectedterminalassets_posfeed_rednoise(120, 1.15, InterestPar(), sd, corrrange, 50, reps)
    lowymax_100 = expectedterminalassets_posfeed_rednoise(130, 1.00, InterestPar(), sd, corrrange, 50, reps)
    rednoise_exptermassets = figure()
    subplot(3,1,1)
    plot(highymax_133[:,1], highymax_133[:,4], color="blue", label="High ymax")
    plot(medymax_133[:,1], medymax_133[:,4], color="red", label="Med ymax")
    plot(lowymax_133[:,1], lowymax_133[:,4], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("ETAwNL/ETAwoNL")
    title("Rev/Exp = 1.33")
    subplot(3,1,2)
    plot(highymax_115[:,1], highymax_115[:,4], color="blue", label="High ymax")
    plot(medymax_115[:,1], medymax_115[:,4], color="red", label="Med ymax")
    plot(lowymax_115[:,1], lowymax_115[:,4], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("ETAwNL/ETAwoNL")
    title("Rev/Exp = 1.15")
    subplot(3,1,3)
    plot(highymax_100[:,1], highymax_100[:,4], color="blue", label="High ymax")
    plot(medymax_100[:,1], medymax_100[:,4], color="red", label="Med ymax")
    plot(lowymax_100[:,1], lowymax_100[:,4], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("ETAwNL/ETAwoNL")
    title("Rev/Exp = 1.10")
    tight_layout()
    return rednoise_exptermassets
end 


# #test of white noise against single year profits
# function variability_yieldnoise(ymaxval, revexpratio, σ, len)
#     y0val = calc_y0(revexpratio, ymaxval, FarmBasePar().c, FarmBasePar().p)
#     newpar = FarmBasePar(ymax=ymaxval, y0=y0val)
#     inputsyield = maxprofitIII_vals(newpar)
#     yielddata = noise_creation(inputsyield[2], σ, 0.0, len, 124)
#     inputsdata = repeat([inputsyield[1]], len)
#     pdata = repeat([newpar.p], len)
#     cdata = repeat([newpar.c], len)
#     profits = profitsdata(yielddata, inputsdata, pdata, cdata)
#     return std(profits)/mean(profits)
# end

# variability_yieldnoise(170, 1.10, 20, 50)
# variability_yieldnoise(120, 1.10, 20, 50)
# #std stays the same but CV changes even though slope differs between high and low ymax

function variabilityterminalassets_posfeed_rednoise(ymaxval, revexpratio, interestpar, yielddisturbance_sd, corrrange, maxyears, reps)
    y0val = calc_y0(revexpratio, ymaxval, FarmBasePar().c, FarmBasePar().p)
    newbasepar = FarmBasePar(ymax=ymaxval, y0=y0val)
    inputsyield = maxprofitIII_vals(newbasepar)
    data=zeros(length(corrrange), 4)
    @threads for ri in eachindex(corrrange)
        noisepar = NoisePar(yielddisturbed_σ = yielddisturbance_sd, yielddisturbed_r = corrrange[ri])
        termassetsdata_NL = terminalassets_distribution("with", inputsyield, newbasepar, noisepar, interestpar, maxyears, reps)
        termassetsdata_woNL = terminalassets_distribution("without", inputsyield, newbasepar, noisepar, interestpar, maxyears, reps)
        variabilityassetsdata_NL = variabilityterminalassets(termassetsdata_NL)
        variabilityassetsdata_woNL = variabilityterminalassets(termassetsdata_woNL)
        data[ri,1] = corrrange[ri]
        data[ri,2] = variabilityassetsdata_NL
        data[ri,3] = variabilityassetsdata_woNL
        data[ri,4] = variabilityassetsdata_NL/variabilityassetsdata_woNL
    end
    return data
end

let 
    sd = 20
    corrrange = 0.0:0.01:0.85
    reps = 2000
    highymax_133 = variabilityterminalassets_posfeed_rednoise(170, 1.33, InterestPar(), sd, corrrange, 50, reps)
    highymax_115 = variabilityterminalassets_posfeed_rednoise(170, 1.15, InterestPar(), sd, corrrange, 50, reps)
    highymax_100 = variabilityterminalassets_posfeed_rednoise(170, 1.00, InterestPar(), sd, corrrange, 50, reps)
    medymax_133 = variabilityterminalassets_posfeed_rednoise(140, 1.33, InterestPar(), sd, corrrange, 50, reps)
    medymax_115 = variabilityterminalassets_posfeed_rednoise(140, 1.15, InterestPar(), sd, corrrange, 50, reps)
    medymax_100 = variabilityterminalassets_posfeed_rednoise(140, 1.00, InterestPar(), sd, corrrange, 50, reps)
    lowymax_133 = variabilityterminalassets_posfeed_rednoise(120, 1.33, InterestPar(), sd, corrrange, 50, reps)
    lowymax_115 = variabilityterminalassets_posfeed_rednoise(120, 1.15, InterestPar(), sd, corrrange, 50, reps)
    lowymax_100 = variabilityterminalassets_posfeed_rednoise(130, 1.00, InterestPar(), sd, corrrange, 50, reps)
    rednoise_var_exptermassets = figure()    
    subplot(3,1,1)
    plot(highymax_133[:,1], highymax_133[:,4], color="blue", label="High ymax")
    plot(medymax_133[:,1], medymax_133[:,4], color="red", label="Med ymax")
    plot(lowymax_133[:,1], lowymax_133[:,4], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("VarwNL/VarwoNL")
    title("Rev/Exp = 1.33")
    subplot(3,1,2)
    plot(highymax_115[:,1], highymax_115[:,4], color="blue", label="High ymax")
    plot(medymax_115[:,1], medymax_115[:,4], color="red", label="Med ymax")
    plot(lowymax_115[:,1], lowymax_115[:,4], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("VarwNL/VarwoNL")
    title("Rev/Exp = 1.15")
    subplot(3,1,3)
    plot(highymax_100[:,1], highymax_100[:,4], color="blue", label="High ymax")
    plot(medymax_100[:,1], medymax_100[:,4], color="red", label="Med ymax")
    plot(lowymax_100[:,1], lowymax_100[:,4], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("VarwNL/VarwoNL")
    title("Rev/Exp = 1.10")
    tight_layout()
    return rednoise_var_exptermassets
end 

#TERMINAL ASSETS SHORTFALL 

function termassetsshortfall_posfeed_rednoise(ymaxval, revexpratio, shortfallval, interestpar, yielddisturbance_sd, corrrange, maxyears, reps)
    y0val = calc_y0(revexpratio, ymaxval, FarmBasePar().c, FarmBasePar().p)
    newbasepar = FarmBasePar(ymax=ymaxval, y0=y0val)
    inputsyield = maxprofitIII_vals(newbasepar)
    data=zeros(length(corrrange), 4)
    @threads for ri in eachindex(corrrange)
        noisepar = NoisePar(yielddisturbed_σ = yielddisturbance_sd, yielddisturbed_r = corrrange[ri])
        termassetsdata_NL = terminalassets_distribution("with", inputsyield, newbasepar, noisepar, interestpar, maxyears, reps)
        termassetsdata_woNL = terminalassets_distribution("without", inputsyield, newbasepar, noisepar, interestpar, maxyears, reps)
        termassetsshortfalldata_NL = count_shortfall(termassetsdata_NL, shortfallval)
        termassetsshortfalldata_woNL = count_shortfall(termassetsdata_woNL, shortfallval)
        data[ri,1] = corrrange[ri]
        data[ri,2] = termassetsshortfalldata_NL
        data[ri,3] = termassetsshortfalldata_woNL
        data[ri,4] = termassetsshortfalldata_NL/termassetsshortfalldata_woNL
    end
    return data
end

let 
    sd = 20
    corrrange = 0.0:0.01:0.85
    reps = 4000
    shortfallval = 1000
    highymax_133 = termassetsshortfall_posfeed_rednoise(170, 1.33, shortfallval, InterestPar(), sd, corrrange, 50, reps)
    highymax_115 = termassetsshortfall_posfeed_rednoise(170, 1.15, shortfallval, InterestPar(), sd, corrrange, 50, reps)
    highymax_100 = termassetsshortfall_posfeed_rednoise(170, 1.00, shortfallval, InterestPar(), sd, corrrange, 50, reps)
    medymax_133 = termassetsshortfall_posfeed_rednoise(140, 1.33, shortfallval, InterestPar(), sd, corrrange, 50, reps)
    medymax_115 = termassetsshortfall_posfeed_rednoise(140, 1.15, shortfallval, InterestPar(), sd, corrrange, 50, reps)
    medymax_100 = termassetsshortfall_posfeed_rednoise(140, 1.00, shortfallval, InterestPar(), sd, corrrange, 50, reps)
    lowymax_133 = termassetsshortfall_posfeed_rednoise(120, 1.33, shortfallval, InterestPar(), sd, corrrange, 50, reps)
    lowymax_115 = termassetsshortfall_posfeed_rednoise(120, 1.15, shortfallval, InterestPar(), sd, corrrange, 50, reps)
    lowymax_100 = termassetsshortfall_posfeed_rednoise(130, 1.00, shortfallval, InterestPar(), sd, corrrange, 50, reps)
    rednoise_var_exptermassets = figure()    
    subplot(3,1,1)
    plot(highymax_133[:,1], highymax_133[:,4], color="blue", label="High ymax")
    plot(medymax_133[:,1], medymax_133[:,4], color="red", label="Med ymax")
    plot(lowymax_133[:,1], lowymax_133[:,4], color="purple", label="Low ymax")
    xlabel("Autocorrelation")
    ylabel("ShortwNL/ShortwoNL")
    title("Rev/Exp = 1.33")
    subplot(3,1,2)
    plot(highymax_115[:,1], highymax_115[:,4], color="blue", label="High ymax")
    plot(medymax_115[:,1], medymax_115[:,4], color="red", label="Med ymax")
    plot(lowymax_115[:,1], lowymax_115[:,4], color="purple", label="Low ymax")
    xlabel("Autocorrelation")
    ylabel("ShortwNL/ShortwoNL")
    title("Rev/Exp = 1.15")
    subplot(3,1,3)
    plot(highymax_100[:,1], highymax_100[:,4], color="blue", label="High ymax")
    plot(medymax_100[:,1], medymax_100[:,4], color="red", label="Med ymax")
    plot(lowymax_100[:,1], lowymax_100[:,4], color="purple", label="Low ymax")
    xlabel("Autocorrelation")
    ylabel("ShortwNL/ShortwoNL")
    title("Rev/Exp = 1.10")
    tight_layout()
    return rednoise_var_exptermassets
end 
