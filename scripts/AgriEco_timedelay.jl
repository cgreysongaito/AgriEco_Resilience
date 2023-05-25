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
function zeroyield(yieldplusnoise)
    if yieldplusnoise < 0.0
        return 0.0
    else
        return yieldplusnoise
    end
end

function NLtimedelay_data_CV(defaultinputsyield, ymax, y0, yearsdelay, noiseparCV, minfraction, maxyears, seed)
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
        previousyrsprojectedyield = mean([yieldIII(inputs, ymax, y0) for inputs in inputsdata[i-yearsdelay:i-1]])
        inputsdata[i] = delayedinputs(defaultinputsyield[1], previousyrsactualyield, previousyrsprojectedyield, minfraction)
        yieldprep = yieldIII(inputsdata[i], ymax, y0)
        noisefraction = yieldprep/defaultinputsyield[2]
        yielddata[i] = zeroyield(yieldprep + noisefraction*basenoise[i])
    end
    return hcat(inputsdata[yearsdelay+1:maxyears+yearsdelay], yielddata[yearsdelay+1:maxyears+yearsdelay])
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
CV_timedelay = 0.2
corrrange_timedelay = 0.0:0.01:0.85
yearsdelay = 3
minfraction = 0.2
maxyears_timedelay = 50
reps_timedelay = 1000

#Constrain ymax
let
    vals = calcymaxy0vals("ymax", lowymaxvalue, [0.95,1.08,1.15,1.33], rise, run, EconomicPar())
    constrainymax_095_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(vals[1,:], EconomicPar(), CV_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/constrainymax_095_timedelay_data_CV.csv"), constrainymax_095_timedelay_data_CV)
    constrainymax_108_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(vals[2,:], EconomicPar(), CV_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/constrainymax_108_timedelay_data_CV.csv"), constrainymax_108_timedelay_data_CV)
    constrainymax_115_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(vals[3,:], EconomicPar(), CV_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/constrainymax_115_timedelay_data_CV.csv"), constrainymax_115_timedelay_data_CV)
    constrainymax_133_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(vals[4,:], EconomicPar(), CV_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/constrainymax_133_timedelay_data_CV.csv"), constrainymax_133_timedelay_data_CV)
end

#Constrain y0
let
    vals = calcymaxy0vals("y0", lowymaxvalue, [0.95,1.08,1.15,1.33], rise, run, EconomicPar())
    constrainy0_095_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(vals[1,:], EconomicPar(), CV_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/constrainy0_095_timedelay_data_CV.csv"), constrainy0_095_timedelay_data_CV)
    constrainy0_108_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(vals[2,:], EconomicPar(), CV_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/constrainy0_108_timedelay_data_CV.csv"), constrainy0_108_timedelay_data_CV)
    constrainy0_115_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(vals[3,:], EconomicPar(), CV_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/constrainy0_115_timedelay_data_CV.csv"), constrainy0_115_timedelay_data_CV)
    constrainy0_133_timedelay_data_CV = prepDataFrame(terminalassets_timedelay_rednoise_dataset_CV(vals[4,:], EconomicPar(), CV_timedelay, corrrange_timedelay, yearsdelay, minfraction, maxyears_timedelay, reps_timedelay))
    CSV.write(joinpath(abpath(), "data/constrainy0_133_timedelay_data_CV.csv"), constrainy0_133_timedelay_data_CV)  
end

#Attempt to understand mechanism

#CV breakdown

# constrainymax_133_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainymax_133_timedelay_data_CV.csv"), DataFrame))
# constrainymax_108_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainymax_108_timedelay_data_CV.csv"), DataFrame))

# let
#     highdata = variabilityterminalassets_breakdown(constrainymax_133_timedelay_data_CV)
#     lowdata = variabilityterminalassets_breakdown(constrainymax_108_timedelay_data_CV)
#     test = figure()
#     subplot(2,2,1)
#     plot(highdata[:,1], highdata[:,2])
#     plot(lowdata[:,1], lowdata[:,2])
#     ylim(0,3500)
#     subplot(2,2,2)
#     plot(highdata[:,1], highdata[:,4])
#     plot(lowdata[:,1], lowdata[:,4])
#     ylim(0,3500)
#     subplot(2,2,3)
#     plot(highdata[:,1], highdata[:,3])
#     plot(lowdata[:,1], lowdata[:,3])
#     subplot(2,2,4)
#     plot(highdata[:,1], highdata[:,5])
#     plot(lowdata[:,1], lowdata[:,5])
#     tight_layout()
#     return test
# end

# let 
#     vals = calcymaxy0vals("ymax", 140, [1.08,1.33], 10, 0.02, EconomicPar())
#     highdefaultinputsyield = maxprofitIII_vals(vals[2,1], vals[2,2], EconomicPar())
#     lowdefaultinputsyield = maxprofitIII_vals(vals[1,1], vals[1,2], EconomicPar())
#     Irange = 0.0:0.01:20.0
#     datahigh = [yieldIII(I, vals[2,1], vals[2,2]) for I in Irange]
#     datalow = [yieldIII(I, vals[1,1], vals[1,2]) for I in Irange]
#     test = figure(figsize = (5,6.5))
#     subplot(2,1,1)
#     plot(Irange, datahigh, color = "black", linewidth = 3)
#     xlabel("Inputs", fontsize = 20)
#     ylabel("Yield", fontsize = 20)
#     hlines(highdefaultinputsyield[2], 0.0, 20.0)
#     vlines(highdefaultinputsyield[1], 0.0, 175.0)
#     ylim(0.0, 180.0)
#     subplot(2,1,2)
#     plot(Irange, datalow, color = "black", linewidth = 3)
#     hlines(lowdefaultinputsyield[2], 0.0, 20.0)
#     vlines(lowdefaultinputsyield[1], 0.0, 175.0)
#     xlabel("Inputs", fontsize = 20)
#     ylabel("Yield", fontsize = 20)
#     ylim(0.0, 180.0)
#     tight_layout()
#     return test
# end

# let 
#     vals = calcymaxy0vals("y0", 140, [1.08,1.33], 10, 0.02, EconomicPar())
#     highdefaultinputsyield = maxprofitIII_vals(vals[2,1], vals[2,2], EconomicPar())
#     lowdefaultinputsyield = maxprofitIII_vals(vals[1,1], vals[1,2], EconomicPar())
#     Irange = 0.0:0.01:20.0
#     datahigh = [yieldIII(I, vals[2,1], vals[2,2]) for I in Irange]
#     datalow = [yieldIII(I, vals[1,1], vals[1,2]) for I in Irange]
#     test = figure(figsize = (5,6.5))
#     subplot(2,1,1)
#     plot(Irange, datahigh, color = "black", linewidth = 3)
#     xlabel("Inputs", fontsize = 20)
#     ylabel("Yield", fontsize = 20)
#     hlines(highdefaultinputsyield[2], 0.0, 20.0)
#     vlines(highdefaultinputsyield[1], 0.0, 175.0)
#     vlines(highdefaultinputsyield[1]*1.3, 0.0, 175.0, color="blue")
#     vlines(highdefaultinputsyield[1]*0.7, 0.0, 175.0, color="blue")
#     ylim(0.0, 180.0)
#     subplot(2,1,2)
#     plot(Irange, datalow, color = "black", linewidth = 3)
#     hlines(lowdefaultinputsyield[2], 0.0, 20.0)
#     vlines(lowdefaultinputsyield[1], 0.0, 175.0)
#     vlines(lowdefaultinputsyield[1]*1.3, 0.0, 175.0, color="blue")
#     vlines(lowdefaultinputsyield[1]*0.7, 0.0, 175.0, color="blue")
#     xlabel("Inputs", fontsize = 20)
#     ylabel("Yield", fontsize = 20)
#     ylim(0.0, 180.0)
#     tight_layout()
#     return test
# end

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