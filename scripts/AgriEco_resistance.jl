include("packages.jl")
include("AgriEco_commoncode.jl")

#Trying out how to minimize crossing of AVCK with MR line
function AVCK_MR(profityield, par, maxyieldslope::Float64=0.1)
    Yrange = 0.0:0.01:par.ymax
    data = [avvarcostkickIII(Y, par, profityield, maxyieldslope) for Y in Yrange]
    Yindex = isapprox_index(data, par.p)
    minyield = Yrange[Yindex]
    return minyield
end

# function AVCK_MRdata(y0range, ymaxrange, p, profityield, maxyieldslope::Float64=0.1)
#     Irange = 0.0:0.01:10.0
#     y0range = y0range
#     ymaxrange = ymaxrange
#     data = Array{Float64}(undef, length(ymaxrange), length(y0range))
#     @threads for ymaxi in eachindex(ymaxrange)
#         @inbounds for (y0i, y0num) in enumerate(y0range)
#             par = BMPPar(y0 = y0num, ymax = ymaxrange[ymaxi], c = 0.5, p = 2.2)
#             if minimum([margcostIII(I, par) for I in Irange]) >= p || minimum([avvarcostIII(I, par) for I in Irange]) >= p
#                 data[ymaxi, y0i] = NaN
#             else
#                 data[ymaxi, y0i] = AVCK_MR(profityield, par, maxyieldslope)
#             end
#         end
#     end
#     return [ymaxrange, y0range, data]
# end

# let 
#     data = AVCK_MRdata(0.5:0.01:2.0, 0.5:0.01:2.0, 2.2, "profit")
#     test = figure()
#     pcolor(data[1], data[2], data[3])
#     xlabel("ymax")
#     ylabel("y0")
#     colorbar()
#     return test
# end
# #Is minimizing of AVCK and MR just the same as minimizing of AVC line at input decision? I think so but how to prove. If same, then we already have the answer (ymax and yo)
# #Not quite because can have minimized AVC but still max yield is low pushing down optimal decision and inputs going in.

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
# #minimizing AVCK is just by the inputs put in because of a/x where a is the c*I.
let 
    data1 = [-1/(X^2) for X in 0.0:0.1:10.0]
    data2 = [-2/(X^2) for X in 0.0:0.1:10.0]
    data3 = [-5/(X^2) for X in 0.0:0.1:10.0]
    test = figure()
    plot(0.0:0.1:10.0, data1, label = "1")
    plot(0.0:0.1:10.0, data2, label = "2")
    plot(0.0:0.1:10.0, data3, label = "5")
    ylim(-100.0, 0.0)
    legend()
    return test
end


#Trying out maximizing of AVCK MC distance
function AVCK_MCdata(y0range, ymaxrange, profityield, p::Float64=2.2, maxyieldslope::Float64=0.1)
    Irange = 0.0:0.01:10.0
    y0range = y0range
    ymaxrange = ymaxrange
    data = Array{Float64}(undef, length(ymaxrange), length(y0range))
    @threads for ymaxi in eachindex(ymaxrange)
        @inbounds for (y0i, y0num) in enumerate(y0range)
            par = BMPPar(y0 = y0num, ymax = ymaxrange[ymaxi], c = 0.5, p = p)
            if minimum(filter(!isnan,[margcostIII(I, par) for I in Irange])) >= par.p || minimum([avvarcostIII(I, par) for I in Irange]) >= par.p || maxprofitIII_vals(par)[2] == AVCK_MR(profityield, par)
                data[ymaxi, y0i] = NaN
            elseif profityield == "profit"
                data[ymaxi, y0i] = maxprofitIII_vals(par)[2] - AVCK_MR(profityield, par)
            elseif profityield == "yield" && avvarcostIII(maxyieldIII_vals(maxyieldslope, par)[1],par) >= par.p
                data[ymaxi, y0i] = NaN
            else    
                data[ymaxi, y0i] = maxyieldIII_vals(maxyieldslope, par)[2] - AVCK_MR(profityield, par, maxyieldslope)
            end
        end
    end
    return [ymaxrange, y0range, data]
end

let 
    data_maxprofit = AVCK_MCdata(0.8:0.1:2.0, 0.8:0.1:2.0, "profit")
    data_maxyield = AVCK_MCdata(0.8:0.1:2.0, 0.8:0.1:2.0, "yield")
    AVCK_MCfig = figure(figsize=(8,3))
    subplot(1,2,1)
    title("Maximum profit")
    pcolor(data_maxprofit[1], data_maxprofit[2], data_maxprofit[3], vmin=0.0, vmax=1.2)
    colorbar()
    ylabel("ymax")
    xlabel("y0")
    subplot(1,2,2)
    title("Maximum yield")
    pcolor(data_maxyield[1], data_maxyield[2], data_maxyield[3], vmin=0.0, vmax=1.2)
    colorbar()
    ylabel("ymax")
    xlabel("y0")
    tight_layout()
    return AVCK_MCfig
    # savefig(joinpath(abpath(), "figs/AVCK_MCfig.png"))
end


#Trying out comparing AVCK_MR/YieldChoice distance between max profit and max yield
function compare_distance(par, maxyieldslope::Float64=0.1)
    maxprofitdistance = maxprofitIII_vals(par)[2] - AVCK_MR("profit", par)
    maxyielddistance = maxyieldIII_vals(maxyieldslope, par)[2] - AVCK_MR("yield", par, maxyieldslope)
    return [maxprofitdistance, maxyielddistance]
end

function compare_distance_data(y0range, ymaxrange, p::Float64=2.2, maxyieldslope::Float64=0.1)
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
                distances = compare_distance(par)
                data[ymaxi, y0i] = distances[1]-distances[2]
            end
        end
    end
    return [ymaxrange, y0range, data]
end

let 
    data = compare_distance_data(0.8:0.01:2.0, 0.8:0.01:2.0, 2.2)
    comparedistancefig = figure()
    pcolor(data[1], data[2], data[3])
    ylabel("ymax")
    xlabel("y0")
    colorbar()
    # return comparedistancefig
    savefig(joinpath(abpath(), "figs/comparedistancefig.png"))
end

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

#Trying out "profit margin" numerical analysis
function unitmargin(profityield, par)
    if profityield == "profit"
        vals = maxprofitIII_vals(par)
    elseif profityield == "yield"
        vals = maxprofitIII_vals(par)
    else
        error("profityield variable must be either \"profit\" or \"yield\".")
    end
    unitcost = avvarcostIII(vals[1], par)
    return par.p-unitcost
end

function unitmargindata(y0range, ymaxrange, profityield, p::Float64=2.2)
    Irange = 0.0:0.01:10.0
    y0range = y0range
    ymaxrange = ymaxrange
    data = Array{Float64}(undef, length(ymaxrange), length(y0range))
    @threads for ymaxi in eachindex(ymaxrange)
        @inbounds for (y0i, y0num) in enumerate(y0range)
            par = BMPPar(y0 = y0num, ymax = ymaxrange[ymaxi], c = 0.5, p = p)
            if minimum([margcostIII(I, par) for I in Irange]) >= p || minimum([avvarcostIII(I, par) for I in Irange]) >= p
                data[ymaxi, y0i] = NaN
            else
                data[ymaxi, y0i] = unitmargin(profityield, par)
            end
        end
    end
    return [ymaxrange, y0range, data]
end

let 
    data = unitmargindata(0.5:0.01:2.0, 0.5:0.01:2.0, "profit")
    test = figure()
    pcolor(data[1], data[2], data[3])
    xlabel("ymax")
    ylabel("y0")
    colorbar()
    return test
end


function mincosts(profityield, par)
    if profityield == "profit"
        vals = maxprofitIII_vals(par)
    elseif profityield == "yield"
        vals = maxprofitIII_vals(par)
    else
        error("profityield variable must be either \"profit\" or \"yield\".")
    end
    unitcost = avvarcostIII(vals[1],par)
    return unitcost
end

function mincostsdata(y0range, ymaxrange, profityield, p::Float64=2.2)
    Irange = 0.0:0.01:10.0
    y0range = y0range
    ymaxrange = ymaxrange
    data = Array{Float64}(undef, length(ymaxrange), length(y0range))
    @threads for ymaxi in eachindex(ymaxrange)
        @inbounds for (y0i, y0num) in enumerate(y0range)
            par = BMPPar(y0 = y0num, ymax = ymaxrange[ymaxi], c = 0.5, p = p)
            if minimum([margcostIII(I, par) for I in Irange]) >= par.p || minimum([avvarcostIII(I, par) for I in Irange]) >= par.p #may not need this line because minimising
                data[ymaxi, y0i] = NaN
            else
                data[ymaxi, y0i] = mincosts(profityield, par)
            end
        end
    end
    return [ymaxrange, y0range, data]
end

let 
    data_maxprofit = mincostsdata(0.8:0.01:2.0, 0.8:0.01:2.0, "profit")
    data_maxyield = mincostsdata(0.8:0.01:2.0, 0.8:0.01:2.0, "yield")
    mincostsfig = figure(figsize=(8,3))
    subplot(1,2,1)
    title("Maximum profit")
    pcolor(data_maxprofit[1], data_maxprofit[2], data_maxprofit[3], vmin=0.6, vmax=1.8)
    colorbar()
    ylabel("ymax")
    xlabel("y0")
    subplot(1,2,2)
    title("Maximum yield")
    pcolor(data_maxyield[1], data_maxyield[2], data_maxyield[3], vmin=0.6, vmax=1.8)
    colorbar()
    ylabel("ymax")
    xlabel("y0")
    tight_layout()
    # return mincostsfig
    savefig(joinpath(abpath(), "figs/mincostsfig.png"))
end
#ymax has the biggest effect on minimizing costs (further from p) but not at smaller ymax values then y0 becomes important
