include("packages.jl")
include("AgriEco_commoncode.jl")

#Trying out AVCK slope numerical analysis
function AVCKslope(profityield, par, maxyieldslope::Float64=0.1)
    Yrange = 0.0:0.01:par.ymax
    data = [avvarcostkickIII(Y, par, profityield, maxyieldslope) for Y in Yrange]
    if profityield == "profit"
        Yindex = isapprox_index(Yrange, maxprofitIII_vals(par)[2])
    elseif profityield == "yield"
        Yindex = isapprox_index(Yrange, maxyieldIII_vals(maxyieldslope, par)[2])
    else
        error("profityield variable must be either \"profit\" or \"yield\".")
    end
    slope = (data[Yindex+1] - data[Yindex]) / (Yrange[Yindex+1] - Yrange[Yindex])
    return slope
end

function AVCKslopedata(y0range, ymaxrange, profityield, p::Float64 = 2.2, maxyieldslope::Float64 = 0.1)
    Irange = 0.0:0.01:10.0
    y0range = y0range
    ymaxrange = ymaxrange
    data = Array{Float64}(undef, length(ymaxrange), length(y0range))
    @threads for ymaxi in eachindex(ymaxrange)
        @inbounds for (y0i, y0num) in enumerate(y0range)
            par = BMPPar(y0 = y0num, ymax = ymaxrange[ymaxi], c = 0.5, p = p)
            if minimum(filter(!isnan, [margcostIII(I, par) for I in Irange])) >= par.p || minimum(filter(!isnan, [avvarcostIII(I, par) for I in Irange])) >= par.p
                data[ymaxi, y0i] = NaN
            elseif profityield == "yield" && avvarcostIII(maxyieldIII_vals(maxyieldslope, par)[1],par) >= par.p
                data[ymaxi, y0i] = NaN
            else
                data[ymaxi, y0i] = AVCKslope(profityield, par, maxyieldslope)
            end
        end
    end
    return [ymaxrange, y0range, data]
end


let 
    data_maxprofit = AVCKslopedata(0.8:0.01:2.0, 0.8:0.01:2.0, "profit", 2.2)
    data_maxyield = AVCKslopedata(0.8:0.01:2.0, 0.8:0.01:2.0, "yield", 2.2)
    AVCKslopefig = figure(figsize=(8,3))
    subplot(1,2,1)
    title("Maximum profit")
    pcolor(data_maxprofit[1], data_maxprofit[2], data_maxprofit[3], vmin=-4.5, vmax=-0.5)
    colorbar()
    ylabel("Maximize potential yield")
    xlabel("Input efficiency")
    subplot(1,2,2)
    title("Maximize yield")
    pcolor(data_maxyield[1], data_maxyield[2], data_maxyield[3], vmin=-4.5, vmax=-0.5)
    colorbar()
    ylabel("Maximum potential yield")
    xlabel("Input efficiency")
    tight_layout()
    # return AVCKslopefig
    savefig(joinpath(abpath(), "figs/AVCKslopefig.png"))
end
#bigger effect of ymax on slope. but effect of yo happens when ymax is small.

#Trying out compare slopes of AVCK between max profit and max yield
function compare_slopes(par, maxyieldslope::Float64=0.1)
    maxprofitslope = AVCKslope("profit", par)
    maxyslope = AVCKslope("yield", par, maxyieldslope)
    return [maxprofitslope, maxyslope]
end

function compare_slopes_data(y0range, ymaxrange, p::Float64 = 2.2, maxyieldslope::Float64=0.1)
    Irange = 0.0:0.01:10.0
    y0range = y0range
    ymaxrange = ymaxrange
    data = Array{Float64}(undef, length(ymaxrange), length(y0range))
    @threads for ymaxi in eachindex(ymaxrange)
        @inbounds for (y0i, y0num) in enumerate(y0range)
            par = BMPPar(y0 = y0num, ymax = ymaxrange[ymaxi], c = 0.5, p = p)
            if minimum(filter(!isnan,[margcostIII(I, par) for I in Irange])) >= par.p || avvarcostIII(maxyieldIII_vals(maxyieldslope, par)[1],par) >= par.p
                data[ymaxi, y0i] = NaN
            else
                slopes = compare_slopes(par, maxyieldslope)
                data[ymaxi, y0i] = abs(slopes[1])-abs(slopes[2])
            end
        end
    end
    return [ymaxrange, y0range, data]
end
#Most of the time max yield causes higher variability (larger AVCK slope) compared to max profit. except when ymax is low and the opposite is true

function compare_slopes_AVC_min(y0range, ymaxrange, p::Float64 = 2.2, maxyieldslope::Float64=0.1)
    Irange = 0.0:0.01:10.0
    y0range = y0range
    ymaxrange = ymaxrange
    data = Array{Float64}(undef, length(ymaxrange), length(y0range))
    @threads for ymaxi in eachindex(ymaxrange)
        @inbounds for (y0i, y0num) in enumerate(y0range)
            par = BMPPar(y0 = y0num, ymax = ymaxrange[ymaxi], c = 0.5, p = p)
            if minimum(filter(!isnan,[margcostIII(I, par) for I in Irange])) >= par.p
                data[ymaxi, y0i] = NaN
            elseif minimum(filter(!isnan,[avvarcostIII(I, par) for I in Irange])) >= par.p
                data[ymaxi, y0i] = 1
            else
                data[ymaxi, y0i] = 0
            end
        end
    end
    return data
end

function compare_slopes_AVC_maxyieldinput(y0range, ymaxrange, p::Float64 = 2.2, maxyieldslope::Float64=0.1)
    Irange = 0.0:0.01:10.0
    y0range = y0range
    ymaxrange = ymaxrange
    data = Array{Float64}(undef, length(ymaxrange), length(y0range))
    @threads for ymaxi in eachindex(ymaxrange)
        @inbounds for (y0i, y0num) in enumerate(y0range)
            par = BMPPar(y0 = y0num, ymax = ymaxrange[ymaxi], c = 0.5, p = p)
            if minimum(filter(!isnan,[margcostIII(I, par) for I in Irange])) >= par.p
                data[ymaxi, y0i] = NaN
            elseif avvarcostIII(maxyieldIII_vals(maxyieldslope, par)[1],par) >= par.p
                data[ymaxi, y0i] = 1
            else
                data[ymaxi, y0i] = 0
            end
        end
    end
    return data
end

function true_slopescompare(data1, data2)
    data = Array{Float64}(undef, size(data1,1), size(data1,2))
    for i in 1:size(data1,1)
        for j in 1:size(data1,2)
            if isnan(data1[i,j])
                data[i,j] =  NaN
            elseif data1[i,j] > 0.0 && data2[i,j] == 0.0
                data[i,j] =  1.0
            else
                data[i,j] = 0.0
            end
        end
    end
    return data
end
 
compare_slopes_AVC_maxyieldinput(0.8:0.1:2.0, 0.8:0.1:2.0, 1.2)

true_slopescompare(compare_slopes_data(0.8:0.1:2.0, 0.8:0.1:2.0, 1.2)[3], compare_slopes_AVC_maxyieldinput(0.8:0.1:2.0, 0.8:0.1:2.0, 1.2))

[avvarcostIII(I, BMPPar(y0 = 1.4, ymax = 0.9, c = 0.5, p = 1.2)) for I in 0.01:0.01:10.0]

minimum([avvarcostIII(I, BMPPar(y0 = 1.4, ymax = 0.9, c = 0.5, p = 1.2)) for I in 0.01:0.01:10.0])
using CSV
compare_slopes_data(0.8:0.1:2.0, 0.8:0.1:2.0, 1.2)[3]

let 
    data = compare_slopes_data(0.8:0.1:2.0, 0.8:0.1:2.0, 2.2)
    compareslopesfig = figure()
    pcolor(data[1], data[2], data[3])
    ylabel("ymax")
    xlabel("y0")
    colorbar()
    return compareslopesfig
    # savefig(joinpath(abpath(), "figs/compareslopesfig.png"))
end

#Coefficient of variation
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