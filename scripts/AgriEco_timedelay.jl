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

function NLtimedelay_data(defaultinputsyield, ymax, y0, yearsdelay, noisepar, minfraction, maxyears, seed)
    basenoise = noise_creation(0.0, noisepar.yielddisturbed_σ, noisepar.yielddisturbed_r, maxyears+yearsdelay, seed)
    inputsdata = zeros(maxyears+yearsdelay)
    yielddata = zeros(maxyears+yearsdelay)
    for i in 1:yearsdelay
        inputsdata[i] = defaultinputsyield[1]
        yielddata[i] = defaultinputsyield[2] + basenoise[i]
    end
    for i in yearsdelay+1:maxyears+yearsdelay
        previousyrsactualyield = mean(yielddata[i-yearsdelay:i-1])
        previousyrsprojectedyield = mean([yieldIII(inputs, ymax, y0) for inputs in inputsdata[i-yearsdelay:i-1]])
        inputsdata[i] = delayedinputs(defaultinputsyield[1], minfraction, previousyrsactualyield, previousyrsprojectedyield)
        yielddata[i] = yieldIII(inputsdata[i], ymax, y0) + basenoise[i]
    end
    return hcat(inputsdata[yearsdelay+1:maxyears+yearsdelay], convert_neg_zero(yielddata[yearsdelay+1:maxyears+yearsdelay]))
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

function terminalassets_distribution_NLtimedelay(NL, defaultinputsyield, ymax, y0, yearsdelay, economicpar, noisepar, minfraction, maxyears, reps)
    assetsdebtdata =  zeros(reps)
    if NL == "with"
        for i in 1:reps
            basedataNL = NLtimedelay_data(defaultinputsyield, ymax, y0, yearsdelay, noisepar, minfraction, maxyears, i)
            simdata = simulation_NLtimedelay(basedataNL, economicpar)
            assetsdebtdata[i] = simdata[end]
        end
    elseif NL == "without"
        for i in 1:reps
            basedatawoNL = hcat(repeat([defaultinputsyield[1]], maxyears), yielddisturbed(defaultinputsyield, noisepar, maxyears, i))
            simdata = simulation_NLtimedelay(basedatawoNL, economicpar)
            assetsdebtdata[i] = simdata[end]
        end
    else
        error("NL should be either with or without")
    end
    return assetsdebtdata
end

function terminalassets_timedelay_rednoise_dataset(ymaxy0vals, economicpar, yielddisturbance_sd, corrrange, yearsdelay, minfraction, maxyears, reps)
    defaultinputsyield = maxprofitIII_vals(ymaxy0vals[1], ymaxy0vals[2], economicpar)
    data = Array{Vector{Float64}}(undef,length(corrrange), 2)
    @threads for ri in eachindex(corrrange)
        noisepar = NoisePar(yielddisturbed_σ = yielddisturbance_sd, yielddisturbed_r = corrrange[ri])
        data[ri, 1] = terminalassets_distribution_NLtimedelay("with", defaultinputsyield, ymaxy0vals[1], ymaxy0vals[2], yearsdelay, economicpar, noisepar, minfraction, maxyears, reps)
        data[ri, 2] = terminalassets_distribution_NLtimedelay("without", defaultinputsyield, ymaxy0vals[1], ymaxy0vals[2], yearsdelay, economicpar, noisepar, minfraction, maxyears, reps)
    end
    return hcat(corrrange, data)
end

lowrevexpratio = 1.08
lowymaxvalue = 140
rise = 10
run = 0.02
yearsdelay = 3
minfraction = 0.2
sd_timedelay = 20
corrrange_timedelay = 0.0:0.01:0.85
maxyears_timedelay = 50
reps_timedelay = 1000

#ymax and y0 both change (general response)
let
    vals = calcymaxy0vals("neither", lowymaxvalue, [1.08,1.15,1.33], rise, run, EconomicPar())
    changeboth_108_timedelay_data = prepDataFrame(terminalassets_timedelay_rednoise_dataset(vals[1,:], EconomicPar(), sd_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/changeboth_108_timedelay_data.csv"), changeboth_108_timedelay_data)
    changeboth_115_timedelay_data = prepDataFrame(terminalassets_timedelay_rednoise_dataset(vals[2,:], EconomicPar(), sd_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/changeboth_115_timedelay_data.csv"), changeboth_115_timedelay_data)
    changeboth_133_timedelay_data = prepDataFrame(terminalassets_timedelay_rednoise_dataset(vals[3,:], EconomicPar(), sd_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/changeboth_133_timedelay_data.csv"), changeboth_133_timedelay_data)
end

#Constrain ymax
let
    vals = calcymaxy0vals("ymax", lowymaxvalue, [1.08,1.15,1.33], rise, run, EconomicPar())
    constrainymax_108_timedelay_data = prepDataFrame(terminalassets_timedelay_rednoise_dataset(vals[1,:], EconomicPar(), sd_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/constrainymax_108_timedelay_data.csv"), constrainymax_108_timedelay_data)
    constrainymax_115_timedelay_data = prepDataFrame(terminalassets_timedelay_rednoise_dataset(vals[2,:], EconomicPar(), sd_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/constrainymax_115_timedelay_data.csv"), constrainymax_115_timedelay_data)
    constrainymax_133_timedelay_data = prepDataFrame(terminalassets_timedelay_rednoise_dataset(vals[3,:], EconomicPar(), sd_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/constrainymax_133_timedelay_data.csv"), constrainymax_133_timedelay_data)
end

#Constrain y0
let
    vals = calcymaxy0vals("y0", lowymaxvalue, [1.08,1.15,1.33], rise, run, EconomicPar())
    constrainy0_108_timedelay_data = prepDataFrame(terminalassets_timedelay_rednoise_dataset(vals[1,:], EconomicPar(), sd_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/constrainy0_108_timedelay_data.csv"), constrainy0_108_timedelay_data)
    constrainy0_115_timedelay_data = prepDataFrame(terminalassets_timedelay_rednoise_dataset(vals[2,:], EconomicPar(), sd_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/constrainy0_115_timedelay_data.csv"), constrainy0_115_timedelay_data)
    constrainy0_133_timedelay_data = prepDataFrame(terminalassets_timedelay_rednoise_dataset(vals[3,:], EconomicPar(), sd_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/constrainy0_133_timedelay_data.csv"), constrainy0_133_timedelay_data)  
end

# #Rev/Exp = 1.33
# let
#     highymax_133_timedelay_data = prepDataFrame(terminalassets_timedelay_rednoise_dataset(170, 1.33, sd_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
#     CSV.write(joinpath(abpath(), "data/highymax_133_timedelay_data.csv"), highymax_133_timedelay_data)
#     medymax_133_timedelay_data = prepDataFrame(terminalassets_timedelay_rednoise_dataset(140, 1.33, sd_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
#     CSV.write(joinpath(abpath(), "data/medymax_133_timedelay_data.csv"), medymax_133_timedelay_data)
#     lowymax_133_timedelay_data = prepDataFrame(terminalassets_timedelay_rednoise_dataset(120, 1.33, sd_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
#     CSV.write(joinpath(abpath(), "data/lowymax_133_timedelay_data.csv"), lowymax_133_timedelay_data)
# end

# #Rev/Exp = 1.15
# let
#     highymax_115_timedelay_data = prepDataFrame(terminalassets_timedelay_rednoise_dataset(170, 1.15, sd_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
#     CSV.write(joinpath(abpath(), "data/highymax_115_timedelay_data.csv"), highymax_115_timedelay_data)
#     medymax_115_timedelay_data = prepDataFrame(terminalassets_timedelay_rednoise_dataset(140, 1.15, sd_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
#     CSV.write(joinpath(abpath(), "data/medymax_115_timedelay_data.csv"), medymax_115_timedelay_data)
#     lowymax_115_timedelay_data = prepDataFrame(terminalassets_timedelay_rednoise_dataset(120, 1.15, sd_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
#     CSV.write(joinpath(abpath(), "data/lowymax_115_timedelay_data.csv"), lowymax_115_timedelay_data)
# end

# #Rev/Exp = 1.08
# let
#     highymax_108_timedelay_data = prepDataFrame(terminalassets_timedelay_rednoise_dataset(170, 1.08, sd_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
#     CSV.write(joinpath(abpath(), "data/highymax_108_timedelay_data.csv"), highymax_108_timedelay_data)
#     medymax_108_timedelay_data = prepDataFrame(terminalassets_timedelay_rednoise_dataset(140, 1.08, sd_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
#     CSV.write(joinpath(abpath(), "data/medymax_108_timedelay_data.csv"), medymax_108_timedelay_data)
#     lowymax_108_timedelay_data = prepDataFrame(terminalassets_timedelay_rednoise_dataset(130, 1.08, sd_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
#     CSV.write(joinpath(abpath(), "data/lowymax_108_timedelay_data.csv"), lowymax_108_timedelay_data)
# end


# let
#     medy0_133_timedelay_data = prepDataFrame(terminalassets_timedelay_rednoise_dataset("y0", 1/0.125, 1.33, sd_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
#     CSV.write(joinpath(abpath(), "data/medy0_133_timedelay_data.csv"), medy0_133_timedelay_data)
#     medy0_115_timedelay_data = prepDataFrame(terminalassets_timedelay_rednoise_dataset("y0", 1/0.125, 1.15, sd_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
#     CSV.write(joinpath(abpath(), "data/medy0_115_timedelay_data.csv"), medy0_115_timedelay_data)
#     medy0_108_timedelay_data = prepDataFrame(terminalassets_timedelay_rednoise_dataset("y0", 1/0.125, 1.08, sd_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
#     CSV.write(joinpath(abpath(), "data/medy0_108_timedelay_data.csv"), medy0_108_timedelay_data)
# end


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
        inputsdata[i] = delayedinputs(defaultinputsyield[1], minfraction, previousyrsactualyield, previousyrsprojectedyield)
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
CV_timedelay = 0.05
corrrange_timedelay = 0.0:0.01:0.85
yearsdelay = 3
minfraction_timedelay = 0.2
maxyears_timedelay = 50
reps_timedelay = 1000

#ymax and y0 both change (general response)
let
    vals = calcymaxy0vals("neither", lowymaxvalue, [1.08,1.15,1.33], rise, run, EconomicPar())
    changeboth_108_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(vals[1,:], EconomicPar(), sd_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/changeboth_108_timedelay_data_CV.csv"), changeboth_108_timedelay_data_CV)
    changeboth_115_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(vals[2,:], EconomicPar(), sd_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/changeboth_115_timedelay_data_CV.csv"), changeboth_115_timedelay_data_CV)
    changeboth_133_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(vals[3,:], EconomicPar(), sd_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/changeboth_133_timedelay_data_CV.csv"), changeboth_133_timedelay_data_CV)
end

#Constrain ymax
let
    vals = calcymaxy0vals("ymax", lowymaxvalue, [1.08,1.15,1.33], rise, run, EconomicPar())
    constrainymax_108_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(vals[1,:], EconomicPar(), sd_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/constrainymax_108_timedelay_data_CV.csv"), constrainymax_108_timedelay_data_CV)
    constrainymax_115_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(vals[2,:], EconomicPar(), sd_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/constrainymax_115_timedelay_data_CV.csv"), constrainymax_115_timedelay_data_CV)
    constrainymax_133_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(vals[3,:], EconomicPar(), sd_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/constrainymax_133_timedelay_data_CV.csv"), constrainymax_133_timedelay_data_CV)
end

#Constrain y0
let
    vals = calcymaxy0vals("y0", lowymaxvalue, [1.08,1.15,1.33], rise, run, EconomicPar())
    constrainy0_108_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(vals[1,:], EconomicPar(), sd_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/constrainy0_108_timedelay_data_CV.csv"), constrainy0_108_timedelay_data_CV)
    constrainy0_115_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(vals[2,:], EconomicPar(), sd_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/constrainy0_115_timedelay_data_CV.csv"), constrainy0_115_timedelay_data_CV)
    constrainy0_133_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(vals[3,:], EconomicPar(), sd_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/constrainy0_133_timedelay_data_CV.csv"), constrainy0_133_timedelay_data_CV)  
end

# #Rev/Exp = 1.33
# let
#     highymax_133_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(170, 1.33, CV_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
#     CSV.write(joinpath(abpath(), "data/highymax_133_timedelay_data_CV.csv"), highymax_133_timedelay_data_CV)
#     medymax_133_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(140, 1.33, CV_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
#     CSV.write(joinpath(abpath(), "data/medymax_133_timedelay_data_CV.csv"), medymax_133_timedelay_data_CV)
#     lowymax_133_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(120, 1.33, CV_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
#     CSV.write(joinpath(abpath(), "data/lowymax_133_timedelay_data_CV.csv"), lowymax_133_timedelay_data_CV)
# end

# #Rev/Exp = 1.15
# let
#     highymax_115_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(170, 1.15, CV_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
#     CSV.write(joinpath(abpath(), "data/highymax_115_timedelay_data_CV.csv"), highymax_115_timedelay_data_CV)
#     medymax_115_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(140, 1.15, CV_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
#     CSV.write(joinpath(abpath(), "data/medymax_115_timedelay_data_CV.csv"), medymax_115_timedelay_data_CV)
#     lowymax_115_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(120, 1.15, CV_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
#     CSV.write(joinpath(abpath(), "data/lowymax_115_timedelay_data_CV.csv"), lowymax_115_timedelay_data_CV)
# end

# #Rev/Exp = 1.08
# let
#     highymax_108_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(170, 1.08, CV_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
#     CSV.write(joinpath(abpath(), "data/highymax_108_timedelay_data_CV.csv"), highymax_108_timedelay_data_CV)
#     medymax_108_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(140, 1.08, CV_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
#     CSV.write(joinpath(abpath(), "data/medymax_108_timedelay_data_CV.csv"), medymax_108_timedelay_data_CV)
#     lowymax_108_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(130, 1.08, CV_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
#     CSV.write(joinpath(abpath(), "data/lowymax_108_timedelay_data_CV.csv"), lowymax_108_timedelay_data_CV)
# end

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

#Rev-Exp = 225
let
    highymax_225_timedelay_data_abs = prepDataFrame(terminalassets_timedelay_rednoise_dataset_abs(170, 225, sd_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/highymax_225_timedelay_data_abs.csv"), highymax_225_timedelay_data_abs)
    medymax_225_timedelay_data_abs = prepDataFrame(terminalassets_timedelay_rednoise_dataset_abs(140, 225, sd_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/medymax_225_timedelay_data_abs.csv"), medymax_225_timedelay_data_abs)
    lowymax_225_timedelay_data_abs = prepDataFrame(terminalassets_timedelay_rednoise_dataset_abs(120, 225, sd_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/lowymax_225_timedelay_data_abs.csv"), lowymax_225_timedelay_data_abs)
end

#Rev-Exp = 75
let
    highymax_75_timedelay_data_abs = prepDataFrame(terminalassets_timedelay_rednoise_dataset_abs(170, 75, sd_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/highymax_75_timedelay_data_abs.csv"), highymax_75_timedelay_data_abs)
    medymax_75_timedelay_data_abs = prepDataFrame(terminalassets_timedelay_rednoise_dataset_abs(140, 75, sd_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/medymax_75_timedelay_data_abs.csv"), medymax_75_timedelay_data_abs)
    lowymax_75_timedelay_data_abs = prepDataFrame(terminalassets_timedelay_rednoise_dataset_abs(130, 75, sd_timedelay, corrrange_timedelay, yearsdelay, minfraction_timedelay, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/lowymax_75_timedelay_data_abs.csv"), lowymax_75_timedelay_data_abs)
end
