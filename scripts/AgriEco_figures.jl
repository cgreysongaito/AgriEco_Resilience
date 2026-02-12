include("packages.jl")
include("AgriEco_commoncode.jl")

#Data

revexpcurve108_lowymax_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/revexpcurve108_lowymax_posfeed_data33to08.csv"), DataFrame))
revexpcurve108_medymax_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/revexpcurve108_medymax_posfeed_data33to08.csv"), DataFrame))
revexpcurve108_highymax_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/revexpcurve108_highymax_posfeed_data33to08.csv"), DataFrame))
revexpcurve133_lowymax_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/revexpcurve133_lowymax_posfeed_data33to08.csv"), DataFrame))
revexpcurve133_medymax_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/revexpcurve133_medymax_posfeed_data33to08.csv"), DataFrame))
revexpcurve133_highymax_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/revexpcurve133_highymax_posfeed_data33to08.csv"), DataFrame))

revexpcurve108_lowymax_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/revexpcurve108_lowymax_timedelay_data33to08.csv"), DataFrame))
revexpcurve108_medymax_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/revexpcurve108_medymax_timedelay_data33to08.csv"), DataFrame))
revexpcurve108_highymax_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/revexpcurve108_highymax_timedelay_data33to08.csv"), DataFrame))
revexpcurve133_lowymax_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/revexpcurve133_lowymax_timedelay_data33to08.csv"), DataFrame))
revexpcurve133_medymax_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/revexpcurve133_medymax_timedelay_data33to08.csv"), DataFrame))
revexpcurve133_highymax_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/revexpcurve133_highymax_timedelay_data33to08.csv"), DataFrame))

##Figure 2 Schematic
let 
    Irange = 0.0:0.01:20.0
    datahYmaxhyo = [yieldIII(I, 174.0, 10) for I in Irange]
    Ymaxrange = 140.0:1.0:210.0
    I0data133rel = [calc_I0(1.33, Ymax, EconomicPar()) for Ymax in Ymaxrange]
    I0data108rel = [calc_I0(1.08, Ymax, EconomicPar()) for Ymax in Ymaxrange]
    figure2schematicprep = figure(figsize = (5,6.5))
    subplot(2,1,1)
    plot(Irange, datahYmaxhyo, color = "black", linewidth = 3)
    xlabel("Inputs", fontsize = 20)
    ylabel("Yield", fontsize = 20)
    xticks([])
    yticks([])
    ylim(0.0, 180.0)
    subplot(2,1,2)
    plot(1 ./ I0data133rel, Ymaxrange, linestyle="solid", color="black", label="rev/exp = 1.33")
    plot(1 ./ I0data108rel, Ymaxrange, linestyle="dotted", color="black", label="rev/exp = 1.08")
    xlabel("1/I0", fontsize = 20)
    ylabel("Ymax", fontsize = 20)
    # xticks([])
    # yticks([])
    tight_layout()
    # return figure2schematicprep
    savefig(joinpath(abpath(), "figs/figure2schematicprep.pdf"))
end

## Positive feedbacks ##
#Figure 3
#Expected terminal assets residual (along rel profits curve)
let 
    lowymax_108 = expectedterminalassets_residual(revexpcurve108_lowymax_posfeed_data)
    medymax_108 = expectedterminalassets_residual(revexpcurve108_medymax_posfeed_data)
    highymax_108 = expectedterminalassets_residual(revexpcurve108_highymax_posfeed_data)
    lowymax_133 = expectedterminalassets_residual(revexpcurve133_lowymax_posfeed_data)
    medymax_133 = expectedterminalassets_residual(revexpcurve133_medymax_posfeed_data)
    highymax_133 = expectedterminalassets_residual(revexpcurve133_highymax_posfeed_data)
    posfeed_etaresidual_alongrelprof = figure(figsize=(4,6))    
    subplot(2,1,1)
    plot(lowymax_108[:,1], lowymax_108[:,2], linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_108[:,1], medymax_108[:,2], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_108[:,1], highymax_108[:,2], linestyle="dotted", color="black", label="High Ymax")
    title("1.08", fontsize=15)
    xlabel("Noise correlation", fontsize = 15)
    ylabel("EFAwNL - EFAwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    subplot(2,1,2)
    plot(lowymax_133[:,1], lowymax_133[:,2], linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_133[:,1], medymax_133[:,2], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_133[:,1], highymax_133[:,2], linestyle="dotted", color="black", label="High Ymax")
    title("1.33", fontsize=15)
    xlabel("Noise correlation", fontsize = 15)
    ylabel("EFAwNL - EFAwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    tight_layout()
    return posfeed_etaresidual_alongrelprof
    # savefig(joinpath(abpath(), "figs/posfeed_etaresidual_alongrelprof.pdf")) 
end

# let #ETA residual standardized by yield
#     YmaxI0valslow = calcYmaxI0vals_Ymaxrelprof(150, [1.08,1.33], EconomicPar())
#     YmaxI0valsmed = calcYmaxI0vals_Ymaxrelprof(174, [1.08,1.33], EconomicPar())
#     YmaxI0valshigh = calcYmaxI0vals_Ymaxrelprof(200, [1.08,1.33], EconomicPar())
#     inputsyieldlow108 = maxprofitIII_vals(YmaxI0valslow[1,1], YmaxI0valslow[1,2], EconomicPar())
#     inputsyieldlow133 = maxprofitIII_vals(YmaxI0valslow[2,1], YmaxI0valslow[2,2], EconomicPar())
#     inputsyieldmed108 = maxprofitIII_vals(YmaxI0valsmed[1,1], YmaxI0valsmed[1,2], EconomicPar())
#     inputsyieldmed133 = maxprofitIII_vals(YmaxI0valsmed[2,1], YmaxI0valsmed[2,2], EconomicPar())
#     inputsyieldhigh108 = maxprofitIII_vals(YmaxI0valshigh[1,1], YmaxI0valshigh[1,2], EconomicPar())
#     inputsyieldhigh133 = maxprofitIII_vals(YmaxI0valshigh[2,1], YmaxI0valshigh[2,2], EconomicPar())
#     lowymax_108 = expectedterminalassets_residualstandyield(revexpcurve108_lowymax_posfeed_data, inputsyieldlow108[2])
#     medymax_108 = expectedterminalassets_residualstandyield(revexpcurve108_medymax_posfeed_data, inputsyieldmed108[2])
#     highymax_108 = expectedterminalassets_residualstandyield(revexpcurve108_highymax_posfeed_data, inputsyieldhigh108[2])
#     lowymax_133 = expectedterminalassets_residualstandyield(revexpcurve133_lowymax_posfeed_data, inputsyieldlow133[2])
#     medymax_133 = expectedterminalassets_residualstandyield(revexpcurve133_medymax_posfeed_data, inputsyieldmed133[2])
#     highymax_133 = expectedterminalassets_residualstandyield(revexpcurve133_highymax_posfeed_data, inputsyieldhigh133[2])
#     posfeed_etaresidual_alongrelprof = figure(figsize=(4,6))    
#     subplot(2,1,1)
#     plot(lowymax_108[:,1], lowymax_108[:,2], linestyle="solid", color="black", label="Low Ymax")
#     plot(medymax_108[:,1], medymax_108[:,2], linestyle="dashed", color="black", label="Med Ymax")
#     plot(highymax_108[:,1], highymax_108[:,2], linestyle="dotted", color="black", label="High Ymax")
#     title("1.08", fontsize=15)
#     xlabel("Noise correlation", fontsize = 15)
#     ylabel("(EFAwNL - EFAwoNL)/Yield", fontsize = 15)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     legend()
#     subplot(2,1,2)
#     plot(lowymax_133[:,1], lowymax_133[:,2], linestyle="solid", color="black", label="Low Ymax")
#     plot(medymax_133[:,1], medymax_133[:,2], linestyle="dashed", color="black", label="Med Ymax")
#     plot(highymax_133[:,1], highymax_133[:,2], linestyle="dotted", color="black", label="High Ymax")
#     title("1.33", fontsize=15)
#     xlabel("Noise correlation", fontsize = 15)
#     ylabel("(EFAwNL - EFAwoNL)/Yield", fontsize = 15)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     legend()
#     tight_layout()
#     return posfeed_etaresidual_alongrelprof
#     # savefig(joinpath(abpath(), "figs/posfeed_etaresidual_alongrelprof.pdf")) 
# end

#Figure 4 Amplification or muting of white to reddened noise with positive feedback
#Variability along revenue/expenses curve
let 
    lowymax_108 = variabilityterminalassets_rednoise(revexpcurve108_lowymax_posfeed_data)
    medymax_108 = variabilityterminalassets_rednoise(revexpcurve108_medymax_posfeed_data)
    highymax_108 = variabilityterminalassets_rednoise(revexpcurve108_highymax_posfeed_data)
    lowymax_133 = variabilityterminalassets_rednoise(revexpcurve133_lowymax_posfeed_data)
    medymax_133 = variabilityterminalassets_rednoise(revexpcurve133_medymax_posfeed_data)
    highymax_133 = variabilityterminalassets_rednoise(revexpcurve133_highymax_posfeed_data)
    posfeed_var_alongrelprofcurve = figure(figsize=(4,6))    
    subplot(2,1,1)
    plot(lowymax_108[:,1], lowymax_108[:,4].+0.001, linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_108[:,1], medymax_108[:,4], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_108[:,1], highymax_108[:,4].-0.001, linestyle="dotted", color="black", label="High Ymax")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwNL/CVwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    ylim(1.02,1.15)
    title("Relative Profits = 1.08")
    legend()
    subplot(2,1,2)
    plot(lowymax_133[:,1], lowymax_133[:,4].+0.001, linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_133[:,1], medymax_133[:,4], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_133[:,1], highymax_133[:,4].-0.001, linestyle="dotted", color="black", label="High Ymax")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwNL/CVwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    ylim(1.02,1.15)
    title("Relative Profits = 1.33")
    legend()
    tight_layout()
    return posfeed_var_alongrelprofcurve
    # savefig(joinpath(abpath(), "figs/posfeed_var_alongrelprofcurve.pdf")) 
end 

#Figure 5 Resistance to yield disturbance
let 
    YmaxI0vals = calcYmaxI0vals_Ymaxrelprof(174, [1.08,1.33], EconomicPar())
    inputsyield1 = maxprofitIII_vals(YmaxI0vals[1,1], YmaxI0vals[1,2], EconomicPar())
    inputsyield2 = maxprofitIII_vals(YmaxI0vals[2,1], YmaxI0vals[2,2], EconomicPar())
    Irange = 0.0:0.01:20.0
    Yrange = 0.0:0.1:180.0
    Yield1 = [yieldIII(I, YmaxI0vals[1,1], YmaxI0vals[1,2]) for I in Irange]
    MC1 = [margcostIII(I, YmaxI0vals[1,1], YmaxI0vals[1,2], EconomicPar()) for I in Irange]
    DAVC1 = [avvarcostkickIII(inputsyield1[1], Y, EconomicPar()) for Y in Yrange]
    Yield2 = [yieldIII(I, YmaxI0vals[2,1], YmaxI0vals[2,2]) for I in Irange]
    MC2 = [margcostIII(I, YmaxI0vals[2,1], YmaxI0vals[2,2], EconomicPar()) for I in Irange]
    DAVC2 = [avvarcostkickIII(inputsyield2[1], Y, EconomicPar()) for Y in Yrange]
    lowYmax = AVCK_MC_distance_ymaxrelprofcurve_data(150, 1.08:0.01:1.33, 0.02, EconomicPar())
    medYmax = AVCK_MC_distance_ymaxrelprofcurve_data(174, 1.08:0.01:1.33, 0.02, EconomicPar())
    highYmax = AVCK_MC_distance_ymaxrelprofcurve_data(200, 1.08:0.01:1.33, 0.02, EconomicPar())
    yielddisturbanceresistance = figure(figsize=(10,8))
    subplot(2,2,1)
    plot(Yield1, MC1, color="#238A8DFF", label="Marginal Costs", linewidth = 3)
    hlines(EconomicPar().p, 0.0, 174.0, colors="#FDE725FF", label = "Marginal Revenue", linewidth = 3)
    plot(Yrange, DAVC1, color="#404788FF", label = "Noise Average Variable Costs", linewidth = 3)
    vlines(inputsyield1[2], 0.0, 10.0, colors="black", linestyle="dashed", linewidth=2)
    ylim(0.0, 10.0)
    xlim(0.0, 174.0)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    xlabel("Yield", fontsize = 15)
    ylabel("Revenue & Cost", fontsize = 15)
    subplot(2,2,2)
    plot(Yield2, MC2, color="#238A8DFF", label="Marginal Costs", linewidth = 3)
    hlines(EconomicPar().p, 0.0, 174.0, colors="#FDE725FF", label = "Marginal Revenue", linewidth = 3)
    plot(Yrange, DAVC2, color="#404788FF", label = "Noise Average Variable Costs", linewidth = 3)
    vlines(inputsyield2[2], 0.0, 10.0, colors="black", linestyle="dashed", linewidth=2)
    ylim(0.0, 10.0)
    xlim(0.0, 174.0)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    xlabel("Yield", fontsize = 15)
    ylabel("Revenue & Cost", fontsize = 15)
    subplot(2,2,3)
    plot(lowYmax[:,1], lowYmax[:,3].+0.07, linestyle="solid", color="black", label="Low Ymax",linewidth = 3)
    plot(medYmax[:,1], medYmax[:,3], linestyle="dashed", color="black", label="Med Ymax",linewidth = 3)
    plot(highYmax[:,1], highYmax[:,3].-0.07, linestyle="dotted", color="black", label="High Ymax", linewidth = 3)
    xlabel("Relative Profits", fontsize = 15)
    ylabel("Standardized \nResistance to yield disturbance", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    tight_layout()
    return yielddisturbanceresistance
    # savefig(joinpath(abpath(), "figs/yielddisturbanceresistance_relprofcurve.pdf"))
end 

## Time Delay ##
#Figure 6
#Expected final assets residuals along the relative profits curves
let 
    lowymax_108 = expectedterminalassets_residual(revexpcurve108_lowymax_timedelay_data)
    medymax_108 = expectedterminalassets_residual(revexpcurve108_medymax_timedelay_data)
    highymax_108 = expectedterminalassets_residual(revexpcurve108_highymax_timedelay_data)
    lowymax_133 = expectedterminalassets_residual(revexpcurve133_lowymax_timedelay_data)
    medymax_133 = expectedterminalassets_residual(revexpcurve133_medymax_timedelay_data)
    highymax_133 = expectedterminalassets_residual(revexpcurve133_highymax_timedelay_data)
    timedelay_etaresidual_alongrelprofitcurve = figure(figsize=(4,6))    
    subplot(2,1,1)
    plot(lowymax_108[:,1], lowymax_108[:,2], linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_108[:,1], medymax_108[:,2], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_108[:,1], highymax_108[:,2], linestyle="dotted", color="black", label="High Ymax")
    title("1.08", fontsize=15)
    xlabel("Noise correlation", fontsize = 15)
    ylabel("EFAwNL - EFAwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    ylim(-400,850)
    legend()
    subplot(2,1,2)
    plot(lowymax_133[:,1], lowymax_133[:,2], linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_133[:,1], medymax_133[:,2], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_133[:,1], highymax_133[:,2], linestyle="dotted", color="black", label="High Ymax")
    title("1.33", fontsize=15)
    xlabel("Noise correlation", fontsize = 15)
    ylabel("EFAwNL - EFAwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    ylim(-400,850)
    legend()
    tight_layout()
    return timedelay_etaresidual_alongrelprofitcurve
    # savefig(joinpath(abpath(), "figs/timedelay_etaresidual_alongrelprofitcurve.pdf")) 
end

# let #standardize residuals by EFAnoNL
#     lowymax_108 = expectedterminalassets_residualstand(revexpcurve108_lowymax_timedelay_data)
#     medymax_108 = expectedterminalassets_residualstand(revexpcurve108_medymax_timedelay_data)
#     highymax_108 = expectedterminalassets_residualstand(revexpcurve108_highymax_timedelay_data)
#     lowymax_133 = expectedterminalassets_residualstand(revexpcurve133_lowymax_timedelay_data)
#     medymax_133 = expectedterminalassets_residualstand(revexpcurve133_medymax_timedelay_data)
#     highymax_133 = expectedterminalassets_residualstand(revexpcurve133_highymax_timedelay_data)
#     timedelay_etaresidual_alongrelprofitcurve = figure(figsize=(4,6))    
#     subplot(2,1,1)
#     plot(lowymax_108[:,1], lowymax_108[:,2], linestyle="solid", color="black", label="Low Ymax")
#     plot(medymax_108[:,1], medymax_108[:,2], linestyle="dashed", color="black", label="Med Ymax")
#     plot(highymax_108[:,1], highymax_108[:,2], linestyle="dotted", color="black", label="High Ymax")
#     title("1.08", fontsize=15)
#     xlabel("Noise correlation", fontsize = 15)
#     ylabel("(EFAwNL - EFAwoNL)/EFAwoNL", fontsize = 15)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     # ylim(-400,850)
#     legend()
#     subplot(2,1,2)
#     plot(lowymax_133[:,1], lowymax_133[:,2], linestyle="solid", color="black", label="Low Ymax")
#     plot(medymax_133[:,1], medymax_133[:,2], linestyle="dashed", color="black", label="Med Ymax")
#     plot(highymax_133[:,1], highymax_133[:,2], linestyle="dotted", color="black", label="High Ymax")
#     title("1.33", fontsize=15)
#     xlabel("Noise correlation", fontsize = 15)
#     ylabel("(EFAwNL - EFAwoNL)/EFAwoNL", fontsize = 15)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     # ylim(-400,850)
#     legend()
#     tight_layout()
#     return timedelay_etaresidual_alongrelprofitcurve
#     # savefig(joinpath(abpath(), "figs/timedelay_etaresidual_alongrelprofitcurve.pdf")) 
# end

# let #attempt to standardize residuals by yield - but problem with also dividing the 
#     YmaxI0valslow = calcYmaxI0vals_Ymaxrelprof(150, [1.08,1.33], EconomicPar())
#     YmaxI0valsmed = calcYmaxI0vals_Ymaxrelprof(174, [1.08,1.33], EconomicPar())
#     YmaxI0valshigh = calcYmaxI0vals_Ymaxrelprof(200, [1.08,1.33], EconomicPar())
#     inputsyieldlow108 = maxprofitIII_vals(YmaxI0valslow[1,1], YmaxI0valslow[1,2], EconomicPar())
#     inputsyieldlow133 = maxprofitIII_vals(YmaxI0valslow[2,1], YmaxI0valslow[2,2], EconomicPar())
#     inputsyieldmed108 = maxprofitIII_vals(YmaxI0valsmed[1,1], YmaxI0valsmed[1,2], EconomicPar())
#     inputsyieldmed133 = maxprofitIII_vals(YmaxI0valsmed[2,1], YmaxI0valsmed[2,2], EconomicPar())
#     inputsyieldhigh108 = maxprofitIII_vals(YmaxI0valshigh[1,1], YmaxI0valshigh[1,2], EconomicPar())
#     inputsyieldhigh133 = maxprofitIII_vals(YmaxI0valshigh[2,1], YmaxI0valshigh[2,2], EconomicPar())
#     lowymax_108 = expectedterminalassets_residualstandyield(revexpcurve108_lowymax_timedelay_data, inputsyieldlow108[2])
#     medymax_108 = expectedterminalassets_residualstandyield(revexpcurve108_medymax_timedelay_data, inputsyieldmed108[2]) 
#     highymax_108 = expectedterminalassets_residualstandyield(revexpcurve108_highymax_timedelay_data, inputsyieldhigh108[2]) 
#     lowymax_133 = expectedterminalassets_residualstandyield(revexpcurve133_lowymax_timedelay_data, inputsyieldlow133[2]) 
#     medymax_133 = expectedterminalassets_residualstandyield(revexpcurve133_medymax_timedelay_data, inputsyieldmed133[2]) 
#     highymax_133 = expectedterminalassets_residualstandyield(revexpcurve133_highymax_timedelay_data, inputsyieldhigh133[2]) 
#     timedelay_etaresidual_alongrelprofitcurve = figure(figsize=(4,6))    
#     subplot(2,1,1)
#     plot(lowymax_108[:,1], lowymax_108[:,2], linestyle="solid", color="black", label="Low Ymax")
#     plot(medymax_108[:,1], medymax_108[:,2], linestyle="dashed", color="black", label="Med Ymax")
#     plot(highymax_108[:,1], highymax_108[:,2], linestyle="dotted", color="black", label="High Ymax")
#     title("1.08", fontsize=15)
#     xlabel("Noise correlation", fontsize = 15)
#     ylabel("(EFAwNL - EFAwoNL)/Yield", fontsize = 15)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     # ylim(-400,850)
#     legend()
#     subplot(2,1,2)
#     plot(lowymax_133[:,1], lowymax_133[:,2], linestyle="solid", color="black", label="Low Ymax")
#     plot(medymax_133[:,1], medymax_133[:,2], linestyle="dashed", color="black", label="Med Ymax")
#     plot(highymax_133[:,1], highymax_133[:,2], linestyle="dotted", color="black", label="High Ymax")
#     title("1.33", fontsize=15)
#     xlabel("Noise correlation", fontsize = 15)
#     ylabel("(EFAwNL - EFAwoNL)/Yield", fontsize = 15)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     # ylim(-400,850)
#     legend()
#     tight_layout()
#     return timedelay_etaresidual_alongrelprofitcurve
#     # savefig(joinpath(abpath(), "figs/timedelay_etaresidual_alongrelprofitcurve.pdf")) 
# end


#Figure 7 Amplification or muting of white to reddened noise with time delay
#Variability along relative profits curves
let 
    lowymax_108 = variabilityterminalassets_rednoise(revexpcurve108_lowymax_timedelay_data)
    medymax_108 = variabilityterminalassets_rednoise(revexpcurve108_medymax_timedelay_data)
    highymax_108 = variabilityterminalassets_rednoise(revexpcurve108_highymax_timedelay_data)
    lowymax_133 = variabilityterminalassets_rednoise(revexpcurve133_lowymax_timedelay_data)
    medymax_133 = variabilityterminalassets_rednoise(revexpcurve133_medymax_timedelay_data)
    highymax_133 = variabilityterminalassets_rednoise(revexpcurve133_highymax_timedelay_data)
    timedelay_var_alongrelprofcurve = figure(figsize=(4,6))    
    subplot(2,1,1)
    plot(lowymax_108[:,1], lowymax_108[:,4].+0.0017, linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_108[:,1], medymax_108[:,4], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_108[:,1], highymax_108[:,4].-0.0017, linestyle="dotted", color="black", label="High Ymax")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwNL/CVwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    ylim(0.80,1.05)
    title("Relative Profits = 1.08")
    legend()
    subplot(2,1,2)
    plot(lowymax_133[:,1], lowymax_133[:,4].+0.0017, linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_133[:,1], medymax_133[:,4], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_133[:,1], highymax_133[:,4].-0.0017, linestyle="dotted", color="black", label="High Ymax")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwNL/CVwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    ylim(0.80,1.05)
    title("Relative Profits = 1.33")
    legend()
    tight_layout()
    return timedelay_var_alongrelprofcurve
    # savefig(joinpath(abpath(), "figs/timedelay_var_alongrelprofcurve.pdf")) 
end

# Figure 8 - Resistance to error
let 
    YmaxI0vals = calcYmaxI0vals_Ymaxrelprof(174, [1.08,1.33], EconomicPar())
    inputsyield1 = maxprofitIII_vals(YmaxI0vals[1,1], YmaxI0vals[1,2], EconomicPar())
    inputsyield2 = maxprofitIII_vals(YmaxI0vals[2,1], YmaxI0vals[2,2], EconomicPar())
    Irange = 0.0:0.01:20.0
    Yrange = 0.0:0.1:180.0
    Yield1 = [yieldIII(I, YmaxI0vals[1,1], YmaxI0vals[1,2]) for I in Irange]
    MC1 = [margcostIII(I, YmaxI0vals[1,1], YmaxI0vals[1,2], EconomicPar()) for I in Irange]
    AVC1 = [avvarcostIII(I, YmaxI0vals[1,1], YmaxI0vals[1,2], EconomicPar()) for I in Irange]
    Yield2 = [yieldIII(I, YmaxI0vals[2,1], YmaxI0vals[2,2]) for I in Irange]
    MC2 = [margcostIII(I, YmaxI0vals[2,1], YmaxI0vals[2,2], EconomicPar()) for I in Irange]
    AVC2 = [avvarcostIII(I, YmaxI0vals[2,1], YmaxI0vals[2,2], EconomicPar()) for I in Irange]
    lowYmax = AVCmin_MR_distance_ymaxrelprofcurve_data(150, 1.08:0.01:1.33, Irange, EconomicPar())
    medYmax = AVCmin_MR_distance_ymaxrelprofcurve_data(174, 1.08:0.01:1.33, Irange, EconomicPar())
    highYmax = AVCmin_MR_distance_ymaxrelprofcurve_data(180, 1.08:0.01:1.33, Irange, EconomicPar())
    errorresistance = figure(figsize=(10,8))
    subplot(2,2,1)
    plot(Yield1, MC1, color="#238A8DFF", label="Marginal Costs", linewidth = 3)
    plot(Yield1, AVC1, color="#404788FF", label="Average Variable Costs", linewidth = 3)
    hlines(EconomicPar().p, 0.0, 174.0, colors="#FDE725FF", label = "Marginal Revenue", linewidth = 3)
    vlines(inputsyield1[2], 0.0, 10.0, colors="black", linestyle="dashed", linewidth=2)
    ylim(0.0, 10.0)
    xlim(0.0, 174.0)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    xlabel("Yield", fontsize = 15)
    ylabel("Revenue & Cost", fontsize = 15)
    subplot(2,2,2)
    plot(Yield2, MC2, color="#238A8DFF", label="Marginal Costs", linewidth = 3)
    plot(Yield2, AVC2, color="#404788FF", label="Average Variable Costs", linewidth = 3)
    hlines(EconomicPar().p, 0.0, 174.0, colors="#FDE725FF", label = "Marginal Revenue", linewidth = 3)
    vlines(inputsyield2[2], 0.0, 10.0, colors="black", linestyle="dashed", linewidth=2)
    ylim(0.0, 10.0)
    xlim(0.0, 174.0)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    xlabel("Yield", fontsize = 15)
    ylabel("Revenue & Cost", fontsize = 15)
    subplot(2,2,3)
    plot(lowYmax[:,1], lowYmax[:,2].+0.008, linestyle="solid", color="black", label="Low Ymax",linewidth = 3)
    plot(medYmax[:,1], medYmax[:,2], linestyle="dashed", color="black",label="Medium Ymax", linewidth = 3)
    plot(highYmax[:,1], highYmax[:,2].-0.008, linestyle="dotted", color="black", label="High Ymax", linewidth = 3)
    xlabel("Relative Profits", fontsize = 15)
    ylabel("Resistance to error", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    tight_layout()
    return errorresistance
    # savefig(joinpath(abpath(), "figs/errorresistance_relprofcurveymax.pdf"))
end 

# let 
#     YmaxI0vals_low = calcYmaxI0vals_Ymaxrelprof(150, [1.08,1.33], EconomicPar())
#     YmaxI0vals_high = calcYmaxI0vals_Ymaxrelprof(200, [1.08,1.33], EconomicPar())
#     inputsyieldlow1 = maxprofitIII_vals(YmaxI0vals_low[1,1], YmaxI0vals_low[1,2], EconomicPar())
#     inputsyieldlow2 = maxprofitIII_vals(YmaxI0vals_low[2,1], YmaxI0vals_low[2,2], EconomicPar())
#     inputsyieldhigh1 = maxprofitIII_vals(YmaxI0vals_high[1,1], YmaxI0vals_high[1,2], EconomicPar())
#     inputsyieldhigh2 = maxprofitIII_vals(YmaxI0vals_high[2,1], YmaxI0vals_high[2,2], EconomicPar())
#     Irange = 0.0:0.01:20.0
#     Yrange = 0.0:0.1:180.0
#     Yieldlow1 = [yieldIII(I, YmaxI0vals_low[1,1], YmaxI0vals_low[1,2]) for I in Irange]
#     MClow1 = [margcostIII(I, YmaxI0vals_low[1,1], YmaxI0vals_low[1,2], EconomicPar()) for I in Irange]
#     AVClow1 = [avvarcostIII(I, YmaxI0vals_low[1,1], YmaxI0vals_low[1,2], EconomicPar()) for I in Irange]
#     Yieldlow2 = [yieldIII(I, YmaxI0vals_low[2,1], YmaxI0vals_low[2,2]) for I in Irange]
#     MClow2 = [margcostIII(I, YmaxI0vals_low[2,1], YmaxI0vals_low[2,2], EconomicPar()) for I in Irange]
#     AVClow2 = [avvarcostIII(I, YmaxI0vals_low[2,1], YmaxI0vals_low[2,2], EconomicPar()) for I in Irange]
#     Yieldhigh1 = [yieldIII(I, YmaxI0vals_high[1,1], YmaxI0vals_high[1,2]) for I in Irange]
#     MChigh1 = [margcostIII(I, YmaxI0vals_high[1,1], YmaxI0vals_high[1,2], EconomicPar()) for I in Irange]
#     AVChigh1 = [avvarcostIII(I, YmaxI0vals_high[1,1], YmaxI0vals_high[1,2], EconomicPar()) for I in Irange]
#     Yieldhigh2 = [yieldIII(I, YmaxI0vals_high[2,1], YmaxI0vals_high[2,2]) for I in Irange]
#     MChigh2 = [margcostIII(I, YmaxI0vals_high[2,1], YmaxI0vals_high[2,2], EconomicPar()) for I in Irange]
#     AVChigh2 = [avvarcostIII(I, YmaxI0vals_high[2,1], YmaxI0vals_high[2,2], EconomicPar()) for I in Irange]
#     errorresistance = figure(figsize=(10,8))
#     subplot(2,2,1)
#     plot(Yieldlow1, MClow1, color="#238A8DFF", label="Marginal Costs", linewidth = 3)
#     plot(Yieldlow1, AVClow1, color="#404788FF", label="Average Variable Costs", linewidth = 3)
#     hlines(EconomicPar().p, 0.0, 174.0, colors="#FDE725FF", label = "Marginal Revenue", linewidth = 3)
#     hlines(minimum(filter(!isnan, AVClow1)), 0.0, 174.0, colors="black", linestyle="dashed", linewidth = 2)
#     vlines(inputsyieldlow1[2], 0.0, 10.0, colors="black", linestyle="dashed", linewidth=2)
#     ylim(0.0, 10.0)
#     xlim(0.0, 174.0)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     title("Low Ymax", fontsize=15)
#     legend()
#     xlabel("Yield", fontsize = 15)
#     ylabel("Revenue & Cost", fontsize = 15)
#     subplot(2,2,2)
#     plot(Yieldhigh1, MChigh1, color="#238A8DFF", label="Marginal Costs", linewidth = 3)
#     plot(Yieldhigh1, AVChigh1, color="#404788FF", label="Average Variable Costs", linewidth = 3)
#     hlines(EconomicPar().p, 0.0, 174.0, colors="#FDE725FF", label = "Marginal Revenue", linewidth = 3)
#     hlines(minimum(filter(!isnan, AVChigh1)), 0.0, 174.0, colors="black", linestyle="dashed", linewidth = 2)
#     vlines(inputsyieldhigh1[2], 0.0, 10.0, colors="black", linestyle="dashed", linewidth=2)
#     ylim(0.0, 10.0)
#     xlim(0.0, 174.0)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     legend()
#     xlabel("Yield", fontsize = 15)
#     ylabel("Revenue & Cost", fontsize = 15)
#     title("High Ymax", fontsize=15)
#     subplot(2,2,3)
#     plot(Yieldlow2, MClow2, color="#238A8DFF", label="Marginal Costs", linewidth = 3)
#     plot(Yieldlow2, AVClow2, color="#404788FF", label="Average Variable Costs", linewidth = 3)
#     hlines(EconomicPar().p, 0.0, 174.0, colors="#FDE725FF", label = "Marginal Revenue", linewidth = 3)
#     hlines(minimum(filter(!isnan, AVClow2)), 0.0, 174.0, colors="black", linestyle="dashed", linewidth = 2)
#     vlines(inputsyieldlow2[2], 0.0, 10.0, colors="black", linestyle="dashed", linewidth=2)
#     ylim(0.0, 10.0)
#     xlim(0.0, 174.0)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     legend()
#     xlabel("Yield", fontsize = 15)
#     ylabel("Revenue & Cost", fontsize = 15)
#     subplot(2,2,4)
#     plot(Yieldhigh2, MChigh2, color="#238A8DFF", label="Marginal Costs", linewidth = 3)
#     plot(Yieldhigh2, AVChigh2, color="#404788FF", label="Average Variable Costs", linewidth = 3)
#     hlines(EconomicPar().p, 0.0, 174.0, colors="#FDE725FF", label = "Marginal Revenue", linewidth = 3)
#     hlines(minimum(filter(!isnan, AVChigh2)), 0.0, 174.0, colors="black", linestyle="dashed", linewidth = 2)
#     vlines(inputsyieldhigh2[2], 0.0, 10.0, colors="black", linestyle="dashed", linewidth=2)
#     ylim(0.0, 10.0)
#     xlim(0.0, 174.0)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     legend()
#     xlabel("Yield", fontsize = 15)
#     ylabel("Revenue & Cost", fontsize = 15)
#     tight_layout()
#     return errorresistance
#     # savefig(joinpath(abpath(), "figs/errorresistance_relprofcurveymax.pdf"))
# end 

### Supporting Information
include("AgriEco_supportinginformation.jl")

#Maintaining geometry while changing I₀ and c
let 
    newI0 = 2500
    newc = calc_c(1.08, 174, newI0, EconomicPar())
    inputsyield1 = maxprofitIII_vals(174, 0.25, EconomicPar())
    inputsyield2 = maxprofitIII_vals(174, 2500, EconomicPar(c=newc))
    Irange = 0.0:0.01:200.0
    Yield1 = [yieldIII(I, 174, 0.25) for I in Irange]
    MC1 = [margcostIII(I, 174, 0.25, EconomicPar()) for I in Irange]
    AVC1 = [avvarcostIII(I, 174, 0.25, EconomicPar()) for I in Irange]
    Yield2 = [yieldIII(I, 174, newI0) for I in Irange]
    MC2 = [margcostIII(I, 174, newI0, EconomicPar(c=newc)) for I in Irange]
    AVC2 = [avvarcostIII(I, 174, newI0, EconomicPar(c=newc)) for I in Irange]
    costcurves = figure(figsize=(5,6))
    subplot(2,1,1)
    plot(Yield1, MC1, color="#238A8DFF", label="Marginal Costs", linewidth = 3)
    plot(Yield1, AVC1, color="#404788FF", label="Average Variable Costs", linewidth = 3)
    hlines(EconomicPar().p, 0.0, 180.0, colors="#FDE725FF", label = "Marginal Revenue", linewidth = 3)
    vlines(inputsyield1[2], 0.0, 10.0, colors="black", linestyle="dashed", linewidth=2)
    legend()
    ylim(0.0, 10.0)
    xlim(0.0, 180.0)
    xticks(fontsize=12)
    yticks(fontsize=12)
    xlabel("Yield", fontsize = 15)
    ylabel("Revenue & Cost", fontsize = 15)
    subplot(2,1,2)
    plot(Yield2, MC2, color="#238A8DFF", label="Marginal Costs", linewidth = 3)
    plot(Yield2, AVC2, color="#404788FF", label="Average Variable Costs", linewidth = 3)
    hlines(EconomicPar().p, 0.0, 180.0, colors="#FDE725FF", label = "Marginal Revenue", linewidth = 3)
    vlines(inputsyield2[2], 0.0, 10.0, colors="black", linestyle="dashed", linewidth=2)
    legend()
    ylim(0.0, 10.0)
    xlim(0.0, 180.0)
    xticks(fontsize=12)
    yticks(fontsize=12)
    xlabel("Yield", fontsize = 15)
    ylabel("Revenue & Cost", fontsize = 15)
    tight_layout()
    # return costcurves
    savefig(joinpath(abpath(), "figs/SIchangingI0c.pdf"))
end    

#Relative profits versus absolute profits
let 
    Irange = 0.0:0.01:20.0
    Ymaxrange = 160.0:1.0:230.0
    I0data225abs = [calc_I0_abs(225, Ymax, EconomicPar()) for Ymax in Ymaxrange]
    I0data125abs = [calc_I0_abs(125, Ymax, EconomicPar()) for Ymax in Ymaxrange]
    I0data25abs = [calc_I0_abs(25, Ymax, EconomicPar()) for Ymax in Ymaxrange]
    I0data133rel = [calc_I0(1.33, Ymax, EconomicPar()) for Ymax in Ymaxrange]
    I0data115rel = [calc_I0(1.15, Ymax, EconomicPar()) for Ymax in Ymaxrange]
    I0data108rel = [calc_I0(1.08, Ymax, EconomicPar()) for Ymax in Ymaxrange]
    relvsabsplot = figure(figsize = (6,4))
    plot(1 ./ I0data25abs, Ymaxrange, color="#440154FF", label="Rev-Exp = \$25")
    plot(1 ./ I0data125abs,Ymaxrange, color="#1F968BFF", label="Rev-Exp = \$125")
    plot(1 ./ I0data225abs, Ymaxrange, color="#73D055FF", label="Rev-Exp = \$225")
    plot(1 ./ I0data133rel, Ymaxrange, linewidth=3, linestyle="solid", color="black", label="Rev/Exp = 1.33")
    plot(1 ./ I0data115rel, Ymaxrange, linewidth=3, linestyle="dashed", color="black", label="Rev/Exp = 1.15")
    plot(1 ./ I0data108rel, Ymaxrange, linewidth=3, linestyle="dotted", color="black", label="Rev/Exp = 1.08")
    xlabel("1/I0", fontsize = 15)
    ylabel("Ymax", fontsize = 15)
    legend()
    return relvsabsplot
    # savefig(joinpath(abpath(), "figs/relvsabsplot.pdf"))
end

# Separating CVwNL and CVwoNL
#CVwoNL (NOTE that the CVwoNL is exactly the same whether generated from the positive feedback or time delay functions)
let 
    lowymax_108 = variabilityterminalassets_rednoise(revexpcurve108_lowymax_timedelay_data)
    medymax_108 = variabilityterminalassets_rednoise(revexpcurve108_medymax_timedelay_data)
    highymax_108 = variabilityterminalassets_rednoise(revexpcurve108_highymax_timedelay_data)
    lowymax_133 = variabilityterminalassets_rednoise(revexpcurve133_lowymax_timedelay_data)
    medymax_133 = variabilityterminalassets_rednoise(revexpcurve133_medymax_timedelay_data)
    highymax_133 = variabilityterminalassets_rednoise(revexpcurve133_highymax_timedelay_data)
    varwoNL_changingrevexp = figure(figsize=(4,6))    
    subplot(2,1,1)
    plot(lowymax_108[:,1], lowymax_108[:,3].*1.025, linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_108[:,1], medymax_108[:,3], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_108[:,1], highymax_108[:,3].*0.975, linestyle="dotted", color="black", label="High Ymax")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    title("Relative Profits = 1.08")
    legend()
    subplot(2,1,2)
    plot(lowymax_133[:,1], lowymax_133[:,3].*1.025, linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_133[:,1], medymax_133[:,3], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_133[:,1], highymax_133[:,3].*0.975, linestyle="dotted", color="black", label="High Ymax")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    title("Relative Profits = 1.33")
    legend()
    tight_layout()
    # return varwoNL_changingrevexp
    savefig(joinpath(abpath(), "figs/varwoNL_relprofcurve.pdf")) 
end

#CVwNL positive feedback
let 
    lowymax_108 = variabilityterminalassets_rednoise(revexpcurve108_lowymax_posfeed_data)
    medymax_108 = variabilityterminalassets_rednoise(revexpcurve108_medymax_posfeed_data)
    highymax_108 = variabilityterminalassets_rednoise(revexpcurve108_highymax_posfeed_data)
    lowymax_133 = variabilityterminalassets_rednoise(revexpcurve133_lowymax_posfeed_data)
    medymax_133 = variabilityterminalassets_rednoise(revexpcurve133_medymax_posfeed_data)
    highymax_133 = variabilityterminalassets_rednoise(revexpcurve133_highymax_posfeed_data)
    posfeed_varwNL_changingrevexp = figure(figsize=(4,6))    
    subplot(2,1,1)
    plot(lowymax_108[:,1], lowymax_108[:,2].*1.025, linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_108[:,1], medymax_108[:,2], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_108[:,1], highymax_108[:,2].*0.975, linestyle="dotted", color="black", label="High Ymax")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    title("Relative Profits = 1.08")
    subplot(2,1,2)
    plot(lowymax_133[:,1], lowymax_133[:,2].*1.025, linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_133[:,1], medymax_133[:,2], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_133[:,1], highymax_133[:,2].*0.975, linestyle="dotted", color="black", label="High Ymax")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    title("Relative Profits = 1.33")
    tight_layout()
    # return posfeed_varwNL_changingrevexp
    savefig(joinpath(abpath(), "figs/posfeed_varwNL_relprofcurve.pdf")) 
end

#CVwNL time delay
let 
    lowymax_108 = variabilityterminalassets_rednoise(revexpcurve108_lowymax_timedelay_data)
    medymax_108 = variabilityterminalassets_rednoise(revexpcurve108_medymax_timedelay_data)
    highymax_108 = variabilityterminalassets_rednoise(revexpcurve108_highymax_timedelay_data)
    lowymax_133 = variabilityterminalassets_rednoise(revexpcurve133_lowymax_timedelay_data)
    medymax_133 = variabilityterminalassets_rednoise(revexpcurve133_medymax_timedelay_data)
    highymax_133 = variabilityterminalassets_rednoise(revexpcurve133_highymax_timedelay_data)
    timedelays_varwNL_changingrevexp = figure(figsize=(4,6))    
    subplot(2,1,1)
    plot(lowymax_108[:,1], lowymax_108[:,2].*1.025, linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_108[:,1], medymax_108[:,2], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_108[:,1], highymax_108[:,2].*0.975, linestyle="dotted", color="black", label="High Ymax")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    title("Relative Profits = 1.08")
    subplot(2,1,2)
    plot(lowymax_133[:,1], lowymax_133[:,2].*1.025, linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_133[:,1], medymax_133[:,2], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_133[:,1], highymax_133[:,2].*0.975, linestyle="dotted", color="black", label="High Ymax")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    title("Relative Profits = 1.33")
    tight_layout()
    # return timedelays_varwNL_changingrevexp
    savefig(joinpath(abpath(), "figs/timedelays_varwNL_relprofcurve.pdf")) 
end 


#Expected Terminal Assets (along rel profits curve) - Positive feedbacks
let 
    lowymax_108 = expectedterminalassets_absolute(revexpcurve108_lowymax_posfeed_data)
    medymax_108 = expectedterminalassets_absolute(revexpcurve108_medymax_posfeed_data)
    highymax_108 = expectedterminalassets_absolute(revexpcurve108_highymax_posfeed_data)
    lowymax_133 = expectedterminalassets_absolute(revexpcurve133_lowymax_posfeed_data)
    medymax_133 = expectedterminalassets_absolute(revexpcurve133_medymax_posfeed_data)
    highymax_133 = expectedterminalassets_absolute(revexpcurve133_highymax_posfeed_data)
    posfeed_eta_alongrelprofcurve = figure(figsize=(4,6))    
    subplot(2,1,1)
    plot(lowymax_108[:,1], lowymax_108[:,2], linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_108[:,1], medymax_108[:,2], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_108[:,1], highymax_108[:,2], linestyle="dotted", color="black", label="High Ymax")
    title("Relative profits = 1.08", fontsize=15)
    xlabel("Noise correlation", fontsize = 15)
    ylabel("Expected Final Assets", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    subplot(2,1,2)
    plot(lowymax_133[:,1], lowymax_133[:,2], linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_133[:,1], medymax_133[:,2], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_133[:,1], highymax_133[:,2], linestyle="dotted", color="black", label="High Ymax")
    title("Relative profits = 1.33", fontsize=15)
    xlabel("Noise correlation", fontsize = 15)
    ylabel("Expected Final Assets", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    tight_layout()
    # return posfeed_eta_alongrelprofcurve
    savefig(joinpath(abpath(), "figs/posfeed_eta_alongrelprofcurve.pdf")) 
end

#Expected Terminal Assets (along rel profits curve) - Time delay
let 
    lowymax_108 = expectedterminalassets_absolute(revexpcurve108_lowymax_timedelay_data)
    medymax_108 = expectedterminalassets_absolute(revexpcurve108_medymax_timedelay_data)
    highymax_108 = expectedterminalassets_absolute(revexpcurve108_highymax_timedelay_data)
    lowymax_133 = expectedterminalassets_absolute(revexpcurve133_lowymax_timedelay_data)
    medymax_133 = expectedterminalassets_absolute(revexpcurve133_medymax_timedelay_data)
    highymax_133 = expectedterminalassets_absolute(revexpcurve133_highymax_timedelay_data)
    timedelays_eta_alongrelprofcurve = figure(figsize=(4,6))    
    subplot(2,1,1)
    plot(lowymax_108[:,1], lowymax_108[:,2], linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_108[:,1], medymax_108[:,2], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_108[:,1], highymax_108[:,2], linestyle="dotted", color="black", label="High Ymax")
    title("Relative profits = 1.08", fontsize=15)
    xlabel("Noise correlation", fontsize = 15)
    ylabel("Expected Final Assets", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    subplot(2,1,2)
    plot(lowymax_133[:,1], lowymax_133[:,2], linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_133[:,1], medymax_133[:,2], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_133[:,1], highymax_133[:,2], linestyle="dotted", color="black", label="High Ymax")
    title("Relative profits = 1.33", fontsize=15)
    xlabel("Noise correlation", fontsize = 15)
    ylabel("Expected Final Assets", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    tight_layout()
    # return timedelays_eta_alongrelprofcurve
    savefig(joinpath(abpath(), "figs/timedelays_eta_alongrelprofcurve.pdf")) 
end 

function changerelative(data)
    ini=data[1,2]
    max=maximum(data[:,2])
    min=minimum(data[:,2])
    return (max-min)/ini
end


#Checking whether reduction in ETA residual relative to absolute value
let 
    lowymax_108 = expectedterminalassets_absolute(revexpcurve108_lowymax_timedelay_data)
    medymax_108 = expectedterminalassets_absolute(revexpcurve108_medymax_timedelay_data)
    highymax_108 = expectedterminalassets_absolute(revexpcurve108_highymax_timedelay_data)
    lowymax_133 = expectedterminalassets_absolute(revexpcurve133_lowymax_timedelay_data)
    medymax_133 = expectedterminalassets_absolute(revexpcurve133_medymax_timedelay_data)
    highymax_133 = expectedterminalassets_absolute(revexpcurve133_highymax_timedelay_data)
    low108change = changerelative(lowymax_108) 
    med108change = changerelative(medymax_108)
    high108change = changerelative(highymax_108)
    low133change = changerelative(lowymax_133)
    med133change = changerelative(medymax_133)
    high133change = changerelative(highymax_133)
    vals = [low108change,med108change,high108change,low133change,med133change,high133change]  
    params = ["low108","med108","high108","low133","med133","high133"]
    return hcat(params,vals)
end


#Standardizing by sd of noise removes differences between low and high ymax in both positive feedback and time delay
#but does it make sense to standarized by sd of noise for positive feedback (because by definition the sds will be different)


#Standard Deviation and mean for time delay mechanism
constrainYmax_133_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainYmax_133_timedelay_data_CV.csv"), DataFrame))
constrainYmax_108_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainYmax_108_timedelay_data_CV.csv"), DataFrame))

let
    highdata = variabilityterminalassets_breakdown(constrainYmax_133_timedelay_data_CV)
    lowdata = variabilityterminalassets_breakdown(constrainYmax_108_timedelay_data_CV)
    variabilitybreakdown = figure()
    subplot(2,2,1)
    plot(highdata[:,1], highdata[:,2])
    plot(highdata[:,1], highdata[:,4])
    xlabel("Autocorrelation", fontsize=15)
    ylabel("Standard Deviation", fontsize=15)
    ylim(0,3500)
    xticks(fontsize=12)
    yticks(fontsize=12)
    subplot(2,2,2)
    plot(lowdata[:,1], lowdata[:,2])
    plot(lowdata[:,1], lowdata[:,4])
    xlabel("Autocorrelation", fontsize=15)
    ylabel("Standard Deviation", fontsize=15)
    ylim(0,3500)
    xticks(fontsize=12)
    yticks(fontsize=12)
    subplot(2,2,3)
    plot(highdata[:,1], highdata[:,3])
    plot(highdata[:,1], highdata[:,5])
    xlabel("Autocorrelation", fontsize=15)
    ylabel("Mean", fontsize=15)
    ylim(6400, 7200)
    xticks(fontsize=12)
    yticks(fontsize=12)
    subplot(2,2,4)
    plot(lowdata[:,1], lowdata[:,3])
    plot(lowdata[:,1], lowdata[:,5])
    xlabel("Autocorrelation", fontsize=15)
    ylabel("Mean", fontsize=15)
    ylim(1600, 2400)
    xticks(fontsize=12)
    yticks(fontsize=12)
    tight_layout()
    return variabilitybreakdown
end

let 
    Ymaxrange = 120.0:1.0:200.0
    I0data225abs = [calc_I0_abs(225, Ymax, 139, 6.70) for Ymax in Ymaxrange]
    I0data75abs = [calc_I0_abs(75, Ymax, 139, 6.70) for Ymax in Ymaxrange]
    abs = figure()
    plot(1 ./ I0data225abs, Ymaxrange, linestyle="dashed", color="black", label="rev-exp = 225")
    plot(1 ./ I0data75abs, Ymaxrange, linestyle="dotted", color="black", label="rev-exp = 75")
    xlabel("1/I0", fontsize = 20)
    ylabel("Ymax", fontsize = 20)
    return abs
    # savefig(joinpath(abpath(), "figs/abs_constrainedgraph.pdf"))
end

# Showing that changing I0 and c keeps geometry the same (as long as rev/exp is constrained)
#setting I0 and c arbitrarily but still ratio is 1.33

calc_c(1.33, 174, 10, 6.70)
parratio2 = FarmBasePar(I0 = 10, Ymax = 174, p = 6.70, c = 138.59335)

param_ratio(FarmBasePar(I0 = 10, Ymax = 120, p = 6.70, c = 138.59335))
param_ratio(FarmBasePar(I0 = 5, Ymax = 120, p = 6.70, c = 138.59335))
param_ratio(parratio2)
let 
    par1 = FarmBasePar(I0 = 10, Ymax = 174, p = 6.70, c = 138.59335)
    par2 = FarmBasePar(I0 = 10, Ymax = 120, p = 6.70, c = 138.59335)
    par3 = FarmBasePar(I0 = 5, Ymax = 174, p = 6.70, c = 138.59335)
    par4 = FarmBasePar(I0 = 5, Ymax = 120, p = 6.70, c = 138.59335)
    Irange = 0.0:0.01:10.0
    Yield1 = [yieldIII(I, par1) for I in Irange]
    MC1 = [margcostIII(I, par1) for I in Irange]
    AVC1 = [avvarcostIII(I,par1) for I in Irange]
    Yield2 = [yieldIII(I, par2) for I in Irange]
    MC2 = [margcostIII(I, par2) for I in Irange]
    AVC2 = [avvarcostIII(I,par2) for I in Irange]
    Yield3 = [yieldIII(I, par3) for I in Irange]
    MC3 = [margcostIII(I, par3) for I in Irange]
    AVC3 = [avvarcostIII(I,par3) for I in Irange]
    Yield4 = [yieldIII(I, par4) for I in Irange]
    MC4 = [margcostIII(I, par4) for I in Irange]
    AVC4 = [avvarcostIII(I,par4) for I in Irange]
    costcurves = figure()
    subplot(2,2,1)
    plot(Yield1, MC1, color="blue", label="MC")
    plot(Yield1, AVC1, color="orange", label="AVC")
    hlines(par1.p, 0.0, 174, colors="black", label = "MR")
    legend()
    ylim(0.0, 50.0)
    # xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(2,2,2)
    plot(Yield2, MC2, color="blue", label="MC")
    plot(Yield2, AVC2, color="orange", label="AVC")
    hlines(par2.p, 0.0, 174, colors="black", label = "MR")
    legend()
    ylim(0.0, 50.0)
    # xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(2,2,3)
    plot(Yield3, MC3, color="blue", label="MC")
    plot(Yield3, AVC3, color="orange", label="AVC")
    hlines(par3.p, 0.0, 174, colors="black", label = "MR")
    legend()
    ylim(0.0, 50.0)
    # xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(2,2,4)
    plot(Yield4, MC4, color="blue", label="MC")
    plot(Yield4, AVC4, color="orange", label="AVC")
    hlines(par4.p, 0.0, 174, colors="black", label = "MR")
    legend()
    ylim(0.0, 50.0)
    # xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    tight_layout()
    return costcurves
    # savefig(joinpath(abpath(), "figs/costcurves.png"))
end  


#checking what happens between low ymax and hymax our assumption
let 
    YmaxI0valshigh = calcYmaxI0vals_Ymaxrelprof(200, [1.08,1.33], EconomicPar())
    YmaxI0valslow = calcYmaxI0vals_Ymaxrelprof(150, [1.08,1.33], EconomicPar())
    inputsyield1high = maxprofitIII_vals(YmaxI0valshigh[1,1], YmaxI0valshigh[1,2], EconomicPar())
    inputsyield2high = maxprofitIII_vals(YmaxI0valshigh[2,1], YmaxI0valshigh[2,2], EconomicPar())
    inputsyield1low = maxprofitIII_vals(YmaxI0valslow[1,1], YmaxI0valslow[1,2], EconomicPar())
    inputsyield2low = maxprofitIII_vals(YmaxI0valslow[2,1], YmaxI0valslow[2,2], EconomicPar())
    Irange = 0.0:0.01:20.0
    Yrange = 0.0:0.1:180.0
    Yield1high = [yieldIII(I, YmaxI0valshigh[1,1], YmaxI0valshigh[1,2]) for I in Irange]
    MC1high = [margcostIII(I, YmaxI0valshigh[1,1], YmaxI0valshigh[1,2], EconomicPar()) for I in Irange]
    AVC1high = [avvarcostIII(I, YmaxI0valshigh[1,1], YmaxI0valshigh[1,2], EconomicPar()) for I in Irange]
    Yield2high = [yieldIII(I, YmaxI0valshigh[2,1], YmaxI0valshigh[2,2]) for I in Irange]
    MC2high = [margcostIII(I, YmaxI0valshigh[2,1], YmaxI0valshigh[2,2], EconomicPar()) for I in Irange]
    AVC2high = [avvarcostIII(I, YmaxI0valshigh[2,1], YmaxI0valshigh[2,2], EconomicPar()) for I in Irange]
    Yield1low = [yieldIII(I, YmaxI0valslow[1,1], YmaxI0valslow[1,2]) for I in Irange]
    MC1low = [margcostIII(I, YmaxI0valslow[1,1], YmaxI0valslow[1,2], EconomicPar()) for I in Irange]
    AVC1low = [avvarcostIII(I, YmaxI0valslow[1,1], YmaxI0valslow[1,2], EconomicPar()) for I in Irange]
    Yield2low = [yieldIII(I, YmaxI0valslow[2,1], YmaxI0valslow[2,2]) for I in Irange]
    MC2low = [margcostIII(I, YmaxI0valshigh[2,1], YmaxI0valslow[2,2], EconomicPar()) for I in Irange]
    AVC2low = [avvarcostIII(I, YmaxI0valslow[2,1], YmaxI0valslow[2,2], EconomicPar()) for I in Irange]
    errorresistance = figure(figsize=(10,8))
    subplot(2,2,1)
    plot(Yield1high, MC1high, color="#238A8DFF", label="Marginal Costs", linewidth = 3)
    plot(Yield1high, AVC1high, color="#404788FF", label="Average Variable Costs", linewidth = 3)
    hlines(EconomicPar().p, 0.0, 200.0, colors="#FDE725FF", label = "Marginal Revenue", linewidth = 3)
    vlines(inputsyield1high[2], 0.0, 10.0, colors="black", linestyle="dashed", linewidth=2)
    ylim(0.0, 10.0)
    xlim(0.0, 174.0)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    xlabel("Yield", fontsize = 15)
    ylabel("Revenue & Cost", fontsize = 15)
    subplot(2,2,2)
    plot(Yield2high, MC2high, color="#238A8DFF", label="Marginal Costs", linewidth = 3)
    plot(Yield2high, AVC2high, color="#404788FF", label="Average Variable Costs", linewidth = 3)
    hlines(EconomicPar().p, 0.0, 200.0, colors="#FDE725FF", label = "Marginal Revenue", linewidth = 3)
    vlines(inputsyield2high[2], 0.0, 10.0, colors="black", linestyle="dashed", linewidth=2)
    ylim(0.0, 10.0)
    xlim(0.0, 174.0)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    xlabel("Yield", fontsize = 15)
    ylabel("Revenue & Cost", fontsize = 15)
    subplot(2,2,3)
    plot(Yield1low, MC1low, color="#238A8DFF", label="Marginal Costs", linewidth = 3)
    plot(Yield1low, AVC1low, color="#404788FF", label="Average Variable Costs", linewidth = 3)
    hlines(EconomicPar().p, 0.0, 150.0, colors="#FDE725FF", label = "Marginal Revenue", linewidth = 3)
    vlines(inputsyield1low[2], 0.0, 10.0, colors="black", linestyle="dashed", linewidth=2)
    ylim(0.0, 10.0)
    xlim(0.0, 174.0)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    xlabel("Yield", fontsize = 15)
    ylabel("Revenue & Cost", fontsize = 15)
    subplot(2,2,4)
    plot(Yield2low, MC2low, color="#238A8DFF", label="Marginal Costs", linewidth = 3)
    plot(Yield2low, AVC2low, color="#404788FF", label="Average Variable Costs", linewidth = 3)
    hlines(EconomicPar().p, 0.0, 150.0, colors="#FDE725FF", label = "Marginal Revenue", linewidth = 3)
    vlines(inputsyield2low[2], 0.0, 10.0, colors="black", linestyle="dashed", linewidth=2)
    ylim(0.0, 10.0)
    xlim(0.0, 174.0)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    xlabel("Yield", fontsize = 15)
    ylabel("Revenue & Cost", fontsize = 15)
    tight_layout()
    return errorresistance
    # savefig(joinpath(abpath(), "figs/errorresistance_relprofcurveymax.pdf"))
end 

let 
    YmaxI0valshigh = calcYmaxI0vals_Ymaxrelprof(200, [1.08,1.33], EconomicPar())
    YmaxI0valslow = calcYmaxI0vals_Ymaxrelprof(150, [1.08,1.33], EconomicPar())
    inputsyield1high = maxprofitIII_vals(YmaxI0valshigh[1,1], YmaxI0valshigh[1,2], EconomicPar())
    avc1high = (inputsyield1high[1]*863.56)/inputsyield1high[2]
    inputsyield1low = maxprofitIII_vals(YmaxI0valslow[1,1], YmaxI0valslow[1,2], EconomicPar())
    avc1low = (inputsyield1low[1]*863.56)/inputsyield1low[2]
    return avc1low, avc1high
end



#####Constrain ymax io old code
# constrainYmax_133_posfeed_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainYmax_133_posfeed_data_CV.csv"), DataFrame))
# constrainYmax_115_posfeed_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainYmax_115_posfeed_data_CV.csv"), DataFrame))
# constrainYmax_108_posfeed_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainYmax_108_posfeed_data_CV.csv"), DataFrame))
# constrainI0_133_posfeed_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainI0_133_posfeed_data_CV.csv"), DataFrame))
# constrainI0_115_posfeed_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainI0_115_posfeed_data_CV.csv"), DataFrame))
# constrainI0_108_posfeed_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainI0_108_posfeed_data_CV.csv"), DataFrame))
# constrainYmax_133_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainYmax_133_timedelay_data_CV.csv"), DataFrame))
# constrainYmax_115_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainYmax_115_timedelay_data_CV.csv"), DataFrame))
# constrainYmax_108_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainYmax_108_timedelay_data_CV.csv"), DataFrame))
# constrainI0_133_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainI0_133_timedelay_data_CV.csv"), DataFrame))
# constrainI0_115_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainI0_115_timedelay_data_CV.csv"), DataFrame))
# constrainI0_108_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainI0_108_timedelay_data_CV.csv"), DataFrame))
# constrainYmax_095_posfeed_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainYmax_095_posfeed_data_CV.csv"), DataFrame))
# constrainI0_095_posfeed_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainI0_095_posfeed_data_CV.csv"), DataFrame))
# constrainYmax_095_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainYmax_095_timedelay_data_CV.csv"), DataFrame))
# constrainI0_095_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainI0_095_timedelay_data_CV.csv"), DataFrame))

# let 
#     constrainYmax_133 = variabilityterminalassets_rednoise(constrainYmax_133_posfeed_data_CV)
#     constrainYmax_115 = variabilityterminalassets_rednoise(constrainYmax_115_posfeed_data_CV)
#     constrainYmax_108 = variabilityterminalassets_rednoise(constrainYmax_108_posfeed_data_CV)
#     constrainI0_133 = variabilityterminalassets_rednoise(constrainI0_133_posfeed_data_CV)
#     constrainI0_115 = variabilityterminalassets_rednoise(constrainI0_115_posfeed_data_CV)
#     constrainI0_108 = variabilityterminalassets_rednoise(constrainI0_108_posfeed_data_CV)
#     posfeed_var_changingrevexp = figure(figsize=(4,6))    
#     subplot(2,1,1)
#     plot(constrainYmax_133[:,1], constrainYmax_133[:,4], linestyle="solid", color="black", label="Rev/Exp = 1.33")
#     plot(constrainYmax_115[:,1], constrainYmax_115[:,4], linestyle="dashed", color="black", label="Rev/Exp = 1.15")
#     plot(constrainYmax_108[:,1], constrainYmax_108[:,4], linestyle="dotted", color="black", label="Rev/Exp = 1.08")
#     xlabel("Noise correlation", fontsize = 15)
#     ylabel("CVwNL/CVwoNL", fontsize = 15)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     legend()
#     subplot(2,1,2)
#     plot(constrainI0_133[:,1], constrainI0_133[:,4], linestyle="solid", color="black", label="Rev/Exp = 1.33")
#     plot(constrainI0_115[:,1], constrainI0_115[:,4], linestyle="dashed", color="black", label="Rev/Exp = 1.15")
#     plot(constrainI0_108[:,1], constrainI0_108[:,4], linestyle="dotted", color="black", label="Rev/Exp = 1.08")
#     xlabel("Noise correlation", fontsize = 15)
#     ylabel("CVwNL/CVwoNL", fontsize = 15)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     legend()
#     tight_layout()
#     # return posfeed_var_changingrevexp
#     savefig(joinpath(abpath(), "figs/posfeed_var_changingrevexp.pdf")) 
# end 

# let 
#     YmaxI0vals = calcYmaxI0vals("I0", 174, [1.08,1.33], 10, 0.02, EconomicPar())
#     inputsyield1 = maxprofitIII_vals(YmaxI0vals[1,1], YmaxI0vals[1,2], EconomicPar())
#     inputsyield2 = maxprofitIII_vals(YmaxI0vals[2,1], YmaxI0vals[2,2], EconomicPar())
#     Irange = 0.0:0.01:20.0
#     Yrange = 0.0:0.1:180.0
#     Yield1 = [yieldIII(I, YmaxI0vals[1,1], YmaxI0vals[1,2]) for I in Irange]
#     MC1 = [margcostIII(I, YmaxI0vals[1,1], YmaxI0vals[1,2], EconomicPar()) for I in Irange]
#     DAVC1 = [avvarcostkickIII(inputsyield1[1], Y, EconomicPar()) for Y in Yrange]
#     Yield2 = [yieldIII(I, YmaxI0vals[2,1], YmaxI0vals[2,2]) for I in Irange]
#     MC2 = [margcostIII(I, YmaxI0vals[2,1], YmaxI0vals[2,2], EconomicPar()) for I in Irange]
#     DAVC2 = [avvarcostkickIII(inputsyield2[1], Y, EconomicPar()) for Y in Yrange]
#     conYmax = AVCK_MC_distance_revexp_data("Ymax", 174, 1.08:0.01:1.33, 10, 0.02, EconomicPar())
#     conI0 = AVCK_MC_distance_revexp_data("I0", 174, 1.08:0.01:1.33, 10, 0.02, EconomicPar())
#     yielddisturbanceresistance = figure(figsize=(10,8))
#     subplot(2,2,1)
#     plot(Yield1, MC1, color="#238A8DFF", label="Marginal Costs", linewidth = 3)
#     hlines(EconomicPar().p, 0.0, 174.0, colors="#FDE725FF", label = "Marginal Revenue", linewidth = 3)
#     plot(Yrange, DAVC1, color="#404788FF", label = "Noise Average Variable Costs", linewidth = 3)
#     vlines(inputsyield1[2], 0.0, 10.0, colors="black", linestyle="dashed", linewidth=2)
#     ylim(0.0, 10.0)
#     xlim(0.0, 174.0)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     legend()
#     xlabel("Yield", fontsize = 15)
#     ylabel("Revenue & Cost", fontsize = 15)
#     subplot(2,2,2)
#     plot(Yield2, MC2, color="#238A8DFF", label="Marginal Costs", linewidth = 3)
#     hlines(EconomicPar().p, 0.0, 174.0, colors="#FDE725FF", label = "Marginal Revenue", linewidth = 3)
#     plot(Yrange, DAVC2, color="#404788FF", label = "Noise Average Variable Costs", linewidth = 3)
#     vlines(inputsyield2[2], 0.0, 10.0, colors="black", linestyle="dashed", linewidth=2)
#     ylim(0.0, 10.0)
#     xlim(0.0, 174.0)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     legend()
#     xlabel("Yield", fontsize = 15)
#     ylabel("Revenue & Cost", fontsize = 15)
#     subplot(2,2,3)
#     plot(conYmax[:,1], conYmax[:,2], color="#440154FF", label="Ymax constrained",linewidth = 3)
#     plot(conI0[:,1], conI0[:,2], color="#73D055FF", label="I0 constrained", linewidth = 3)
#     xlabel("Relative Profits", fontsize = 15)
#     ylabel("Resistance to yield disturbance", fontsize = 15)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     legend()
#     tight_layout()
#     return yielddisturbanceresistance
#     # savefig(joinpath(abpath(), "figs/Figure4yielddisturbanceresistance_prep.pdf"))
# end 

# let 
#     YmaxI0vals = calcYmaxI0vals("I0", 174, [1.08,1.33], 10, 0.02, EconomicPar())
#     inputsyield1 = maxprofitIII_vals(YmaxI0vals[1,1], YmaxI0vals[1,2], EconomicPar())
#     inputsyield2 = maxprofitIII_vals(YmaxI0vals[2,1], YmaxI0vals[2,2], EconomicPar())
#     Irange = 0.0:0.01:20.0
#     Yrange = 0.0:0.1:180.0
#     Yield1 = [yieldIII(I, YmaxI0vals[1,1], YmaxI0vals[1,2]) for I in Irange]
#     MC1 = [margcostIII(I, YmaxI0vals[1,1], YmaxI0vals[1,2], EconomicPar()) for I in Irange]
#     DAVC1 = [avvarcostkickIII(inputsyield1[1], Y, EconomicPar()) for Y in Yrange]
#     Yield2 = [yieldIII(I, YmaxI0vals[2,1], YmaxI0vals[2,2]) for I in Irange]
#     MC2 = [margcostIII(I, YmaxI0vals[2,1], YmaxI0vals[2,2], EconomicPar()) for I in Irange]
#     DAVC2 = [avvarcostkickIII(inputsyield2[1], Y, EconomicPar()) for Y in Yrange]
#     yielddisturbanceresistance = figure(figsize=(5,8))
#     subplot(2,1,1)
#     plot(Yield1, MC1, color="#238A8DFF", label="Marginal Costs", linewidth = 3)
#     hlines(EconomicPar().p, 0.0, 174.0, colors="#FDE725FF", label = "Marginal Revenue", linewidth = 3)
#     plot(Yrange, DAVC1, color="#404788FF", label = "Noise Average Variable Costs", linewidth = 3)
#     vlines(inputsyield1[2], 0.0, 10.0, colors="black", linestyle="dashed", linewidth=2)
#     ylim(0.0, 10.0)
#     xlim(0.0, 174.0)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     legend()
#     xlabel("Yield", fontsize = 15)
#     ylabel("Revenue & Cost", fontsize = 15)
#     subplot(2,1,2)
#     plot(Yield2, MC2, color="#238A8DFF", label="Marginal Costs", linewidth = 3)
#     hlines(EconomicPar().p, 0.0, 174.0, colors="#FDE725FF", label = "Marginal Revenue", linewidth = 3)
#     plot(Yrange, DAVC2, color="#404788FF", label = "Noise Average Variable Costs", linewidth = 3)
#     vlines(inputsyield2[2], 0.0, 10.0, colors="black", linestyle="dashed", linewidth=2)
#     ylim(0.0, 10.0)
#     xlim(0.0, 174.0)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     legend()
#     xlabel("Yield", fontsize = 15)
#     ylabel("Revenue & Cost", fontsize = 15)
#     tight_layout()
#     # return yielddisturbanceresistance
#     savefig(joinpath(abpath(), "figs/yielddisturbanceresistance_marginalcurves.pdf"))
# end 

# let 
#     conYmax = AVCK_MC_distance_revexp_data("Ymax", 174, 1.08:0.01:1.33, 10, 0.02, 0.2, EconomicPar())
#     conI0 = AVCK_MC_distance_revexp_data("I0", 174, 1.08:0.01:1.33, 10, 0.02, 0.2, EconomicPar())
#     yielddisturbanceresistance = figure(figsize=(6,8))
#     subplot(2,1,1)
#     plot(conYmax[:,1], conYmax[:,2], color="#440154FF", label="Ymax constrained",linewidth = 3)
#     plot(conI0[:,1], conI0[:,2], color="#73D055FF", label="I0 constrained", linewidth = 3)
#     xlabel("Relative Profits", fontsize = 15)
#     ylabel("Resistance to yield disturbance \n(wo standardizing)", fontsize = 15)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     legend()
#     subplot(2,1,2)
#     plot(conYmax[:,1], conYmax[:,3], color="#440154FF", label="Ymax constrained",linewidth = 3)
#     plot(conI0[:,1], conI0[:,3], color="#73D055FF", label="I0 constrained", linewidth = 3)
#     xlabel("Relative Profits", fontsize = 15)
#     ylabel("Resistance to yield disturbance", fontsize = 15)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     legend()
#     tight_layout()
#     # return yielddisturbanceresistance
#     savefig(joinpath(abpath(), "figs/resistancetoyieldstandardizing.pdf"))
# end

# let 
#     constrainYmax_133 = variabilityterminalassets_rednoise(constrainYmax_133_timedelay_data_CV)
#     constrainYmax_115 = variabilityterminalassets_rednoise(constrainYmax_115_timedelay_data_CV)
#     constrainYmax_108 = variabilityterminalassets_rednoise(constrainYmax_108_timedelay_data_CV)
#     constrainI0_133 = variabilityterminalassets_rednoise(constrainI0_133_timedelay_data_CV)
#     constrainI0_115 = variabilityterminalassets_rednoise(constrainI0_115_timedelay_data_CV)
#     constrainI0_108 = variabilityterminalassets_rednoise(constrainI0_108_timedelay_data_CV)
#     timedelays_var_changingrevexp = figure(figsize=(4,6))    
#     subplot(2,1,1)
#     plot(constrainYmax_133[:,1], constrainYmax_133[:,4], linestyle="solid", color="black", label="Rev/Exp = 1.33")
#     plot(constrainYmax_115[:,1], constrainYmax_115[:,4], linestyle="dashed", color="black", label="Rev/Exp = 1.15")
#     plot(constrainYmax_108[:,1], constrainYmax_108[:,4], linestyle="dotted", color="black", label="Rev/Exp = 1.08")
#     xlabel("Noise correlation", fontsize = 15)
#     ylabel("CVwNL/CVwoNL", fontsize = 15)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     legend()
#     subplot(2,1,2)
#     plot(constrainI0_133[:,1], constrainI0_133[:,4], linestyle="solid", color="black", label="Rev/Exp = 1.33")
#     plot(constrainI0_115[:,1], constrainI0_115[:,4], linestyle="dashed", color="black", label="Rev/Exp = 1.15")
#     plot(constrainI0_108[:,1], constrainI0_108[:,4], linestyle="dotted", color="black", label="Rev/Exp = 1.08")
#     xlabel("Noise correlation", fontsize = 15)
#     ylabel("CVwNL/CVwoNL", fontsize = 15)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     legend()
#     tight_layout()
#     # return timedelays_var_changingrevexp
#     savefig(joinpath(abpath(), "figs/timedelays_var_changingrevexp.pdf")) 
# end 

# let 
#     YmaxI0vals = calcYmaxI0vals("I0", 174, [1.08,1.33], 10, 0.02, EconomicPar())
#     inputsyield1 = maxprofitIII_vals(YmaxI0vals[1,1], YmaxI0vals[1,2], EconomicPar())
#     inputsyield2 = maxprofitIII_vals(YmaxI0vals[2,1], YmaxI0vals[2,2], EconomicPar())
#     Irange = 0.0:0.01:20.0
#     Yrange = 0.0:0.1:180.0
#     Yield1 = [yieldIII(I, YmaxI0vals[1,1], YmaxI0vals[1,2]) for I in Irange]
#     MC1 = [margcostIII(I, YmaxI0vals[1,1], YmaxI0vals[1,2], EconomicPar()) for I in Irange]
#     AVC1 = [avvarcostIII(I, YmaxI0vals[1,1], YmaxI0vals[1,2], EconomicPar()) for I in Irange]
#     Yield2 = [yieldIII(I, YmaxI0vals[2,1], YmaxI0vals[2,2]) for I in Irange]
#     MC2 = [margcostIII(I, YmaxI0vals[2,1], YmaxI0vals[2,2], EconomicPar()) for I in Irange]
#     AVC2 = [avvarcostIII(I, YmaxI0vals[2,1], YmaxI0vals[2,2], EconomicPar()) for I in Irange]
#     conYmax = AVCmin_MR_distance_revexp_data("Ymax", 174, 1.08:0.01:1.33, Irange, 10, 0.02, EconomicPar())
#     conI0 = AVCmin_MR_distance_revexp_data("I0", 174, 1.08:0.01:1.33, Irange, 10, 0.02, EconomicPar())
#     errorresistance = figure(figsize=(10,8))
#     subplot(2,2,1)
#     plot(Yield1, MC1, color="#238A8DFF", label="Marginal Costs", linewidth = 3)
#     plot(Yield1, AVC1, color="#404788FF", label="Average Variable Costs", linewidth = 3)
#     hlines(EconomicPar().p, 0.0, 174.0, colors="#FDE725FF", label = "Marginal Revenue", linewidth = 3)
#     vlines(inputsyield1[2], 0.0, 10.0, colors="black", linestyle="dashed", linewidth=2)
#     ylim(0.0, 10.0)
#     xlim(0.0, 174.0)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     legend()
#     xlabel("Yield", fontsize = 15)
#     ylabel("Revenue & Cost", fontsize = 15)
#     subplot(2,2,2)
#     plot(Yield2, MC2, color="#238A8DFF", label="Marginal Costs", linewidth = 3)
#     plot(Yield2, AVC2, color="#404788FF", label="Average Variable Costs", linewidth = 3)
#     hlines(EconomicPar().p, 0.0, 174.0, colors="#FDE725FF", label = "Marginal Revenue", linewidth = 3)
#     vlines(inputsyield2[2], 0.0, 10.0, colors="black", linestyle="dashed", linewidth=2)
#     ylim(0.0, 10.0)
#     xlim(0.0, 174.0)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     legend()
#     xlabel("Yield", fontsize = 15)
#     ylabel("Revenue & Cost", fontsize = 15)
#     subplot(2,2,3)
#     plot(conYmax[:,1], conYmax[:,2], color="#440154FF", label="Ymax constrained",linewidth = 3)
#     #plot(conI0[:,1], conI0[:,2], color="#29AF7FFF", label="Ymax or I0 constrained", linewidth = 3)
#     xlabel("Relative Profits", fontsize = 15)
#     ylabel("Resistance to error", fontsize = 15)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     legend()
#     tight_layout()
#     return errorresistance
#     # savefig(joinpath(abpath(), "figs/Figure6errorresistance_prep.pdf"))
# end 


# #Expected Terminal Assets - Positive feedbacks
# let 
#     constrainYmax_133 = expectedterminalassets_absolute(constrainYmax_133_posfeed_data_CV)
#     constrainYmax_115 = expectedterminalassets_absolute(constrainYmax_115_posfeed_data_CV)
#     constrainYmax_108 = expectedterminalassets_absolute(constrainYmax_108_posfeed_data_CV)
#     constrainYmax_095 = expectedterminalassets_absolute(constrainYmax_095_posfeed_data_CV)
#     constrainI0_133 = expectedterminalassets_absolute(constrainI0_133_posfeed_data_CV)
#     constrainI0_115 = expectedterminalassets_absolute(constrainI0_115_posfeed_data_CV)
#     constrainI0_108 = expectedterminalassets_absolute(constrainI0_108_posfeed_data_CV)
#     constrainI0_095 = expectedterminalassets_absolute(constrainI0_095_posfeed_data_CV)
#     posfeed_eta_changingrevexp = figure(figsize=(4,6))    
#     subplot(2,1,1)
#     plot(constrainYmax_133[:,1], constrainYmax_133[:,2], linestyle="solid", color="black", label="Rev/Exp = 1.33")
#     plot(constrainYmax_115[:,1], constrainYmax_115[:,2], linestyle="dashed", color="black", label="Rev/Exp = 1.15")
#     plot(constrainYmax_108[:,1], constrainYmax_108[:,2], linestyle="dotted", color="black", label="Rev/Exp = 1.08")
#     plot(constrainYmax_095[:,1], constrainYmax_095[:,2], linestyle="dashdot", color="black", label="Rev/Exp = 0.95")
#     title("Constrain Ymax", fontsize=15)
#     xlabel("Noise correlation", fontsize = 15)
#     ylabel("Expected Final Assets", fontsize = 15)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     legend()
#     subplot(2,1,2)
#     plot(constrainI0_133[:,1], constrainI0_133[:,2], linestyle="solid", color="black", label="Rev/Exp = 1.33")
#     plot(constrainI0_115[:,1], constrainI0_115[:,2], linestyle="dashed", color="black", label="Rev/Exp = 1.15")
#     plot(constrainI0_108[:,1], constrainI0_108[:,2], linestyle="dotted", color="black", label="Rev/Exp = 1.08")
#     plot(constrainI0_095[:,1], constrainI0_095[:,2], linestyle="dashdot", color="black", label="Rev/Exp = 0.95")
#     title("Constrain I0", fontsize=15)
#     xlabel("Noise correlation", fontsize = 15)
#     ylabel("Expected Final Assets", fontsize = 15)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     legend()
#     tight_layout()
#     # return posfeed_eta_changingrevexp
#     savefig(joinpath(abpath(), "figs/posfeed_eta_changingrevexp.pdf")) 
# end

# #Expected Terminal Assets - Time delay
# let 
#     constrainYmax_133 = expectedterminalassets_absolute(constrainYmax_133_timedelay_data_CV)
#     constrainYmax_115 = expectedterminalassets_absolute(constrainYmax_115_timedelay_data_CV)
#     constrainYmax_108 = expectedterminalassets_absolute(constrainYmax_108_timedelay_data_CV)
#     constrainYmax_095 = expectedterminalassets_absolute(constrainYmax_095_timedelay_data_CV)
#     constrainI0_133 = expectedterminalassets_absolute(constrainI0_133_timedelay_data_CV)
#     constrainI0_115 = expectedterminalassets_absolute(constrainI0_115_timedelay_data_CV)
#     constrainI0_108 = expectedterminalassets_absolute(constrainI0_108_timedelay_data_CV)
#     constrainI0_095 = expectedterminalassets_absolute(constrainI0_095_timedelay_data_CV)
#     timedelays_eta_changingrevexp = figure(figsize=(4,6))    
#     subplot(2,1,1)
#     plot(constrainYmax_133[:,1], constrainYmax_133[:,2], linestyle="solid", color="black", label="Rev/Exp = 1.33")
#     plot(constrainYmax_115[:,1], constrainYmax_115[:,2], linestyle="dashed", color="black", label="Rev/Exp = 1.15")
#     plot(constrainYmax_108[:,1], constrainYmax_108[:,2], linestyle="dotted", color="black", label="Rev/Exp = 1.08")
#     plot(constrainYmax_095[:,1], constrainYmax_095[:,2], linestyle="dashdot", color="black", label="Rev/Exp = 0.95")
#     title("Constrain Ymax", fontsize=15)
#     xlabel("Noise correlation", fontsize = 15)
#     ylabel("Expected Final Assets", fontsize = 15)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     legend()
#     subplot(2,1,2)
#     plot(constrainI0_133[:,1], constrainI0_133[:,2], linestyle="solid", color="black", label="Rev/Exp = 1.33")
#     plot(constrainI0_115[:,1], constrainI0_115[:,2], linestyle="dashed", color="black", label="Rev/Exp = 1.15")
#     plot(constrainI0_108[:,1], constrainI0_108[:,2], linestyle="dotted", color="black", label="Rev/Exp = 1.08")
#     plot(constrainI0_095[:,1], constrainI0_095[:,2], linestyle="dashdot", color="black", label="Rev/Exp = 0.95")
#     title("Constrain I0", fontsize=15)
#     xlabel("Noise correlation", fontsize = 15)
#     ylabel("Expected Final Assets", fontsize = 15)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     legend()
#     tight_layout()
#     # return timedelays_eta_changingrevexp
#     savefig(joinpath(abpath(), "figs/timedelays_eta_changingrevexp.pdf")) 
# end 

# let 
#     YmaxI0valsI0con = calcYmaxI0vals("I0", 174, [1.08,1.15,1.33], 10, 0.02, EconomicPar())
#     YmaxI0valsYmaxcon = calcYmaxI0vals("Ymax", 174, [1.08,1.15,1.33], 10, 0.02, EconomicPar())
#     I0133 = marginalcurves(YmaxI0valsI0con[3,1], YmaxI0valsI0con[3,2], EconomicPar())
#     Ymax133 = marginalcurves(YmaxI0valsYmaxcon[3,1], YmaxI0valsYmaxcon[3,2], EconomicPar())
#     marginalcurvesfig = figure(figsize=(8,3))
#     subplot(1,2,1)
#     plot(I0133[2][:,1], I0133[2][:,2], color="#238A8DFF", label="Marginal Costs", linewidth = 3)
#     plot(I0133[2][:,1], I0133[2][:,3], color="#404788FF", label="Average Variable Costs", linewidth = 3)
#     hlines(EconomicPar().p, 0.0, 174.0, colors="#FDE725FF", label = "Marginal Revenue", linewidth = 3)
#     vlines(I0133[1][2], 0.0, 10.0, colors="black", linestyle="dashed", linewidth=2)
#     ylim(0.0, 10.0)
#     xlim(0.0, 174.0)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     legend()
#     xlabel("Yield", fontsize = 15)
#     ylabel("Revenue & Cost", fontsize = 15)
#     title("I0 constrained, R/E=1.33")
#     subplot(1,2,2)
#     plot(Ymax133[2][:,1], Ymax133[2][:,2], color="#238A8DFF", label="Marginal Costs", linewidth = 3)
#     plot(Ymax133[2][:,1], Ymax133[2][:,3], color="#404788FF", label="Average Variable Costs", linewidth = 3)
#     hlines(EconomicPar().p, 0.0, 174.0, colors="#FDE725FF", label = "Marginal Revenue", linewidth = 3)
#     vlines(Ymax133[1][2], 0.0, 10.0, colors="black", linestyle="dashed", linewidth=2)
#     ylim(0.0, 10.0)
#     xlim(0.0, 174.0)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     legend()
#     xlabel("Yield", fontsize = 15)
#     ylabel("Revenue & Cost", fontsize = 15)
#     title("Ymax constrained, R/E=1.33")
#     tight_layout()
#     return marginalcurvesfig
#     # savefig(joinpath(abpath(), "figs/averagevariablecostcurves.pdf"))
# end

#Expected Terminal Assets residual (constrained) - Positive feedbacks
# let 
#     constrainYmax_133 = expectedterminalassets_residual(constrainYmax_133_posfeed_data_CV)
#     constrainYmax_115 = expectedterminalassets_residual(constrainYmax_115_posfeed_data_CV)
#     constrainYmax_108 = expectedterminalassets_residual(constrainYmax_108_posfeed_data_CV)
#     constrainYmax_095 = expectedterminalassets_residual(constrainYmax_095_posfeed_data_CV)
#     constrainI0_133 = expectedterminalassets_residual(constrainI0_133_posfeed_data_CV)
#     constrainI0_115 = expectedterminalassets_residual(constrainI0_115_posfeed_data_CV)
#     constrainI0_108 = expectedterminalassets_residual(constrainI0_108_posfeed_data_CV)
#     constrainI0_095 = expectedterminalassets_residual(constrainI0_095_posfeed_data_CV)
#     posfeed_etaresidual_changingrevexp = figure(figsize=(4,6))    
#     subplot(2,1,1)
#     plot(constrainYmax_133[:,1], constrainYmax_133[:,2], linestyle="solid", color="black", label="Rev/Exp = 1.33")
#     plot(constrainYmax_115[:,1], constrainYmax_115[:,2], linestyle="dashed", color="black", label="Rev/Exp = 1.15")
#     plot(constrainYmax_108[:,1], constrainYmax_108[:,2], linestyle="dotted", color="black", label="Rev/Exp = 1.08")
#     plot(constrainYmax_095[:,1], constrainYmax_095[:,2], linestyle="dashdot", color="black", label="Rev/Exp = 0.95")
#     title("Constrain Ymax", fontsize=15)
#     xlabel("Noise correlation", fontsize = 15)
#     ylabel("Expected Final Assets \nResidual", fontsize = 15)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     legend()
#     subplot(2,1,2)
#     plot(constrainI0_133[:,1], constrainI0_133[:,2], linestyle="solid", color="black", label="Rev/Exp = 1.33")
#     plot(constrainI0_115[:,1], constrainI0_115[:,2], linestyle="dashed", color="black", label="Rev/Exp = 1.15")
#     plot(constrainI0_108[:,1], constrainI0_108[:,2], linestyle="dotted", color="black", label="Rev/Exp = 1.08")
#     plot(constrainI0_095[:,1], constrainI0_095[:,2], linestyle="dashdot", color="black", label="Rev/Exp = 0.95")
#     title("Constrain I0", fontsize=15)
#     xlabel("Noise correlation", fontsize = 15)
#     ylabel("Expected Final Assets \nResidual", fontsize = 15)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     legend()
#     tight_layout()
#     # return posfeed_etaresidual_changingrevexp
#     savefig(joinpath(abpath(), "figs/posfeed_etaresidual_changingrevexp.pdf")) 
# end

# #Expected Terminal Assets residuals (constrained) - Time delay
# let 
#     constrainYmax_133 = expectedterminalassets_residual(constrainYmax_133_timedelay_data_CV)
#     constrainYmax_115 = expectedterminalassets_residual(constrainYmax_115_timedelay_data_CV)
#     constrainYmax_108 = expectedterminalassets_residual(constrainYmax_108_timedelay_data_CV)
#     constrainYmax_095 = expectedterminalassets_residual(constrainYmax_095_timedelay_data_CV)
#     constrainI0_133 = expectedterminalassets_residual(constrainI0_133_timedelay_data_CV)
#     constrainI0_115 = expectedterminalassets_residual(constrainI0_115_timedelay_data_CV)
#     constrainI0_108 = expectedterminalassets_residual(constrainI0_108_timedelay_data_CV)
#     constrainI0_095 = expectedterminalassets_residual(constrainI0_095_timedelay_data_CV)
#     timedelays_etaresidual_changingrevexp = figure(figsize=(4,6))    
#     subplot(2,1,1)
#     plot(constrainYmax_133[:,1], constrainYmax_133[:,2], linestyle="solid", color="black", label="Rev/Exp = 1.33")
#     plot(constrainYmax_115[:,1], constrainYmax_115[:,2], linestyle="dashed", color="black", label="Rev/Exp = 1.15")
#     plot(constrainYmax_108[:,1], constrainYmax_108[:,2], linestyle="dotted", color="black", label="Rev/Exp = 1.08")
#     plot(constrainYmax_095[:,1], constrainYmax_095[:,2], linestyle="dashdot", color="black", label="Rev/Exp = 0.95")
#     title("Constrain Ymax", fontsize=15)
#     xlabel("Noise correlation", fontsize = 15)
#     ylabel("Expected Final Assets \nResidual", fontsize = 15)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     legend()
#     subplot(2,1,2)
#     plot(constrainI0_133[:,1], constrainI0_133[:,2], linestyle="solid", color="black", label="Rev/Exp = 1.33")
#     plot(constrainI0_115[:,1], constrainI0_115[:,2], linestyle="dashed", color="black", label="Rev/Exp = 1.15")
#     plot(constrainI0_108[:,1], constrainI0_108[:,2], linestyle="dotted", color="black", label="Rev/Exp = 1.08")
#     plot(constrainI0_095[:,1], constrainI0_095[:,2], linestyle="dashdot", color="black", label="Rev/Exp = 0.95")
#     title("Constrain I0", fontsize=15)
#     xlabel("Noise correlation", fontsize = 15)
#     ylabel("Expected Final Assets \nResidual", fontsize = 15)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     legend()
#     tight_layout()
#     # return timedelays_etaresidual_changingrevexp
#     savefig(joinpath(abpath(), "figs/timedelays_etaresidual_changingrevexp.pdf")) 
# end 