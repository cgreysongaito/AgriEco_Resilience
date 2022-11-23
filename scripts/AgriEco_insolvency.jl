
include("packages.jl")
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
    return hcat(years_vec, totalpayment_vec, interest_vec,principaldue_vec, principal_vec)
end

function amortizeschedule_update(currentamortizeschedule, newloan, year, interestrate, maxyears)
    constantpart_schedule = currentamortizeschedule[1:year+1, :]
    newpart_schedule_prep = amortization_calc(newloan, year, interestrate, maxyears)
    constantpart_schedule[year+1,5] = newpart_schedule_prep[1,5]
    newpart_schedule = newpart_schedule_prep[2:end,:]
    return vcat(constantpart_schedule, newpart_schedule)
end

test = amortization_calc(30000, 0, 3, 10)
test2 = amortizeschedule_update(test, 24687.7, 2, 3, 10)

# is this a problem that when take on more debt the debt payments become larger because time horizon is shorter for debt payments

function asset_update(year, yieldinput_data, currentamortizeschedule)
    newassets = currentassets - ( expenses_calc(inputs, inputs_price) + currentamortizeschedule[year, 2] )
    if newassets < 0
        midseasonassets = 0
        newloan = currentamortizeschedule[year+1,5] + newassets
    else
        midseasonassets = newassets
        newloan = currentamortizeschedule[year+1,5]
    end
    endseasonassets = midseasonassets + revenue_calc(yield, yield_price)
    return hcat(endseasonassets, newloan)
end

function insolvency_sim(maxyears, initialloan, initialassets, interestrate, yieldinput_data)
    currentamortizeschedule = amortization_calc(initialloan, 0, interestrate, maxyears)
    years_vec = 0:1:maxyears
    assets_vec = vcat([initialassets], zeros(maxyears))
    liabilities_vec = vcat([initialloan], zeros(maxyears))
    for i in 1:maxyears
        assetupdate_data = asset_update(i, yieldinput_data, currentamortizeschedule)
        assets_vec[i+1] = assetupdate_data[1]
        currentamortizeschedule = amortizeschedule_update(currentamortizeschedule, assetupdate_data[2], i+1, interestrate, maxyears)
        liabilities_vec[i+1] = currentamortizeschedule[i+1, 4]
    return hcat(years_vec, assets_vec, liabilities_vec)
end

insolvency_sim(10, 30000, 100, 3, 2)

# array of early season and late season assets and liabilities for each year. 
#separate array of input, input prices, yield, yield prices - make function to produce this array 
#separate array of total payment, interest, principal paid, liability