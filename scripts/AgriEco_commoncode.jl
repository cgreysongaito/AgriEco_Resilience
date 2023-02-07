### Helper functions

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

function profit(I, Y, par)
    @unpack p, c = par
    return p * Y - c * I
end

function cv_calc(data)
    stddev = std(data)
    mn = mean(data)
    return stddev/mn
end

### Parameters

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

@with_kw mutable struct FarmBasePar
    ymax = 174.0 # yield per acre #budget summary field crops budgets 2022 corn conventional
    y0 = 10
    p = 6.70 # market price pert unit (not acre) #budget summary field crops budgets 2022 corn conventional
    c = 139
end

### production and marginal functions

function yieldIII(I, par)
    @unpack ymax, y0 = par
    return ymax * (I^2) / (y0 + (I^2))
end

function margprodIII(I, par)
    @unpack ymax, y0 = par
    return 2 * I * ymax * y0 / (( y0 + (I^2) )^2)
end

function margcostIII(I, par)
    @unpack c = par
    return c / margprodIII(I, par)
end

function avvarcostIII(I,par)
    @unpack c = par
    Y = yieldIII(I, par)
    return c * I / Y
end

# function yieldII(I, par)
#     @unpack ymax, y0 = par
#     return ymax * I / (y0 + I)
# end

# function margprodII(I, par)
#     @unpack ymax, y0 = par
#     return ymax * y0 / (( y0 + I )^2)
# end

# function margcostII(I, par)
#     @unpack c = par
#     return c / margprodII(I, par)
# end

# function avvarcostII(I,par)
#     @unpack c = par
#     Y = yieldII(I, par)
#     return c * I / Y
# end

### Input decision functions

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
    try
    I = find_zero(I -> maxyieldIII_param(I, slope, par), 2 * sqrt(par.y0))
    Y = yieldIII(I, par)
    [I, Y]
    catch err
        if isa(err, Roots.ConvergenceFailed)
            smallerguess = (sqrt(par.y0) + find_zero(I -> maxyieldIII_param(I, slope, par), 0.0))/2
            I = find_zero(I -> maxyieldIII_param(I, slope, par), smallerguess)
            Y = yieldIII(I, par)
            [I, Y]
        end
    end
end

### Yield disturbance function
function avvarcostkickIII(Y, par, profityield, maxyieldslope::Float64=1.0)
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

### Noise creation function

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
    