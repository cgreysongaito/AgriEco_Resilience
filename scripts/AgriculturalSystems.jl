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

maxprofit_vals(BMPPar(ymax=5, c = 2.0))[2]
let 
    Irange = 0.0:0.01:10.0
    Yrange = 0.0:0.01:5.0
    Yield = [yield(I, BMPPar(ymax=5, c = 2.0)) for I in Irange]
    MC = [margcost(I, BMPPar(ymax=5, c = 2.0)) for I in Irange]
    AVC = [avvarcost(I,BMPPar(ymax=5, c = 2.0)) for I in Irange]
    AVCK = [avvarcostkick(Y,BMPPar(ymax=5, c = 2.0)) for Y in Yrange]
    test = figure()
    plot(Yield, MC)
    plot(Yield, AVC)
    plot(Yrange, AVCK)
    hlines(1, 0.0, 5.0)
    vlines(maxprofit_vals(BMPPar(ymax=5, c = 2.0))[2]*0.65, 0.0, avvarcostkick(maxprofit_vals(BMPPar(ymax=5, c = 2.0))[2], BMPPar(ymax=5, c = 2.0)))
    ylim(0.0, 5.0)
    return test
end

#SOMETHING IS WRONG WITH AVVARCOSTKICK stuff




