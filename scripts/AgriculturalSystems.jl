include("packages.jl")

function abpath()
    replace(@__DIR__, "scripts" => "")
end 

#white and red noise can be created by an AR process – equation 1 in ruokolainen et al 2009

# Yield model
@with_kw mutable struct BMPPar
    ymax = 1.0
    y0 = 1.0
    p = 1.0
    c = 1.0
end

@vars C
@vars y y₀ p c

f(C) = y * (C^2) / (y₀ + (C^2))
SymPy.simplify(diff(f(C),C))

g(C) = y * (C^2) / (y₀ + (C^2))
SymPy.simplify(diff(g(C),C))

SymPy.solve((c/p)*((y₀+(C^2))^2)-(2*C*y*y₀), C)

function yieldIII(I, par)
    @unpack ymax, y0 = par
    return ymax * (I^2) / (y0 + (I^2))
end

let 
    data = [yieldIII(I, BMPPar(y0 = 1.0)) for I in 0.0:0.01:5.0]
    typeIII = figure()
    plot(0.0:0.01:5.0, data)
    xlabel("Inputs")
    ylabel("Yield")
    # return typeIII
    savefig(joinpath(abpath(), "figs/typeIIIexample.png"))
end

let 
    Irange = 0.0:0.01:5.0
    data2010 = [yieldIII(I, BMPPar(y0 = 2.0, ymax = 1.0)) for I in Irange]
    data2005 = [yieldIII(I, BMPPar(y0 = 2.0, ymax = 0.5)) for I in Irange]
    data0210 = [yieldIII(I, BMPPar(y0 = 0.2, ymax = 1.0)) for I in Irange]
    data0205 = [yieldIII(I, BMPPar(y0 = 0.2, ymax = 0.5)) for I in Irange]
    typeIIIparamfigure = figure()
    subplot(2,2,1)
    plot(Irange, data2010)
    xlabel("Inputs")
    ylabel("Yield")
    ylim(0.0, 1.0)
    subplot(2,2,2)
    plot(Irange, data2005)
    xlabel("Inputs")
    ylabel("Yield")
    ylim(0.0, 1.0)
    subplot(2,2,3)
    plot(Irange, data0210)
    xlabel("Inputs")
    ylabel("Yield")
    ylim(0.0, 1.0)
    subplot(2,2,4)
    plot(Irange, data0205)
    xlabel("Inputs")
    ylabel("Yield")
    ylim(0.0, 1.0)
    tight_layout()
    # return typeIIIparamfigure
    savefig(joinpath(abpath(), "figs/typeIIIparamfigure.png"))
end

function margprodII(I, par)
    @unpack ymax, y0 = par
    return ymax * y0 / (( y0 + I )^2)
end

function margprodIII(I, par)
    @unpack ymax, y0 = par
    return 2 * I * ymax * y0 / (( y0 + (I^2) )^2)
end

let 
    par = BMPPar(y0 = 0.2, ymax = 1.0, c = 0.5, p=2.2)
    Irange = 0.0:0.01:10.0
    data1 = [margprodII(I, par) for I in Irange]
    data2 = [margprodIII(I, par) for I in Irange]
    test = figure()
    plot(Irange, data1)
    plot(Irange, data2)
    hlines(par.c/par.p, 0.0, 10.0)
    return test
end #KEEP to help improve code for guess for root solver

function yieldII(I, par)
    @unpack ymax, y0 = par
    return ymax * I / (y0 + I)
end

function maxprofitII_vals(par)
    @unpack ymax, y0, p, c = par
    I = sqrt((p * ymax * y0)/c)-y0
    Y = yieldII(I, par)
    return [I, Y]
end

function maxprofitIII_param(I, par)
    @unpack y0, ymax, c, p = par
    return 2 * I * ymax * y0 / (( y0 + (I^2) )^2) - c/p
end

function maxprofitIII_vals(par)
    guess = maximum([par.y0, maxprofitII_vals(par)[1]])
    I = find_zero(I -> maxprofitIII_param(I, par), guess)
    Y = yieldIII(I, par)
    return [I, Y]
end

maxprofitIII_vals(BMPPar(y0 = 0.2, ymax = 1.0, c = 0.5, p = 2.2))
maxprofitIII_vals(BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2))


function maxyieldIII_param(I, slope, par)
    @unpack y0, ymax, c, p = par
    return 2 * I * ymax * y0 / (( y0 + (I^2) )^2) - slope
end

function maxyieldIII_vals(slope, par)
    guess = maximum([par.y0, maxprofitII_vals(par)[1]])
    I = find_zero(I -> maxyieldIII_param(I, slope, par), guess)
    Y = yieldIII(I, par)
    return [I, Y]
end

maxyieldIII_vals(0.2, BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2))

#Any way to geometrically show the parameters and their effects
#https://www.economics.utoronto.ca/osborne/2x3/tutorial/MPFRM.HTM
#Marginal revenue versus marginal cost figures
function avvarcostIII(I,par)
    @unpack c = par
    Y = yieldIII(I, par)
    return c * I / Y
end
###might be a way of making this more general
function avvarcostkickIII(Y, par)
    @unpack c = par
    I = maxprofitIII_vals(par)[1]
    return c * I / Y
end

function margcostIII(I, par)
    @unpack c = par
    return c / margprodIII(I, par)
end

function avvarcostkickIII_maxyield(Y, slope, par)
    @unpack c = par
    I = maxyieldIII_vals(slope, par)[1]
    return c * I / Y
end

let 
    par1 = BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2)
    par2 = BMPPar(y0 = 2.0, ymax = 0.5, c = 0.5, p = 2.2)
    par3 = BMPPar(y0 = 0.2, ymax = 1.0, c = 0.5, p = 2.2)
    par4 = BMPPar(y0 = 0.2, ymax = 0.5, c = 0.5, p = 2.2)
    Irange = 0.0:0.01:10.0
    Yield1 = [yieldIII(I, par1) for I in Irange]
    MC1 = [margcostIII(I, par1) for I in Irange]
    AVC1 = [avvarcostIII(I,par1) for I in Irange]
    Yield2 = [yieldIII(I, par2) for I in Irange]
    MC2 = [margcostIII(I, par2) for I in Irange]
    AVC2 = [avvarcostIII(I,par2) for I in Irange]
    Yield3 = [yieldIII(I, par3) for I in Irange]
    MC3 = [margcostIII(I, par3) for I in Irange]
    AVC3 = [avvarcostIII(I,par3) for I in Irange]
    Yield4 = [yieldIII(I, par4) for I in Irange]
    MC4 = [margcostIII(I, par4) for I in Irange]
    AVC4 = [avvarcostIII(I,par4) for I in Irange]
    costcurves = figure()
    subplot(2,2,1)
    plot(Yield1, MC1, color="blue", label="MC")
    plot(Yield1, AVC1, color="orange", label="AVC")
    hlines(par1.p, 0.0, 1.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(2,2,2)
    plot(Yield2, MC2, color="blue", label="MC")
    plot(Yield2, AVC2, color="orange", label="AVC")
    hlines(par2.p, 0.0, 1.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(2,2,3)
    plot(Yield3, MC3, color="blue", label="MC")
    plot(Yield3, AVC3, color="orange", label="AVC")
    hlines(par3.p, 0.0, 1.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(2,2,4)
    plot(Yield4, MC4, color="blue", label="MC")
    plot(Yield4, AVC4, color="orange", label="AVC")
    hlines(par4.p, 0.0, 1.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    tight_layout()
    # return costcurves
    savefig(joinpath(abpath(), "figs/costcurves.png"))
end       


let 
    par1 = BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2)
    par2 = BMPPar(y0 = 2.0, ymax = 0.5, c = 0.5, p = 2.2)
    par3 = BMPPar(y0 = 0.2, ymax = 1.0, c = 0.5, p = 2.2)
    par4 = BMPPar(y0 = 0.2, ymax = 0.5, c = 0.5, p = 2.2)
    Irange = 0.0:0.01:10.0
    Yrange = 0.0:0.01:1.0
    Yield1 = [yieldIII(I, par1) for I in Irange]
    MC1 = [margcostIII(I, par1) for I in Irange]
    AVC1 = [avvarcostIII(I,par1) for I in Irange]
    AVCK1 = [avvarcostkickIII(Y,par1) for Y in Yrange]
    Yield2 = [yieldIII(I, par2) for I in Irange]
    MC2 = [margcostIII(I, par2) for I in Irange]
    AVC2 = [avvarcostIII(I,par2) for I in Irange]
    AVCK2 = [avvarcostkickIII(Y,par2) for Y in Yrange]
    Yield3 = [yieldIII(I, par3) for I in Irange]
    MC3 = [margcostIII(I, par3) for I in Irange]
    AVC3 = [avvarcostIII(I,par3) for I in Irange]
    AVCK3 = [avvarcostkickIII(Y,par3) for Y in Yrange]
    Yield4 = [yieldIII(I, par4) for I in Irange]
    MC4 = [margcostIII(I, par4) for I in Irange]
    AVC4 = [avvarcostIII(I,par4) for I in Irange]
    AVCK4 = [avvarcostkickIII(Y,par4) for Y in Yrange]
    costcurveskick = figure()
    subplot(2,2,1)
    plot(Yield1, MC1, color="blue", label="MC")
    plot(Yield1, AVC1, color="orange", label="AVC")
    plot(Yrange, AVCK1, color="green", label="AVCK")
    hlines(par1.p, 0.0, 1.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(2,2,2)
    plot(Yield2, MC2, color="blue", label="MC")
    plot(Yield2, AVC2, color="orange", label="AVC")
    plot(Yrange, AVCK2, color="green", label="AVCK")
    hlines(par2.p, 0.0, 1.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(2,2,3)
    plot(Yield3, MC3, color="blue", label="MC")
    plot(Yield3, AVC3, color="orange", label="AVC")
    plot(Yrange, AVCK3, color="green", label="AVCK")
    hlines(par3.p, 0.0, 1.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(2,2,4)
    plot(Yield4, MC4, color="blue", label="MC")
    plot(Yield4, AVC4, color="orange", label="AVC")
    plot(Yrange, AVCK4, color="green", label="AVCK")
    hlines(par4.p, 0.0, 1.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    tight_layout()
    # return costcurveskick
    savefig(joinpath(abpath(), "figs/costcurveskick.png"))
end 


let 
    par1 = BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2)
    par2 = BMPPar(y0 = 2.0, ymax = 0.5, c = 0.5, p = 2.2)
    par3 = BMPPar(y0 = 0.2, ymax = 1.0, c = 0.5, p = 2.2)
    par4 = BMPPar(y0 = 0.2, ymax = 0.5, c = 0.5, p = 2.2)
    Irange = 0.0:0.01:10.0
    Yrange = 0.0:0.01:1.0
    Yield1 = [yieldIII(I, par1) for I in Irange]
    MC1 = [margcostIII(I, par1) for I in Irange]
    AVC1 = [avvarcostIII(I,par1) for I in Irange]
    AVCK1 = [avvarcostkickIII_maxyield(Y, 0.2, par1) for Y in Yrange]
    Yield2 = [yieldIII(I, par2) for I in Irange]
    MC2 = [margcostIII(I, par2) for I in Irange]
    AVC2 = [avvarcostIII(I,par2) for I in Irange]
    AVCK2 = [avvarcostkickIII_maxyield(Y, 0.2, par2) for Y in Yrange]
    Yield3 = [yieldIII(I, par3) for I in Irange]
    MC3 = [margcostIII(I, par3) for I in Irange]
    AVC3 = [avvarcostIII(I,par3) for I in Irange]
    AVCK3 = [avvarcostkickIII_maxyield(Y, 0.2, par3) for Y in Yrange]
    Yield4 = [yieldIII(I, par4) for I in Irange]
    MC4 = [margcostIII(I, par4) for I in Irange]
    AVC4 = [avvarcostIII(I,par4) for I in Irange]
    AVCK4 = [avvarcostkickIII_maxyield(Y, 0.2, par4) for Y in Yrange]
    costcurveskick = figure()
    subplot(2,2,1)
    plot(Yield1, MC1, color="blue", label="MC")
    plot(Yield1, AVC1, color="orange", label="AVC")
    plot(Yrange, AVCK1, color="green", label="AVCK")
    hlines(par1.p, 0.0, 1.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(2,2,2)
    plot(Yield2, MC2, color="blue", label="MC")
    plot(Yield2, AVC2, color="orange", label="AVC")
    plot(Yrange, AVCK2, color="green", label="AVCK")
    hlines(par2.p, 0.0, 1.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(2,2,3)
    plot(Yield3, MC3, color="blue", label="MC")
    plot(Yield3, AVC3, color="orange", label="AVC")
    plot(Yrange, AVCK3, color="green", label="AVCK")
    hlines(par3.p, 0.0, 1.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(2,2,4)
    plot(Yield4, MC4, color="blue", label="MC")
    plot(Yield4, AVC4, color="orange", label="AVC")
    plot(Yrange, AVCK4, color="green", label="AVCK")
    hlines(par4.p, 0.0, 1.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    tight_layout()
    return costcurveskick
    # savefig(joinpath(abpath(), "figs/costcurveskick.png"))
end 

#Programming of time series of profit
function profit(I, Y, par)
    @unpack p, c = par
    return p * Y - c * I
end

function noise_creation(r, len)
    white = rand(Normal(0.0, 0.01), Int64(len))
    intnoise = [white[1]]
    for i in 2:Int64(len)
        intnoise = append!(intnoise, r * intnoise[i-1] + white[i] )
    end
    c = std(white)/std(intnoise)
    meanintnoise = mean(intnoise)
    scalednoise = zeros(Int64(len))
    for i in 1:Int64(len)
        scalednoise[i] = c * (intnoise[i] - meanintnoise)
    end
    return scalednoise
end

function timeseries_profit(length, par, r)
    noise = noise_creation(r, length)
    vals = maxprofitIII_vals(par)
    prof = zeros(length)
    for i in 1:length
        prof[i] = profit(vals[1], vals[2]+noise[i], par)
    end
    return prof
end

function cv_calc(data)
    stddev = std(data)
    mn = mean(data)
    return stddev/mn
end

function avcv_calc(iter, length, par, r)
    cv_data = zeros(iter)
    @threads for i in 1:iter
        @inbounds cv_data[i] = cv_calc(timeseries_profit(length, par, r))
    end
    return mean(cv_data)
end

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

#Trying out resilience boundary - where minimum time required to get back to positive terminal equity
function minτ_termprofit(k, par, type)
    if type == "II"
        vals = maxprofitII_vals(par)
    else
        vals = maxprofitIII_vals(par)
    end
    termprofit = profit(vals[1], vals[2]*k, par)
    minτ = 0
    while termprofit <= 0
        termprofit += profit(vals[1], vals[2], par)
        minτ += 1
    end
    return minτ
end

function res_bound(krange, par, type)
    vals = maxprofitIII_vals(par)
    checkprof = profit(vals[1], vals[2], par)
    if checkprof < 0
        error("Change params - farms are making a loss by default")
    end
    minτ = zeros(length(krange))
    for (ki, knum) in enumerate(krange)
        minτ[ki] = minτ_termprofit(knum, par, type)
    end
    return minτ
end

let 
    par1 = BMPPar(ymax=5.0, y0=1.5, c = 3.0)
    Irange = 0.0:0.01:10.0
    Yrange = 0.0:0.01:5.0
    Yield1 = [yieldII(I, par1) for I in Irange]
    MC1 = [margcost(I, par1) for I in Irange]
    AVC1 = [avvarcost(I,par1) for I in Irange]
    AVCK1 = [avvarcostkick(Y,par1) for Y in Yrange]
    test = figure()
    plot(Yield1, MC1)
    plot(Yield1, AVC1)
    plot(Yrange, AVCK1)
    hlines(1, 0.0, 5.0)
    ylim(0.0, 5.0)
    return test
end

let
    krange = 1.0:-0.01:0.0
    par1 = BMPPar(ymax=1.0, y0=2.0, c = 0.5, p = 2.2)
    par2 = BMPPar(ymax=0.8, y0=2.0, c = 0.5, p = 2.2)
    par3 = BMPPar(ymax=1.0, y0=1.3, c = 0.5, p = 2.2)
    resbound = figure()
    plot(res_bound(krange, par1, "III"), 1.0 .- collect(krange), label="y0=2.0, ymax=1.0")
    plot(res_bound(krange, par2, "III"), 1.0 .- collect(krange), label="y0=2.0, ymax=0.8")
    plot(res_bound(krange, par3, "III"), 1.0 .- collect(krange), label="y0=1.3, ymax=1.0")
    xlabel("Years")
    ylabel("Kick (proportion of yield)")
    legend()
    # return resbound
    savefig(joinpath(abpath(), "figs/resbound.png"))
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

# Monod Type II version
@vars C
@vars y y₀ c p

diff(sqrt(C), C)

f(C) = y * C / (y₀ + C)
g(y) = (p * y₀) / (y * (y₀ - sqrt((p * y * y₀)/c)))
s(y₀) = (p * y₀) / (y * (y₀ - sqrt((p * y * y₀)/c)))
SymPy.simplify(diff(g(y),y))
SymPy.simplify(diff(s(y₀),y₀))

SymPy.simplify(diff(f(C),C))

SymPy.simplify((-c * ((sqrt((p * y * y₀)/c))-y₀)) / ((y * ((sqrt((p * y * y₀)/c))-y₀)) / (y₀ + ((sqrt((p * y * y₀)/c))-y₀)) )^2)


maxprofitII_vals(BMPPar(y0=0.2, ymax=1.0, p=2.2, c=0.5))[1]

#Any way to geometrically show the parameters and their effects
#https://www.economics.utoronto.ca/osborne/2x3/tutorial/MPFRM.HTM
#Marginal revenue versus marginal cost figures
function avvarcostII(I,par)
    @unpack c = par
    Y = yieldII(I, par)
    return c * I / Y
end
###might be a way of making this more general
function avvarcostkickII(Y, par)
    @unpack c = par
    I = maxprofitII_vals(par)[1]
    return c * I / Y
end #THIS IS WRONG I NEEDS TO BE CONSTANT 

function margcostII(I, par)
    @unpack c = par
    return c / margprod(I, par)
end

let 
    par1 = BMPPar(ymax=5.0, c = 2.0)
    par2 = BMPPar(ymax=3.0, c = 2.0)
    Irange = 0.0:0.01:10.0
    Yrange = 0.0:0.01:5.0
    Yield1 = [yieldII(I, par1) for I in Irange]
    MC1 = [margcost(I, par1) for I in Irange]
    AVC1 = [avvarcost(I,par1) for I in Irange]
    AVCK1 = [avvarcostkick(Y,par1) for Y in Yrange]
    Yield2 = [yieldII(I, par2) for I in Irange]
    MC2 = [margcost(I, par2) for I in Irange]
    AVC2 = [avvarcost(I,par2) for I in Irange]
    AVCK2 = [avvarcostkick(Y,par2) for Y in Yrange]
    test = figure()
    subplot(2,1,1)
    plot(Yield1, MC1)
    plot(Yield1, AVC1)
    plot(Yrange, AVCK1)
    hlines(1, 0.0, 5.0)
    ylim(0.0, 5.0)
    subplot(2,1,2)
    plot(Yield2, MC2)
    plot(Yield2, AVC2)
    plot(Yrange, AVCK2)
    hlines(1, 0.0, 5.0)
    ylim(0.0, 3.0)
    tight_layout()
    return test
end

let 
    par1 = BMPPar(ymax=5.0, y0=1.0, c = 2.0)
    par2 = BMPPar(ymax=5.0, y0=0.5, c = 2.0)
    Irange = 0.0:0.01:10.0
    Yrange = 0.0:0.01:5.0
    Yield1 = [yieldII(I, par1) for I in Irange]
    MC1 = [margcost(I, par1) for I in Irange]
    AVC1 = [avvarcost(I,par1) for I in Irange]
    AVCK1 = [avvarcostkick(Y,par1) for Y in Yrange]
    Yield2 = [yieldII(I, par2) for I in Irange]
    MC2 = [margcost(I, par2) for I in Irange]
    AVC2 = [avvarcost(I,par2) for I in Irange]
    AVCK2 = [avvarcostkick(Y,par2) for Y in Yrange]
    test = figure()
    subplot(2,1,1)
    plot(Yield1, MC1)
    plot(Yield1, AVC1)
    plot(Yrange, AVCK1)
    hlines(1, 0.0, 5.0)
    ylim(0.0, 5.0)
    subplot(2,1,2)
    plot(Yield2, MC2)
    plot(Yield2, AVC2)
    plot(Yrange, AVCK2)
    hlines(1, 0.0, 5.0)
    ylim(0.0, 3.0)
    tight_layout()
    return test
end


#Monod vs type III
let 
    par = BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2)
    Irange = 0.0:0.01:10.0
    YieldII = [yieldII(I, par) for I in Irange]
    MCII = [margcostII(I, par) for I in Irange]
    AVCII = [avvarcostII(I,par) for I in Irange]
    YieldIII = [yieldIII(I, par) for I in Irange]
    MCIII = [margcostIII(I, par) for I in Irange]
    AVCIII = [avvarcostIII(I,par) for I in Irange]
    monodvstypeIII = figure()
    subplot(2,2,1)
    plot(Irange, YieldII)
    xlabel("Inputs")
    ylabel("Yield")
    ylim(0.0, 1.0)
    subplot(2,2,2)
    plot(Irange, YieldIII)
    xlabel("Inputs")
    ylabel("Yield")
    ylim(0.0, 1.0)
    subplot(2,2,3)
    plot(YieldII, MCII, color="blue", label="MC")
    plot(YieldII, AVCII, color="orange", label="AVC")
    hlines(par.p, 0.0, 1.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(2,2,4)
    plot(YieldIII, MCIII, color="blue", label="MC")
    plot(YieldIII, AVCIII, color="orange", label="AVC")
    hlines(par.p, 0.0, 1.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    tight_layout()
    # return monodvstypeIII
    savefig(joinpath(abpath(), "figs/monodvstypeIII.png"))
end

    