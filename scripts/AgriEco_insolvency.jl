
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
    return hcat(years_vec, illiquid_assets_vec, liquid_assets_vec, liabilities_vec)
    # return currentamortizeschedule  
end

yieldinputs_testdata = yieldinputs_staticdata(YieldInputsPar(), 10)
revenue_calc(yieldinputs_testdata[10, 2], yieldinputs_testdata[10, 3])
expenses_calc(yieldinputs_testdata[10, 4], yieldinputs_testdata[10, 5])

#Bug in my code Year 4
test = insolvency_sim(YieldInputsPar(), AssetsDebtPar(), 10)
test2 = insolvency_sim(YieldInputsPar(), AssetsDebtPar(), 10)


##Setting parameters##
# Debt:Asset 0.162 2021 (https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=3210005601) Solvency Ratio: Debt
# Average Debt (current and long-term) 700,000. 2021 Total Debt Outstanding/Number of farms  129,038,322,000/189,874 (https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=3210005101)/(https://www.gov.mb.ca/agriculture/markets-and-statistics/ag-census/pubs/census-manitoba-profile-2021.pdf)
# Starting assets 700000/0.162 = 4320000
# Starting liquid assets set by Liquidity Current Ratio (Current assets:Current liabilities) 2021 2.303 (https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=3210005601)
# Average number of acres per farm 800 acres (https://www.foodfocusguelph.ca/post/average-farm-size-has-stopped-growing)
#Averag number of acres for crop land
# Beginning liquid assets = 800 * 700 * 2.303 = 1,289,680

# Debt servicing coverage ratio = 1.91 (https://www.fcc-fac.ca/en/knowledge/economics/debt-service-coverage-ratio-anchoring-farm-financial-fitness.html)

#Average operating expenses (2020) 400,000 (https://www150.statcan.gc.ca/n1/daily-quotidien/220325/cg-a001-eng.htm)

##Setting parameters Version 1 (Top down) (debt structure method)##
# Average Debt (current and long-term) 700,000. 2021 Total Debt Outstanding/Number of farms  129,038,322,000/189,874 (https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=3210005101)/(https://www.gov.mb.ca/agriculture/markets-and-statistics/ag-census/pubs/census-manitoba-profile-2021.pdf)
# Debt:Asset 0.162 2021 (https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=3210005601) Solvency Ratio: Debt
# Starting assets 700000/0.162 = 4,320,000
# Debt structure ratio (current/total liabilities) = 0.157
# Current liabilities = 0.157*700000 = 109900   long-term liabilities = 700000-109900 = 590100 
# Starting liquid assets set by Liquidity Current Ratio (Current assets:Current liabilities) 2021 2.303 (https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=3210005601)
# Starting liquid assets = 109900*2.303 = 253099.7

# interest rate = 3 for overnight policy rate + 1 for bank loan

# Debt servicing coverage ratio (income/debt service) = 1.91 (https://www.fcc-fac.ca/en/knowledge/economics/debt-service-coverage-ratio-anchoring-farm-financial-fitness.html)
# 109900 * 1.04 = 114296
# amortized portion = 37773.5
amortization_calc(590100, 0, 4, 25)
# income = operating expenses / 0.76 = 526315
# DSCR = 526315/(114296+37773.5) = 3.46

# Expenses method
# Average operating expenses (2020) 400,000 (https://www150.statcan.gc.ca/n1/daily-quotidien/220325/cg-a001-eng.htm)
# Debt servicing coverage ratio (income/debt service) = 1.91 (https://www.fcc-fac.ca/en/knowledge/economics/debt-service-coverage-ratio-anchoring-farm-financial-fitness.html)
# 40000 * 1.04 = 416000
# amortized portion = 37773.5
amortization_calc(590100, 0, 4, 25)
# income = operating expenses / 0.76 = 526315
# DSCR = 526315/(416000+37773.5) = 1.16

##Setting parameters Version 2 (Top down) Expenses method + half of operating expenses funded by loan and half from current assets##
# Average Debt (current and long-term) 700,000. 2021 Total Debt Outstanding/Number of farms  129,038,322,000/189,874 (https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=3210005101)/(https://www.gov.mb.ca/agriculture/markets-and-statistics/ag-census/pubs/census-manitoba-profile-2021.pdf)
# Debt:Asset 0.162 2021 (https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=3210005601) Solvency Ratio: Debt
# Starting assets 700000/0.162 = 4,320,000
# Starting liquid assets = 600*700*0.5*2.303 =~ 483630
# Operating expenses = 400000
# Current liabilities = 200000   
# long-term liabilities = 700000-200000 = 500000
# ratio of current liabilities to current assets to pay for operating expenses = 0.5

# interest rate = 3 for overnight policy rate + 1 for bank loan

# Debt servicing coverage ratio (income/debt service) = 1.91 (https://www.fcc-fac.ca/en/knowledge/economics/debt-service-coverage-ratio-anchoring-farm-financial-fitness.html)
# 200,000 *1.04 = 208000
# amortized portion = 32006.0
amortization_calc(500000, 0, 4, 25)
# income = operating expenses / 0.76 = 526315
# DSCR = 526315/(208000+32006.0) = 2.19


## Setting parameters version 3 (Bottom Up) ##
# Average operating expenses (2020) 400,000 (https://www150.statcan.gc.ca/n1/daily-quotidien/220325/cg-a001-eng.htm)
# Current liabilities = 400,000
# Debt structure ratio (current/total liabilities) = 0.157
# total liabilities = 400,000/0.157 = 2,547,770
# long term liabilities = 2,547,770-400000 = 2,147,770
# Debt:Asset 0.162 2021 (https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=3210005601) Solvency Ratio: Debt
# Total assets = total debt/0.162 = 15,726,975
# Starting liquid assets set by Liquidity Current Ratio (Current assets:Current liabilities) 2021 2.303 (https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=3210005601)
# Starting liquid assets = 400,000*2.303 = 921,200
# Starting illiquid assets = 15,726,975 - 921,200 = 14,805,775

# interest rate = 3 for overnight policy rate + 1 for bank loan

# Debt servicing coverage ratio (income/debt service) = 1.91 (https://www.fcc-fac.ca/en/knowledge/economics/debt-service-coverage-ratio-anchoring-farm-financial-fitness.html)
# 400,000 *1.04 = 416000
# amortized portion = 137,483
amortization_calc(2147770, 0, 4, 25)
# income = operating expenses / 0.76 = 526315
# DSCR = 526315/(416000+137483) = 0.95

## Setting parameters version 4 (Bottom Up) half of operating expenses funded by loan and half from current assets ##
# Average operating expenses (2020) 400,000 (https://www150.statcan.gc.ca/n1/daily-quotidien/220325/cg-a001-eng.htm)
# Ratio of using operating loan versus current assets to pay for operating expense = 0.5?
# Current liabilities = 200,000
# Debt structure ratio (current/total liabilities) = 0.157
# total liabilities = 200,000/0.157 = 1,273,885
# long term liabilities = 1,273,885-200,000 = 1,073,885
# Debt:Asset 0.162 2021 (https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=3210005601) Solvency Ratio: Debt
# Total assets = 1,273,885/0.162 = 7,863,487
# Starting liquid assets set by Liquidity Current Ratio (Current assets:Current liabilities) 2021 2.303 (https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=3210005601)
# Starting liquid assets = 200,000*2.303 = 460,600
# Starting illiquid assets = 7,863,487 - 460,600 = 7,402,887

# interest rate = 3 for overnight policy rate + 1 for bank loan

# Debt servicing coverage ratio (income/debt service) = 1.91 (https://www.fcc-fac.ca/en/knowledge/economics/debt-service-coverage-ratio-anchoring-farm-financial-fitness.html)
# 200,000 *1.04 = 208000
# amortized portion = 68741
amortization_calc(1073885, 0, 4, 25)
# income = operating expenses / 0.76 = 526315
# DSCR = 526315/(208000+68741) = 1.901


## Setting parameters version 4 (Bottom Up) 0.25 of operating expenses funded by loan and 0.75 from current assets ##
# Average operating expenses (2020) 400,000 (https://www150.statcan.gc.ca/n1/daily-quotidien/220325/cg-a001-eng.htm)
# Ratio of using operating loan versus current assets to pay for operating expense = 0.25
# Current liabilities = 100,000
# Debt structure ratio (current/total liabilities) = 0.157
# total liabilities = 100,000/0.157 = 636,942
# long term liabilities = 636,942-100,000 = 536,942
# Debt:Asset 0.162 2021 (https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=3210005601) Solvency Ratio: Debt
# Total assets = 636,942/0.162 = 3,931,740
# Starting liquid assets set by Liquidity Current Ratio (Current assets:Current liabilities) 2021 2.303 (https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=3210005601)
# Starting liquid assets = 100,000*2.303 = 230,300
# Starting illiquid assets = 3,931,740 - 230,300 = 3701440

# interest rate = 3 for overnight policy rate + 1 for bank loan

# Debt servicing coverage ratio (income/debt service) = 1.91 (https://www.fcc-fac.ca/en/knowledge/economics/debt-service-coverage-ratio-anchoring-farm-financial-fitness.html)
# 100,000 *1.04 = 104000
# amortized portion = 34370.7
amortization_calc(536942, 0, 4, 25)
# income = operating expenses / 0.76 = 526315
# DSCR = 526315/(104000+34370.7) = 3.80


## Setting parameters version 4 (Bottom Up) 0.4 of operating expenses funded by loan and 0.6 from current assets ##
# Average operating expenses (2020) 400,000 (https://www150.statcan.gc.ca/n1/daily-quotidien/220325/cg-a001-eng.htm)
# Ratio of using operating loan versus current assets to pay for operating expense = 0.4
# Current liabilities = 160000
# Debt structure ratio (current/total liabilities) = 0.157
# total liabilities = 160,000/0.157 = 1,019,108
# long term liabilities = 1,019,108-160,000 = 859108
# Debt:Asset 0.162 2021 (https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=3210005601) Solvency Ratio: Debt
# Total assets = 1,019,108/0.162 = 6,290,790
# Starting liquid assets set by Liquidity Current Ratio (Current assets:Current liabilities) 2021 2.303 (https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=3210005601)
# Starting liquid assets = 160,000*2.303 = 368480
# Starting illiquid assets = 6,290,790 - 368480 = 5,922,310

# interest rate = 3 for overnight policy rate + 1 for bank loan

# Debt servicing coverage ratio (income/debt service) = 1.91 (https://www.fcc-fac.ca/en/knowledge/economics/debt-service-coverage-ratio-anchoring-farm-financial-fitness.html)
# 160,000 *1.04 = 166400
# amortized portion = 54993.2
amortization_calc(859108, 0, 4, 25)
# income = operating expenses / 0.76 = 526315
# DSCR = 526315/(166400+54993.2) = 2.37


#Changes
#May need to lower average number of acres per crop farm - because includes pasture (and pushes expenses too high)

#check parameters
#debt structure (current liabilities/total liabilities) 0.17 - which means long term liabilities at the moment seems too small
#1 with ratio of debt to asset ratio
#2 with ratio of debt to profits
#3 with ratio of revenue to debt payments (debt servicing coverage ratio)


#Sensitivity analyses
#interest rates
#amortization schedule (debt payments)


# Data Links
#Average debt and assets per grain farm in Canada***** -https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=3210010201

# Land in crops = 93,595,208 acres
# number of grain oilseed farms = 154,549 (https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=3210015301)
# average number of acres = 93595208/154,549 = 600 acres (https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=3210015301)
# number of farms = https://www150.statcan.gc.ca/n1/daily-quotidien/220511/dq220511a-eng.htm

#operating revenue to operating expenses (https://www150.statcan.gc.ca/n1/daily-quotidien/220511/t004a-eng.htm)

#OMAFRA publication 60 - http://omafra.gov.on.ca/english/busdev/facts/pub60.pdf
#https://www.cmegroup.com/
#https://www.dtnpf.com/agriculture/web/ag/crops/article/2022/11/23/fertilizer-prices-mainly-lower
#http://omafra.gov.on.ca/english/busdev/facts/pub60.htm
#https://gfo.ca/marketing/daily-commodity-report/
#http://www.omafra.gov.on.ca/english/stats/agriculture_summary.htm#farm - statistics
# https://data.ers.usda.gov/reports.aspx?ID=17838 -  debt to asset ratios
#https://www.ers.usda.gov/topics/farm-economy/farm-sector-income-finances/
#https://www.ers.usda.gov/data-products/farm-income-and-wealth-statistics/documentation-for-the-farm-sector-financial-ratios/#dtoa

#https://www.ers.usda.gov/data-products/farm-income-and-wealth-statistics/documentation-for-the-farm-sector-financial-ratios/


#Debt to asset ratio
#US about 0.11-0.14 https://data.ers.usda.gov/reports.aspx?ID=17838
#Canada about 0.15-1.16 https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=3210005601


#loans outstanding to cash income
#https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=3210028501

#Debt outstanding Canada
#https://publications.gc.ca/Collection/Statcan/21-014-XIE/21-014-XIE2004001.pdf

#Average profits to debt payments OR USE DEBT SERVICING COVERAGE RATIO
#https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=3210010201 - has interest payments for crop farms
#https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=3210028501 - has change in liabilities
#COULD USE DSCR to calculate approximate debt payments - from https://www.fcc-fac.ca/en/knowledge/economics/debt-service-coverage-ratio-anchoring-farm-financial-fitness.html

#debt structure (current liabilities/total liabilities)


#explanation of balance sheet (Stats Can)
#https://www150.statcan.gc.ca/n1/pub/21-016-x/2011001/technote-notetech2-eng.htm

#net operating income
# https://www150.statcan.gc.ca/n1/daily-quotidien/220325/dq220325a-eng.htm