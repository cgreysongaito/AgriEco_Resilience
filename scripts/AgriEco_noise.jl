include("packages.jl")
include("AgriEco_commoncode.jl")

# normal distribution to bimodal
# https://stats.stackexchange.com/questions/128912/possible-to-morph-a-bimodal-distribution-into-a-normal-distribution-slowly

###rev/exp
#noise on disturbance
#expected profit
function revenue_calc(yield, p)
    return yield * p
end

function expenses_calc(inputs, c)
    return inputs * c
end

function yield_noise(par,σ, corr, reps)
    inputsyield = maxprofitIII_vals(par)
    noise = noise_creation(inputsyield[2], σ, corr, reps, seed)


function distribution_prob_convert(histogramdata)
    sumcounts = sum(histogramdata.weights)
    probdata = zeros(length(histogramdata.weights))
    for bini in eachindex(probdata)
        probdata[bini] = histogramdata.weights[bini]/sumcounts
    end
    return probdata
end

function expectedterminalassets(distributiondata, numbins)
    histogramdata = fit(Histogram, distributiondata, nbins=numbins)
    probdata = distribution_prob_convert(histogramdata)
    expectedassets = 0
    for bini in eachindex(probdata)
        midpoint = histogramdata.edges[1][bini]+step(histogramdata.edges[1])/2
        expectedassets += midpoint*probdata[bini]
    end
    return expectedassets
end

