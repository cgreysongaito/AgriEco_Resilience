include("packages.jl")
include("AgriEco_commoncode.jl")
# include("AgriEco_relprofitscurve.jl")

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

revexpcurve_vals = calcYmaxI0vals_relprofcurve_final([0.95,1.10,1.25,1.40], [150,174,200], EconomicPar())
revexpcurve_vals110140 = calcYmaxI0vals_relprofcurve_final([1.10,1.40], [150,174,200], EconomicPar())

#Rev/Exp = 1.40 - along the curve
let 
    revexpcurve140_lowymax_posfeed_data40to10 = prepDataFrame(terminalassets_posfeed_rednoise_dataset_CV(revexpcurve_vals[4][1,:], EconomicPar(), InterestPar(), CV_posfeed, corrrange_posfeed, maxyears_posfeed, reps_posfeed))
    CSV.write(joinpath(abpath(), "data/revexpcurve140_lowymax_posfeed_data40to10.csv"), revexpcurve140_lowymax_posfeed_data40to10)
    revexpcurve140_medymax_posfeed_data40to10 = prepDataFrame(terminalassets_posfeed_rednoise_dataset_CV(revexpcurve_vals[4][2,:], EconomicPar(), InterestPar(), CV_posfeed, corrrange_posfeed, maxyears_posfeed, reps_posfeed))
    CSV.write(joinpath(abpath(), "data/revexpcurve140_medymax_posfeed_data40to10.csv"), revexpcurve140_medymax_posfeed_data40to10)
    revexpcurve140_highymax_posfeed_data40to10 = prepDataFrame(terminalassets_posfeed_rednoise_dataset_CV(revexpcurve_vals[4][3,:], EconomicPar(), InterestPar(), CV_posfeed, corrrange_posfeed, maxyears_posfeed, reps_posfeed))
    CSV.write(joinpath(abpath(), "data/revexpcurve140_highymax_posfeed_data40to10.csv"), revexpcurve140_highymax_posfeed_data40to10)
end

#Rev/Exp = 1.10 - along the curve
let 
    revexpcurve110_lowymax_posfeed_data40to10 = prepDataFrame(terminalassets_posfeed_rednoise_dataset_CV(revexpcurve_vals[2][1,:], EconomicPar(), InterestPar(), CV_posfeed, corrrange_posfeed, maxyears_posfeed, reps_posfeed))
    CSV.write(joinpath(abpath(), "data/revexpcurve110_lowymax_posfeed_data40to10.csv"), revexpcurve110_lowymax_posfeed_data40to10)
    revexpcurve110_medymax_posfeed_data40to10 = prepDataFrame(terminalassets_posfeed_rednoise_dataset_CV(revexpcurve_vals[2][2,:], EconomicPar(), InterestPar(), CV_posfeed, corrrange_posfeed, maxyears_posfeed, reps_posfeed))
    CSV.write(joinpath(abpath(), "data/revexpcurve110_medymax_posfeed_data40to10.csv"), revexpcurve110_medymax_posfeed_data40to10)
    revexpcurve110_highymax_posfeed_data40to10 = prepDataFrame(terminalassets_posfeed_rednoise_dataset_CV(revexpcurve_vals[2][3,:], EconomicPar(), InterestPar(), CV_posfeed, corrrange_posfeed, maxyears_posfeed, reps_posfeed))
    CSV.write(joinpath(abpath(), "data/revexpcurve110_highymax_posfeed_data40to10.csv"), revexpcurve110_highymax_posfeed_data40to10)
end




