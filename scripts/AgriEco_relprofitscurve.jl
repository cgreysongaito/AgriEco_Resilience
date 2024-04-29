function calcYmaxI0vals_relprofcurve_prep(revexpval, Ymaxvals, economicpar) #Returns I0 values (not the reciprocal)
    vals = zeros(length(Ymaxvals),2)
    for i in eachindex(Ymaxvals)
        vals[i,1] = Ymaxvals[i]
        vals[i,2] = calc_I0(revexpval, Ymaxvals[i], economicpar)
    end
    return vals
end

function calcYmaxI0vals_relprofcurve_final(revexpvals, Ymaxvals, economicpar) #Returns I0 values (not the reciprocal)
    vals = Array{Array{Float64}}(undef,length(revexpvals))
    for i in eachindex(revexpvals)
        vals[i] = calcYmaxI0vals_relprofcurve_prep(revexpvals[i], Ymaxvals, economicpar)
    end
    return vals
end
