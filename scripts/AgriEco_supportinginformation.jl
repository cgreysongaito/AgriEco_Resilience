## Expected Terminal Assets
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

## Profit variability (to yield disturbance)
#Trying out AVCK slope numerical analysis
function AVCKslope(profityield, par, maxyieldslope::Float64=0.1)
    if profityield == "profit"
        inputsyield = maxprofitIII_vals(par)
    elseif profityield == "yield"
        inputsyield = maxyieldIII_vals(maxyieldslope, par)
    else
        error("profityield variable must be either \"profit\" or \"yield\".")
    end
    Yrange = 0.0:0.01:par.ymax
    data = [avvarcostkickIII(inputsyield[1],Y, par) for Y in Yrange]
    Yindex = isapprox_index(Yrange, inputsyield[2])
    slope = (data[Yindex+1] - data[Yindex]) / (Yrange[Yindex+1] - Yrange[Yindex])
    return slope
end

function AVCKslope_revexpcon_data(revexpratio, ymaxrange, pval::Float64 =  6.70, cval::Float64 = 139.0)
    Irange = 0.0:0.01:40.0
    data=zeros(length(ymaxrange), 2)
    @threads for ymaxi in eachindex(ymaxrange)
        y0val = calc_y0(revexpratio, ymaxrange[ymaxi], cval, pval)
        par = FarmBasePar(ymax = ymaxrange[ymaxi], y0 = y0val, c = cval, p = pval)
        inputsyield = maxprofitIII_vals(par)
        if minimum(filter(!isnan, [margcostIII(I, par) for I in Irange])) >= par.p #|| minimum(filter(!isnan, [avvarcostIII(I, par) for I in Irange])) >= par.p
            data[ymaxi, 2] = NaN
        else
            data[ymaxi, 1] = ymaxrange[ymaxi]
            data[ymaxi, 2] = AVCKslope("profit", par)/inputsyield[2]
        end
    end
    return data
end


## Resistance to yield disturbance
function AVCK_MR(inputs, par, maxyieldslope::Float64=0.1)
    Yrange = 0.0:0.01:par.ymax
    data = [avvarcostkickIII(inputs, Y, par) for Y in Yrange]
    Yindex = isapprox_index(data, par.p)
    return Yrange[Yindex]
end

function AVCK_MC_distance_revexpcon_data(revexpratio, ymaxrange, pval::Float64 =  6.70, cval::Float64 = 139.0)
    Irange = 0.0:0.01:40.0
    data=zeros(length(ymaxrange), 2)
    @threads for ymaxi in eachindex(ymaxrange)
        y0val = calc_y0(revexpratio, ymaxrange[ymaxi], cval, pval)
        par = FarmBasePar(ymax = ymaxrange[ymaxi], y0 = y0val, c = cval, p = pval)
        inputsyield = maxprofitIII_vals(par)
        if minimum(filter(!isnan, [margcostIII(I, par) for I in Irange])) >= par.p #|| minimum(filter(!isnan, [avvarcostIII(I, par) for I in Irange])) >= par.p
            data[ymaxi, 2] = NaN
        else
            data[ymaxi, 1] = ymaxrange[ymaxi]
            data[ymaxi, 2] = inputsyield[2] - AVCK_MR(inputsyield[1], par)
        end
    end
    return data
end