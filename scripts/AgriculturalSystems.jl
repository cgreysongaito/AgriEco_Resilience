include("packages.jl")
@vars C
@vars y y₀

f(C) = y * C / (y₀ + C)
SymPy.simplify(diff(f(C),C))

#Monod function (without critical value)
@with_kw mutable struct MonodPar
    r = 1.0
    k1 = 1.0
end

function monod(N, p)
    @unpack r, k1 = p
    r * N / ( k1 + N )
end


function monod_diff(N, p)
    @unpack r, k1 = p
    r * k1 / (( k1 + N )^2)
end


let 
    Nrange = 0.0:0.01:5.0
    data = [monod(N,MonodPar(r=0.5,k1 = 1.0)) for N in Nrange]
    # data2 = [monod_diff(N,MonodPar(r=1.0)) for N in Nrange]
    test = figure()
    plot(Nrange, data)
    ylim(0.0,1.0)
    xlim(0.0, 5.0)
    # plot(Nrange, data2)
    return test
end

# r changes where the top plateua occurs but not shape. k1 changes shape ie gradient



#note for model - Can vary r depending on the amount of water within a year. Keep k1 larger so that slope is smaller.
#white and red noise can be created by an AR process – equation 1 in ruokolainen et al 2009


# Yield model
@with_kw mutable struct BMPPar
    ymax = 1.0
    y0 = 1.0
    p = 1.0
    c = 1.0
end

function yield(I, par)
    @unpack ymax, y0 = par
    return ymax * I / (y0 + I)
end

function margprod(I, par)
    @unpack ymax, y0 = par
    return ymax * y0 / (( y0 + I )^2)
end

function maxprofit_vals(par)
    @unpack ymax, y0, p, c = par
    I = sqrt((p * ymax * y0)/c)-y0
    Y = yield(I, par)
    return [I, Y]
end

#Any way to geometrically show the parameters and their effects
#https://www.economics.utoronto.ca/osborne/2x3/tutorial/MPFRM.HTM
#Marginal revenue versus marginal cost figures
function avvarcost(I,par)
    @unpack c = par
    Y = yield(I, par)
    return c * I / Y
end
###might be a way of making this more general
function avvarcostkick(Y, par)
    @unpack c = par
    I = maxprofit_vals(par)[1]
    return c * I / Y
end #THIS IS WRONG I NEEDS TO BE CONSTANT 

function margcost(I, par)
    @unpack c = par
    return c / margprod(I, par)
end

let 
    par1 = BMPPar(ymax=5.0, c = 2.0)
    par2 = BMPPar(ymax=3.0, c = 2.0)
    Irange = 0.0:0.01:10.0
    Yrange = 0.0:0.01:5.0
    Yield1 = [yield(I, par1) for I in Irange]
    MC1 = [margcost(I, par1) for I in Irange]
    AVC1 = [avvarcost(I,par1) for I in Irange]
    AVCK1 = [avvarcostkick(Y,par1) for Y in Yrange]
    Yield2 = [yield(I, par2) for I in Irange]
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
    Yield1 = [yield(I, par1) for I in Irange]
    MC1 = [margcost(I, par1) for I in Irange]
    AVC1 = [avvarcost(I,par1) for I in Irange]
    AVCK1 = [avvarcostkick(Y,par1) for Y in Yrange]
    Yield2 = [yield(I, par2) for I in Irange]
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

#Trying out resilience boundary - where minimum time required to get back to positive terminal equity
function profit(Y, I, par)
    @unpack p, c = par
    return p * Y - c * I
end

function minτ_termprofit(k,par)
    vals = maxprofit_vals(par)
    termprofit = profit(vals[2]*k, vals[1], par)
    minτ = 0
    while termprofit <= 0
        termprofit += profit(vals[2], vals[1], par)
        minτ += 1
    end
    return minτ
end

minτ_termprofit(0.1,BMPPar(ymax=5.0, y0=1.0, c = 2.0))

function res_bound(krange, par)
    minτ = zeros(length(krange))
    for (ki, knum) in enumerate(krange)
        minτ[ki] = minτ_termprofit(knum, par)
    end
    return minτ
end

res_bound(1.0:-0.01:0.0, BMPPar(ymax=5.0, y0=2.0, c = 3.0))

let
    krange = 1.0:-0.01:0.0
    par1 = BMPPar(ymax=5.0, y0=1.0, c = 3.0)
    par2 = BMPPar(ymax=5.0, y0=1.5, c = 3.0)
    par3 = BMPPar(ymax=3.5, y0=1.0, c = 3.0)
    test = figure()
    plot(res_bound(krange, par1), 1.0 .- collect(krange))
    plot(res_bound(krange, par2), 1.0 .- collect(krange))
    plot(res_bound(krange, par3), 1.0 .- collect(krange))
    return test
end

let 
    par1 = BMPPar(ymax=5.0, y0=1.5, c = 3.0)
    Irange = 0.0:0.01:10.0
    Yrange = 0.0:0.01:5.0
    Yield1 = [yield(I, par1) for I in Irange]
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


#Trying out type III yield curve
@vars C
@vars y y₀

f(C) = y * (C^2) / (y₀ + (C^2))
SymPy.simplify(diff(f(C),C))

function yieldIII(I, par)
    @unpack ymax, y0 = par
    return ymax * (I^2) / (y0 + (I^2))
end

let 
    data = [yieldIII(I, BMPPar(y0 = 1.5)) for I in 0.0:0.01:5.0]
    test = figure()
    plot(0.0:0.01:5.0, data)
    return test
end

function margprodIII(I, par)
    @unpack ymax, y0 = par
    return 2 * I * ymax * y0 / (( y0 + (I^2) )^2)
end

function maxprofit_valsIII(par)
    @unpack ymax, y0, p, c = par
    I = sqrt((p * ymax * y0)/c)-y0 ###NEEDS TO BE CHANGED
    Y = yieldIII(I, par)
    return [I, Y]
end

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
    I = maxprofit_valsIII(par)[1]
    return c * I / Y
end

function margcostIII(I, par)
    @unpack c = par
    return c / margprodIII(I, par)
end

let 
    par1 = BMPPar(ymax=5.0, c = 2.0)
    par2 = BMPPar(ymax=3.0, c = 2.0)
    Irange = 0.0:0.01:10.0
    Yrange = 0.0:0.01:5.0
    Yield1 = [yieldIII(I, par1) for I in Irange]
    MC1 = [margcostIII(I, par1) for I in Irange]
    AVC1 = [avvarcostIII(I,par1) for I in Irange]
    # AVCK1 = [avvarcostkick(Y,par1) for Y in Yrange]
    Yield2 = [yieldIII(I, par2) for I in Irange]
    MC2 = [margcostIII(I, par2) for I in Irange]
    AVC2 = [avvarcostIII(I,par2) for I in Irange]
    # AVCK2 = [avvarcostkick(Y,par2) for Y in Yrange]
    test = figure()
    subplot(2,1,1)
    plot(Yield1, MC1)
    plot(Yield1, AVC1)
    # plot(Yrange, AVCK1)
    hlines(1, 0.0, 5.0)
    ylim(0.0, 5.0)
    subplot(2,1,2)
    plot(Yield2, MC2)
    plot(Yield2, AVC2)
    # plot(Yrange, AVCK2)
    hlines(1, 0.0, 5.0)
    ylim(0.0, 3.0)
    tight_layout()
    return test
end