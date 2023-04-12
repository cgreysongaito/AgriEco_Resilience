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

function terminalassets_posfeed_rednoise_dataset(ymaxval, revexpratio, interestpar, yielddisturbance_sd, corrrange, maxyears, reps)
    y0val = calc_y0(revexpratio, ymaxval, FarmBasePar().c, FarmBasePar().p)
    newbasepar = FarmBasePar(ymax=ymaxval, y0=y0val)
    defaultinputsyield = maxprofitIII_vals(newbasepar)
    data = Array{Vector{Float64}}(undef,length(corrrange), 2)
    @threads for ri in eachindex(corrrange)
        noisepar = NoisePar(yielddisturbed_σ = yielddisturbance_sd, yielddisturbed_r = corrrange[ri])
        data[ri, 1] = terminalassets_distribution("with", defaultinputsyield, newbasepar, noisepar, interestpar, maxyears, reps)
        data[ri, 2] = terminalassets_distribution("without", defaultinputsyield, newbasepar, noisepar, interestpar, maxyears, reps)
    end
    return hcat(corrrange, data)
end

sd = 20
corrrange = 0.0:0.01:0.85
maxyears = 50
reps = 1000
highymax_133_posfeed_data = terminalassets_posfeed_rednoise_dataset(170, 1.33, InterestPar(), sd, corrrange, maxyears, reps)
highymax_115_posfeed_data = terminalassets_posfeed_rednoise_dataset(170, 1.15, InterestPar(), sd, corrrange, maxyears, reps)
highymax_100_posfeed_data = terminalassets_posfeed_rednoise_dataset(170, 1.00, InterestPar(), sd, corrrange, maxyears, reps)
medymax_133_posfeed_data = terminalassets_posfeed_rednoise_dataset(140, 1.33, InterestPar(), sd, corrrange, maxyears, reps)
medymax_115_posfeed_data = terminalassets_posfeed_rednoise_dataset(140, 1.15, InterestPar(), sd, corrrange, maxyears, reps)
medymax_100_posfeed_data = terminalassets_posfeed_rednoise_dataset(140, 1.00, InterestPar(), sd, corrrange, maxyears, reps)
lowymax_133_posfeed_data = terminalassets_posfeed_rednoise_dataset(120, 1.33, InterestPar(), sd, corrrange, maxyears, reps)
lowymax_115_posfeed_data = terminalassets_posfeed_rednoise_dataset(120, 1.15, InterestPar(), sd, corrrange, maxyears, reps)
lowymax_100_posfeed_data = terminalassets_posfeed_rednoise_dataset(130, 1.00, InterestPar(), sd, corrrange, maxyears, reps)

let
    highymax_133 = expectedterminalassets_rednoise(highymax_133_posfeed_data)
    highymax_115 = expectedterminalassets_rednoise(highymax_115_posfeed_data)
    highymax_100 = expectedterminalassets_rednoise(highymax_100_posfeed_data)
    medymax_133 = expectedterminalassets_rednoise(medymax_133_posfeed_data)
    medymax_115 = expectedterminalassets_rednoise(medymax_115_posfeed_data)
    medymax_100 = expectedterminalassets_rednoise(medymax_100_posfeed_data)
    lowymax_133 = expectedterminalassets_rednoise(lowymax_133_posfeed_data)
    lowymax_115 = expectedterminalassets_rednoise(lowymax_115_posfeed_data)
    lowymax_100 = expectedterminalassets_rednoise(lowymax_100_posfeed_data)
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

let 
    highymax_133 = variabilityterminalassets_rednoise(highymax_133_posfeed_data)
    highymax_115 = variabilityterminalassets_rednoise(highymax_115_posfeed_data)
    highymax_100 = variabilityterminalassets_rednoise(highymax_100_posfeed_data)
    medymax_133 = variabilityterminalassets_rednoise(medymax_133_posfeed_data)
    medymax_115 = variabilityterminalassets_rednoise(medymax_115_posfeed_data)
    medymax_100 = variabilityterminalassets_rednoise(medymax_100_posfeed_data)
    lowymax_133 = variabilityterminalassets_rednoise(lowymax_133_posfeed_data)
    lowymax_115 = variabilityterminalassets_rednoise(lowymax_115_posfeed_data)
    lowymax_100 = variabilityterminalassets_rednoise(lowymax_100_posfeed_data)
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
let 
    shortfallval = 1000
    highymax_133 = termassetsshortfall_rednoise(highymax_133_posfeed_data, shortfallval)
    highymax_115 = termassetsshortfall_rednoise(highymax_115_posfeed_data, shortfallval)
    highymax_100 = termassetsshortfall_rednoise(highymax_100_posfeed_data, shortfallval)
    medymax_133 = termassetsshortfall_rednoise(medymax_133_posfeed_data, shortfallval)
    medymax_115 = termassetsshortfall_rednoise(medymax_115_posfeed_data, shortfallval)
    medymax_100 = termassetsshortfall_rednoise(medymax_100_posfeed_data, shortfallval)
    lowymax_133 = termassetsshortfall_rednoise(lowymax_133_posfeed_data, shortfallval)
    lowymax_115 = termassetsshortfall_rednoise(lowymax_115_posfeed_data, shortfallval)
    lowymax_100 = termassetsshortfall_rednoise(lowymax_100_posfeed_data, shortfallval)
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