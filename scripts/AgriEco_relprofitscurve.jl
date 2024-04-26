include("AgriEco_commoncode.jl")

function calcYmaxI0vals_relprofcurve_prep(revexpval, Ymaxvals, economicpar) #Returns I0 values (not the reciprocal)
    vals = zeros(length(Ymaxvals),2)
    for i in eachindex(Ymaxvals)
        vals[i,1] = calc_I0(revexpval, Ymaxvals[i], economicpar)
        vals[i,2] = Ymaxvals[i]
    end
    return vals
end

function calcYmaxI0vals_relprofcurve_final(revexpvals, Ymaxvals, economicpar) #Returns I0 values (not the reciprocal)
    vals = Array{Vector{Float64}}(undef,length(revexpvals))
    for i in eachindex(revexpvals)
        vals[i] = calcYmaxI0vals_relprofcurve_prep(revexpvals[i], Ymaxvals, economicpar)
    end
    return vals
end

calcYmaxI0vals_relprofcurve_final([1.08,1.15,1.30], [110,120,130], EconomicPar())

function calcYmaxI0vals(constrain, origYmax, revexpratios, rise, run, economicpar, startrevexpval::Float64=1.08) #Returns I0 values (not the reciprocal)
    origI0 = calc_I0(startrevexpval, origYmax, economicpar)
    vals = zeros(length(revexpratios), 2)
    if constrain == "Ymax"
        for i in eachindex(revexpratios)
            vals[i, 1] = origYmax
            vals[i, 2] = calc_I0(revexpratios[i], origYmax, economicpar)
        end
    elseif constrain =="I0"
        for i in eachindex(revexpratios)
            vals[i, 1] = calc_Ymax(revexpratios[i], origI0, economicpar)
            vals[i, 2] = origI0
        end
    elseif constrain == "neither"
        vals[1,1] = origYmax
        vals[1,2] = origI0
        for i in 2:length(revexpratios)
            newI0 = calc_revexpintercept(origYmax, origI0, rise, run, revexpratios[i], economicpar)
            vals[i,1] = calc_Ymax(revexpratios[i], newI0, economicpar)
            vals[i,2] = newI0
        end
    else
        error("constrain should be either Ymax, I0, or neither")
    end
    return vals
end