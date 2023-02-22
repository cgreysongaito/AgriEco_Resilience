include("packages.jl")
include("AgriEco_commoncode.jl")

# Resistance to yield disturbance
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

#Resistance to price disturbance or cost disturbance
function MR_AVC_distance_revexpcon_data(revexpratio, ymaxrange, pval::Float64 =  6.70, cval::Float64 = 139.0)
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
            data[ymaxi, 2] = par.p -  avvarcostIII(inputsyield[1], par)
        end
    end
    return data
end
###NOTE because constraining rev/exp - distance between MR and AVC is constant regardless of ymax and y0 - could probably prove 

#Comparison of max profit and max yield NEED TO WORK ON

#maxing yield (instead of maxing profit) always makes farms more vulnerable to yield kicks (negative profit) because avck line is closer to yield decision
#THIS HAPPENS WHEN? BUT there seems to be a sweet spot depending on the slope of the hueristic decision after which max profit distance can be l


#trying out multidimensional measure
function AVCK_MR_multidimension(inputs, par, dist, combo)
    @unpack c, p, ymax = par
    if combo == "++"
        distcombo = [dist, dist]
    elseif combo == "--"
        distcombo = [-dist, -dist]
    elseif combo == "+-"
        distcombo = [dist,-dist]
    elseif combo =="-+"
        distcombo = [-dist,dist]
    else
        error("Ensure combo is ++, --, +-, -+")
    end
    Yrange = 0.0:0.01:ymax
    data = [(c+distcombo[2]) * inputs / Y  for Y in Yrange]
    Yindex = isapprox_index(data, p+distcombo[1])
    minyield = Yrange[Yindex]
    return minyield
end


function AVCK_MC_multi_distance_revexpcon_data(revexpratio, ymaxrange, dist, combo, pval::Float64 =  6.70, cval::Float64 = 139.0)
    Irange = 0.0:0.01:40.0
    data=zeros(length(ymaxrange), 4)
    @threads for ymaxi in eachindex(ymaxrange)
        y0val = calc_y0(revexpratio, ymaxrange[ymaxi], cval, pval)
        par = FarmBasePar(ymax = ymaxrange[ymaxi], y0 = y0val, c = cval, p = pval)
        inputsyield = maxprofitIII_vals(par)
        if minimum(filter(!isnan, [margcostIII(I, par) for I in Irange])) >= par.p #|| minimum(filter(!isnan, [avvarcostIII(I, par) for I in Irange])) >= par.p
            data[ymaxi, 2] = NaN
        else
            origdistance = inputsyield[2] - AVCK_MR(inputsyield[1], par)
            newdistance = inputsyield[2] - AVCK_MR_multidimension(inputsyield[1], par, dist, combo)
            data[ymaxi, 1] = ymaxrange[ymaxi]
            data[ymaxi, 2] = origdistance
            data[ymaxi, 3] = newdistance
            data[ymaxi, 4] = newdistance/origdistance
        end
    end
    return data
end

# function avvarcost_multikickIII(Y, par, profityield, dist, maxyieldslope::Float64=0.1)
#     @unpack c = par
#     if profityield == "profit"
#         I = maxprofitIII_vals(par)[1]
#     elseif profityield == "yield"
#         I = maxyieldIII_vals(maxyieldslope, par)[1]
#     else
#         error("profityield variable must be either \"profit\" or \"yield\".")
#     end
#     return (c+dist) * I / Y
# end


# function AVCK_MR_multidist(par, dist, inputs)
#     Yrange = 0.0:0.01:par.ymax
#     data = [(par.c+dist) * inputs / Y  for Y in Yrange]
#     Yindex = isapprox_index(data, par.p-dist)
#     minyield = Yrange[Yindex]
#     return minyield
# end


# function AVCK_MC_multidist_data(y0range, ymaxrange, profityield, dist, combo, pval::Float64=2.2, maxyieldslope::Float64=0.1)
#     Irange = 0.0:0.01:30.0
#     y0range = y0range
#     ymaxrange = ymaxrange
#     data = Array{Float64}(undef, length(ymaxrange), length(y0range))
#     @threads for ymaxi in eachindex(ymaxrange)
#         @inbounds for (y0i, y0num) in enumerate(y0range)
#             par = FarmBasePar(y0 = y0num, ymax = ymaxrange[ymaxi], c = 0.5, p = pval)
#             if minimum(filter(!isnan,[margcostIII(I, par) for I in Irange])) >= par.p || minimum([avvarcostIII(I, par) for I in Irange]) >= par.p
#                 data[ymaxi, y0i] = NaN
#             elseif profityield == "profit"
#                 inputyield_profit = maxprofitIII_vals(par)
#                 origdistance = inputyield_profit[2] - AVCK_MR_multidimension(par, 0.0, combo, inputyield_profit[1])
#                 newdistance = inputyield_profit[2] - AVCK_MR_multidimension(par, dist, combo, inputyield_profit[1])
#                 data[ymaxi, y0i] = newdistance/origdistance
#             elseif profityield == "yield" && avvarcostIII(maxyieldIII_vals(maxyieldslope, par)[1],par) >= par.p
#                 data[ymaxi, y0i] = NaN
#             else
#                 inputyield_yield = maxyieldIII_vals(maxyieldslope, par)
#                 origdistance = inputyield_yield[2] - AVCK_MR_multidimension(par, 0.0, combo, inputyield_yield[1])
#                 newdistance = inputyield_yield[2] - AVCK_MR_multidimension(par, dist, combo, inputyield_yield[1])
#                 data[ymaxi, y0i] = newdistance/origdistance
#             end
#         end
#     end
#     return [ymaxrange, y0range, data]
# end

#need to change parameters - but unit change in cost (either negative or postive) seems to have the larger effect
#increase profit by a unit makes the situations slightly better but cost unit change determines the most 
# why?