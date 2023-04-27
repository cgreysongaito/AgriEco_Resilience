#Trying out changing rev/exp perpendicular analysis
include("packages.jl")
include("AgriEco_commoncode.jl")

function points_distance(point1, point2)
    return sqrt(((point2[1]-point1[1])^2) + ((point2[2]-point1[2])^2))
end


function find_mindist(smallrevexpval, largerevexpval, origymaxval, basepar)
    reciporigy0val = 1/calc_y0(smallrevexpval,origymaxval, basepar.c, basepar.p)
    ymaxrange = 120.0:0.1:170.0
    largerevexpcurve = 1 ./ [calc_y0(largerevexpval, ymax, basepar.c, basepar.p) for ymax in ymaxrange]
    points = hcat(largerevexpcurve, ymaxrange)
    dist = zeros(length(largerevexpcurve))
    for i in 1:length(largerevexpcurve)
        dist[i] = points_distance([reciporigy0val,origymaxval], points[i,:]) 
    end
    # minindex = argmin(dist)
    # return [largerevexpcurve[minindex],ymaxrange[minindex]]
    return dist
end

let
    test = figure()
    plot(1:1:501,find_mindist(1.08, 1.33, 140, FarmBasePar()))
    return test
end

function find_slope(origymaxval, origy0val, revexpval, basepar)
    secondy0val = calc_y0(revexpval,origymaxval+0.1, basepar.c, basepar.p)
    # firstslope = (origymaxval - (origymaxval+0.1))/((1/origy0val)-(1/secondy0val))
    firstslope = ((origymaxval+0.1) - origymaxval)/((1/secondy0val)-(1/origy0val))
    return firstslope
end 

function find_yintercept(slope, ymaxval, recipy0val)
    return ymaxval - slope * recipy0val
end


origy0val = calc_y0(1.33, 140, FarmBasePar().c, FarmBasePar().p)
secondy0val = calc_y0(1.33,140+0.1, FarmBasePar().c, FarmBasePar().p)
slope = find_slope(140, origy0val, 1.33, FarmBasePar())
int = find_yintercept(0.002217297846828907, 140, 1/origy0val)

let 
    ymaxrange = 120.0:1.0:200.0
    y0data133rel = [calc_y0(1.33, ymax, 139, 6.70) for ymax in ymaxrange]
    y0data108rel = [calc_y0(1.08, ymax, 139, 6.70) for ymax in ymaxrange]
    tangentline = [-450.99940065795 * x + 210.0750089253848 for x in 0.1:0.001:0.2]
    perpenline = [0.002217297846828907 * x + 139.9996554825435 for x in 0.1:0.001:0.2]
    figure2schematicprep = figure()
    plot(1 ./ y0data133rel, ymaxrange, linestyle="dashed", color="black", label="rev/exp = 1.33")
    plot(1 ./ y0data108rel, ymaxrange, linestyle="dotted", color="black", label="rev/exp = 1.08")
    plot(0.1:0.001:0.2, tangentline, color="red")
    plot(0.1:0.001:0.2, perpenline, color="blue")
    scatter(origy0val, [140], color="blue")
    scatter(secondy0val, [140.1], color="blue")
    xlabel("1/y0", fontsize = 20)
    ylabel("ymax", fontsize = 20)
    # ylim(139,141)
    xlim(0.1,0.2)
    tight_layout()
    return figure2schematicprep
    # savefig(joinpath(abpath(), "figs/figure2schematicprep.pdf"))
end


let 
    line1 = [2*x+2 for x in 0.0:0.1:10.0]
    line2 = [(-1/2)*x + 3 for x in 0.0:0.1:10.0]
    test =figure()
    plot(0.0:0.1:10.0, line1)
    plot(0.0:0.1:10.0, line2)
    ylim(0,10)
    xlim(0,10)
    return test
end


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