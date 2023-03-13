include("packages.jl")
include("AgriEco_commoncode.jl")

function distribution_prob_convert(histogramdata)
    sumcounts = sum(histogramdata.weights)
    probdata = zeros(length(histogramdata.weights))
    for bini in eachindex(probdata)
        probdata[bini] = histogramdata.weights[bini]/sumcounts
    end
    return probdata
end

function profitsdata(yielddata, inputsdata, pdata, cdata)
    profitsdata = zeros(length(yielddata))
    for i in 1:length(yielddata)
        rev = revenue_calc(yielddata[i], pdata[i])
        exp = expenses_calc(inputsdata[i], cdata[i])
        profitsdata[i] = rev - exp
    end
    return profitsdata
end

###rev/exp
#noise on disturbance
#expected profit
function revenue_calc(yield, p)
    return yield * p
end

function expenses_calc(inputs, c)
    return inputs * c
end

function expectedprofits(distributiondata, numbins)
    histogramdata = fit(Histogram, distributiondata, nbins=numbins)
    probdata = distribution_prob_convert(histogramdata)
    expectedprofits = 0
    for bini in eachindex(probdata)
        midpoint = histogramdata.edges[1][bini]+step(histogramdata.edges[1])/2
        expectedprofits += midpoint*probdata[bini]
    end
    return expectedprofits
end

function expectedprofits_yieldnoise(ymaxval, revexpratio, σ, corrrange, len, reps)
    y0val = calc_y0(revexpratio, ymaxval, FarmBasePar().c, FarmBasePar().p)
    newpar = FarmBasePar(ymax=ymaxval, y0=y0val)
    inputsyield = maxprofitIII_vals(newpar)
    avexpectedprofitsdata = zeros(length(corrrange))
    @threads for ri in eachindex(corrrange)
        expectedprofitsdata = zeros(reps)
        for i in 1:reps
            yielddata = noise_creation(inputsyield[2], σ, corrrange[ri], len, i)
            inputsdata = repeat([inputsyield[1]], len)
            pdata = repeat([newpar.p], len)
            cdata = repeat([newpar.c], len)
            expectedprofitsdata[i] = expectedprofits(profitsdata(yielddata, inputsdata, pdata, cdata), 25)
        end
        avexpectedprofitsdata[ri] = mean(expectedprofitsdata)
    end
    return avexpectedprofitsdata
end


expectedprofits_yieldnoise(120, 1.33, 0.1, 0.1:0.1:0.9, 50, 10)

