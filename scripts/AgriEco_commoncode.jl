function abpath()
    replace(@__DIR__, "scripts" => "")
end 

function isapprox_index(data, val)
    for i in 1:length(data)
        if isapprox(data[i], val, atol=0.05) == true
            return i
        end
    end
end

#white and red noise can be created by an AR process – equation 1 in ruokolainen et al 2009

# Yield model
@with_kw mutable struct FarmBasePar
    ymax = 174.0
    y0 = 10
    p = 6.70
    c = 139
end


# @with_kw mutable struct BMPPar
#     ymax = 1.0
#     y0 = 1.0
#     p = 1.0
#     c = 1.0
# end

function yieldIII(I, par)
    @unpack ymax, y0 = par
    return ymax * (I^2) / (y0 + (I^2))
end

function margprodII(I, par)
    @unpack ymax, y0 = par
    return ymax * y0 / (( y0 + I )^2)
end

function margprodIII(I, par)
    @unpack ymax, y0 = par
    return 2 * I * ymax * y0 / (( y0 + (I^2) )^2)
end

# let 
#     par = BMPPar(y0 = 0.2, ymax = 1.0, c = 0.5, p=2.2)
#     Irange = 0.0:0.01:10.0
#     data1 = [margprodII(I, par) for I in Irange]
#     data2 = [margprodIII(I, par) for I in Irange]
#     test = figure()
#     plot(Irange, data1)
#     plot(Irange, data2)
#     hlines(par.c/par.p, 0.0, 10.0)
#     return test
# end #KEEP to help improve code for guess for root solver

# function yieldII(I, par)
#     @unpack ymax, y0 = par
#     return ymax * I / (y0 + I)
# end

# function maxprofitII_vals(par)
#     @unpack ymax, y0, p, c = par
#     I = sqrt((p * ymax * y0)/c)-y0
#     Y = yieldII(I, par)
#     return [I, Y]
# end

function maxprofitIII_param(I, par)
    @unpack y0, ymax, c, p = par
    return 2 * I * ymax * y0 / (( y0 + (I^2) )^2) - c/p
end

function maxprofitIII_vals(par)
    Irange = 0.0:0.01:Int64(round(3*par.y0))
    MC = [margcostIII(I, par) for I in Irange]
    if minimum(MC) >= par.p
        return [0,0]
    else
        try
        I = find_zero(I -> maxprofitIII_param(I, par), 2 * sqrt(par.y0))
        Y = yieldIII(I, par)
        [I, Y]
        catch err
            if isa(err, Roots.ConvergenceFailed)
                smallerguess = (sqrt(par.y0) + find_zero(I -> maxprofitIII_param(I, par), 0.0))/2
                I = find_zero(I -> maxprofitIII_param(I, par), smallerguess)
                Y = yieldIII(I, par)
                [I, Y]
            end
        end
    end
end

function maxyieldIII_param(I, slope, par)
    @unpack y0, ymax, c, p = par
    return 2 * I * ymax * y0 / (( y0 + (I^2) )^2) - slope
end

function maxyieldIII_vals(slope, par)
    guess = maximum([par.y0, maxprofitII_vals(par)[1]])
    I = find_zero(I -> maxyieldIII_param(I, slope, par), guess)
    Y = yieldIII(I, par)
    return [I, Y]
end

function avvarcostIII(I,par)
    @unpack c = par
    Y = yieldIII(I, par)
    return c * I / Y
end

function avvarcostkickIII(Y, par, profityield, maxyieldslope::Float64=0.1)
    @unpack c = par
    if profityield == "profit"
        I = maxprofitIII_vals(par)[1]
    elseif profityield == "yield"
        I = maxyieldIII_vals(maxyieldslope, par)[1]
    else
        error("profityield variable must be either \"profit\" or \"yield\".")
    end
    return c * I / Y
end 

# function avvarcostkickIII_maxprofit(Y, par)
#     @unpack c = par
#     I = maxprofitIII_vals(par)[1]
#     return c * I / Y
# end ###might be a way of making this more general

function margcostIII(I, par)
    @unpack c = par
    return c / margprodIII(I, par)
end

# function avvarcostkickIII_maxyield(Y, slope, par)
#     @unpack c = par
#     I = maxyieldIII_vals(slope, par)[1]
#     return c * I / Y
# end


#Programming of time series of profit
function profit(I, Y, par)
    @unpack p, c = par
    return p * Y - c * I
end

function noise_creation(μ, σ, corr, len, seed)
    Random.seed!(seed)
    white = rand(Normal(0.0, σ), Int64(len))
    intnoise = [white[1]]
    for i in 2:Int64(len)
        intnoise = append!(intnoise, corr * intnoise[i-1] + white[i] )
    end
    c = std(white)/std(intnoise)
    meanintnoise = mean(intnoise)
    scalednoise = zeros(Int64(len))
    for i in 1:Int64(len)
        scalednoise[i] = c * (intnoise[i] - meanintnoise)
    end
    recentrednoise = zeros(Int64(len))
    for i in 1:Int64(len)
        recentrednoise[i] = scalednoise[i]+μ
    end
    return recentrednoise
end

# function unscaled_noise_creation(r, var, len)
#     white = rand(Normal(0.0, 1.0), Int64(len))
#     white[1] = white[1] * var
#     intnoise = [white[1]]
#     for i in 2:Int64(len)
#         intnoise = append!(intnoise, r * intnoise[i-1] + var * white[i] )
#     end
#     return intnoise
# end

# let 
#     Random.seed!(4)
#     test = figure()
#     plot(1.0:1.0:5.0, unscaled_noise_creation(0.9, 0.1, 5) )
#     return test
# end

# function test_noise(seed,length, r)
#     Random.seed!(seed)
#     return sum(noise_creation(r, length))
# end

# test_noise(1, 1000, 0.9)
# test_noise(6, 1000, 0.9)
# test_noise(45, 1000, 0.9)

function timeseries_profit_unscaled(par, r, var, length, seed)
    Random.seed!(seed)
    noise = unscaled_noise_creation(r, var, length)
    vals = maxprofitIII_vals(par)
    prof = zeros(length)
    for i in 1:length
        prof[i] = profit(vals[1], vals[2]+noise[i], par)
    end
    return prof
end

function timeseries_profit_scaled_debt(par, r, var, length, seed)
    Random.seed!(seed)
    noise = scaled_noise_creation(r, var, length)
    vals = maxprofitIII_vals(par)
    prof = zeros(length)
    termprofit = zeros(length)
    prof[1] = profit(vals[1], vals[2]+noise[1], par)
    termprofit[1] = prof[1]
    for i in 2:length
        prof[i] = profit(vals[1], vals[2]+noise[i], par)
        if termprofit[i-1] < 0.0
            termprofit[i] = prof[i] + (1.1 * termprofit[i-1]) #pay off "debt" from last year
        else
            termprofit[i] = prof[i] + termprofit[i-1]
        end
    end
    return termprofit[end] ####NEED TO ADD FEEDBACK
end

# let 
#     test = figure()
#     plot(1:1:50, timeseries_profit_scaled_debt(BMPPar(y0 = 2.0, ymax = 0.8, c = 0.5, p = 2.2), 0.0, 0.1, 50, 154))
#     xlim(1,50)
#     ylim(-10, 10)
#     return test
# end
# timeseries_profit_scaled_debt(BMPPar(y0 = 2.0, ymax = 0.8, c = 0.5, p = 2.2), 0.0, 0.1, 50, 12)


# timeseries_profit(50, par, r, seed)

function cv_calc(data)
    stddev = std(data)
    mn = mean(data)
    return stddev/mn
end

function avcv_calc(iter, length, par, r)
    cv_data = zeros(iter)
    @threads for i in 1:iter
        @inbounds cv_data[i] = cv_calc(timeseries_profit(length, par, r))
    end
    return mean(cv_data)
end

function avvarcostII(I,par)
    @unpack c = par
    Y = yieldII(I, par)
    return c * I / Y
end

function avvarcostkickII(Y, par)
    @unpack c = par
    I = maxprofitII_vals(par)[1]
    return c * I / Y
end ###might be a way of making this more general

function margcostII(I, par)
    @unpack c = par
    return c / margprodII(I, par)
end

#Useful functions for setting up parameters
function param_ratio(par)
    @unpack y0, ymax, p, c = par
    return (ymax * p) / (2 * sqrt(y0) * c)
end

function calc_c(rev_exp_ratio, ymax, y0, p)
    return (ymax * p) / (2 * sqrt(y0) * rev_exp_ratio)
end

function calc_y0(rev_exp_ratio, ymax, c, p)
    return ((ymax * p) / (2 * c * rev_exp_ratio) )^2
end

    