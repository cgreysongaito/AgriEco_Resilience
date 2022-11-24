
include("packages.jl")
include("AgriEco_commoncode.jl")
## Starting values
#Land value plus machinery
#Debt
#what is the starting value of liquid assets? (equity)

#data set of year, illiquid and liquid assets, liabilities, amortized debt amount

#each year
#liquid assets minus input costs  QUESTION what to set input at - do I make inputs just match rest of liquid assets or add more debt)
#liquid assets minus minus amortized liabilities
#liabilities minus ammortized liabilities
# if liquid assets go into negatives then add new debt to replace negative (liabilities plus new debt)
#if liabilities increase recalculate amortized debt payments
#run profits function and add to liquid assets

@with_kw mutable struct YieldInputsPar
    yield_r = 0.0
    yield_prices_r = 0.0
    inputs_r = 0.0
    inputs_prices_r = 0.0
    yield_var = 3.0
    yield_prices_var = 3.0
    inputs_var = 3.0
    inputs_prices_var = 3.0
    yield_midpoint = 200.0
    yield_prices_midpoint = 30.0
    inputs_midpoint = 100.0
    inputs_prices_midpoint = 30.0
end

@with_kw mutable struct AssetsDebtPar
    initial_total_assets = 40000.0
    initial_illiquid_assets_fraction = 0.8
    initial_debt_fraction = 0.75
    interestrate = 3
end

function yieldinputs_createdata(par, maxyears)
    @unpack yield_r, yield_prices_r, yield_prices_r, inputs_r, inputs_prices_r, yield_var, yield_prices_var, inputs_var, inputs_prices_var, yield_midpoint, yield_prices_midpoint, inputs_midpoint, inputs_prices_midpoint = par
    yield_data = scaled_noise_creation(yield_r, yield_var, yield_midpoint, maxyears)
    yield_prices_data = scaled_noise_creation(yield_prices_r, yield_prices_var, yield_prices_midpoint, maxyears)
    inputs_data = scaled_noise_creation(inputs_r, inputs_var, inputs_midpoint, maxyears)
    inputs_prices_data = scaled_noise_creation(inputs_prices_r, inputs_prices_var, inputs_prices_midpoint, maxyears)
    return hcat(1:1:maxyears, yield_data, yield_prices_data, inputs_data, inputs_prices_data)
end

function yieldinputs_staticdata(par, maxyears)
    @unpack yield_midpoint, yield_prices_midpoint, inputs_midpoint, inputs_prices_midpoint = par
    yield_data = repeat([yield_midpoint], maxyears)
    yield_prices_data = repeat([yield_prices_midpoint], maxyears)
    inputs_data = repeat([inputs_midpoint], maxyears)
    inputs_prices_data = repeat([inputs_prices_midpoint], maxyears)
    return hcat(1:1:maxyears, yield_data, yield_prices_data, inputs_data, inputs_prices_data)
end

function revenue_calc(yield, yield_price)
    return yield * yield_price
end

function expenses_calc(inputs, inputs_price)
    return inputs * inputs_price
end

function totalpayment(loan, interestrate, maxyears)
    convertedrate = interestrate/100
    return round(loan * ((convertedrate * (1 + convertedrate)^maxyears)/(((1+convertedrate)^maxyears) - 1)); digits=2)
end

function interest(loan, interestrate)
    convertedrate = interestrate/100
    return round(loan * convertedrate; digits = 2)
end

function amortization_calc(newloan, year, interestrate, maxyears)
    yearsleft = maxyears-year
    years_vec = year:1:maxyears
    totalpayment_vec = vcat([0],repeat([totalpayment(newloan, interestrate, yearsleft)], yearsleft))
    principal_vec = vcat([newloan], zeros(yearsleft))
    interest_vec = zeros(yearsleft+1)
    principaldue_vec = zeros(yearsleft+1)
    for i in 1:yearsleft
        interest_vec[i+1] = interest(principal_vec[i], interestrate)
        principaldue_vec[i+1] = totalpayment_vec[i+1] - interest_vec[i+1]
        principal_vec[i+1] = principal_vec[i]-principaldue_vec[i+1]
    end
    return hcat(years_vec, totalpayment_vec, interest_vec, principaldue_vec, principal_vec)
end

function amortizeschedule_update(currentamortizeschedule, newloan, year, interestrate, maxyears)
    constantpart_schedule = currentamortizeschedule[1:year+1, :]
    newpart_schedule_prep = amortization_calc(newloan, year, interestrate, maxyears)
    constantpart_schedule[year+1,5] = newpart_schedule_prep[1,5]
    newpart_schedule = newpart_schedule_prep[2:end,:]
    return vcat(constantpart_schedule, newpart_schedule)
end

# is this a problem that when take on more debt the debt payments become larger because time horizon is shorter for debt payments

function liquid_asset_update(year, current_liquid_assets, yieldinputs_data, currentamortizeschedule)
    newassets = current_liquid_assets - ( expenses_calc(yieldinputs_data[year, 4], yieldinputs_data[year, 5]) + currentamortizeschedule[year+1, 2] )
    if newassets < 0
        midseasonassets = 0
        newloan = currentamortizeschedule[year+1,5] + abs(newassets)
    else
        midseasonassets = newassets
        newloan = currentamortizeschedule[year+1,5]
    end
    endseasonassets = midseasonassets + revenue_calc(yieldinputs_data[year, 2], yieldinputs_data[year, 3])
    return hcat(endseasonassets, newloan)
end

function insolvency_sim(yieldinputspar, assetsdebtpar, maxyears)
    @unpack initial_total_assets, initial_illiquid_assets_fraction, initial_debt_fraction, interestrate = assetsdebtpar
    initial_loan = initial_total_assets * initial_debt_fraction
    initial_illiquid_assets = initial_total_assets * initial_illiquid_assets_fraction
    initial_liquid_assets = initial_total_assets * (1-initial_illiquid_assets_fraction)
    yieldinputs_data = yieldinputs_staticdata(yieldinputspar, maxyears)
    currentamortizeschedule = amortization_calc(initial_loan, 0, interestrate, maxyears)
    years_vec = 0:1:maxyears
    illiquid_assets_vec = repeat([initial_illiquid_assets], length(years_vec))
    liquid_assets_vec = vcat([initial_liquid_assets], zeros(maxyears))
    liabilities_vec = vcat([initial_loan], zeros(maxyears))
    for yr in 1:maxyears
        assetupdate_data = liquid_asset_update(yr,liquid_assets_vec[yr], yieldinputs_data, currentamortizeschedule)
        liquid_assets_vec[yr+1] = assetupdate_data[1]
        currentamortizeschedule = amortizeschedule_update(currentamortizeschedule, assetupdate_data[2], yr, interestrate, maxyears)
        liabilities_vec[yr+1] = currentamortizeschedule[yr+1, 5]
    end
    # return hcat(years_vec, illiquid_assets_vec, liquid_assets_vec, liabilities_vec)
    return currentamortizeschedule  
end

#Bug in my code Year 4
test = insolvency_sim(YieldInputsPar(), AssetsDebtPar(), 10)
test2 = insolvency_sim(YieldInputsPar(), AssetsDebtPar(), 10)
