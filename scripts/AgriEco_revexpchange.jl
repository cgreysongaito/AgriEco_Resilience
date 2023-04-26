#Trying out changing rev/exp perpendicular analysis
include("packages.jl")
include("AgriEco_commoncode.jl")

function find_slope(origymaxval, origy0val, revexpval, basepar)
    secondy0val = calc_y0(revexpval,origymaxval+0.1, basepar.c, basepar.p)
    firstslope = -0.1/((1/origy0val)-(1/secondy0val))
    return -1/firstslope
end 

function find_yintercept(slope, ymaxval, y0val)
    return ymaxval - slope * y0val
end

origy0val = calc_y0(1.33, 140, FarmBasePar().c, FarmBasePar().p)
slope = find_slope(140, origy0val, 1.33, FarmBasePar())
int = find_yintercept(slope, 140, origy0val)

function guess_intercept(revexpval, basepar, linslope, linint)
    ymaxrange = 120.0:2.0:170.0
    line1y0 = [(ymax - linint)/linslope for ymax in ymaxrange]
    curve1y0 = 1 ./ [calc_y0(revexpval, ymax, basepar.c, basepar.p) for ymax in ymaxrange]
    return hcat(line1y0, curve1y0)
    # for i in eachindex(line)
    #     for j in eachindex(curve)
    #         if isapprox(line1y0[i], curve1y0[j]) == true
    #             return curve1y0[j]
    #         end
    #     end
    # end
end

let 
    data = guess_intercept(1.15, FarmBasePar(), slope, int)
    test = figure()
    plot(data[:,1],120.0:2.0:170.0)
    plot(data[:,2],120.0:2.0:170.0)
    xlim(0,0.2)
    return test
end


function find_intercept(revexpval, basepar, linslope, linint, guess)
    return find_zero(y0 -> linslope * (1/y0) + linint - (revexpval * 2 * basepar.c * y0^(1/2))/basepar.p, 1/guess)
end