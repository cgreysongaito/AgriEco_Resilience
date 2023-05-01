include("packages.jl")
include("AgriEco_commoncode.jl")

function delayedinputs(defaultinputs, lastyrsactualyield, lastyrsprojectedyield, minfraction,)
    lastyrsoutcome = lastyrsactualyield/lastyrsprojectedyield
    if lastyrsoutcome > minfraction
        return defaultinputs * lastyrsactualyield/lastyrsprojectedyield
    else
        return defaultinputs * minfraction
    end
end

function simulation_NLtimedelay(basedata, economicpar)
    maxyears = size(basedata,1)
    assetsdebt = zeros(maxyears+1)
    for yr in 2:maxyears+1
        expenses = expenses_calc(basedata[yr-1,1], economicpar.c)
        revenue = revenue_calc(basedata[yr-1,2], economicpar.p)
        assetsdebt[yr] = assetsdebt[yr-1] + (revenue - expenses)
    end
    return assetsdebt
end

## CV
function NLtimedelay_data_CV(defaultinputsyield, ymax, y0, yearsdelay, noiseparCV, minfraction, maxyears, seed)
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
        previousyrsprojectedyield = mean([yieldIII(inputs, ymax, y0) for inputs in inputsdata[i-yearsdelay:i-1]])
        inputsdata[i] = delayedinputs(defaultinputsyield[1], previousyrsactualyield, previousyrsprojectedyield, minfraction)
        yielddata[i] = yieldIII(inputsdata[i], ymax, y0) + basenoise[i]
    end
    return hcat(inputsdata[yearsdelay+1:maxyears+yearsdelay], convert_neg_zero(yielddata[yearsdelay+1:maxyears+yearsdelay]))
end

function terminalassets_distribution_NLtimedelay_CV(NL, defaultinputsyield, ymax, y0, yearsdelay, economicpar, noiseparCV, minfraction, maxyears, reps)
    assetsdebtdata =  zeros(reps)
    if NL == "with"
        for i in 1:reps
            basedataNL = NLtimedelay_data_CV(defaultinputsyield, ymax, y0, yearsdelay, noiseparCV, minfraction, maxyears, i)
            simdata = simulation_NLtimedelay(basedataNL, economicpar)
            assetsdebtdata[i] = simdata[end]
        end
    elseif NL == "without"
        for i in 1:reps
            basedatawoNL = hcat(repeat([defaultinputsyield[1]], maxyears), yielddisturbed_CV(defaultinputsyield, noiseparCV, maxyears, i))
            simdata = simulation_NLtimedelay(basedatawoNL, economicpar)
            assetsdebtdata[i] = simdata[end]
        end
    else
        error("NL should be either with or without")
    end
    return assetsdebtdata
end

function terminalassets_timedelay_rednoise_dataset_CV(ymaxy0vals, economicpar, yielddisturbance_CV, corrrange, yearsdelay, minfraction, maxyears, reps)
    defaultinputsyield = maxprofitIII_vals(ymaxy0vals[1], ymaxy0vals[2], economicpar)
    data = Array{Vector{Float64}}(undef,length(corrrange), 2)
    @threads for ri in eachindex(corrrange)
        noiseparCV = NoiseParCV(yielddisturbed_CV = yielddisturbance_CV, yielddisturbed_r = corrrange[ri])
        data[ri, 1] = terminalassets_distribution_NLtimedelay_CV("with", defaultinputsyield, ymaxy0vals[1], ymaxy0vals[2], yearsdelay, economicpar, noiseparCV, minfraction, maxyears, reps)
        data[ri, 2] = terminalassets_distribution_NLtimedelay_CV("without", defaultinputsyield, ymaxy0vals[1], ymaxy0vals[2], yearsdelay, economicpar, noiseparCV, minfraction, maxyears, reps)
    end
    return hcat(corrrange, data)
end

lowrevexpratio = 1.08
lowymaxvalue = 140
rise = 10
run = 0.02
CV_timedelay = 0.15
corrrange_timedelay = 0.0:0.01:0.85
yearsdelay = 3
minfraction_timedelay = 0.2
maxyears_timedelay = 50
reps_timedelay = 1000

#ymax and y0 both change (general response)
let
    vals = calcymaxy0vals("neither", lowymaxvalue, [1.08,1.15,1.33], rise, run, EconomicPar())
    changeboth_108_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(vals[1,:], EconomicPar(), CV_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/changeboth_108_timedelay_data_CV.csv"), changeboth_108_timedelay_data_CV)
    changeboth_115_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(vals[2,:], EconomicPar(), CV_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/changeboth_115_timedelay_data_CV.csv"), changeboth_115_timedelay_data_CV)
    changeboth_133_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(vals[3,:], EconomicPar(), CV_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/changeboth_133_timedelay_data_CV.csv"), changeboth_133_timedelay_data_CV)
end

#Constrain ymax
let
    vals = calcymaxy0vals("ymax", lowymaxvalue, [1.08,1.15,1.33], rise, run, EconomicPar())
    constrainymax_108_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(vals[1,:], EconomicPar(), CV_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/constrainymax_108_timedelay_data_CV.csv"), constrainymax_108_timedelay_data_CV)
    constrainymax_115_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(vals[2,:], EconomicPar(), CV_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/constrainymax_115_timedelay_data_CV.csv"), constrainymax_115_timedelay_data_CV)
    constrainymax_133_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(vals[3,:], EconomicPar(), CV_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/constrainymax_133_timedelay_data_CV.csv"), constrainymax_133_timedelay_data_CV)
end

#Constrain y0
let
    vals = calcymaxy0vals("y0", lowymaxvalue, [1.08,1.15,1.33], rise, run, EconomicPar())
    constrainy0_108_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(vals[1,:], EconomicPar(), CV_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/constrainy0_108_timedelay_data_CV.csv"), constrainy0_108_timedelay_data_CV)
    constrainy0_115_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(vals[2,:], EconomicPar(), CV_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/constrainy0_115_timedelay_data_CV.csv"), constrainy0_115_timedelay_data_CV)
    constrainy0_133_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(vals[3,:], EconomicPar(), CV_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/constrainy0_133_timedelay_data_CV.csv"), constrainy0_133_timedelay_data_CV)  
end

#ymax and y0 both change (general response) - 6years
let
    vals = calcymaxy0vals("neither", lowymaxvalue, [1.08,1.15,1.33], rise, run, EconomicPar())
    changeboth_108_timedelay_data_CV_6 = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(vals[1,:], EconomicPar(), CV_timedelay, corrrange_timedelay, 50, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/changeboth_108_timedelay_data_CV_6.csv"), changeboth_108_timedelay_data_CV_6)
    changeboth_115_timedelay_data_CV_6 = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(vals[2,:], EconomicPar(), CV_timedelay, corrrange_timedelay, 50, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/changeboth_115_timedelay_data_CV_6.csv"), changeboth_115_timedelay_data_CV_6)
    changeboth_133_timedelay_data_CV_6 = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(vals[3,:], EconomicPar(), CV_timedelay, corrrange_timedelay, 50, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/changeboth_133_timedelay_data_CV_6.csv"), changeboth_133_timedelay_data_CV_6)
end

#Constrain ymax - 6years
let
    vals = calcymaxy0vals("ymax", lowymaxvalue, [1.08,1.15,1.33], rise, run, EconomicPar())
    constrainymax_108_timedelay_data_CV_6 = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(vals[1,:], EconomicPar(), CV_timedelay, corrrange_timedelay, 1, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/constrainymax_108_timedelay_data_CV_6.csv"), constrainymax_108_timedelay_data_CV_6)
    constrainymax_115_timedelay_data_CV_6 = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(vals[2,:], EconomicPar(), CV_timedelay, corrrange_timedelay, 1, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/constrainymax_115_timedelay_data_CV_6.csv"), constrainymax_115_timedelay_data_CV_6)
    constrainymax_133_timedelay_data_CV_6 = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(vals[3,:], EconomicPar(), CV_timedelay, corrrange_timedelay, 1, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/constrainymax_133_timedelay_data_CV_6.csv"), constrainymax_133_timedelay_data_CV_6)
end

#Constrain y0 - 6years
let
    vals = calcymaxy0vals("y0", lowymaxvalue, [1.08,1.15,1.33], rise, run, EconomicPar())
    constrainy0_108_timedelay_data_CV_6 = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(vals[1,:], EconomicPar(), CV_timedelay, corrrange_timedelay, 1, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/constrainy0_108_timedelay_data_CV_6.csv"), constrainy0_108_timedelay_data_CV_6)
    constrainy0_115_timedelay_data_CV_6 = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(vals[2,:], EconomicPar(), CV_timedelay, corrrange_timedelay, 1, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/constrainy0_115_timedelay_data_CV_6.csv"), constrainy0_115_timedelay_data_CV_6)
    constrainy0_133_timedelay_data_CV_6 = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(vals[3,:], EconomicPar(), CV_timedelay, corrrange_timedelay, 1, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/constrainy0_133_timedelay_data_CV_6.csv"), constrainy0_133_timedelay_data_CV_6)  
end

# #Rev-exp
# function terminalassets_timedelay_rednoise_dataset_abs(ymaxval, revexpabs, yielddisturbance_sd, corrrange, yearsdelay, minfraction, maxyears, reps)
#     y0val = calc_y0_abs(revexpabs, ymaxval, FarmBasePar().c, FarmBasePar().p)
#     newbasepar = FarmBasePar(ymax=ymaxval, y0=y0val)
#     defaultinputsyield = maxprofitIII_vals(newbasepar)
#     data = Array{Vector{Float64}}(undef,length(corrrange), 2)
#     @threads for ri in eachindex(corrrange)
#         noisepar = NoisePar(yielddisturbed_σ = yielddisturbance_sd, yielddisturbed_r = corrrange[ri])
#         data[ri, 1] = terminalassets_distribution_NLtimedelay("with", defaultinputsyield, yearsdelay, newbasepar, noisepar, minfraction, maxyears, reps)
#         data[ri, 2] = terminalassets_distribution_NLtimedelay("without", defaultinputsyield, yearsdelay, newbasepar, noisepar, minfraction, maxyears, reps)
#     end
#     return hcat(corrrange, data)
# end