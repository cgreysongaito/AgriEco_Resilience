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

function terminalassets_distribution(NL, inputsyield, basepar, noisepar, interestpar, maxyears, reps)
    assetsdebtdata =  zeros(reps)
    for i in 1:reps
        basedata = yieldnoise_createdata(inputsyield, basepar, noisepar, maxyears, i)
        simdata = simulation_NLposfeed(NL, basedata, interestpar)
        assetsdebtdata[i] = simdata[end]
    end
    return assetsdebtdata
end

function terminalassets_posfeed_rednoise_dataset(ymaxval, revexpratio, interestpar, yielddisturbance_sd, corrrange, maxyears, reps)
    y0val = calc_y0(revexpratio, ymaxval, FarmBasePar().c, FarmBasePar().p)
    newbasepar = FarmBasePar(ymax=ymaxval, y0=y0val)
    defaultinputsyield = maxprofitIII_vals(newbasepar)
    data = Array{Vector{Float64}}(undef,length(corrrange), 2)
    @threads for ri in eachindex(corrrange)
        noisepar = NoisePar(yielddisturbed_σ = yielddisturbance_sd, yielddisturbed_r = corrrange[ri])
        data[ri, 1] = terminalassets_distribution("with", defaultinputsyield, newbasepar, noisepar, interestpar, maxyears, reps)
        data[ri, 2] = terminalassets_distribution("without", defaultinputsyield, newbasepar, noisepar, interestpar, maxyears, reps)
    end
    return hcat(corrrange, data)
end

sd_posfeed = 20
corrrange_posfeed = 0.0:0.01:0.85
maxyears_posfeed = 50
reps_posfeed = 20000

let
    highymax_133_posfeed_data = prepDataFrame(terminalassets_posfeed_rednoise_dataset(170, 1.33, InterestPar(), sd_posfeed, corrrange_posfeed, maxyears_posfeed, reps_posfeed))
    CSV.write(joinpath(abpath(), "data/highymax_133_posfeed_data.csv"), highymax_133_posfeed_data)
    medymax_133_posfeed_data = prepDataFrame(terminalassets_posfeed_rednoise_dataset(140, 1.33, InterestPar(), sd_posfeed, corrrange_posfeed, maxyears_posfeed, reps_posfeed))
    CSV.write(joinpath(abpath(), "data/medymax_133_posfeed_data.csv"), medymax_133_posfeed_data)
    lowymax_133_posfeed_data = prepDataFrame(terminalassets_posfeed_rednoise_dataset(120, 1.33, InterestPar(), sd_posfeed, corrrange_posfeed, maxyears_posfeed, reps_posfeed))
    CSV.write(joinpath(abpath(), "data/lowymax_133_posfeed_data.csv"), lowymax_133_posfeed_data)
end

let
    highymax_115_posfeed_data = prepDataFrame(terminalassets_posfeed_rednoise_dataset(170, 1.15, InterestPar(), sd_posfeed, corrrange_posfeed, maxyears_posfeed, reps_posfeed))
    CSV.write(joinpath(abpath(), "data/highymax_115_posfeed_data.csv"), highymax_115_posfeed_data)
    medymax_115_posfeed_data = prepDataFrame(terminalassets_posfeed_rednoise_dataset(140, 1.15, InterestPar(), sd_posfeed, corrrange_posfeed, maxyears_posfeed, reps_posfeed))
    CSV.write(joinpath(abpath(), "data/medymax_115_posfeed_data.csv"), medymax_115_posfeed_data)
    lowymax_115_posfeed_data = prepDataFrame(terminalassets_posfeed_rednoise_dataset(120, 1.15, InterestPar(), sd_posfeed, corrrange_posfeed, maxyears_posfeed, reps_posfeed))
    CSV.write(joinpath(abpath(), "data/lowymax_115_posfeed_data.csv"), lowymax_115_posfeed_data)
end

let
    highymax_108_posfeed_data = prepDataFrame(terminalassets_posfeed_rednoise_dataset(170, 1.08, InterestPar(), sd_posfeed, corrrange_posfeed, maxyears_posfeed, reps_posfeed))
    CSV.write(joinpath(abpath(), "data/highymax_108_posfeed_data.csv"), highymax_108_posfeed_data)
    medymax_108_posfeed_data = prepDataFrame(terminalassets_posfeed_rednoise_dataset(140, 1.08, InterestPar(), sd_posfeed, corrrange_posfeed, maxyears_posfeed, reps_posfeed))
    CSV.write(joinpath(abpath(), "data/medymax_108_posfeed_data.csv"), medymax_108_posfeed_data)
    lowymax_108_posfeed_data = prepDataFrame(terminalassets_posfeed_rednoise_dataset(130, 1.08, InterestPar(), sd_posfeed, corrrange_posfeed, maxyears_posfeed, reps_posfeed))
    CSV.write(joinpath(abpath(), "data/lowymax_108_posfeed_data.csv"), lowymax_108_posfeed_data)
end

