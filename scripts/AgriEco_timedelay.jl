include("packages.jl")
include("AgriEco_commoncode.jl")
# include("AgriEco_relprofitscurve.jl")

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
function zeroyield(yieldplusnoise)
    if yieldplusnoise < 0.0
        return 0.0
    else
        return yieldplusnoise
    end
end

function NLtimedelay_data_CV(defaultinputsyield, Ymax, I0, yearsdelay, noiseparCV, minfraction, maxyears, seed)
    sd = noiseparCV.yielddisturbed_CV * defaultinputsyield[2]
    basenoise = noise_creation(0.0, sd, noiseparCV.yielddisturbed_r, maxyears+yearsdelay, seed)
    inputsdata = zeros(maxyears+yearsdelay)
    yielddata = zeros(maxyears+yearsdelay)
    for i in 1:yearsdelay
        inputsdata[i] = defaultinputsyield[1]
        yielddata[i] = zeroyield(defaultinputsyield[2] + basenoise[i])
    end
    for i in yearsdelay+1:maxyears+yearsdelay
        previousyrsactualyield = mean(yielddata[i-yearsdelay:i-1])
        previousyrsprojectedyield = mean([yieldIII(inputs, Ymax, I0) for inputs in inputsdata[i-yearsdelay:i-1]])
        inputsdata[i] = delayedinputs(defaultinputsyield[1], previousyrsactualyield, previousyrsprojectedyield, minfraction)
        yieldprep = yieldIII(inputsdata[i], Ymax, I0)
        noisefraction = yieldprep/defaultinputsyield[2]
        yielddata[i] = zeroyield(yieldprep + noisefraction*basenoise[i])
    end
    return hcat(inputsdata[yearsdelay+1:maxyears+yearsdelay], yielddata[yearsdelay+1:maxyears+yearsdelay])
end

function terminalassets_distribution_NLtimedelay_CV(NL, defaultinputsyield, Ymax, I0, yearsdelay, economicpar, noiseparCV, minfraction, maxyears, reps)
    assetsdebtdata =  zeros(reps)
    if NL == "with"
        for i in 1:reps
            basedataNL = NLtimedelay_data_CV(defaultinputsyield, Ymax, I0, yearsdelay, noiseparCV, minfraction, maxyears, i)
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

function terminalassets_timedelay_rednoise_dataset_CV(YmaxI0vals, economicpar, yielddisturbance_CV, corrrange, yearsdelay, minfraction, maxyears, reps)
    defaultinputsyield = maxprofitIII_vals(YmaxI0vals[1], YmaxI0vals[2], economicpar)
    data = Array{Vector{Float64}}(undef,length(corrrange), 2)
    @threads for ri in eachindex(corrrange)
        noiseparCV = NoiseParCV(yielddisturbed_CV = yielddisturbance_CV, yielddisturbed_r = corrrange[ri])
        data[ri, 1] = terminalassets_distribution_NLtimedelay_CV("with", defaultinputsyield, YmaxI0vals[1], YmaxI0vals[2], yearsdelay, economicpar, noiseparCV, minfraction, maxyears, reps)
        data[ri, 2] = terminalassets_distribution_NLtimedelay_CV("without", defaultinputsyield, YmaxI0vals[1], YmaxI0vals[2], yearsdelay, economicpar, noiseparCV, minfraction, maxyears, reps)
    end
    return hcat(corrrange, data)
end

revexpcurve_vals = calcYmaxI0vals_relprofcurve_final([0.95,1.10,1.25,1.40], [150,174,200], EconomicPar())
CV_timedelay = 0.2
corrrange_timedelay = 0.0:0.01:0.85
yearsdelay = 3
minfraction = 0.2
maxyears_timedelay = 50
reps_timedelay = 1000

#Rev/Exp = 1.40 - along the curve
let 
    revexpcurve140_lowymax_timedelay_data40to10 = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(revexpcurve_vals[4][1,:], EconomicPar(), CV_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/revexpcurve140_lowymax_timedelay_data40to10.csv"), revexpcurve140_lowymax_timedelay_data40to10)
    revexpcurve140_medymax_timedelay_data40to10 = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(revexpcurve_vals[4][2,:], EconomicPar(), CV_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/revexpcurve140_medymax_timedelay_data40to10.csv"), revexpcurve140_medymax_timedelay_data40to10)
    revexpcurve140_highymax_timedelay_data40to10 = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(revexpcurve_vals[4][3,:], EconomicPar(), CV_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/revexpcurve140_highymax_timedelay_data40to10.csv"), revexpcurve140_highymax_timedelay_data40to10)
end

#Rev/Exp = 1.10 - along the curve
let 
    revexpcurve110_lowymax_timedelay_data40to10 = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(revexpcurve_vals[2][1,:], EconomicPar(), CV_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/revexpcurve110_lowymax_timedelay_data40to10.csv"), revexpcurve110_lowymax_timedelay_data40to10)
    revexpcurve110_medymax_timedelay_data40to10 = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(revexpcurve_vals[2][2,:], EconomicPar(), CV_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/revexpcurve110_medymax_timedelay_data40to10.csv"), revexpcurve110_medymax_timedelay_data40to10)
    revexpcurve110_highymax_timedelay_data40to10 = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(revexpcurve_vals[2][3,:], EconomicPar(), CV_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/revexpcurve110_highymax_timedelay_data40to10.csv"), revexpcurve110_highymax_timedelay_data40to10)
end

