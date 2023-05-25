## Expected Terminal Assets
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

function expectedterminalassets_absolute(dataset)
    corrrange = dataset[:,1]
    data=zeros(length(corrrange), 2)
    @threads for ri in eachindex(corrrange)
        expectedtermassetsdata = expectedterminalassets(dataset[ri,2], 30)
        data[ri,1] = corrrange[ri]
        data[ri,2] = expectedtermassetsdata
    end
    return data
end