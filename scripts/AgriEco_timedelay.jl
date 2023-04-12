include("packages.jl")
include("AgriEco_commoncode.jl")

function delayedinputs(defaultinputs, minfraction, lastyrsactualyield, lastyrsprojectedyield)
    lastyrsoutcome = lastyrsactualyield/lastyrsprojectedyield
    if lastyrsoutcome > minfraction
        return defaultinputs * lastyrsactualyield/lastyrsprojectedyield
    else
        return defaultinputs * minfraction
    end
end

function NLtimedelay_data(defaultinputsyield, basepar, noisepar, minfraction, maxyears, seed)
    basenoise = noise_creation(0.0, noisepar.yielddisturbed_σ, noisepar.yielddisturbed_r, maxyears, seed)
    inputsdata = zeros(maxyears)
    inputsdata[1] = defaultinputsyield[1]
    yielddata = zeros(maxyears)
    yielddata[1] = defaultinputsyield[2] + basenoise[1]
    for i in 2:maxyears
        lastyrsprojectedyield = yieldIII(inputsdata[i-1], basepar)
        inputsdata[i] = delayedinputs(defaultinputsyield[1], minfraction, yielddata[i-1], lastyrsprojectedyield)
        yielddata[i] = yieldIII(inputsdata[i], basepar) + basenoise[i]
    end
    return hcat(inputsdata, convert_neg_zero(yielddata))
end

function simulation_NLtimedelay(basedata, basepar)
    maxyears = size(basedata,1)
    assetsdebt = zeros(maxyears+1)
    for yr in 2:maxyears+1
        expenses = expenses_calc(basedata[yr-1,1], basepar.c)
        revenue = revenue_calc(basedata[yr-1,2], basepar.p)
        assetsdebt[yr] = assetsdebt[yr-1] + (revenue - expenses)
    end
    return assetsdebt
end


function terminalassets_distribution_NLtimedelay(NL, defaultinputsyield, basepar, noisepar, minfraction, maxyears, reps)
    assetsdebtdata =  zeros(reps)
    if NL == "with"
        for i in 1:reps
            basedataNL = NLtimedelay_data(defaultinputsyield, basepar, noisepar, minfraction, maxyears, i)
            simdata = simulation_NLtimedelay(basedataNL, basepar)
            assetsdebtdata[i] = simdata[end]
        end
    elseif NL == "without"
        for i in 1:reps
            basedatawoNL = hcat(repeat([defaultinputsyield[1]], maxyears), yielddisturbed(defaultinputsyield, noisepar, maxyears, i))
            simdata = simulation_NLtimedelay(basedatawoNL, basepar)
            assetsdebtdata[i] = simdata[end]
        end
    else
        error("NL should be either with or without")
    end
    return assetsdebtdata
end

# let 
#     ymaxval = 170
#     y0val = calc_y0(1.33, 170, 139, 6.70)
#     basepar = FarmBasePar(ymax = ymaxval, y0 = y0val)
#     3.88448*84.5482/yieldIII(3.88448, basepar)
# end


# let 
#     ymaxval = 170
#     y0val = calc_y0(1.33, 170, 139, 6.70)
#     basepar = FarmBasePar(ymax = ymaxval, y0 = y0val)
#     noisepar = NoisePar(yielddisturbed_σ = 20, yielddisturbed_r = 0.0)
#     return terminalassets_distribution_NLtimedelay("without", basepar, noisepar, 0.2, 50, 10)
#     # defaultinputsyield = maxprofitIII_vals(basepar)
#     # basedata = NLtimedelay_data(defaultinputsyield, basepar, noisepar, 0.2, 50, 48)
#     # returnsimulation_NLtimedelay(basedata, basepar)
# end

function expectedterminalassets_timedelay_rednoise(ymaxval, revexpratio, yielddisturbance_sd, corrrange, minfraction, maxyears, reps)
    y0val = calc_y0(revexpratio, ymaxval, FarmBasePar().c, FarmBasePar().p)
    newbasepar = FarmBasePar(ymax=ymaxval, y0=y0val)
    defaultinputsyield = maxprofitIII_vals(newbasepar)
    data=zeros(length(corrrange), 4)
    @threads for ri in eachindex(corrrange)
        noisepar = NoisePar(yielddisturbed_σ = yielddisturbance_sd, yielddisturbed_r = corrrange[ri])
        termassetsdata_NL = terminalassets_distribution_NLtimedelay("with", defaultinputsyield, newbasepar, noisepar, minfraction, maxyears, reps)
        termassetsdata_woNL = terminalassets_distribution_NLtimedelay("without", defaultinputsyield, newbasepar, noisepar, minfraction, maxyears, reps)
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
    highymax_133 = expectedterminalassets_timedelay_rednoise(170, 1.33, sd, corrrange, 0.2, 50, reps)
    highymax_115 = expectedterminalassets_timedelay_rednoise(170, 1.15, sd, corrrange, 0.2, 50, reps)
    highymax_100 = expectedterminalassets_timedelay_rednoise(170, 1.00, sd, corrrange, 0.2, 50, reps)
    medymax_133 = expectedterminalassets_timedelay_rednoise(140, 1.33, sd, corrrange, 0.2, 50, reps)
    medymax_115 = expectedterminalassets_timedelay_rednoise(140, 1.15, sd, corrrange, 0.2, 50, reps)
    medymax_100 = expectedterminalassets_timedelay_rednoise(140, 1.00, sd, corrrange, 0.2, 50, reps)
    lowymax_133 = expectedterminalassets_timedelay_rednoise(120, 1.33, sd, corrrange, 0.2, 50, reps)
    lowymax_115 = expectedterminalassets_timedelay_rednoise(120, 1.15, sd, corrrange, 0.2, 50, reps)
    lowymax_100 = expectedterminalassets_timedelay_rednoise(130, 1.00, sd, corrrange, 0.2, 50, reps)
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

#WHY AM I RECREATING THE DATASET EVERYTIME - COULDNT I JUST MAKE ONE DATASET AND THEN MEASURE EXPECTED/VARIABILITY/PROFTI SHORTFALL

function variabilityterminalassets_timedelay_rednoise(ymaxval, revexpratio, yielddisturbance_sd, corrrange, minfraction, maxyears, reps)
    y0val = calc_y0(revexpratio, ymaxval, FarmBasePar().c, FarmBasePar().p)
    newbasepar = FarmBasePar(ymax=ymaxval, y0=y0val)
    defaultinputsyield = maxprofitIII_vals(newbasepar)
    data=zeros(length(corrrange), 4)
    @threads for ri in eachindex(corrrange)
        noisepar = NoisePar(yielddisturbed_σ = yielddisturbance_sd, yielddisturbed_r = corrrange[ri])
        termassetsdata_NL = terminalassets_distribution_NLtimedelay("with", defaultinputsyield, newbasepar, noisepar, minfraction, maxyears, reps)
        termassetsdata_woNL = terminalassets_distribution_NLtimedelay("without", defaultinputsyield, newbasepar, noisepar, minfraction, maxyears, reps)
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
    minfraction = 0.2
    maxyears = 50
    reps = 2000
    highymax_133 = variabilityterminalassets_timedelay_rednoise(170, 1.33, sd, corrrange, minfraction, maxyears, reps)
    highymax_115 = variabilityterminalassets_timedelay_rednoise(170, 1.15, sd, corrrange, minfraction, maxyears, reps)
    highymax_100 = variabilityterminalassets_timedelay_rednoise(170, 1.00, sd, corrrange, minfraction, maxyears, reps)
    medymax_133 = variabilityterminalassets_timedelay_rednoise(140, 1.33, sd, corrrange, minfraction, maxyears, reps)
    medymax_115 = variabilityterminalassets_timedelay_rednoise(140, 1.15, sd, corrrange, minfraction, maxyears, reps)
    medymax_100 = variabilityterminalassets_timedelay_rednoise(140, 1.00, sd, corrrange, minfraction, maxyears, reps)
    lowymax_133 = variabilityterminalassets_timedelay_rednoise(120, 1.33, sd, corrrange, minfraction, maxyears, reps)
    lowymax_115 = variabilityterminalassets_timedelay_rednoise(120, 1.15, sd, corrrange, minfraction, maxyears, reps)
    lowymax_100 = variabilityterminalassets_timedelay_rednoise(130, 1.00, sd, corrrange, minfraction, maxyears, reps)
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

function termassetsshortfall_timedelay_rednoise(ymaxval, revexpratio, shortfallval, yielddisturbance_sd, corrrange, minfraction, maxyears, reps)
    y0val = calc_y0(revexpratio, ymaxval, FarmBasePar().c, FarmBasePar().p)
    newbasepar = FarmBasePar(ymax=ymaxval, y0=y0val)
    defaultinputsyield = maxprofitIII_vals(newbasepar)
    data=zeros(length(corrrange), 4)
    @threads for ri in eachindex(corrrange)
        noisepar = NoisePar(yielddisturbed_σ = yielddisturbance_sd, yielddisturbed_r = corrrange[ri])
        termassetsdata_NL = terminalassets_distribution_NLtimedelay("with", defaultinputsyield, newbasepar, noisepar, minfraction, maxyears, reps)
        termassetsdata_woNL = terminalassets_distribution_NLtimedelay("without", defaultinputsyield, newbasepar, noisepar, minfraction, maxyears, reps)
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
    minfraction = 0.2
    maxyears = 50
    reps = 4000
    shortfallval = 1000
    highymax_133 = termassetsshortfall_timedelay_rednoise(170, 1.33, shortfallval, sd, corrrange, minfraction, maxyears, reps)
    highymax_115 = termassetsshortfall_timedelay_rednoise(170, 1.15, shortfallval, sd, corrrange, minfraction, maxyears, reps)
    highymax_100 = termassetsshortfall_timedelay_rednoise(170, 1.00, shortfallval, sd, corrrange, minfraction, maxyears, reps)
    medymax_133 = termassetsshortfall_timedelay_rednoise(140, 1.33, shortfallval, sd, corrrange, minfraction, maxyears, reps)
    medymax_115 = termassetsshortfall_timedelay_rednoise(140, 1.15, shortfallval, sd, corrrange, minfraction, maxyears, reps)
    medymax_100 = termassetsshortfall_timedelay_rednoise(140, 1.00, shortfallval, sd, corrrange, minfraction, maxyears, reps)
    lowymax_133 = termassetsshortfall_timedelay_rednoise(120, 1.33, shortfallval, sd, corrrange, minfraction, maxyears, reps)
    lowymax_115 = termassetsshortfall_timedelay_rednoise(120, 1.15, shortfallval, sd, corrrange, minfraction, maxyears, reps)
    lowymax_100 = termassetsshortfall_timedelay_rednoise(130, 1.00, shortfallval, sd, corrrange, minfraction, maxyears, reps)
    rednoise_shortfall_exptermassets = figure()    
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
    return rednoise_shortfall_exptermassets
end 



