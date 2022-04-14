include("packages.jl")
include("AgriEco_commoncode.jl")

let 
    y0range = 0.2:0.01:2.2
    data = [avcv_calc(1000, 50, BMPPar(y0 = y, ymax = 1.0, c = 0.5, p = 2.2), 0.0) for y in y0range]
    test = figure()
    plot(y0range, data)
    xlabel("y0")
    ylabel("CV")
    return test
end

let 
    ymaxrange = 0.6:0.01:1.0
    data = [avcv_calc(1000, 50, BMPPar(y0 = 2.0, ymax = y, c = 0.5, p = 2.2), 0.0) for y in ymaxrange]
    test = figure()
    plot(ymaxrange, data)
    xlabel("ymax")
    ylabel("CV")
    return test
end

let 
    par1 = BMPPar(y0 = 2.0, ymax = 0.6, c = 0.5, p = 2.2)
    Irange = 0.0:0.01:10.0
    Yrange = 0.0:0.01:1.0
    Yield1 = [yieldIII(I, par1) for I in Irange]
    MC1 = [margcostIII(I, par1) for I in Irange]
    AVC1 = [avvarcostIII(I,par1) for I in Irange]
    AVCK1 = [avvarcostkickIII(Y,par1) for Y in Yrange]
    test = figure()
    plot(Yield1, MC1, color="blue", label="MC")
    plot(Yield1, AVC1, color="orange", label="AVC")
    plot(Yrange, AVCK1, color="green", label="AVCK")
    hlines(par1.p, 0.0, 1.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    return test
end

let 
    data = timeseries_profit(50, BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2), 0.0)
    test = figure()
    plot(1:1:50, data)
    return test
end

#Trying out AVCK slope numerical analysis
function AVCKslope(par)
    Yrange = 0.0:0.01:par.ymax
    data = [avvarcostkickIII(Y,par) for Y in Yrange]
    Yindex = isapprox_index(Yrange, maxprofitIII_vals(par)[2])
    slope = (data[Yindex+1] - data[Yindex]) / (Yrange[Yindex+1] - Yrange[Yindex])
    return slope
end

function AVCKslopedata(y0range, ymaxrange)
    Irange = 0.0:0.01:10.0
    y0range = y0range
    ymaxrange = ymaxrange
    data = Array{Float64}(undef, length(y0range), length(ymaxrange))
    @threads for y0i in eachindex(y0range)
        @inbounds for (ymaxi, ymaxnum) in enumerate(ymaxrange)
            par = BMPPar(ymax = ymaxnum, y0 = y0range[y0i], c = 0.5, p = 2.2)
            if minimum([margcostIII(I, par) for I in Irange]) >= par.p || minimum([avvarcostIII(I, par) for I in Irange]) >= par.p
                data[y0i,ymaxi] = NaN
            else
                data[y0i,ymaxi] = AVCKslope(par)
            end
        end
    end
    return [y0range, ymaxrange, data]
end


let 
    data = AVCKslopedata(0.8:0.01:2.0, 0.8:0.01:2.0)
    test = figure()
    pcolor(data[1], data[2], data[3])
    colorbar()
    xlabel("ymax")
    ylabel("y0")
    return test
end
#bigger effect of ymax on slope. but effect of yo happens when ymax is small.

#Trying out how to minimize crossing of AVCK with MR line
function AVCK_MR(par)
    Yrange = 0.0:0.01:par.ymax
    data = [avvarcostkickIII(Y,par) for Y in Yrange]
    Yindex = isapprox_index(data, par.p)
    minyield = Yrange[Yindex]
    return minyield
end

function AVCKmaxyield_MR(par, slope)
    Yrange = 0.0:0.01:par.ymax
    data = [avvarcostkickIII_maxyield(Y, slope, par) for Y in Yrange]
    Yindex = isapprox_index(data, par.p)
    minyield = Yrange[Yindex]
    return minyield
end

function AVCK_MRdata(y0range, ymaxrange, p)
    Irange = 0.0:0.01:10.0
    y0range = y0range
    ymaxrange = ymaxrange
    data = Array{Float64}(undef, length(y0range), length(ymaxrange))
    @threads for y0i in eachindex(y0range)
        @inbounds for (ymaxi, ymaxnum) in enumerate(ymaxrange)
            par = BMPPar(ymax = ymaxnum, y0 = y0range[y0i], c = 0.5, p = p)
            if minimum([margcostIII(I, par) for I in Irange]) >= p || minimum([avvarcostIII(I, par) for I in Irange]) >= p
                data[y0i,ymaxi] = NaN
            else
                data[y0i,ymaxi] = AVCK_MR(par)
            end
        end
    end
    return [y0range, ymaxrange, data]
end

AVCK_MRdata(0.5:0.01:2.0, 0.5:0.01:2.0, 2.2)

let 
    data = AVCK_MRdata(0.5:0.01:2.0, 0.5:0.01:2.0, 2.2)
    test = figure()
    pcolor(data[1], data[2], data[3])
    xlabel("ymax")
    ylabel("y0")
    colorbar()
    return test
end
#Is minimizing of AVCK and MR just the same as minimizing of AVC line at input decision? I think so but how to prove. If same, then we already have the answer (ymax and yo)
#Not quite because can have minimized AVC but still max yield is low pushing down optimal decision and inputs going in.

let 
    data1 = [1/X for X in 0.0:0.1:10.0]
    data2 = [2/X for X in 0.0:0.1:10.0]
    data3 = [5/X for X in 0.0:0.1:10.0]
    test = figure()
    plot(0.0:0.1:10.0, data1, label = "1")
    plot(0.0:0.1:10.0, data2, label = "2")
    plot(0.0:0.1:10.0, data3, label = "5")
    legend()
    return test
end

maxprofitIII_vals(BMPPar(ymax = 1.0, y0 = 2.0, c = 0.5, p = 2.2))
maxprofitIII_vals(BMPPar(ymax = 1.0, y0 = 0.2, c = 0.5, p = 2.2))
maxprofitIII_vals(BMPPar(ymax = 0.5, y0 = 2.0, c = 0.5, p = 2.2))
maxprofitIII_vals(BMPPar(ymax = 0.5, y0 = 0.2, c = 0.5, p = 2.2))

maxprofitIII_vals(BMPPar(ymax = 1.0, y0 = 2.0, c = 0.5, p = 2.2))[2] - AVCK_MR(BMPPar(ymax = 1.0, y0 = 2.0, c = 0.5, p = 2.2))

#Trying out maximizing of AVCK MC distance
function AVCK_MCdata(y0range, ymaxrange)
    Irange = 0.0:0.01:10.0
    y0range = y0range
    ymaxrange = ymaxrange
    data = Array{Float64}(undef, length(y0range), length(ymaxrange))
    for (y0i, y0num) in enumerate(y0range)
        for (ymaxi, ymaxnum) in enumerate(ymaxrange)
            par = BMPPar(ymax = ymaxnum, y0 = y0num, c = 0.5, p = 2.2)
            if minimum([margcostIII(I, par) for I in Irange]) >= par.p || minimum([avvarcostIII(I, par) for I in Irange]) >= par.p || maxprofitIII_vals(par)[2] == AVCK_MR(par)
                data[y0i,ymaxi] = NaN
            else
                data[y0i,ymaxi] = maxprofitIII_vals(par)[2] - AVCK_MR(par)
            end
        end
    end
    return [y0range, ymaxrange, data]
end

AVCK_MCdata(0.5:0.1:2.0, 0.5:0.1:2.0)

let 
    data = AVCK_MCdata(0.5:0.1:2.0, 0.5:0.1:2.0, 2.2)
    test = figure()
    pcolor(data[1], data[2], data[3])
    xlabel("ymax")
    ylabel("y0")
    colorbar()
    return test
end

#Trying out comparing AVCK_MR/YieldChoice distance between max profit and max yield
function compare_distance(par, maxyieldslope)
    maxprofitdistance = maxprofitIII_vals(par)[2] - AVCK_MR(par)
    maxyielddistance = maxyieldIII_vals(maxyieldslope, par)[2] - AVCKmaxyield_MR(par, maxyieldslope)
    return [maxprofitdistance, maxyielddistance]
end

compare_distance(BMPPar(ymax = 0.7, y0 = 0.5, c = 0.5, p = 2.2), 0.2)

function check_compare_distance(y0range, ymaxrange, maxyieldslope)
    Irange = 0.0:0.01:10.0
    y0range = y0range
    ymaxrange = ymaxrange
    count = 0
    for (y0i, y0num) in enumerate(y0range)
        for (ymaxi, ymaxnum) in enumerate(ymaxrange)
            par = BMPPar(ymax = ymaxnum, y0 = y0num, c = 0.5, p = 2.2)
            distance = compare_distance(par, maxyieldslope)
            if distance[1] < distance[2]
                count += 1
                return [ymaxnum, y0num]
            end
        end
    end
    # return count/(length(y0range)*length(ymaxrange))
end

compare_distance(BMPPar(ymax = 1.0, y0 = 0.5, c = 0.5, p = 2.2), 0.18)

check_compare_distance(0.5:0.1:2.0, 0.5:0.1:2.0, 0.18)
#maxing yield (instead of maxing profit) always makes farms more vulnerable to yield kicks (negative profit) because avck line is closer to yield decision
#THIS HAPPENS WHEN? BUT there seems to be a sweet spot depending on the slope of the hueristic decision after which max profit distance can be l

let 
    par1 = BMPPar(y0 = 0.5, ymax = 1.0, c = 0.5, p = 2.2)
    maxyieldslope = 0.15
    Irange = 0.0:0.01:10.0
    Yrange = 0.0:0.01:1.0
    Yield1 = [yieldIII(I, par1) for I in Irange]
    MC1 = [margcostIII(I, par1) for I in Irange]
    AVC1 = [avvarcostIII(I,par1) for I in Irange]
    AVCK1 = [avvarcostkickIII(Y, par1) for Y in Yrange]
    AVCK2 = [avvarcostkickIII_maxyield(Y, maxyieldslope, par1) for Y in Yrange]
    costcurveskick = figure()
    plot(Yield1, MC1, color="blue", label="MC")
    plot(Yield1, AVC1, color="orange", label="AVC")
    plot(Yrange, AVCK1, color="green", label="AVCK")
    plot(Yrange, AVCK2, color="red", label="AVCKMxY")
    hlines(par1.p, 0.0, 1.0, colors="black", label = "MR")
    vlines(maxyieldIII_vals(maxyieldslope, par1)[2], 0.0, 4.0, label = "MxY")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    return costcurveskick
    # savefig(joinpath(abpath(), "figs/costcurveskick.png"))
end 

#Trying out compare slopes of AVCK between max profit and max yield
function AVCKslope_maxyield(par, maxyieldslope)
    Yrange = 0.0:0.01:par.ymax
    data = [avvarcostkickIII_maxyield(Y,maxyieldslope,par) for Y in Yrange]
    Yindex = isapprox_index(Yrange, maxyieldIII_vals(maxyieldslope, par)[2])
    slope = (data[Yindex+1] - data[Yindex]) / (Yrange[Yindex+1] - Yrange[Yindex])
    return slope
end

function compare_slopes(par, maxyieldslope)
    maxprofitslope = AVCKslope(par)
    maxyslope = AVCKslope_maxyield(par, maxyieldslope)
    return [maxprofitslope, maxyslope]
end

compare_slopes(BMPPar(y0 = 1.0, ymax = 2.0, c = 0.5, p = 2.2), 0.1)

function compare_slopes_data(y0range, ymaxrange, maxyieldslope)
    Irange = 0.0:0.01:10.0
    y0range = y0range
    ymaxrange = ymaxrange
    data = Array{Float64}(undef, length(y0range), length(ymaxrange))
    @threads for y0i in eachindex(y0range)
        @inbounds for (ymaxi, ymaxnum) in enumerate(ymaxrange)
            par = BMPPar(ymax = ymaxnum, y0 = y0range[y0i], c = 0.5, p = 2.2)
            slopes = compare_slopes(par, maxyieldslope)
            if minimum([margcostIII(I, par) for I in Irange]) >= par.p || minimum([avvarcostIII(I, par) for I in Irange]) >= par.p
                data[y0i,ymaxi] = NaN
            else
                data[y0i,ymaxi] = abs(slopes[1])-abs(slopes[2])
            end
        end
    end
    return [y0range, ymaxrange, data]
end

compare_slopes_data(0.5:0.1:2.0, 0.5:0.1:2.0, 0.1)
#Most of the time max yield causes higher variability (larger AVCK slope) compared to max profit. except when ymax is low and the opposite is true

let 
    data = compare_slopes_data(0.8:0.1:2.0, 0.8:0.1:2.0, 0.1)
    test = figure()
    pcolor(data[1], data[2], data[3])
    xlabel("ymax")
    ylabel("y0")
    colorbar()
    return test
end

#Trying out "profit margin" numerical analysis
function unitmargin(par)
    vals = maxprofitIII_vals(par)
    unitcost = avvarcostIII(vals[1],par)
    return par.p-unitcost
end

function unitmargindata(y0range, ymaxrange, p)
    Irange = 0.0:0.01:10.0
    y0range = y0range
    ymaxrange = ymaxrange
    data = Array{Float64}(undef, length(y0range), length(ymaxrange))
    @threads for y0i in eachindex(y0range)
        @inbounds for (ymaxi, ymaxnum) in enumerate(ymaxrange)
            par = BMPPar(ymax = ymaxnum, y0 = y0range[y0i], c = 0.5, p = p)
            if minimum([margcostIII(I, par) for I in Irange]) >= p || minimum([avvarcostIII(I, par) for I in Irange]) >= p
                data[y0i,ymaxi] = NaN
            else
                data[y0i,ymaxi] = unitmargin(par)
            end
        end
    end
    return [y0range, ymaxrange, data]
end

let 
    data = unitmargindata(0.5:0.01:2.0, 0.5:0.01:2.0, 2.2)
    test = figure()
    pcolor(data[1], data[2], data[3])
    xlabel("ymax")
    ylabel("y0")
    colorbar()
    return test
end


function mincosts(par)
    vals = maxprofitIII_vals(par)
    unitcost = avvarcostIII(vals[1],par)
    return unitcost
end

function mincostsdata(y0range, ymaxrange)
    Irange = 0.0:0.01:10.0
    y0range = y0range
    ymaxrange = ymaxrange
    data = Array{Float64}(undef, length(y0range), length(ymaxrange))
    @threads for y0i in eachindex(y0range)
        @inbounds for (ymaxi, ymaxnum) in enumerate(ymaxrange)
            par = BMPPar(ymax = ymaxnum, y0 = y0range[y0i], c = 0.5, p = 2.2)
            if minimum([margcostIII(I, par) for I in Irange]) >= par.p || minimum([avvarcostIII(I, par) for I in Irange]) >= par.p #may not need this line because minimising
                data[y0i,ymaxi] = NaN
            else
                data[y0i,ymaxi] = mincosts(par)
            end
        end
    end
    return [y0range, ymaxrange, data]
end

let 
    data = mincostsdata(0.5:0.01:2.0, 0.5:0.01:2.0)
    test = figure()
    pcolor(data[1], data[2], data[3])
    xlabel("ymax")
    ylabel("y0")
    colorbar()
    return test
end
#ymax has the biggest effect on minimizing costs (further from p) but not at smaller ymax values then y0 becomes important

#Trying out noise in cost of inputs
let 
    par1 = BMPPar(y0 = 2.0, ymax = 1.0, c = 0.2, p = 2.2)
    par2 = BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2)
    par3 = BMPPar(y0 = 2.0, ymax = 1.0, c = 0.8, p = 2.2)
    par4 = BMPPar(y0 = 2.0, ymax = 1.0, c = 1.2, p = 2.2)
    Irange = 0.0:0.01:10.0
    Yield = [yieldIII(I, par1) for I in Irange]
    MC1 = [margcostIII(I, par1) for I in Irange]
    AVC1 = [avvarcostIII(I,par1) for I in Irange]
    MC2 = [margcostIII(I, par2) for I in Irange]
    AVC2 = [avvarcostIII(I,par2) for I in Irange]
    MC3 = [margcostIII(I, par3) for I in Irange]
    AVC3 = [avvarcostIII(I,par3) for I in Irange]
    MC4 = [margcostIII(I, par4) for I in Irange]
    AVC4 = [avvarcostIII(I,par4) for I in Irange]
    costcurves = figure()
    subplot(2,2,1)
    plot(Yield, MC1, color="blue", label="MC")
    plot(Yield, AVC1, color="orange", label="AVC")
    hlines(par1.p, 0.0, 1.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(2,2,2)
    plot(Yield, MC2, color="blue", label="MC")
    plot(Yield, AVC2, color="orange", label="AVC")
    hlines(par2.p, 0.0, 1.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(2,2,3)
    plot(Yield, MC3, color="blue", label="MC")
    plot(Yield, AVC3, color="orange", label="AVC")
    hlines(par3.p, 0.0, 1.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(2,2,4)
    plot(Yield, MC4, color="blue", label="MC")
    plot(Yield, AVC4, color="orange", label="AVC")
    hlines(par4.p, 0.0, 1.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    tight_layout()
    return costcurves
    # savefig(joinpath(abpath(), "figs/costcurves.png"))
end   


#Cumulative distribution

function termprofit_sims_unscaled(iter, par, r, var, length)
    data = zeros(iter)
    @threads for i in 1:iter
        @inbounds data[i] = sum(timeseries_profit_unscaled(par, r, var, length, i))
    end
    return data
end

function counttermprof(data, value)
    count = 0
    for i in 1:length(data)
        if data[i] < value
            count += 1
        end
    end
    return count
end

function cumulativeprob(data, stepsize)
    range = minimum(data):stepsize:maximum(data)
    cumulprob = zeros(length(range))
    for (tpi, tpnum) in enumerate(range)
        cumulprob[tpi] = counttermprof(data, tpnum) / length(data)
    end
    return [range, cumulprob]
end

let 
    data = cumulativeprob(termprofit_sims_unscaled(100, BMPPar(y0 = 2.0, ymax = 0.8, c = 0.5, p = 2.2), 0.9, 0.1, 50), 0.1)
    test = figure()
    plot(data[1], data[2])
    return test
end
cumulativeprob(testdata, 0.1)


function termprofit_sims_scaled_debt(iter, par, r, var, length)
    data = zeros(iter)
    @threads for i in 1:iter
        @inbounds data[i] = timeseries_profit_scaled_debt(par, r, var, length, i)
    end
    return data
end

termprofit_sims_scaled_debt(100, BMPPar(y0 = 2.0, ymax = 3.0, c = 0.5, p = 2.2), 0.0, 0.1, 50)

let 
    data = cumulativeprob(termprofit_sims_scaled_debt(100, BMPPar(y0 = 2.0, ymax = 2.0, c = 0.5, p = 2.2), 0.0, 0.1, 50), 0.1)
    test = figure()
    plot(data[1], data[2])
    return test
end
#again problem with using scaled noise - when profit always positive - term profit is always the same.

cumulativeprob_profit(100, 50, BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2), 0.8)

timeseries_profit(5, BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2), 0.0, 2)
timeseries_profit(5, BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2), 0.0, 137)
timeseries_profit(5, BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2), 0.9, 2)
timeseries_profit(5, BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2), 0.9, 137)

sum(timeseries_profit(5, BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2), 0.0, 2))
sum(timeseries_profit(5, BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2), 0.0, 137))
sum(timeseries_profit(5, BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2), 0.9, 2))
sum(timeseries_profit(5, BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2), 0.9, 137))


#random iter is still returning the same sum and profit. regardless of correlation in noise