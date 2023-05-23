include("packages.jl")
include("AgriEco_commoncode.jl")

@with_kw mutable struct InterestPar
    debtinterest = 4
    savingsinterest = 2
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
        assetsdebtafterfarming = assetsdebt[yr-1] + (revenue - expenses)
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

function terminalassets_distribution_CV(NL, inputsyield, economicpar, noiseparCV, interestpar, maxyears, reps)
    assetsdebtdata =  zeros(reps)
    for i in 1:reps
        basedata = yieldnoise_createdata_CV(inputsyield, economicpar, noiseparCV, maxyears, i)
        simdata = simulation_NLposfeed(NL, basedata, interestpar)
        assetsdebtdata[i] = simdata[end]
    end
    return assetsdebtdata
end

function terminalassets_posfeed_rednoise_dataset_CV(ymaxy0vals, economicpar, interestpar, yielddisturbance_CV, corrrange, maxyears, reps)
    defaultinputsyield = maxprofitIII_vals(ymaxy0vals[1],ymaxy0vals[2], economicpar)
    data = Array{Vector{Float64}}(undef,length(corrrange), 2)
    @threads for ri in eachindex(corrrange)
        noiseparCV = NoiseParCV(yielddisturbed_CV = yielddisturbance_CV, yielddisturbed_r = corrrange[ri])
        data[ri, 1] = terminalassets_distribution_CV("with", defaultinputsyield, economicpar, noiseparCV, interestpar, maxyears, reps)
        data[ri, 2] = terminalassets_distribution_CV("without", defaultinputsyield, economicpar, noiseparCV, interestpar, maxyears, reps)
    end
    return hcat(corrrange, data)
end

lowrevexpratio = 1.08
lowymaxvalue = 140
rise = 10
run = 0.02
CV_posfeed = 0.15
corrrange_posfeed = 0.0:0.01:0.85
maxyears_posfeed = 50
reps_posfeed = 1000

#Constrain ymax
let
    vals = calcymaxy0vals("ymax", lowymaxvalue, [0.95,1.08,1.15,1.33], rise, run, EconomicPar())
    constrainymax_095_posfeed_data_CV = prepDataFrame(terminalassets_posfeed_rednoise_dataset_CV(vals[1,:], EconomicPar(), InterestPar(), CV_posfeed, corrrange_posfeed, maxyears_posfeed, reps_posfeed))
    CSV.write(joinpath(abpath(), "data/constrainymax_095_posfeed_data_CV.csv"), constrainymax_095_posfeed_data_CV)
    constrainymax_108_posfeed_data_CV = prepDataFrame(terminalassets_posfeed_rednoise_dataset_CV(vals[2,:], EconomicPar(), InterestPar(), CV_posfeed, corrrange_posfeed, maxyears_posfeed, reps_posfeed))
    CSV.write(joinpath(abpath(), "data/constrainymax_108_posfeed_data_CV.csv"), constrainymax_108_posfeed_data_CV)
    constrainymax_115_posfeed_data_CV = prepDataFrame(terminalassets_posfeed_rednoise_dataset_CV(vals[3,:], EconomicPar(), InterestPar(), CV_posfeed, corrrange_posfeed, maxyears_posfeed, reps_posfeed))
    CSV.write(joinpath(abpath(), "data/constrainymax_115_posfeed_data_CV.csv"), constrainymax_115_posfeed_data_CV)
    constrainymax_133_posfeed_data_CV = prepDataFrame(terminalassets_posfeed_rednoise_dataset_CV(vals[4,:], EconomicPar(), InterestPar(), CV_posfeed, corrrange_posfeed, maxyears_posfeed, reps_posfeed))
    CSV.write(joinpath(abpath(), "data/constrainymax_133_posfeed_data_CV.csv"), constrainymax_133_posfeed_data_CV)
end

#Constrain y0
let
    vals = calcymaxy0vals("y0", lowymaxvalue, [0.95,1.08,1.15,1.33], rise, run, EconomicPar())
    constrainy0_095_posfeed_data_CV = prepDataFrame(terminalassets_posfeed_rednoise_dataset_CV(vals[1,:], EconomicPar(), InterestPar(), CV_posfeed, corrrange_posfeed, maxyears_posfeed, reps_posfeed))
    CSV.write(joinpath(abpath(), "data/constrainy0_095_posfeed_data_CV.csv"), constrainy0_095_posfeed_data_CV)
    constrainy0_108_posfeed_data_CV = prepDataFrame(terminalassets_posfeed_rednoise_dataset_CV(vals[2,:], EconomicPar(), InterestPar(), CV_posfeed, corrrange_posfeed, maxyears_posfeed, reps_posfeed))
    CSV.write(joinpath(abpath(), "data/constrainy0_108_posfeed_data_CV.csv"), constrainy0_108_posfeed_data_CV)
    constrainy0_115_posfeed_data_CV = prepDataFrame(terminalassets_posfeed_rednoise_dataset_CV(vals[3,:], EconomicPar(), InterestPar(), CV_posfeed, corrrange_posfeed, maxyears_posfeed, reps_posfeed))
    CSV.write(joinpath(abpath(), "data/constrainy0_115_posfeed_data_CV.csv"), constrainy0_115_posfeed_data_CV)
    constrainy0_133_posfeed_data_CV = prepDataFrame(terminalassets_posfeed_rednoise_dataset_CV(vals[4,:], EconomicPar(), InterestPar(), CV_posfeed, corrrange_posfeed, maxyears_posfeed, reps_posfeed))
    CSV.write(joinpath(abpath(), "data/constrainy0_133_posfeed_data_CV.csv"), constrainy0_133_posfeed_data_CV)  
end

# #Rev-exp (absolute)
# function terminalassets_posfeed_rednoise_dataset_abs(ymaxval, revexpabs, interestpar, yielddisturbance_sd, corrrange, maxyears, reps)
#     y0val = calc_y0_abs(revexpabs, ymaxval, FarmBasePar().c, FarmBasePar().p)
#     newbasepar = FarmBasePar(ymax=ymaxval, y0=y0val)
#     defaultinputsyield = maxprofitIII_vals(newbasepar)
#     data = Array{Vector{Float64}}(undef,length(corrrange), 2)
#     @threads for ri in eachindex(corrrange)
#         noisepar = NoisePar(yielddisturbed_σ = yielddisturbance_sd, yielddisturbed_r = corrrange[ri])
#         data[ri, 1] = terminalassets_distribution("with", defaultinputsyield, newbasepar, noisepar, interestpar, maxyears, reps)
#         data[ri, 2] = terminalassets_distribution("without", defaultinputsyield, newbasepar, noisepar, interestpar, maxyears, reps)
#     end
#     return hcat(corrrange, data)
# end