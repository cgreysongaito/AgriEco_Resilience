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

function NLtimedelay_data(defaultinputsyield, yearsdelay, basepar, noisepar, minfraction, maxyears, seed)
    basenoise = noise_creation(0.0, noisepar.yielddisturbed_σ, noisepar.yielddisturbed_r, maxyears+yearsdelay, seed)
    inputsdata = zeros(maxyears+yearsdelay)
    yielddata = zeros(maxyears+yearsdelay)
    for i in 1:yearsdelay
        inputsdata[i] = defaultinputsyield[1]
        yielddata[i] = defaultinputsyield[2] + basenoise[i]
    end
    for i in yearsdelay+1:maxyears+yearsdelay
        previousyrsactualyield = mean(yielddata[i-yearsdelay:i-1])
        previousyrsprojectedyield = mean([yieldIII(inputs, basepar) for inputs in inputsdata[i-yearsdelay:i-1]])
        inputsdata[i] = delayedinputs(defaultinputsyield[1], minfraction, previousyrsactualyield, previousyrsprojectedyield)
        yielddata[i] = yieldIII(inputsdata[i], basepar) + basenoise[i]
    end
    return hcat(inputsdata[yearsdelay+1:maxyears+yearsdelay], convert_neg_zero(yielddata[yearsdelay+1:maxyears+yearsdelay]))
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

function terminalassets_distribution_NLtimedelay(NL, defaultinputsyield, yearsdelay, basepar, noisepar, minfraction, maxyears, reps)
    assetsdebtdata =  zeros(reps)
    if NL == "with"
        for i in 1:reps
            basedataNL = NLtimedelay_data(defaultinputsyield, yearsdelay, basepar, noisepar, minfraction, maxyears, i)
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

function terminalassets_timedelay_rednoise_dataset(ymaxval, revexpratio, yielddisturbance_sd, corrrange, yearsdelay, minfraction, maxyears, reps)
    y0val = calc_y0(revexpratio, ymaxval, FarmBasePar().c, FarmBasePar().p)
    newbasepar = FarmBasePar(ymax=ymaxval, y0=y0val)
    defaultinputsyield = maxprofitIII_vals(newbasepar)
    data = Array{Vector{Float64}}(undef,length(corrrange), 2)
    @threads for ri in eachindex(corrrange)
        noisepar = NoisePar(yielddisturbed_σ = yielddisturbance_sd, yielddisturbed_r = corrrange[ri])
        data[ri, 1] = terminalassets_distribution_NLtimedelay("with", defaultinputsyield, yearsdelay, newbasepar, noisepar, minfraction, maxyears, reps)
        data[ri, 2] = terminalassets_distribution_NLtimedelay("without", defaultinputsyield, yearsdelay, newbasepar, noisepar, minfraction, maxyears, reps)
    end
    return hcat(corrrange, data)
end

sd_timedelay = 20
corrrange_timedelay = 0.0:0.01:0.85
yearsdelay = 3
minfraction_timedelay = 0.2
maxyears_timedelay = 50
reps_timedelay = 20000

#Rev/Exp = 1.33
let
    highymax_133_timedelay_data = prepDataFrame(terminalassets_timedelay_rednoise_dataset(170, 1.33, sd_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/highymax_133_timedelay_data.csv"), highymax_133_timedelay_data)
    medymax_133_timedelay_data = prepDataFrame(terminalassets_timedelay_rednoise_dataset(140, 1.33, sd_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/medymax_133_timedelay_data.csv"), medymax_133_timedelay_data)
    lowymax_133_timedelay_data = prepDataFrame(terminalassets_timedelay_rednoise_dataset(120, 1.33, sd_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/lowymax_133_timedelay_data.csv"), lowymax_133_timedelay_data)
end

#Rev/Exp = 1.15
let
    highymax_115_timedelay_data = prepDataFrame(terminalassets_timedelay_rednoise_dataset(170, 1.15, sd_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/highymax_115_timedelay_data.csv"), highymax_115_timedelay_data)
    medymax_115_timedelay_data = prepDataFrame(terminalassets_timedelay_rednoise_dataset(140, 1.15, sd_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/medymax_115_timedelay_data.csv"), medymax_115_timedelay_data)
    lowymax_115_timedelay_data = prepDataFrame(terminalassets_timedelay_rednoise_dataset(120, 1.15, sd_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/lowymax_115_timedelay_data.csv"), lowymax_115_timedelay_data)
end

#Rev/Exp = 1.08
let
    highymax_108_timedelay_data = prepDataFrame(terminalassets_timedelay_rednoise_dataset(170, 1.08, sd_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/highymax_108_timedelay_data.csv"), highymax_108_timedelay_data)
    medymax_108_timedelay_data = prepDataFrame(terminalassets_timedelay_rednoise_dataset(140, 1.08, sd_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/medymax_108_timedelay_data.csv"), medymax_108_timedelay_data)
    lowymax_108_timedelay_data = prepDataFrame(terminalassets_timedelay_rednoise_dataset(130, 1.08, sd_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/lowymax_108_timedelay_data.csv"), lowymax_108_timedelay_data)
end

## CV
function NLtimedelay_data_CV(defaultinputsyield, yearsdelay, basepar, noiseparCV, minfraction, maxyears, seed)
    sd = noiseparCV.yielddisturbed_CV * defaultinputsyield[2]
    basenoise = noise_creation(0.0, sd, noiseparCV.yielddisturbed_r, maxyears+yearsdelay, seed)
    inputsdata = zeros(maxyears+yearsdelay)
    yielddata = zeros(maxyears+yearsdelay)
    for i in 1:yearsdelay
        inputsdata[i] = defaultinputsyield[1]
        yielddata[i] = defaultinputsyield[2] + basenoise[i]
    end
    for i in yearsdelay+1:maxyears+yearsdelay
        previousyrsactualyield = mean(yielddata[i-yearsdelay:i-1])
        previousyrsprojectedyield = mean([yieldIII(inputs, basepar) for inputs in inputsdata[i-yearsdelay:i-1]])
        inputsdata[i] = delayedinputs(defaultinputsyield[1], minfraction, previousyrsactualyield, previousyrsprojectedyield)
        yielddata[i] = yieldIII(inputsdata[i], basepar) + basenoise[i]
    end
    return hcat(inputsdata[yearsdelay+1:maxyears+yearsdelay], convert_neg_zero(yielddata[yearsdelay+1:maxyears+yearsdelay]))
end

y0val = calc_y0(1.33, 170, FarmBasePar().c, FarmBasePar().p)
defaultinputsyield = maxprofitIII_vals(FarmBasePar(ymax = 170, y0=y0val))
test = NLtimedelay_data_CV(defaultinputsyield, 3, FarmBasePar(), NoiseParCV(), 0.2, 50, 1)

function terminalassets_distribution_NLtimedelay_CV(NL, defaultinputsyield, yearsdelay, basepar, noiseparCV, minfraction, maxyears, reps)
    assetsdebtdata =  zeros(reps)
    if NL == "with"
        for i in 1:reps
            basedataNL = NLtimedelay_data_CV(defaultinputsyield, yearsdelay, basepar, noiseparCV, minfraction, maxyears, i)
            simdata = simulation_NLtimedelay(basedataNL, basepar)
            assetsdebtdata[i] = simdata[end]
        end
    elseif NL == "without"
        for i in 1:reps
            basedatawoNL = hcat(repeat([defaultinputsyield[1]], maxyears), yielddisturbed_CV(defaultinputsyield, noiseparCV, maxyears, i))
            simdata = simulation_NLtimedelay(basedatawoNL, basepar)
            assetsdebtdata[i] = simdata[end]
        end
    else
        error("NL should be either with or without")
    end
    return assetsdebtdata
end

terminalassets_distribution_NLtimedelay_CV("with", defaultinputsyield, 3, FarmBasePar(), NoiseParCV(), 0.2, 50, 10)

function terminalassets_timedelay_rednoise_dataset_CV(ymaxval, revexpratio, yielddisturbance_CV, corrrange, yearsdelay, minfraction, maxyears, reps)
    y0val = calc_y0(revexpratio, ymaxval, FarmBasePar().c, FarmBasePar().p)
    newbasepar = FarmBasePar(ymax=ymaxval, y0=y0val)
    defaultinputsyield = maxprofitIII_vals(newbasepar)
    data = Array{Vector{Float64}}(undef,length(corrrange), 2)
    @threads for ri in eachindex(corrrange)
        noiseparCV = NoiseParCV(yielddisturbed_CV = yielddisturbance_CV, yielddisturbed_r = corrrange[ri])
        data[ri, 1] = terminalassets_distribution_NLtimedelay_CV("with", defaultinputsyield, yearsdelay, newbasepar, noiseparCV, minfraction, maxyears, reps)
        data[ri, 2] = terminalassets_distribution_NLtimedelay_CV("without", defaultinputsyield, yearsdelay, newbasepar, noiseparCV, minfraction, maxyears, reps)
    end
    return hcat(corrrange, data)
end

CV_timedelay = 0.117
corrrange_timedelay = 0.0:0.01:0.85
yearsdelay = 3
minfraction_timedelay = 0.2
maxyears_timedelay = 50
reps_timedelay = 1000

#Rev/Exp = 1.33
let
    highymax_133_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(170, 1.33, CV_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/highymax_133_timedelay_data_CV.csv"), highymax_133_timedelay_data_CV)
    medymax_133_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(140, 1.33, CV_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/medymax_133_timedelay_data_CV.csv"), medymax_133_timedelay_data_CV)
    lowymax_133_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(120, 1.33, CV_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/lowymax_133_timedelay_data_CV.csv"), lowymax_133_timedelay_data_CV)
end

#Rev/Exp = 1.15
let
    highymax_115_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(170, 1.15, CV_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/highymax_115_timedelay_data_CV.csv"), highymax_115_timedelay_data_CV)
    medymax_115_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(140, 1.15, CV_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/medymax_115_timedelay_data_CV.csv"), medymax_115_timedelay_data_CV)
    lowymax_115_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(120, 1.15, CV_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/lowymax_115_timedelay_data_CV.csv"), lowymax_115_timedelay_data_CV)
end

#Rev/Exp = 1.08
let
    highymax_108_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(170, 1.08, CV_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/highymax_108_timedelay_data_CV.csv"), highymax_108_timedelay_data_CV)
    medymax_108_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(140, 1.08, CV_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/medymax_108_timedelay_data_CV.csv"), medymax_108_timedelay_data_CV)
    lowymax_108_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(130, 1.08, CV_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/lowymax_108_timedelay_data_CV.csv"), lowymax_108_timedelay_data_CV)
end

#Rev-exp
function terminalassets_timedelay_rednoise_dataset_abs(ymaxval, revexpabs, yielddisturbance_sd, corrrange, yearsdelay, minfraction, maxyears, reps)
    y0val = calc_y0_abs(revexpabs, ymaxval, FarmBasePar().c, FarmBasePar().p)
    newbasepar = FarmBasePar(ymax=ymaxval, y0=y0val)
    defaultinputsyield = maxprofitIII_vals(newbasepar)
    data = Array{Vector{Float64}}(undef,length(corrrange), 2)
    @threads for ri in eachindex(corrrange)
        noisepar = NoisePar(yielddisturbed_σ = yielddisturbance_sd, yielddisturbed_r = corrrange[ri])
        data[ri, 1] = terminalassets_distribution_NLtimedelay("with", defaultinputsyield, yearsdelay, newbasepar, noisepar, minfraction, maxyears, reps)
        data[ri, 2] = terminalassets_distribution_NLtimedelay("without", defaultinputsyield, yearsdelay, newbasepar, noisepar, minfraction, maxyears, reps)
    end
    return hcat(corrrange, data)
end

sd_timedelay = 20
corrrange_timedelay = 0.0:0.01:0.85
yearsdelay = 3
minfraction_timedelay = 0.2
maxyears_timedelay = 50
reps_timedelay = 1000

#Rev-Exp = 200
let
    highymax_200_timedelay_data_abs = prepDataFrame(terminalassets_timedelay_rednoise_dataset_abs(170, 200, sd_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/highymax_200_timedelay_data_abs.csv"), highymax_200_timedelay_data_abs)
    medymax_200_timedelay_data_abs = prepDataFrame(terminalassets_timedelay_rednoise_dataset_abs(140, 200, sd_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/medymax_200_timedelay_data_abs.csv"), medymax_200_timedelay_data_abs)
    lowymax_200_timedelay_data_abs = prepDataFrame(terminalassets_timedelay_rednoise_dataset_abs(120, 200, sd_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/lowymax_200_timedelay_data_abs.csv"), lowymax_200_timedelay_data_abs)
end

#Rev-Exp = 100
let
    highymax_100_timedelay_data_abs = prepDataFrame(terminalassets_timedelay_rednoise_dataset_abs(170, 100, sd_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/highymax_100_timedelay_data_abs.csv"), highymax_100_timedelay_data_abs)
    medymax_100_timedelay_data_abs = prepDataFrame(terminalassets_timedelay_rednoise_dataset_abs(140, 100, sd_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/medymax_100_timedelay_data_abs.csv"), medymax_100_timedelay_data_abs)
    lowymax_100_timedelay_data_abs = prepDataFrame(terminalassets_timedelay_rednoise_dataset_abs(130, 100, sd_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/lowymax_100_timedelay_data_abs.csv"), lowymax_100_timedelay_data_abs)
end
