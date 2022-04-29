include("packages.jl")
include("AgriEco_commoncode.jl")

#Is resilience boundary just a function of how much profit you get each year. or the distance between AVC and MR line - larger the distance faster the return time
#vertical lines - this distance is essentially the negative yield caused by max of vertical line - so if distance of AVC and MR dictates the length of vertical lines

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