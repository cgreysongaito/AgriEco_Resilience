include("packages.jl")
include("AgriEco_commoncode.jl")

function delayedinputs(defaultinputs, minfraction, lastyrsactualyield, lastyrsprojectedyield)
    lastyrsoutcome = lastyrsactualyield/lastyrsprojectedyield
    if lastyrsoutcome > minfraction
        return defaultinputs * lastyrsactualyield/lastyrsprojectedyield
    else
        return lastyrsoutcome * minfraction
end

function NLtimedelay_data(basepar, noisepar, minfraction, maxyears, seed)
    defaultinputsyield = maxprofitIII_vals(basepar)
    basenoise = noise_creation(0.0, noisepar.yielddisturbed_σ, noisepar.yielddisturbed_r, maxyears, seed)
    data = zeros(maxyears, 2)
    data[1, 1] = defaultinputsyield[1]
    data[1, 2] = defaultinputsyield[2] + basenoise[1]
    for i in 2:maxyears
        lastyrsprojectedyield = yieldIII(data[i-1,1], basepar)
        data[i, 1] = delayedinputs(defaultinputsyield[1], minfraction, data[i-1,2], lastyrsprojectedyield)
        data[i, 2] = yieldIII(data[i, 1], basepar) + basenoise[i]
    end
    return data
end

function simulation_NLtimedelay(basedataNL)


function terminalassets_distribution_NLtimedelay(NL, inputsyield, basepar, noisepar, interestpar, maxyears, reps)
    assetsdebtdata =  zeros(reps)
    for i in 1:reps
        basedata = yieldnoise_createdata(inputsyield, basepar, noisepar, maxyears, i)
        simdata = simulation_NLposfeed(NL, basedata, interestpar)
        assetsdebtdata[i] = simdata[end]
    end
    return assetsdebtdata
end



