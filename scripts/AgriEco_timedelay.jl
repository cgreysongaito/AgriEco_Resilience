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

sd_timedelay = 20
corrrange_timedelay = 0.0:0.01:0.85
minfraction_timedelay = 0.2
maxyears_timedelay = 50
reps_timedelay = 1000
highymax_133_timedelay_data = terminalassets_timedelay_rednoise_dataset(170, 1.33, sd_timedelay, corrrange_timedelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay)
highymax_115_timedelay_data = terminalassets_timedelay_rednoise_dataset(170, 1.15, sd_timedelay, corrrange_timedelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay)
highymax_100_timedelay_data = terminalassets_timedelay_rednoise_dataset(170, 1.00, sd_timedelay, corrrange_timedelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay)
medymax_133_timedelay_data = terminalassets_timedelay_rednoise_dataset(140, 1.33, sd_timedelay, corrrange_timedelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay)
medymax_115_timedelay_data = terminalassets_timedelay_rednoise_dataset(140, 1.15, sd_timedelay, corrrange_timedelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay)
medymax_100_timedelay_data = terminalassets_timedelay_rednoise_dataset(140, 1.00, sd_timedelay, corrrange_timedelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay)
lowymax_133_timedelay_data = terminalassets_timedelay_rednoise_dataset(120, 1.33, sd_timedelay, corrrange_timedelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay)
lowymax_115_timedelay_data = terminalassets_timedelay_rednoise_dataset(120, 1.15, sd_timedelay, corrrange_timedelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay)
lowymax_100_timedelay_data = terminalassets_timedelay_rednoise_dataset(130, 1.00, sd_timedelay, corrrange_timedelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay)
