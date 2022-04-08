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


#Trying out "profit margin" numerical analysis
function unitmargin(par)
    vals = maxprofitIII_vals(par)
    unitcost = avvarcostIII(vals[1],par)
    return par.p-unitcost
end


test = Array{Float64}(undef, 2, 3)
test[2,2]

function unitmargindata(p)
    Irange = 0.0:0.01:10.0
    y0range = 0.001:0.01:2.0
    ymaxrange = 0.001:0.01:2.0
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
    return data
end

unitmargindata(2.2)

let 
    test = figure()
    pcolor(collect(0.001:0.01:2.0), collect(0.001:0.01:2.0), unitmargindata(2.2))
    xlabel("ymax")
    ylabel("y0")
    return test
end


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

function cumulativeprob_profit(iter, length, par, r)
    data = zeros(iter)
    @threads for i in 1:iter
        @inbounds data[i] = sum(timeseries_profit(length, par, r, i))
    end
    return data
end
    
cumulativeprob_profit(100, 50, BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2), 0.8)

timeseries_profit(5, BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2), 0.0, 2)
timeseries_profit(5, BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2), 0.0, 90)
timeseries_profit(5, BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2), 0.9, 2)
timeseries_profit(5, BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2), 0.9, 90)

sum(timeseries_profit(5, BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2), 0.0, 2))
sum(timeseries_profit(5, BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2), 0.0, 90))
sum(timeseries_profit(5, BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2), 0.9, 2))
sum(timeseries_profit(5, BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2), 0.9, 90))

sum(timeseries_profit(2, BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2), 0.0, 2))

#random iter is still returning the same sum and profit. regardless of correlation in noise