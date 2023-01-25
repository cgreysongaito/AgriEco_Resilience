include("packages.jl")
include("AgriEco_commoncode.jl")

calc_c(1.33, 174, 10.0, 6.70)

@with_kw mutable struct NoisePar
    ymax_CV = 0.1
    y0_CV = 0.1
    p_CV = 0.1
    c_CV = 0.1
    ymax_r = 0.0
    y0_r = 0.0
    p_r = 0.0
    c_r = 0.0
    yielddisturbed_CV = 0.2
    yielddisturbed_r = 0.0
end

@with_kw mutable struct InterestPar
    operatinginterest = 4
    debtinterest = 4
    savingsinterest = 2
end

function checkcreatedparams(paramdata)
    for i in 1:length(paramdata)
        if paramdata[i] <= 0.0
            error("Parameters can't be <=0. Change your base parameters or CV")
        end
    end
end

function param_createdata(basepar, maxyears, seed)
    @unpack ymax, y0, p, c = basepar
    @unpack ymax_CV, y0_CV, p_CV, c_CV, ymax_r, y0_r, p_r, c_r = noisepar
    ymax_σ = ymax_CV * ymax
    y0_σ = y0_CV * y0
    p_σ = p_CV * p
    c_σ = c_CV * c
    ymax_data = noise_creation(ymax, ymax_σ, ymax_r, maxyears, seed)
    y0_data = noise_creation(y0, y0_σ, y0_r, maxyears, seed)
    p_data = noise_creation(p, p_σ, p_r, maxyears, seed)
    c_data = noise_creation(c, c_σ, c_r, maxyears, seed)
    checkcreatedparams(ymax_data)
    checkcreatedparams(y0_data)
    checkcreatedparams(p_data)
    checkcreatedparams(c_data)
    return hcat(1:1:maxyears, ymax_data, y0_data, p_data, c_data)
end

function yieldinputs_createdata(param_data, maxyears)
    inputs = zeros(maxyears)
    yield = zeros(maxyears)
    for i in 1:maxyears
        par = FarmBasePar(ymax = param_data[i,2], y0 = param_data[i,3], p = param_data[i,4], c = param_data[i,5])
        yieldinputs = maxprofitIII_vals(par)
        inputs[i] = yieldinputs[1]
        yield[i] = yieldinputs[2]
    end
    return hcat(1:1:maxyears, yield, inputs, param_data[:,4], param_data[:,5])
end

function yielddisturbed_static_createdata(basepar, yield_disturbance_CV, yield_disturbance_r, maxyears, seed)
    yield_disturbance_σ = basepar.ymax * yield_disturbance_CV
    yieldinputs = maxprofitIII_vals(basepar)
    yieldnoise = noise_creation(0.0, yield_disturbance_σ, yield_disturbance_r, maxyears, seed)
    disturbedyield = zeros(maxyears)
    for i in 1:maxyears
        disturbedyield[i] = yieldinputs[2]+yieldnoise[i]
        if disturbedyield[i] < 0.0
            error("Yield cannot be < 0.0. Change your CV.")
        end
    end
    return hcat(1:1:maxyears, disturbedyield, repeat([yieldinputs[1]],maxyears), repeat([basepar.p],maxyears), repeat([basepar.c],maxyears))
end

function pricedisturbed_static_createdata(basepar, noisepar, maxyears, seed)
    p_σ = basepar.p * noisepar.p_CV
    yieldinputs = maxprofitIII_vals(basepar)
    pricenoise = noise_creation(basepar.p, p_σ, noisepar.p_r, maxyears, seed)
    checkcreatedparams(pricenoise)
    return hcat(1:1:maxyears, repeat([yieldinputs[2]],maxyears), repeat([yieldinputs[1]],maxyears), pricenoise, repeat([basepar.c],maxyears))
end

pricedisturbed_static_createdata(FarmBasePar(), NoisePar(), 50, 14)

# let 
#     seed = 10
#     i=9
#     testparams = param_createdata(FarmBasePar(), 10, seed)
#     par = BMPPar(ymax = testparams[i,2], y0 = testparams[i,3], p = testparams[i,4], c = testparams[i,5])
#     return par
#     # println(par)
#     # maxprofitIII_vals(par)
# end

# badpar = BMPPar(ymax = 170.40773455539966, y0 = 6.407734555399665, p = 3.1077345553996656, c = 135.40773455539966)
# maxprofitIII_param(1.565, badpar)
# find_zero(I -> maxprofitIII_param(I, badpar), 0.0)

# 1.36+ ((sqrt(6.407734555399665) - 1.36)/2)

# (sqrt(6.407734555399665)+1.36)/2

# sqrt((50*badpar.y0)/(badpar.ymax - 50))

# function maxprofitIII_vals_test(par)
#     Irange = 0.0:0.01:Int64(round(3*par.y0))
#     MC = [margcostIII(I, par) for I in Irange]
#     if minimum(MC) >= par.p
#         return [0,0]
#     else
#         try
#         I = find_zero(I -> maxprofitIII_param(I, par), 2 * sqrt(par.y0))
#         Y = yieldIII(I, par)
#         [I, Y]
#         catch err
#             if isa(err, Roots.ConvergenceFailed)
#                 smallerguess = (sqrt(par.y0) + find_zero(I -> maxprofitIII_param(I, par), 0.0))/2
#                 I = find_zero(I -> maxprofitIII_param(I, par), smallerguess)
#                 Y = yieldIII(I, par)
#                 [I, Y]
#             end
#         end
#     end
# end



# let 
#     par1 = BMPPar(y0 = 6.407734555399665, ymax = 170.40773455539966, c = 135.40773455539966, p = 3.1077345553996656)
#     Irange = 0.0:0.01:10.0
#     Yield1 = [yieldIII(I, par1) for I in Irange]
#     MC1 = [margcostIII(I, par1) for I in Irange]
#     AVC1 = [avvarcostIII(I,par1) for I in Irange]
#     costcurves = figure()
#     plot(Yield1, MC1, color="blue", label="MC")
#     plot(Yield1, AVC1, color="orange", label="AVC")
#     hlines(par1.p, 0.0, 170, colors="black", label = "MR")
#     legend()
#     ylim(0.0, 10.0)
#     xlim(0.0, 170.0)
#     xlabel("Yield (Q)")
#     ylabel("Revenue & Cost")
#     return costcurves
#     # savefig(joinpath(abpath(), "figs/costcurves.png"))
# end 

# let 
#     par1 = BMPPar(y0 = 6.407734555399665, ymax = 170.40773455539966, c = 135.40773455539966, p = 3.1077345553996656)
#     par2 = BMPPar(ymax = 174, y0 = 10, p = 6.70, c = 139)
#     Irange = 0.0:0.01:10.0
#     Yield1 = [yieldII(I, par2) for I in Irange]
#     MC1 = [margcostII(I, par2) for I in Irange]
#     AVC1 = [avvarcostII(I,par2) for I in Irange]
#     costcurves = figure()
#     plot(Yield1, MC1, color="blue", label="MC")
#     plot(Yield1, AVC1, color="orange", label="AVC")
#     hlines(par1.p, 0.0, 170, colors="black", label = "MR")
#     legend()
#     # ylim(0.0, 10.0)
#     # xlim(0.0, 170.0)
#     xlabel("Yield (Q)")
#     ylabel("Revenue & Cost")
#     return costcurves
#     # savefig(joinpath(abpath(), "figs/costcurves.png"))
# end  

function revenue_calc(yield, p)
    return yield * p
end

function expenses_calc(inputs, c)
    return inputs * c
end

function operatingloan(expenses, interestpar)
    @unpack operatinginterest = interestpar
    return expenses * (1 + operatinginterest/100)
end

function assetsdebtupdate(assetsdebt, interestpar)
    @unpack debtinterest, savingsinterest = interestpar
    if assetsdebt > 0.0
        return assetsdebt * (1 + savingsinterest/100)
    else
        return assetsdebt * (1 + debtinterest/100)
    end
end

function simulation(scenario, basepar, noisepar, interestpar, maxyears, seed)
    if scenario == "normal"
        param_data = param_createdata(basepar, noisepar, maxyears, seed)
        yieldinputs_data = yieldinputs_createdata(param_data, maxyears)
    elseif scenario == "yield_disturbance"
        yieldinputs_data = yielddisturbed_static_createdata(basepar, noisepar.yielddisturbed_CV, noisepar.yielddisturbed_r, maxyears, seed)
    elseif scenario == "price_disturbance"
        yieldinputs_data = pricedisturbed_static_createdata(basepar, noisepar, maxyears, seed)
    else
        error("WTF did you write in your scenario variable?!")
    end
    assetsdebt = zeros(maxyears+1)
    for yr in 2:maxyears+1
        expenses = expenses_calc(yieldinputs_data[yr-1,3], yieldinputs_data[yr-1,5])
        revenue = revenue_calc(yieldinputs_data[yr-1,2], yieldinputs_data[yr-1,4])
        assetsdebtafterfarming = assetsdebt[yr-1] + (revenue - operatingloan(expenses, interestpar))
        assetsdebt[yr] = assetsdebtupdate(assetsdebtafterfarming, interestpar)
    end
    return assetsdebt
end

function distribution(scenario, basepar, noisepar, interestpar, maxyears, reps)
    assetsdebtdata =  zeros(reps)
    @threads for i in 1:reps
        simdata = simulation(scenario, basepar, noisepar, interestpar, maxyears, i)
        assetsdebtdata[i] = simdata[end]
    end
    return assetsdebtdata
end

let
    data = distribution("yield_disturbance", FarmBasePar(ymax=174.0, y0=15.0), NoisePar(yielddisturbed_CV=0.05, yielddisturbed_r=0.9), InterestPar(), 50, 50)
    test = figure()
    plt.hist(data, 25)
    return test
end


let
    data = distribution("price_disturbance", FarmBasePar(), NoisePar(p_CV=0.2,p_r=0.9), InterestPar(), 50, 50)
    test = figure()
    plt.hist(data, 25)
    return test
end
## Determining yield, input, prices midpoints ##
# abstract parameter free version (relationship of parameters)
#(match more closely the abstract geometry approach previous model)
# profit is maximised

#specific parameters to match real world
# set profit as per acre profit
# set revenue and expenses as 2019 averages
# set ymax to average yield of corn