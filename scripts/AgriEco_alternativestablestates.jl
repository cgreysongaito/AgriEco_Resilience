include("packages.jl")
include("AgriEco_commoncode.jl")


#Cumulative distribution

function termprofit_sims_unscaled(iter, par, r, var, length)
    data = zeros(iter)
    @threads for i in 1:iter
        @inbounds data[i] = sum(timeseries_profit_unscaled(par, r, var, length, i))
    end
    return data
end

function counttermprof(data, value)
    count = 0
    for i in 1:length(data)
        if data[i] < value
            count += 1
        end
    end
    return count
end

function cumulativeprob(data, stepsize)
    range = minimum(data):stepsize:maximum(data)
    cumulprob = zeros(length(range))
    for (tpi, tpnum) in enumerate(range)
        cumulprob[tpi] = counttermprof(data, tpnum) / length(data)
    end
    return [range, cumulprob]
end

let 
    data_hy0hymax = cumulativeprob(termprofit_sims_unscaled(100, BMPPar(y0 = 2.0, ymax = 1.5, c = 0.5, p = 2.2), 0.9, 0.1, 50), 0.1)
    data_lyohymax = cumulativeprob(termprofit_sims_unscaled(100, BMPPar(y0 = 0.8, ymax = 1.5, c = 0.5, p = 2.2), 0.9, 0.1, 50), 0.1)
    data_hy0lymax = cumulativeprob(termprofit_sims_unscaled(100, BMPPar(y0 = 2.0, ymax = 0.8, c = 0.5, p = 2.2), 0.9, 0.1, 50), 0.1)
    data_ly0lymax = cumulativeprob(termprofit_sims_unscaled(100, BMPPar(y0 = 0.8, ymax = 0.8, c = 0.5, p = 2.2), 0.9, 0.1, 50), 0.1)
    test = figure()
    subplot(2,2,1)
    plot(data_hy0hymax[1], data_hy0hymax[2])
    xlabel("Terminal Profit")
    ylabel("Cumulative Probability")
    subplot(2,2,2)
    plot(data_hy0lymax[1], data_hy0lymax[2])
    xlabel("Terminal Profit")
    ylabel("Cumulative Probability")
    subplot(2,2,3)
    plot(data_lyohymax[1], data_lyohymax[2])
    xlabel("Terminal Profit")
    ylabel("Cumulative Probability")
    subplot(2,2,4)
    plot(data_ly0lymax[1], data_ly0lymax[2])
    xlabel("Terminal Profit")
    ylabel("Cumulative Probability")
    tight_layout()
    return test
end
#with unscaled noise - cumulative probability doesn't show much more than resistance graphs before. even between white and red noise - red noise just increases the range of term profit by x10


function termprofit_sims_scaled_debt(iter, par, r, var, length)
    data = zeros(iter)
    @threads for i in 1:iter
        @inbounds data[i] = timeseries_profit_scaled_debt(par, r, var, length, i)
    end
    return data
end

termprofit_sims_scaled_debt(100, BMPPar(y0 = 2.0, ymax = 3.0, c = 0.5, p = 2.2), 0.0, 0.1, 50)

let 
    data = cumulativeprob(termprofit_sims_scaled_debt(100, BMPPar(y0 = 2.0, ymax = 2.0, c = 0.5, p = 2.2), 0.0, 0.1, 50), 0.1)
    test = figure()
    plot(data[1], data[2])
    return test
end
#again problem with using scaled noise - when profit always positive - term profit is always the same.

cumulativeprob_profit(100, 50, BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2), 0.8)

timeseries_profit(5, BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2), 0.0, 2)
timeseries_profit(5, BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2), 0.0, 137)
timeseries_profit(5, BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2), 0.9, 2)
timeseries_profit(5, BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2), 0.9, 137)

sum(timeseries_profit(5, BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2), 0.0, 2))
sum(timeseries_profit(5, BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2), 0.0, 137))
sum(timeseries_profit(5, BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2), 0.9, 2))
sum(timeseries_profit(5, BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2), 0.9, 137))


#random iter is still returning the same sum and profit. regardless of correlation in noise