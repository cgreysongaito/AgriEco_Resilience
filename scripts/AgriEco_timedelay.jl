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

#Rev/Exp = 1.03
let
    highymax_108_timedelay_data = prepDataFrame(terminalassets_timedelay_rednoise_dataset(170, 1.08, sd_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/highymax_108_timedelay_data.csv"), highymax_108_timedelay_data)
    medymax_108_timedelay_data = prepDataFrame(terminalassets_timedelay_rednoise_dataset(140, 1.08, sd_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/medymax_108_timedelay_data.csv"), medymax_108_timedelay_data)
    lowymax_108_timedelay_data = prepDataFrame(terminalassets_timedelay_rednoise_dataset(130, 1.08, sd_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/lowymax_108_timedelay_data.csv"), lowymax_108_timedelay_data)
end

# #Testing of rev/exp 1.00 problem
# lowymax_100_timedelay_data = terminalassets_timedelay_rednoise_dataset(130, 1.00, sd_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay)
# lowymax_100 = expectedterminalassets_rednoise(lowymax_100_timedelay_data)
# lowymax_100 = expectedterminalassets_rednoise(lowymax_100_timedelay_data)[38:42, 1:3]

# # 0.39 and 0.4
# function NLtimedelay_data_test(defaultinputsyield, yearsdelay, basepar, noisepar, minfraction, maxyears, seed)
#     basenoise = noise_creation(0.0, noisepar.yielddisturbed_σ, noisepar.yielddisturbed_r, maxyears+yearsdelay, seed)
#     inputsdata = zeros(maxyears+yearsdelay)
#     yielddata = zeros(maxyears+yearsdelay)
#     for i in 1:yearsdelay
#         inputsdata[i] = defaultinputsyield[1]
#         yielddata[i] = defaultinputsyield[2] + basenoise[i]
#     end
#     for i in yearsdelay+1:maxyears+yearsdelay
#         previousyrsactualyield = mean(yielddata[i-yearsdelay:i-1])
#         previousyrsprojectedyield = mean([yieldIII(inputs, basepar) for inputs in inputsdata[i-yearsdelay:i-1]])
#         inputsdata[i] = delayedinputs(defaultinputsyield[1], minfraction, previousyrsactualyield, previousyrsprojectedyield)
#         yielddata[i] = yieldIII(inputsdata[i], basepar) + basenoise[i]
#     end
#     return hcat(inputsdata[yearsdelay+1:maxyears+yearsdelay], convert_neg_zero(yielddata[yearsdelay+1:maxyears+yearsdelay]))
# end

# let 
#     ymaxval = 130
#     y0val = calc_y0(1.00, ymaxval, FarmBasePar().c, FarmBasePar().p)
#     newbasepar = FarmBasePar(ymax=ymaxval, y0=y0val)
#     defaultinputsyield = maxprofitIII_vals(newbasepar)
#     noisepar = NoisePar(yielddisturbed_σ = 20, yielddisturbed_r = 0.39)
#     return NLtimedelay_data_test(defaultinputsyield, 3, newbasepar, noisepar, 0.2, 50, 124)
# end

# let 
#     ymaxval = 130
#     y0val = calc_y0(1.00, ymaxval, FarmBasePar().c, FarmBasePar().p)
#     newbasepar = FarmBasePar(ymax=ymaxval, y0=y0val)
#     defaultinputsyield = maxprofitIII_vals(newbasepar)
#     noisepar = NoisePar(yielddisturbed_σ = 20, yielddisturbed_r = 0.39)
#     return hcat(repeat([defaultinputsyield[1]], 50), yielddisturbed(defaultinputsyield, noisepar, 50, 54))
# end

# let 
#     ymaxval = 130
#     y0val = calc_y0(1.00, ymaxval, FarmBasePar().c, FarmBasePar().p)
#     newbasepar = FarmBasePar(ymax=ymaxval, y0=y0val)
#     defaultinputsyield = maxprofitIII_vals(newbasepar)
#     noisepar = NoisePar(yielddisturbed_σ = 20, yielddisturbed_r = 0.36)
#     return hcat(repeat([defaultinputsyield[1]], 50), yielddisturbed(defaultinputsyield, noisepar, 50, 54))
# end

# let 
#     ymaxval = 130
#     y0val = calc_y0(1.00, ymaxval, FarmBasePar().c, FarmBasePar().p)
#     newbasepar = FarmBasePar(ymax=ymaxval, y0=y0val)
#     defaultinputsyield = maxprofitIII_vals(newbasepar)
#     noisepar = NoisePar(yielddisturbed_σ = 20, yielddisturbed_r = 0.4)
#     data = terminalassets_distribution_NLtimedelay("without", defaultinputsyield, 3, newbasepar, noisepar, 0.2, 50, 1000)
#     test = figure()
#     hist(data, 15)
#     return test
# end

# terminalassets_distribution_NLtimedelay(NL, defaultinputsyield, yearsdelay, basepar, noisepar, minfraction, maxyears, reps)

# test = terminalassets_timedelay_rednoise_dataset(130, 0.99, sd_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay)
# test2 = expectedterminalassets_rednoise(lowymax_100_timedelay_data)
