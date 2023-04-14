include("packages.jl")
include("AgriEco_commoncode.jl")
include("AgriEco_positivefeedbacks.jl")
include("AgriEco_timedelay.jl")

## Positive feedbacks ##
#Expected Terminal Assets
let
    highymax_133 = expectedterminalassets_rednoise(highymax_133_posfeed_data)
    highymax_115 = expectedterminalassets_rednoise(highymax_115_posfeed_data)
    highymax_100 = expectedterminalassets_rednoise(highymax_100_posfeed_data)
    medymax_133 = expectedterminalassets_rednoise(medymax_133_posfeed_data)
    medymax_115 = expectedterminalassets_rednoise(medymax_115_posfeed_data)
    medymax_100 = expectedterminalassets_rednoise(medymax_100_posfeed_data)
    lowymax_133 = expectedterminalassets_rednoise(lowymax_133_posfeed_data)
    lowymax_115 = expectedterminalassets_rednoise(lowymax_115_posfeed_data)
    lowymax_100 = expectedterminalassets_rednoise(lowymax_100_posfeed_data)
    rednoise_exptermassets = figure(figsize=(4,6))
    subplot(3,1,1)
    plot(highymax_133[:,1], highymax_133[:,4], color="blue", label="High ymax")
    plot(medymax_133[:,1], medymax_133[:,4], color="red", label="Med ymax")
    plot(lowymax_133[:,1], lowymax_133[:,4], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("ETAwNL/ETAwoNL")
    title("Rev/Exp = 1.33")
    subplot(3,1,2)
    plot(highymax_115[:,1], highymax_115[:,4], color="blue", label="High ymax")
    plot(medymax_115[:,1], medymax_115[:,4], color="red", label="Med ymax")
    plot(lowymax_115[:,1], lowymax_115[:,4], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("ETAwNL/ETAwoNL")
    title("Rev/Exp = 1.15")
    subplot(3,1,3)
    plot(highymax_100[:,1], highymax_100[:,4], color="blue", label="High ymax")
    plot(medymax_100[:,1], medymax_100[:,4], color="red", label="Med ymax")
    plot(lowymax_100[:,1], lowymax_100[:,4], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("ETAwNL/ETAwoNL")
    title("Rev/Exp = 1.10")
    tight_layout()
    # return rednoise_exptermassets
    savefig(joinpath(abpath(), "figs/posfeed_expectedterminalassets.pdf")) 
end

#Variability Terminal Assets
let 
    highymax_133 = variabilityterminalassets_rednoise(highymax_133_posfeed_data)
    highymax_115 = variabilityterminalassets_rednoise(highymax_115_posfeed_data)
    highymax_100 = variabilityterminalassets_rednoise(highymax_100_posfeed_data)
    medymax_133 = variabilityterminalassets_rednoise(medymax_133_posfeed_data)
    medymax_115 = variabilityterminalassets_rednoise(medymax_115_posfeed_data)
    medymax_100 = variabilityterminalassets_rednoise(medymax_100_posfeed_data)
    lowymax_133 = variabilityterminalassets_rednoise(lowymax_133_posfeed_data)
    lowymax_115 = variabilityterminalassets_rednoise(lowymax_115_posfeed_data)
    lowymax_100 = variabilityterminalassets_rednoise(lowymax_100_posfeed_data)
    rednoise_var_exptermassets = figure(figsize=(4,6))    
    subplot(3,1,1)
    plot(highymax_133[:,1], highymax_133[:,4], color="blue", label="High ymax")
    plot(medymax_133[:,1], medymax_133[:,4], color="red", label="Med ymax")
    plot(lowymax_133[:,1], lowymax_133[:,4], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("VarwNL/VarwoNL")
    title("Rev/Exp = 1.33")
    subplot(3,1,2)
    plot(highymax_115[:,1], highymax_115[:,4], color="blue", label="High ymax")
    plot(medymax_115[:,1], medymax_115[:,4], color="red", label="Med ymax")
    plot(lowymax_115[:,1], lowymax_115[:,4], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("VarwNL/VarwoNL")
    title("Rev/Exp = 1.15")
    subplot(3,1,3)
    plot(highymax_100[:,1], highymax_100[:,4], color="blue", label="High ymax")
    plot(medymax_100[:,1], medymax_100[:,4], color="red", label="Med ymax")
    plot(lowymax_100[:,1], lowymax_100[:,4], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("VarwNL/VarwoNL")
    title("Rev/Exp = 1.10")
    tight_layout()
    # return rednoise_var_exptermassets
    savefig(joinpath(abpath(), "figs/posfeed_variabilityterminalassets.pdf")) 
end 

#TERMINAL ASSETS SHORTFALL
let 
    shortfallval = 1000
    highymax_133 = termassetsshortfall_rednoise(highymax_133_posfeed_data, shortfallval)
    highymax_115 = termassetsshortfall_rednoise(highymax_115_posfeed_data, shortfallval)
    highymax_100 = termassetsshortfall_rednoise(highymax_100_posfeed_data, shortfallval)
    medymax_133 = termassetsshortfall_rednoise(medymax_133_posfeed_data, shortfallval)
    medymax_115 = termassetsshortfall_rednoise(medymax_115_posfeed_data, shortfallval)
    medymax_100 = termassetsshortfall_rednoise(medymax_100_posfeed_data, shortfallval)
    lowymax_133 = termassetsshortfall_rednoise(lowymax_133_posfeed_data, shortfallval)
    lowymax_115 = termassetsshortfall_rednoise(lowymax_115_posfeed_data, shortfallval)
    lowymax_100 = termassetsshortfall_rednoise(lowymax_100_posfeed_data, shortfallval)
    rednoise_shortfall_exptermassets = figure(figsize=(4,6))    
    subplot(3,1,1)
    plot(highymax_133[:,1], highymax_133[:,4], color="blue", label="High ymax")
    plot(medymax_133[:,1], medymax_133[:,4], color="red", label="Med ymax")
    plot(lowymax_133[:,1], lowymax_133[:,4], color="purple", label="Low ymax")
    xlabel("Autocorrelation")
    ylabel("ShortwNL/ShortwoNL")
    title("Rev/Exp = 1.33")
    subplot(3,1,2)
    plot(highymax_115[:,1], highymax_115[:,4], color="blue", label="High ymax")
    plot(medymax_115[:,1], medymax_115[:,4], color="red", label="Med ymax")
    plot(lowymax_115[:,1], lowymax_115[:,4], color="purple", label="Low ymax")
    xlabel("Autocorrelation")
    ylabel("ShortwNL/ShortwoNL")
    title("Rev/Exp = 1.15")
    subplot(3,1,3)
    plot(highymax_100[:,1], highymax_100[:,4], color="blue", label="High ymax")
    plot(medymax_100[:,1], medymax_100[:,4], color="red", label="Med ymax")
    plot(lowymax_100[:,1], lowymax_100[:,4], color="purple", label="Low ymax")
    xlabel("Autocorrelation")
    ylabel("ShortwNL/ShortwoNL")
    title("Rev/Exp = 1.10")
    tight_layout()
    # return rednoise_shortfall_exptermassets
    savefig(joinpath(abpath(), "figs/posfeed_terminalassetsshortfall.pdf")) 
end 

## Time Delay ##
#Expected Terminal Assets
let
    highymax_133 = expectedterminalassets_rednoise(highymax_133_timedelay_data)
    highymax_115 = expectedterminalassets_rednoise(highymax_115_timedelay_data)
    highymax_100 = expectedterminalassets_rednoise(highymax_100_timedelay_data)
    medymax_133 = expectedterminalassets_rednoise(medymax_133_timedelay_data)
    medymax_115 = expectedterminalassets_rednoise(medymax_115_timedelay_data)
    medymax_100 = expectedterminalassets_rednoise(medymax_100_timedelay_data)
    lowymax_133 = expectedterminalassets_rednoise(lowymax_133_timedelay_data)
    lowymax_115 = expectedterminalassets_rednoise(lowymax_115_timedelay_data)
    lowymax_100 = expectedterminalassets_rednoise(lowymax_100_timedelay_data)
    rednoise_exptermassets = figure(figsize=(4,6))    
    subplot(3,1,1)
    plot(highymax_133[:,1], highymax_133[:,4], color="blue", label="High ymax")
    plot(medymax_133[:,1], medymax_133[:,4], color="red", label="Med ymax")
    plot(lowymax_133[:,1], lowymax_133[:,4], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("ETAwNL/ETAwoNL")
    title("Rev/Exp = 1.33")
    subplot(3,1,2)
    plot(highymax_115[:,1], highymax_115[:,4], color="blue", label="High ymax")
    plot(medymax_115[:,1], medymax_115[:,4], color="red", label="Med ymax")
    plot(lowymax_115[:,1], lowymax_115[:,4], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("ETAwNL/ETAwoNL")
    title("Rev/Exp = 1.15")
    subplot(3,1,3)
    plot(highymax_100[:,1], highymax_100[:,4], color="blue", label="High ymax")
    plot(medymax_100[:,1], medymax_100[:,4], color="red", label="Med ymax")
    plot(lowymax_100[:,1], lowymax_100[:,4], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("ETAwNL/ETAwoNL")
    title("Rev/Exp = 1.10")
    tight_layout()
    return rednoise_exptermassets
    # savefig(joinpath(abpath(), "figs/timedelay_expectedterminalassets.pdf")) 
end  #something going wrong at 0.4 for rev/exp = 1.10

#Variability Terminal Assets
let 
    highymax_133 = variabilityterminalassets_rednoise(highymax_133_timedelay_data)
    highymax_115 = variabilityterminalassets_rednoise(highymax_115_timedelay_data)
    highymax_100 = variabilityterminalassets_rednoise(highymax_100_timedelay_data)
    medymax_133 = variabilityterminalassets_rednoise(medymax_133_timedelay_data)
    medymax_115 = variabilityterminalassets_rednoise(medymax_115_timedelay_data)
    medymax_100 = variabilityterminalassets_rednoise(medymax_100_timedelay_data)
    lowymax_133 = variabilityterminalassets_rednoise(lowymax_133_timedelay_data)
    lowymax_115 = variabilityterminalassets_rednoise(lowymax_115_timedelay_data)
    lowymax_100 = variabilityterminalassets_rednoise(lowymax_100_timedelay_data)
    rednoise_var_exptermassets = figure(figsize=(4,6))        
    subplot(3,1,1)
    plot(highymax_133[:,1], highymax_133[:,4], color="blue", label="High ymax")
    plot(medymax_133[:,1], medymax_133[:,4], color="red", label="Med ymax")
    plot(lowymax_133[:,1], lowymax_133[:,4], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("VarwNL/VarwoNL")
    # xlim(0.0,0.8)
    title("Rev/Exp = 1.33")
    subplot(3,1,2)
    plot(highymax_115[:,1], highymax_115[:,4], color="blue", label="High ymax")
    plot(medymax_115[:,1], medymax_115[:,4], color="red", label="Med ymax")
    plot(lowymax_115[:,1], lowymax_115[:,4], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("VarwNL/VarwoNL")
    # xlim(0.0,0.8)
    title("Rev/Exp = 1.15")
    subplot(3,1,3)
    plot(highymax_100[:,1], highymax_100[:,4], color="blue", label="High ymax")
    plot(medymax_100[:,1], medymax_100[:,4], color="red", label="Med ymax")
    plot(lowymax_100[:,1], lowymax_100[:,4], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("VarwNL/VarwoNL")
    # xlim(0.0,0.8)
    title("Rev/Exp = 1.10")
    tight_layout()
    # return rednoise_var_exptermassets
    savefig(joinpath(abpath(), "figs/timedelay_variabilityterminalassets.pdf")) 
end #something is going wrong with 0.8

#TERMINAL ASSETS SHORTFALL 

let 
    shortfallval = 1000
    highymax_133 = termassetsshortfall_rednoise(highymax_133_timedelay_data, shortfallval)
    highymax_115 = termassetsshortfall_rednoise(highymax_115_timedelay_data, shortfallval)
    highymax_100 = termassetsshortfall_rednoise(highymax_100_timedelay_data, shortfallval)
    medymax_133 = termassetsshortfall_rednoise(medymax_133_timedelay_data, shortfallval)
    medymax_115 = termassetsshortfall_rednoise(medymax_115_timedelay_data, shortfallval)
    medymax_100 = termassetsshortfall_rednoise(medymax_100_timedelay_data, shortfallval)
    lowymax_133 = termassetsshortfall_rednoise(lowymax_133_timedelay_data, shortfallval)
    lowymax_115 = termassetsshortfall_rednoise(lowymax_115_timedelay_data, shortfallval)
    lowymax_100 = termassetsshortfall_rednoise(lowymax_100_timedelay_data, shortfallval)
    rednoise_shortfall_exptermassets = figure(figsize=(4,6))       
    subplot(3,1,1)
    plot(highymax_133[:,1], highymax_133[:,4], color="blue", label="High ymax")
    plot(medymax_133[:,1], medymax_133[:,4], color="red", label="Med ymax")
    plot(lowymax_133[:,1], lowymax_133[:,4], color="purple", label="Low ymax")
    xlabel("Autocorrelation")
    ylabel("ShortwNL/ShortwoNL")
    title("Rev/Exp = 1.33")
    subplot(3,1,2)
    plot(highymax_115[:,1], highymax_115[:,4], color="blue", label="High ymax")
    plot(medymax_115[:,1], medymax_115[:,4], color="red", label="Med ymax")
    plot(lowymax_115[:,1], lowymax_115[:,4], color="purple", label="Low ymax")
    xlabel("Autocorrelation")
    ylabel("ShortwNL/ShortwoNL")
    title("Rev/Exp = 1.15")
    subplot(3,1,3)
    plot(highymax_100[:,1], highymax_100[:,4], color="blue", label="High ymax")
    plot(medymax_100[:,1], medymax_100[:,4], color="red", label="Med ymax")
    plot(lowymax_100[:,1], lowymax_100[:,4], color="purple", label="Low ymax")
    xlabel("Autocorrelation")
    ylabel("ShortwNL/ShortwoNL")
    title("Rev/Exp = 1.10")
    tight_layout()
    # return rednoise_shortfall_exptermassets
    savefig(joinpath(abpath(), "figs/timedelay_terminalassetsshortfall.pdf")) 
end 



#figure for weersink lab presentation (showing geometric approach) 
let 
    par1 = FarmBasePar(ymax = 174.0, y0 = 10, p = 6.70, c = 139) 
    par2 = FarmBasePar(ymax = 124.0, y0 = 10, p = 6.70, c = 139) 
    Irange = 0.0:0.01:20.0 
    Yield1 = [yieldIII(I, par1) for I in Irange] 
    MC1 = [margcostIII(I, par1) for I in Irange] 
    AVC1 = [avvarcostIII(I,par1) for I in Irange] 
    Yield2 = [yieldIII(I, par2) for I in Irange] 
    MC2 = [margcostIII(I, par2) for I in Irange] 
    AVC2 = [avvarcostIII(I,par2) for I in Irange] 
    costcurves = figure(figsize=(8,3.5)) 
    subplot(1,2,1) 
    plot(Yield1, MC1, color="blue", label="MC") 
    plot(Yield1, AVC1, color="orange", label="AVC") 
    hlines(par1.p, 0.0, 180.0, colors="black", label = "MR") 
    legend() 
    ylim(0.0, 10.0) 
    xlim(0.0, 180.0) 
    xlabel("Yield (Q)") 
    ylabel("Revenue & Cost") 
    subplot(1,2,2) 
    plot(Yield2, MC2, color="blue", label="MC") 
    plot(Yield2, AVC2, color="orange", label="AVC") 
    hlines(par2.p, 0.0, 180.0, colors="black", label = "MR") 
    legend() 
    ylim(0.0, 10.0) 
    xlim(0.0, 180.0) 
    xlabel("Yield (Q)") 
    ylabel("Revenue & Cost") 
    tight_layout() 
    # return costcurves 
    savefig(joinpath(abpath(), "figs/costcurves_a_weersink.png")) 
end 

let 
    par1 = FarmBasePar(ymax = 174.0, y0 = 10, p = 6.70, c = 139) 
    par2 = FarmBasePar(ymax = 124.0, y0 = 10, p = 6.70, c = 139) 
    Irange = 0.0:0.01:20.0 
    Yrange = 0.0:0.01:180.0 
    Yield1 = [yieldIII(I, par1) for I in Irange] 
    MC1 = [margcostIII(I, par1) for I in Irange] 
    AVC1 = [avvarcostIII(I,par1) for I in Irange] 
    AVCK1 = [avvarcostkickIII(Y, par1, "profit") for Y in Yrange] 
    Yield2 = [yieldIII(I, par2) for I in Irange] 
    MC2 = [margcostIII(I, par2) for I in Irange] 
    AVC2 = [avvarcostIII(I,par2) for I in Irange] 
    AVCK2 = [avvarcostkickIII(Y, par2, "profit") for Y in Yrange] 
    costcurveskick = figure(figsize=(8,3.5)) 
    subplot(1,2,1) 
    # plot(Yield1, MC1, color="blue", label="MC") 
    # plot(Yield1, AVC1, color="orange", label="AVC") 
    plot(Yrange, AVCK1, color="green", label="DAVC") 
    hlines(par1.p, 0.0, 180.0, colors="black", label = "MR") 
    vlines(maxprofitIII_vals(par1)[2], 0.0, 10.0, colors="red", label="Input Decision") 
    legend() 
    ylim(0.0, 10.0) 
    xlim(0.0, 180.0) 
    xlabel("Yield (Q)") 
    ylabel("Revenue & Cost") 
    subplot(1,2,2) 
    # plot(Yield2, MC2, color="blue", label="MC") 
    # plot(Yield2, AVC2, color="orange", label="AVC") 
    plot(Yrange, AVCK2, color="green", label="DAVC") 
    hlines(par2.p, 0.0, 180.0, colors="black", label = "MR") 
    vlines(maxprofitIII_vals(par2)[2], 0.0, 10.0, colors="red", label="Input Decision") 
    legend() 
    ylim(0.0, 10.0) 
    xlim(0.0, 180.0) 
    xlabel("Yield (Q)") 
    ylabel("Revenue & Cost") 
    tight_layout() 
    # return costcurveskick 
    savefig(joinpath(abpath(), "figs/costcurveskick_b_weeksink.png")) 
end


#Figure profit variability (with yield disturbance)

profitvar133 = AVCKslope_revexpcon_data(1.33, 120.0:1.0:180.0)
profitvar110 = AVCKslope_revexpcon_data(1.10, 120.0:1.0:180.0)
profitvar100 = AVCKslope_revexpcon_data(1.00, 120.0:1.0:180.0)
profitvar095 = AVCKslope_revexpcon_data(0.95, 120.0:1.0:180.0)

let 
    ymaxrange = 120.0:1.0:180.0
    profitvarfigure = figure()
    plot(profitvar133[:,1], profitvar133[:,2], color="blue", label="Rev/Exp = 1.33")
    plot(profitvar110[:,1], profitvar110[:,2], color="red", label="Rev/Exp = 1.10")
    plot(profitvar100[:,1], profitvar100[:,2], color="purple", label="Rev/Exp = 1.10")
    plot(profitvar095[:,1], profitvar095[:,2], color="orange", label="Rev/Exp = 0.95")
    xlabel("Ymax")
    ylabel("Profit Variability (DAVC Slope)")
    legend()
    return profitvarfigure
    # savefig(joinpath(abpath(), "figs/profitvarfigure.png")) 
end

#Figure resistance to yield disturbance
resyield133 = AVCK_MC_distance_revexpcon_data(1.33, 120.0:1.0:180.0)
resyield110 = AVCK_MC_distance_revexpcon_data(1.10, 120.0:1.0:180.0)
resyield100 = AVCK_MC_distance_revexpcon_data(1.00, 120.0:1.0:180.0)
resyield095 = AVCK_MC_distance_revexpcon_data(0.95, 120.0:1.0:180.0)

let 
    ymaxrange = 120.0:1.0:180.0
    resyield = figure()
    plot(resyield133[:,1], resyield133[:,2], color="blue", label="Rev/Exp = 1.33")
    plot(resyield110[:,1], resyield110[:,2], color="red", label="Rev/Exp = 1.10")
    plot(resyield100[:,1], resyield100[:,2], color="purple", label="Rev/Exp =1.00")
    plot(resyield095[:,1], resyield095[:,2], color="orange", label="Rev/Exp = 0.95")
    xlabel("Ymax")
    ylabel("Resistance to yield disturbance (Distance between DAVC and Input Decision)")
    legend()
    return resyield
    # savefig(joinpath(abpath(), "figs/resyield.png")) 
end  

#Figure resistance to price and cost disturbance #no change***
respricecost133 = MR_AVC_distance_revexpcon_data(1.33, 120.0:1.0:180.0)
respricecost110 = MR_AVC_distance_revexpcon_data(1.10, 120.0:1.0:180.0)
respricecost100 = MR_AVC_distance_revexpcon_data(1.00, 120.0:1.0:180.0)
respricecost095 = MR_AVC_distance_revexpcon_data(0.95, 120.0:1.0:180.0)

let 
    ymaxrange = 120.0:1.0:180.0
    respricecostfigure = figure()
    plot(respricecost133[:,1], respricecost133[:,2], color="blue", label="Rev/Exp = 1.33")
    plot(respricecost110[:,1], respricecost110[:,2], color="red", label="Rev/Exp = 1.10")
    plot(respricecost100[:,1], respricecost100[:,2], color="purple", label="Rev/Exp =1.00")
    plot(respricecost095[:,1], respricecost095[:,2], color="orange", label="Rev/Exp = 0.95")
    xlabel("Ymax")
    ylabel("Resistance to price and cost (Distance between MR and AVC)")
    legend()
    return respricecostfigure
    # savefig(joinpath(abpath(), "figs/respricecostfigure.png")) 
end 


#Figure resistance to yield, price, and cost disturbance #simular to resistance to price and cost disturbance NO CHANGE
#++
resyieldpricecostpp133 = AVCK_MC_multi_distance_revexpcon_data(1.33, 120.0:1.0:180.0, 0.1, "++")
resyieldpricecostpp110 = AVCK_MC_multi_distance_revexpcon_data(1.10, 120.0:1.0:180.0, 0.1, "++")
resyieldpricecostpp100 = AVCK_MC_multi_distance_revexpcon_data(1.00, 120.0:1.0:180.0, 0.1, "++")
resyieldpricecostpp095 = AVCK_MC_multi_distance_revexpcon_data(0.95, 120.0:1.0:180.0, 0.1, "++")

let 
    ymaxrange = 120.0:1.0:180.0
    resyieldpricecostpp = figure()
    plot(resyieldpricecostpp133[:,1], resyieldpricecostpp133[:,4], color="blue", label="Rev/Exp = 1.33")
    plot(resyieldpricecostpp110[:,1], resyieldpricecostpp110[:,4], color="red", label="Rev/Exp = 1.10")
    # plot(resyieldpricecostpp100[:,1], resyieldpricecostpp100[:,4], color="purple", label="Rev/Exp =1.00")
    plot(resyieldpricecostpp095[:,1], resyieldpricecostpp095[:,4], color="orange", label="Rev/Exp = 0.95")
    xlabel("Ymax")
    ylabel("Resistance to yield, price and cost disturbance")
    legend()
    return resyieldpricecostpp
    # savefig(joinpath(abpath(), "figs/resyieldpricecostpp.png")) 
end

#+-
resyieldpricecostpn133 = AVCK_MC_multi_distance_revexpcon_data(1.33, 120.0:1.0:180.0, 0.1, "+-")
resyieldpricecostpn110 = AVCK_MC_multi_distance_revexpcon_data(1.10, 120.0:1.0:180.0, 0.1, "+-")
resyieldpricecostpn100 = AVCK_MC_multi_distance_revexpcon_data(1.00, 120.0:1.0:180.0, 0.1, "+-")
resyieldpricecostpn095 = AVCK_MC_multi_distance_revexpcon_data(0.95, 120.0:1.0:180.0, 0.1, "+-")

let 
    ymaxrange = 120.0:1.0:180.0
    resyieldpricecostpn = figure()
    plot(resyieldpricecostpn133[:,1], resyieldpricecostpn133[:,4], color="blue", label="Rev/Exp = 1.33")
    plot(resyieldpricecostpn110[:,1], resyieldpricecostpn110[:,4], color="red", label="Rev/Exp = 1.10")
    # plot(resyieldpricecostpn100[:,1], resyieldpricecostpn100[:,4], color="purple", label="Rev/Exp =1.00")
    plot(resyieldpricecostpn095[:,1], resyieldpricecostpn095[:,4], color="orange", label="Rev/Exp = 0.95")
    xlabel("Ymax")
    ylabel("Resistance to yield, price and cost disturbance")
    legend()
    return resyieldpricecostpn
    # savefig(joinpath(abpath(), "figs/resyieldpricecostpn.png")) 
end

#-+
resyieldpricecostnp133 = AVCK_MC_multi_distance_revexpcon_data(1.33, 120.0:1.0:180.0, 0.1, "-+")
resyieldpricecostnp110 = AVCK_MC_multi_distance_revexpcon_data(1.10, 120.0:1.0:180.0, 0.1, "-+")
resyieldpricecostnp100 = AVCK_MC_multi_distance_revexpcon_data(1.00, 120.0:1.0:180.0, 0.1, "-+")
resyieldpricecostnp095 = AVCK_MC_multi_distance_revexpcon_data(0.95, 120.0:1.0:180.0, 0.1, "-+")

let 
    ymaxrange = 120.0:1.0:180.0
    resyieldpricecostnp = figure()
    plot(resyieldpricecostnp133[:,1], resyieldpricecostnp133[:,4], color="blue", label="Rev/Exp = 1.33")
    plot(resyieldpricecostnp110[:,1], resyieldpricecostnp110[:,4], color="red", label="Rev/Exp = 1.10")
    # plot(resyieldpricecostpn100[:,1], resyieldpricecostpn100[:,4], color="purple", label="Rev/Exp =1.00")
    plot(resyieldpricecostnp095[:,1], resyieldpricecostnp095[:,4], color="orange", label="Rev/Exp = 0.95")
    xlabel("Ymax")
    ylabel("Resistance to yield, price and cost disturbance")
    legend()
    return resyieldpricecostnp
    # savefig(joinpath(abpath(), "figs/resyieldpricecostnp.png")) 
end

#--
resyieldpricecostnn133 = AVCK_MC_multi_distance_revexpcon_data(1.33, 120.0:1.0:180.0, 0.1, "--")
resyieldpricecostnn110 = AVCK_MC_multi_distance_revexpcon_data(1.10, 120.0:1.0:180.0, 0.1, "--")
resyieldpricecostnn100 = AVCK_MC_multi_distance_revexpcon_data(1.00, 120.0:1.0:180.0, 0.1, "--")
resyieldpricecostnn095 = AVCK_MC_multi_distance_revexpcon_data(0.95, 120.0:1.0:180.0, 0.1, "--")

let 
    ymaxrange = 120.0:1.0:180.0
    resyieldpricecostnn = figure()
    plot(resyieldpricecostnn133[:,1], resyieldpricecostnn133[:,4], color="blue", label="Rev/Exp = 1.33")
    plot(resyieldpricecostnn110[:,1], resyieldpricecostnn110[:,4], color="red", label="Rev/Exp = 1.10")
    # plot(resyieldpricecostpn100[:,1], resyieldpricecostpn100[:,4], color="purple", label="Rev/Exp =1.00")
    plot(resyieldpricecostnn095[:,1], resyieldpricecostnn095[:,4], color="orange", label="Rev/Exp = 0.95")
    xlabel("Ymax")
    ylabel("Resistance to yield, price and cost disturbance")
    legend()
    return resyieldpricecostnn
    # savefig(joinpath(abpath(), "figs/resyieldpricecostnn.png")) 
end
