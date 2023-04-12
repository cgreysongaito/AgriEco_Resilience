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

function terminalassets_timedelay_rednoise_dataset(ymaxval, revexpratio, yielddisturbance_sd, corrrange, minfraction, maxyears, reps)
    y0val = calc_y0(revexpratio, ymaxval, FarmBasePar().c, FarmBasePar().p)
    newbasepar = FarmBasePar(ymax=ymaxval, y0=y0val)
    defaultinputsyield = maxprofitIII_vals(newbasepar)
    data = Array{Vector{Float64}}(undef,length(corrrange), 2)
    @threads for ri in eachindex(corrrange)
        noisepar = NoisePar(yielddisturbed_σ = yielddisturbance_sd, yielddisturbed_r = corrrange[ri])
        data[ri, 1] = terminalassets_distribution_NLtimedelay("with", defaultinputsyield, newbasepar, noisepar, minfraction, maxyears, reps)
        data[ri, 2] = terminalassets_distribution_NLtimedelay("without", defaultinputsyield, newbasepar, noisepar, minfraction, maxyears, reps)
    end
    return hcat(corrrange, data)
end

sd = 20
corrrange = 0.0:0.01:0.85
minfraction = 0.2
maxyears = 50
reps = 1000
highymax_133_timedelay_data = terminalassets_timedelay_rednoise_dataset(170, 1.33, sd, corrrange, minfraction, maxyears, reps)
highymax_115_timedelay_data = terminalassets_timedelay_rednoise_dataset(170, 1.15, sd, corrrange, minfraction, maxyears, reps)
highymax_100_timedelay_data = terminalassets_timedelay_rednoise_dataset(170, 1.00, sd, corrrange, minfraction, maxyears, reps)
medymax_133_timedelay_data = terminalassets_timedelay_rednoise_dataset(140, 1.33, sd, corrrange, minfraction, maxyears, reps)
medymax_115_timedelay_data = terminalassets_timedelay_rednoise_dataset(140, 1.15, sd, corrrange, minfraction, maxyears, reps)
medymax_100_timedelay_data = terminalassets_timedelay_rednoise_dataset(140, 1.00, sd, corrrange, minfraction, maxyears, reps)
lowymax_133_timedelay_data = terminalassets_timedelay_rednoise_dataset(120, 1.33, sd, corrrange, minfraction, maxyears, reps)
lowymax_115_timedelay_data = terminalassets_timedelay_rednoise_dataset(120, 1.15, sd, corrrange, minfraction, maxyears, reps)
lowymax_100_timedelay_data = terminalassets_timedelay_rednoise_dataset(130, 1.00, sd, corrrange, minfraction, maxyears, reps)

function expectedterminalassets_timedelay_rednoise(dataset)
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

let
    highymax_133 = expectedterminalassets_timedelay_rednoise(highymax_133_timedelay_data)
    highymax_115 = expectedterminalassets_timedelay_rednoise(highymax_115_timedelay_data)
    highymax_100 = expectedterminalassets_timedelay_rednoise(highymax_100_timedelay_data)
    medymax_133 = expectedterminalassets_timedelay_rednoise(medymax_133_timedelay_data)
    medymax_115 = expectedterminalassets_timedelay_rednoise(medymax_115_timedelay_data)
    medymax_100 = expectedterminalassets_timedelay_rednoise(medymax_100_timedelay_data)
    lowymax_133 = expectedterminalassets_timedelay_rednoise(lowymax_133_timedelay_data)
    lowymax_115 = expectedterminalassets_timedelay_rednoise(lowymax_115_timedelay_data)
    lowymax_100 = expectedterminalassets_timedelay_rednoise(lowymax_100_timedelay_data)
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
end  #something going wrong at 0.4 for rev/exp = 1.10

function variabilityterminalassets_timedelay_rednoise(dataset)
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

let 
    highymax_133 = variabilityterminalassets_timedelay_rednoise(highymax_133_timedelay_data)
    highymax_115 = variabilityterminalassets_timedelay_rednoise(highymax_115_timedelay_data)
    highymax_100 = variabilityterminalassets_timedelay_rednoise(highymax_100_timedelay_data)
    medymax_133 = variabilityterminalassets_timedelay_rednoise(medymax_133_timedelay_data)
    medymax_115 = variabilityterminalassets_timedelay_rednoise(medymax_115_timedelay_data)
    medymax_100 = variabilityterminalassets_timedelay_rednoise(medymax_100_timedelay_data)
    lowymax_133 = variabilityterminalassets_timedelay_rednoise(lowymax_133_timedelay_data)
    lowymax_115 = variabilityterminalassets_timedelay_rednoise(lowymax_115_timedelay_data)
    lowymax_100 = variabilityterminalassets_timedelay_rednoise(lowymax_100_timedelay_data)
    rednoise_var_exptermassets = figure()    
    subplot(3,1,1)
    plot(highymax_133[:,1], highymax_133[:,4], color="blue", label="High ymax")
    plot(medymax_133[:,1], medymax_133[:,4], color="red", label="Med ymax")
    plot(lowymax_133[:,1], lowymax_133[:,4], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("VarwNL/VarwoNL")
    # xlim(0.0,0.8)
    title("Rev/Exp = 1.33")
    subplot(3,1,2)
    plot(highymax_115[:,1], highymax_115[:,4], color="blue", label="High ymax")
    plot(medymax_115[:,1], medymax_115[:,4], color="red", label="Med ymax")
    plot(lowymax_115[:,1], lowymax_115[:,4], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("VarwNL/VarwoNL")
    # xlim(0.0,0.8)
    title("Rev/Exp = 1.15")
    subplot(3,1,3)
    plot(highymax_100[:,1], highymax_100[:,4], color="blue", label="High ymax")
    plot(medymax_100[:,1], medymax_100[:,4], color="red", label="Med ymax")
    plot(lowymax_100[:,1], lowymax_100[:,4], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("VarwNL/VarwoNL")
    # xlim(0.0,0.8)
    title("Rev/Exp = 1.10")
    tight_layout()
    return rednoise_var_exptermassets
end #something is going wrong with 0.8

#TERMINAL ASSETS SHORTFALL 

function termassetsshortfall_timedelay_rednoise(dataset, shortfallval)
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

let 
    shortfallval = 1000
    highymax_133 = termassetsshortfall_timedelay_rednoise(highymax_133_timedelay_data, shortfallval)
    highymax_115 = termassetsshortfall_timedelay_rednoise(highymax_115_timedelay_data, shortfallval)
    highymax_100 = termassetsshortfall_timedelay_rednoise(highymax_100_timedelay_data, shortfallval)
    medymax_133 = termassetsshortfall_timedelay_rednoise(medymax_133_timedelay_data, shortfallval)
    medymax_115 = termassetsshortfall_timedelay_rednoise(medymax_115_timedelay_data, shortfallval)
    medymax_100 = termassetsshortfall_timedelay_rednoise(medymax_100_timedelay_data, shortfallval)
    lowymax_133 = termassetsshortfall_timedelay_rednoise(lowymax_133_timedelay_data, shortfallval)
    lowymax_115 = termassetsshortfall_timedelay_rednoise(lowymax_115_timedelay_data, shortfallval)
    lowymax_100 = termassetsshortfall_timedelay_rednoise(lowymax_100_timedelay_data, shortfallval)
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