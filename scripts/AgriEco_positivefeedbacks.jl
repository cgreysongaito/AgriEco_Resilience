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

function terminalassets_posfeed_rednoise_dataset_CV(YmaxI0vals, economicpar, interestpar, yielddisturbance_CV, corrrange, maxyears, reps)
    defaultinputsyield = maxprofitIII_vals(YmaxI0vals[1],YmaxI0vals[2], economicpar)
    data = Array{Vector{Float64}}(undef,length(corrrange), 2)
    @threads for ri in eachindex(corrrange)
        noiseparCV = NoiseParCV(yielddisturbed_CV = yielddisturbance_CV, yielddisturbed_r = corrrange[ri])
        data[ri, 1] = terminalassets_distribution_CV("with", defaultinputsyield, economicpar, noiseparCV, interestpar, maxyears, reps)
        data[ri, 2] = terminalassets_distribution_CV("without", defaultinputsyield, economicpar, noiseparCV, interestpar, maxyears, reps)
    end
    return hcat(corrrange, data)
end

CV_posfeed = 0.2
corrrange_posfeed = 0.0:0.01:0.85
maxyears_posfeed = 50
reps_posfeed = 1000

OERatiocurve_vals = calcYmaxI0vals_OERatiocurve_final([0.71,0.9,0.99], [150,174,200], EconomicPar())

#OERatio = 0.71 - along the curve
let 
    OERatiocurve071_lowymax_posfeed_data = prepDataFrame(terminalassets_posfeed_rednoise_dataset_CV(OERatiocurve_vals[1][1,:], EconomicPar(), InterestPar(), CV_posfeed, corrrange_posfeed, maxyears_posfeed, reps_posfeed))
    CSV.write(joinpath(abpath(), "data/OERatiocurve071_lowymax_posfeed_data.csv"), OERatiocurve071_lowymax_posfeed_data)
    OERatiocurve071_medymax_posfeed_data = prepDataFrame(terminalassets_posfeed_rednoise_dataset_CV(OERatiocurve_vals[1][2,:], EconomicPar(), InterestPar(), CV_posfeed, corrrange_posfeed, maxyears_posfeed, reps_posfeed))
    CSV.write(joinpath(abpath(), "data/OERatiocurve071_medymax_posfeed_data.csv"), OERatiocurve071_medymax_posfeed_data)
    OERatiocurve071_highymax_posfeed_data = prepDataFrame(terminalassets_posfeed_rednoise_dataset_CV(OERatiocurve_vals[1][3,:], EconomicPar(), InterestPar(), CV_posfeed, corrrange_posfeed, maxyears_posfeed, reps_posfeed))
    CSV.write(joinpath(abpath(), "data/OERatiocurve071_highymax_posfeed_data.csv"), OERatiocurve071_highymax_posfeed_data)
end

#OERatio = 0.9 - along the curve
let 
    OERatiocurve09_lowymax_posfeed_data = prepDataFrame(terminalassets_posfeed_rednoise_dataset_CV(OERatiocurve_vals[2][1,:], EconomicPar(), InterestPar(), CV_posfeed, corrrange_posfeed, maxyears_posfeed, reps_posfeed))
    CSV.write(joinpath(abpath(), "data/OERatiocurve09_lowymax_posfeed_data.csv"), OERatiocurve09_lowymax_posfeed_data)
    OERatiocurve09_medymax_posfeed_data = prepDataFrame(terminalassets_posfeed_rednoise_dataset_CV(OERatiocurve_vals[2][2,:], EconomicPar(), InterestPar(), CV_posfeed, corrrange_posfeed, maxyears_posfeed, reps_posfeed))
    CSV.write(joinpath(abpath(), "data/OERatiocurve09_medymax_posfeed_data.csv"), OERatiocurve09_medymax_posfeed_data)
    OERatiocurve09_highymax_posfeed_data = prepDataFrame(terminalassets_posfeed_rednoise_dataset_CV(OERatiocurve_vals[2][3,:], EconomicPar(), InterestPar(), CV_posfeed, corrrange_posfeed, maxyears_posfeed, reps_posfeed))
    CSV.write(joinpath(abpath(), "data/OERatiocurve09_highymax_posfeed_data.csv"), OERatiocurve09_highymax_posfeed_data)
end

#OERatio = 0.99 - along the curve
let 
    OERatiocurve099_lowymax_posfeed_data = prepDataFrame(terminalassets_posfeed_rednoise_dataset_CV(OERatiocurve_vals[3][1,:], EconomicPar(), InterestPar(), CV_posfeed, corrrange_posfeed, maxyears_posfeed, reps_posfeed))
    CSV.write(joinpath(abpath(), "data/OERatiocurve099_lowymax_posfeed_data.csv"), OERatiocurve099_lowymax_posfeed_data)
    OERatiocurve099_medymax_posfeed_data = prepDataFrame(terminalassets_posfeed_rednoise_dataset_CV(OERatiocurve_vals[3][2,:], EconomicPar(), InterestPar(), CV_posfeed, corrrange_posfeed, maxyears_posfeed, reps_posfeed))
    CSV.write(joinpath(abpath(), "data/OERatiocurve099_medymax_posfeed_data.csv"), OERatiocurve099_medymax_posfeed_data)
    OERatiocurve099_highymax_posfeed_data = prepDataFrame(terminalassets_posfeed_rednoise_dataset_CV(OERatiocurve_vals[3][3,:], EconomicPar(), InterestPar(), CV_posfeed, corrrange_posfeed, maxyears_posfeed, reps_posfeed))
    CSV.write(joinpath(abpath(), "data/OERatiocurve099_highymax_posfeed_data.csv"), OERatiocurve099_highymax_posfeed_data)
end




