include("packages.jl")
include("AgriEco_commoncode.jl")

#Data

revexpcurve110_lowymax_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/revexpcurve110_lowymax_posfeed_data40to10.csv"), DataFrame))
revexpcurve110_medymax_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/revexpcurve110_medymax_posfeed_data40to10.csv"), DataFrame))
revexpcurve110_highymax_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/revexpcurve110_highymax_posfeed_data40to10.csv"), DataFrame))
revexpcurve140_lowymax_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/revexpcurve140_lowymax_posfeed_data40to10.csv"), DataFrame))
revexpcurve140_medymax_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/revexpcurve140_medymax_posfeed_data40to10.csv"), DataFrame))
revexpcurve140_highymax_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/revexpcurve140_highymax_posfeed_data40to10.csv"), DataFrame))

revexpcurve110_lowymax_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/revexpcurve110_lowymax_timedelay_data40to10.csv"), DataFrame))
revexpcurve110_medymax_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/revexpcurve110_medymax_timedelay_data40to10.csv"), DataFrame))
revexpcurve110_highymax_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/revexpcurve110_highymax_timedelay_data40to10.csv"), DataFrame))
revexpcurve140_lowymax_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/revexpcurve140_lowymax_timedelay_data40to10.csv"), DataFrame))
revexpcurve140_medymax_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/revexpcurve140_medymax_timedelay_data40to10.csv"), DataFrame))
revexpcurve140_highymax_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/revexpcurve140_highymax_timedelay_data40to10.csv"), DataFrame))

##Figure 2 Schematic
let 
    Irange = 0.0:0.01:20.0
    datahYmaxhyo = [yieldIII(I, 174.0, 10) for I in Irange]
    Ymaxrange = 140.0:1.0:210.0
    I0data140rel = [calc_I0(1.40, Ymax, EconomicPar()) for Ymax in Ymaxrange]
    I0data110rel = [calc_I0(1.10, Ymax, EconomicPar()) for Ymax in Ymaxrange]
    figure2schematicprep = figure(figsize = (5,6.5))
    subplot(2,1,1)
    plot(Irange, datahYmaxhyo, color = "black", linewidth = 3)
    xlabel("Inputs", fontsize = 20)
    ylabel("Yield", fontsize = 20)
    xticks([])
    yticks([])
    ylim(0.0, 180.0)
    subplot(2,1,2)
    plot(1 ./ I0data140rel, Ymaxrange, linestyle="solid", color="black", label="rev/exp = 1.40")
    plot(1 ./ I0data110rel, Ymaxrange, linestyle="dotted", color="black", label="rev/exp = 1.10")
    xlabel("1/I0", fontsize = 20)
    ylabel("Ymax", fontsize = 20)
    # xticks([])
    # yticks([])
    tight_layout()
    return figure2schematicprep
    # savefig(joinpath(abpath(), "figs/figure2schematicprep.pdf"))
end

## Positive feedbacks ##
#Figure 3
#Expected terminal assets residual (along rel profits curve)
let 
    lowymax_110 = expectedterminalassets_residual(revexpcurve110_lowymax_posfeed_data)
    medymax_110 = expectedterminalassets_residual(revexpcurve110_medymax_posfeed_data)
    highymax_110 = expectedterminalassets_residual(revexpcurve110_highymax_posfeed_data)
    lowymax_140 = expectedterminalassets_residual(revexpcurve140_lowymax_posfeed_data)
    medymax_140 = expectedterminalassets_residual(revexpcurve140_medymax_posfeed_data)
    highymax_140 = expectedterminalassets_residual(revexpcurve140_highymax_posfeed_data)
    posfeed_etaresidual_alongrelprof = figure(figsize=(4,6))    
    subplot(2,1,1)
    plot(lowymax_110[:,1], lowymax_110[:,2], linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_110[:,1], medymax_110[:,2], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_110[:,1], highymax_110[:,2], linestyle="dotted", color="black", label="High Ymax")
    title("1.10", fontsize=15)
    xlabel("Noise correlation", fontsize = 15)
    ylabel("EFAwNL - EFAwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    subplot(2,1,2)
    plot(lowymax_140[:,1], lowymax_140[:,2], linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_140[:,1], medymax_140[:,2], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_140[:,1], highymax_140[:,2], linestyle="dotted", color="black", label="High Ymax")
    title("1.40", fontsize=15)
    xlabel("Noise correlation", fontsize = 15)
    ylabel("EFAwNL - EFAwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    tight_layout()
    # return posfeed_etaresidual_alongrelprof
    savefig(joinpath(abpath(), "figs/posfeed_etaresidual_alongrelprof.pdf")) 
end

#Figure 4 Amplification or muting of white to reddened noise with positive feedback
#Variability along revenue/expenses curve
let 
    lowymax_110 = variabilityterminalassets_rednoise(revexpcurve110_lowymax_posfeed_data)
    medymax_110 = variabilityterminalassets_rednoise(revexpcurve110_medymax_posfeed_data)
    highymax_110 = variabilityterminalassets_rednoise(revexpcurve110_highymax_posfeed_data)
    lowymax_140 = variabilityterminalassets_rednoise(revexpcurve140_lowymax_posfeed_data)
    medymax_140 = variabilityterminalassets_rednoise(revexpcurve140_medymax_posfeed_data)
    highymax_140 = variabilityterminalassets_rednoise(revexpcurve140_highymax_posfeed_data)
    posfeed_var_alongrelprofcurve = figure(figsize=(4,6))    
    subplot(2,1,1)
    plot(lowymax_110[:,1], lowymax_110[:,4].+0.001, linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_110[:,1], medymax_110[:,4], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_110[:,1], highymax_110[:,4].-0.001, linestyle="dotted", color="black", label="High Ymax")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwNL/CVwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    ylim(1.02,1.15)
    title("Relative Profits = 1.10")
    legend()
    subplot(2,1,2)
    plot(lowymax_140[:,1], lowymax_140[:,4].+0.001, linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_140[:,1], medymax_140[:,4], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_140[:,1], highymax_140[:,4].-0.001, linestyle="dotted", color="black", label="High Ymax")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwNL/CVwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    ylim(1.02,1.15)
    title("Relative Profits = 1.40")
    legend()
    tight_layout()
    # return posfeed_var_alongrelprofcurve
    savefig(joinpath(abpath(), "figs/posfeed_var_alongrelprofcurve.pdf")) 
end 

#Figure 5 Resistance to yield disturbance
let 
    YmaxI0vals = calcYmaxI0vals_Ymaxrelprof(174, [1.10,1.40], EconomicPar())
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
    lowYmax = AVCK_MC_distance_ymaxrelprofcurve_data(150, 1.10:0.01:1.40, 0.02, EconomicPar())
    medYmax = AVCK_MC_distance_ymaxrelprofcurve_data(174, 1.10:0.01:1.40, 0.02, EconomicPar())
    highYmax = AVCK_MC_distance_ymaxrelprofcurve_data(200, 1.10:0.01:1.40, 0.02, EconomicPar())
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
    # return yielddisturbanceresistance
    savefig(joinpath(abpath(), "figs/yielddisturbanceresistance_relprofcurve.pdf"))
end 

## Time Delay ##
#Figure 6
#Expected final assets residuals along the relative profits curves
let 
    lowymax_110 = expectedterminalassets_residual(revexpcurve110_lowymax_timedelay_data)
    medymax_110 = expectedterminalassets_residual(revexpcurve110_medymax_timedelay_data)
    highymax_110 = expectedterminalassets_residual(revexpcurve110_highymax_timedelay_data)
    lowymax_140 = expectedterminalassets_residual(revexpcurve140_lowymax_timedelay_data)
    medymax_140 = expectedterminalassets_residual(revexpcurve140_medymax_timedelay_data)
    highymax_140 = expectedterminalassets_residual(revexpcurve140_highymax_timedelay_data)
    timedelay_etaresidual_alongrelprofitcurve = figure(figsize=(4,6))    
    subplot(2,1,1)
    plot(lowymax_110[:,1], lowymax_110[:,2], linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_110[:,1], medymax_110[:,2], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_110[:,1], highymax_110[:,2], linestyle="dotted", color="black", label="High Ymax")
    title("1.10", fontsize=15)
    xlabel("Noise correlation", fontsize = 15)
    ylabel("EFAwNL - EFAwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    ylim(-400,850)
    legend()
    subplot(2,1,2)
    plot(lowymax_140[:,1], lowymax_140[:,2], linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_140[:,1], medymax_140[:,2], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_140[:,1], highymax_140[:,2], linestyle="dotted", color="black", label="High Ymax")
    title("1.40", fontsize=15)
    xlabel("Noise correlation", fontsize = 15)
    ylabel("EFAwNL - EFAwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    ylim(-400,850)
    legend()
    tight_layout()
    # return timedelay_etaresidual_alongrelprofitcurve
    savefig(joinpath(abpath(), "figs/timedelay_etaresidual_alongrelprofitcurve.pdf")) 
end


#Figure 7 Amplification or muting of white to reddened noise with time delay
#Variability along relative profits curves
let 
    lowymax_110 = variabilityterminalassets_rednoise(revexpcurve110_lowymax_timedelay_data)
    medymax_110 = variabilityterminalassets_rednoise(revexpcurve110_medymax_timedelay_data)
    highymax_110 = variabilityterminalassets_rednoise(revexpcurve110_highymax_timedelay_data)
    lowymax_140 = variabilityterminalassets_rednoise(revexpcurve140_lowymax_timedelay_data)
    medymax_140 = variabilityterminalassets_rednoise(revexpcurve140_medymax_timedelay_data)
    highymax_140 = variabilityterminalassets_rednoise(revexpcurve140_highymax_timedelay_data)
    timedelay_var_alongrelprofcurve = figure(figsize=(4,6))    
    subplot(2,1,1)
    plot(lowymax_110[:,1], lowymax_110[:,4].+0.0017, linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_110[:,1], medymax_110[:,4], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_110[:,1], highymax_110[:,4].-0.0017, linestyle="dotted", color="black", label="High Ymax")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwNL/CVwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    ylim(0.80,1.05)
    title("Relative Profits = 1.10")
    legend()
    subplot(2,1,2)
    plot(lowymax_140[:,1], lowymax_140[:,4].+0.0017, linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_140[:,1], medymax_140[:,4], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_140[:,1], highymax_140[:,4].-0.0017, linestyle="dotted", color="black", label="High Ymax")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwNL/CVwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    ylim(0.80,1.05)
    title("Relative Profits = 1.40")
    legend()
    tight_layout()
    # return timedelay_var_alongrelprofcurve
    savefig(joinpath(abpath(), "figs/timedelay_var_alongrelprofcurve.pdf")) 
end

# Figure 8 - Resistance to error
let 
    YmaxI0vals = calcYmaxI0vals_Ymaxrelprof(174, [1.10,1.40], EconomicPar())
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
    lowYmax = AVCmin_MR_distance_ymaxrelprofcurve_data(150, 1.10:0.01:1.40, Irange, EconomicPar())
    medYmax = AVCmin_MR_distance_ymaxrelprofcurve_data(174, 1.10:0.01:1.40, Irange, EconomicPar())
    highYmax = AVCmin_MR_distance_ymaxrelprofcurve_data(200, 1.10:0.01:1.40, Irange, EconomicPar())
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
    # return errorresistance
    savefig(joinpath(abpath(), "figs/errorresistance_relprofcurveymax.pdf"))
end 

### Supporting Information
include("AgriEco_supportinginformation.jl")

##Table SI1
df = DataFrame(RP = [1.40, 1.40, 1.40, 1.10, 1.10, 1.10], Ymax = [200, 174, 150, 200, 174, 150])

@chain df begin
  @transform!(@byrow :IO = calc_I0(:RP, :Ymax, EconomicPar()))
  @transform!(@byrow :InEff=1/:IO)
  @transform!(@byrow :FourFifthsInputs=2*sqrt(:IO))
  @transform!(@byrow :DeltaFourFifths=(:FourFifthsInputs-1)*100)
end

#Maintaining geometry while changing I₀ and c
let 
    newI0 = 2500
    newc = calc_c(1.40, 174, newI0, EconomicPar())
    inputsyield1 = maxprofitIII_vals(174, 0.25, EconomicPar())
    inputsyield2 = maxprofitIII_vals(174, 2500, EconomicPar(c=newc))
    Irange = 0.0:0.01:250.0
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
    I0data275abs = [calc_I0_abs(275, Ymax, EconomicPar()) for Ymax in Ymaxrange]
    I0data175abs = [calc_I0_abs(175, Ymax, EconomicPar()) for Ymax in Ymaxrange]
    I0data75abs = [calc_I0_abs(75, Ymax, EconomicPar()) for Ymax in Ymaxrange]
    I0data140rel = [calc_I0(1.40, Ymax, EconomicPar()) for Ymax in Ymaxrange]
    I0data125rel = [calc_I0(1.25, Ymax, EconomicPar()) for Ymax in Ymaxrange]
    I0data110rel = [calc_I0(1.10, Ymax, EconomicPar()) for Ymax in Ymaxrange]
    relvsabsplot = figure(figsize = (6,4))
    plot(1 ./ I0data75abs, Ymaxrange, color="#440154FF", label="Rev-Exp = \$75")
    plot(1 ./ I0data175abs,Ymaxrange, color="#1F968BFF", label="Rev-Exp = \$175")
    plot(1 ./ I0data275abs, Ymaxrange, color="#73D055FF", label="Rev-Exp = \$275")
    plot(1 ./ I0data140rel, Ymaxrange, linewidth=3, linestyle="solid", color="black", label="Rev/Exp = 1.40")
    plot(1 ./ I0data125rel, Ymaxrange, linewidth=3, linestyle="dashed", color="black", label="Rev/Exp = 1.25")
    plot(1 ./ I0data110rel, Ymaxrange, linewidth=3, linestyle="dotted", color="black", label="Rev/Exp = 1.10")
    xlabel("1/I0", fontsize = 15)
    ylabel("Ymax", fontsize = 15)
    legend()
    # return relvsabsplot
    savefig(joinpath(abpath(), "figs/relvsabsplot.pdf"))
end

# Separating CVwNL and CVwoNL
#CVwoNL (NOTE that the CVwoNL is exactly the same whether generated from the positive feedback or time delay functions)
let 
    lowymax_110 = variabilityterminalassets_rednoise(revexpcurve110_lowymax_timedelay_data)
    medymax_110 = variabilityterminalassets_rednoise(revexpcurve110_medymax_timedelay_data)
    highymax_110 = variabilityterminalassets_rednoise(revexpcurve110_highymax_timedelay_data)
    lowymax_140 = variabilityterminalassets_rednoise(revexpcurve140_lowymax_timedelay_data)
    medymax_140 = variabilityterminalassets_rednoise(revexpcurve140_medymax_timedelay_data)
    highymax_140 = variabilityterminalassets_rednoise(revexpcurve140_highymax_timedelay_data)
    varwoNL_changingrevexp = figure(figsize=(4,6))    
    subplot(2,1,1)
    plot(lowymax_110[:,1], lowymax_110[:,3].*1.025, linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_110[:,1], medymax_110[:,3], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_110[:,1], highymax_110[:,3].*0.975, linestyle="dotted", color="black", label="High Ymax")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    title("Relative Profits = 1.10")
    legend()
    subplot(2,1,2)
    plot(lowymax_140[:,1], lowymax_140[:,3].*1.025, linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_140[:,1], medymax_140[:,3], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_140[:,1], highymax_140[:,3].*0.975, linestyle="dotted", color="black", label="High Ymax")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    title("Relative Profits = 1.40")
    legend()
    tight_layout()
    # return varwoNL_changingrevexp
    savefig(joinpath(abpath(), "figs/varwoNL_relprofcurve.pdf")) 
end

#CVwNL positive feedback
let 
    lowymax_110 = variabilityterminalassets_rednoise(revexpcurve110_lowymax_posfeed_data)
    medymax_110 = variabilityterminalassets_rednoise(revexpcurve110_medymax_posfeed_data)
    highymax_110 = variabilityterminalassets_rednoise(revexpcurve110_highymax_posfeed_data)
    lowymax_140 = variabilityterminalassets_rednoise(revexpcurve140_lowymax_posfeed_data)
    medymax_140 = variabilityterminalassets_rednoise(revexpcurve140_medymax_posfeed_data)
    highymax_140 = variabilityterminalassets_rednoise(revexpcurve140_highymax_posfeed_data)
    posfeed_varwNL_changingrevexp = figure(figsize=(4,6))    
    subplot(2,1,1)
    plot(lowymax_110[:,1], lowymax_110[:,2].*1.025, linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_110[:,1], medymax_110[:,2], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_110[:,1], highymax_110[:,2].*0.975, linestyle="dotted", color="black", label="High Ymax")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    title("Relative Profits = 1.10")
    subplot(2,1,2)
    plot(lowymax_140[:,1], lowymax_140[:,2].*1.025, linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_140[:,1], medymax_140[:,2], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_140[:,1], highymax_140[:,2].*0.975, linestyle="dotted", color="black", label="High Ymax")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    title("Relative Profits = 1.40")
    tight_layout()
    # return posfeed_varwNL_changingrevexp
    savefig(joinpath(abpath(), "figs/posfeed_varwNL_relprofcurve.pdf")) 
end

#CVwNL time delay
let 
    lowymax_110 = variabilityterminalassets_rednoise(revexpcurve110_lowymax_timedelay_data)
    medymax_110 = variabilityterminalassets_rednoise(revexpcurve110_medymax_timedelay_data)
    highymax_110 = variabilityterminalassets_rednoise(revexpcurve110_highymax_timedelay_data)
    lowymax_140 = variabilityterminalassets_rednoise(revexpcurve140_lowymax_timedelay_data)
    medymax_140 = variabilityterminalassets_rednoise(revexpcurve140_medymax_timedelay_data)
    highymax_140 = variabilityterminalassets_rednoise(revexpcurve140_highymax_timedelay_data)
    timedelays_varwNL_changingrevexp = figure(figsize=(4,6))    
    subplot(2,1,1)
    plot(lowymax_110[:,1], lowymax_110[:,2].*1.025, linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_110[:,1], medymax_110[:,2], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_110[:,1], highymax_110[:,2].*0.975, linestyle="dotted", color="black", label="High Ymax")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    title("Relative Profits = 1.10")
    subplot(2,1,2)
    plot(lowymax_140[:,1], lowymax_140[:,2].*1.025, linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_140[:,1], medymax_140[:,2], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_140[:,1], highymax_140[:,2].*0.975, linestyle="dotted", color="black", label="High Ymax")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    title("Relative Profits = 1.40")
    tight_layout()
    # return timedelays_varwNL_changingrevexp
    savefig(joinpath(abpath(), "figs/timedelays_varwNL_relprofcurve.pdf")) 
end 


# #Expected Terminal Assets (along rel profits curve) - Positive feedbacks
# let 
#     lowymax_108 = expectedterminalassets_absolute(revexpcurve108_lowymax_posfeed_data)
#     medymax_108 = expectedterminalassets_absolute(revexpcurve108_medymax_posfeed_data)
#     highymax_108 = expectedterminalassets_absolute(revexpcurve108_highymax_posfeed_data)
#     lowymax_133 = expectedterminalassets_absolute(revexpcurve133_lowymax_posfeed_data)
#     medymax_133 = expectedterminalassets_absolute(revexpcurve133_medymax_posfeed_data)
#     highymax_133 = expectedterminalassets_absolute(revexpcurve133_highymax_posfeed_data)
#     posfeed_eta_alongrelprofcurve = figure(figsize=(4,6))    
#     subplot(2,1,1)
#     plot(lowymax_108[:,1], lowymax_108[:,2], linestyle="solid", color="black", label="Low Ymax")
#     plot(medymax_108[:,1], medymax_108[:,2], linestyle="dashed", color="black", label="Med Ymax")
#     plot(highymax_108[:,1], highymax_108[:,2], linestyle="dotted", color="black", label="High Ymax")
#     title("Relative profits = 1.08", fontsize=15)
#     xlabel("Noise correlation", fontsize = 15)
#     ylabel("Expected Final Assets", fontsize = 15)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     legend()
#     subplot(2,1,2)
#     plot(lowymax_133[:,1], lowymax_133[:,2], linestyle="solid", color="black", label="Low Ymax")
#     plot(medymax_133[:,1], medymax_133[:,2], linestyle="dashed", color="black", label="Med Ymax")
#     plot(highymax_133[:,1], highymax_133[:,2], linestyle="dotted", color="black", label="High Ymax")
#     title("Relative profits = 1.33", fontsize=15)
#     xlabel("Noise correlation", fontsize = 15)
#     ylabel("Expected Final Assets", fontsize = 15)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     legend()
#     tight_layout()
#     # return posfeed_eta_alongrelprofcurve
#     savefig(joinpath(abpath(), "figs/posfeed_eta_alongrelprofcurve.pdf")) 
# end

# #Expected Terminal Assets (along rel profits curve) - Time delay
# let 
#     lowymax_108 = expectedterminalassets_absolute(revexpcurve108_lowymax_timedelay_data)
#     medymax_108 = expectedterminalassets_absolute(revexpcurve108_medymax_timedelay_data)
#     highymax_108 = expectedterminalassets_absolute(revexpcurve108_highymax_timedelay_data)
#     lowymax_133 = expectedterminalassets_absolute(revexpcurve133_lowymax_timedelay_data)
#     medymax_133 = expectedterminalassets_absolute(revexpcurve133_medymax_timedelay_data)
#     highymax_133 = expectedterminalassets_absolute(revexpcurve133_highymax_timedelay_data)
#     timedelays_eta_alongrelprofcurve = figure(figsize=(4,6))    
#     subplot(2,1,1)
#     plot(lowymax_108[:,1], lowymax_108[:,2], linestyle="solid", color="black", label="Low Ymax")
#     plot(medymax_108[:,1], medymax_108[:,2], linestyle="dashed", color="black", label="Med Ymax")
#     plot(highymax_108[:,1], highymax_108[:,2], linestyle="dotted", color="black", label="High Ymax")
#     title("Relative profits = 1.08", fontsize=15)
#     xlabel("Noise correlation", fontsize = 15)
#     ylabel("Expected Final Assets", fontsize = 15)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     legend()
#     subplot(2,1,2)
#     plot(lowymax_133[:,1], lowymax_133[:,2], linestyle="solid", color="black", label="Low Ymax")
#     plot(medymax_133[:,1], medymax_133[:,2], linestyle="dashed", color="black", label="Med Ymax")
#     plot(highymax_133[:,1], highymax_133[:,2], linestyle="dotted", color="black", label="High Ymax")
#     title("Relative profits = 1.33", fontsize=15)
#     xlabel("Noise correlation", fontsize = 15)
#     ylabel("Expected Final Assets", fontsize = 15)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     legend()
#     tight_layout()
#     # return timedelays_eta_alongrelprofcurve
#     savefig(joinpath(abpath(), "figs/timedelays_eta_alongrelprofcurve.pdf")) 
# end 

# function changerelative(data)
#     ini=data[1,2]
#     max=maximum(data[:,2])
#     min=minimum(data[:,2])
#     return (max-min)/ini
# end


# #Checking whether reduction in ETA residual relative to absolute value
# let 
#     lowymax_108 = expectedterminalassets_absolute(revexpcurve108_lowymax_timedelay_data)
#     medymax_108 = expectedterminalassets_absolute(revexpcurve108_medymax_timedelay_data)
#     highymax_108 = expectedterminalassets_absolute(revexpcurve108_highymax_timedelay_data)
#     lowymax_133 = expectedterminalassets_absolute(revexpcurve133_lowymax_timedelay_data)
#     medymax_133 = expectedterminalassets_absolute(revexpcurve133_medymax_timedelay_data)
#     highymax_133 = expectedterminalassets_absolute(revexpcurve133_highymax_timedelay_data)
#     low108change = changerelative(lowymax_108) 
#     med108change = changerelative(medymax_108)
#     high108change = changerelative(highymax_108)
#     low133change = changerelative(lowymax_133)
#     med133change = changerelative(medymax_133)
#     high133change = changerelative(highymax_133)
#     vals = [low108change,med108change,high108change,low133change,med133change,high133change]  
#     params = ["low108","med108","high108","low133","med133","high133"]
#     return hcat(params,vals)
# end


# #Standardizing by sd of noise removes differences between low and high ymax in both positive feedback and time delay
# #but does it make sense to standarized by sd of noise for positive feedback (because by definition the sds will be different)


# #Standard Deviation and mean for time delay mechanism
# constrainYmax_133_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainYmax_133_timedelay_data_CV.csv"), DataFrame))
# constrainYmax_108_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainYmax_108_timedelay_data_CV.csv"), DataFrame))

# let
#     highdata = variabilityterminalassets_breakdown(constrainYmax_133_timedelay_data_CV)
#     lowdata = variabilityterminalassets_breakdown(constrainYmax_108_timedelay_data_CV)
#     variabilitybreakdown = figure()
#     subplot(2,2,1)
#     plot(highdata[:,1], highdata[:,2])
#     plot(highdata[:,1], highdata[:,4])
#     xlabel("Autocorrelation", fontsize=15)
#     ylabel("Standard Deviation", fontsize=15)
#     ylim(0,3500)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     subplot(2,2,2)
#     plot(lowdata[:,1], lowdata[:,2])
#     plot(lowdata[:,1], lowdata[:,4])
#     xlabel("Autocorrelation", fontsize=15)
#     ylabel("Standard Deviation", fontsize=15)
#     ylim(0,3500)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     subplot(2,2,3)
#     plot(highdata[:,1], highdata[:,3])
#     plot(highdata[:,1], highdata[:,5])
#     xlabel("Autocorrelation", fontsize=15)
#     ylabel("Mean", fontsize=15)
#     ylim(6400, 7200)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     subplot(2,2,4)
#     plot(lowdata[:,1], lowdata[:,3])
#     plot(lowdata[:,1], lowdata[:,5])
#     xlabel("Autocorrelation", fontsize=15)
#     ylabel("Mean", fontsize=15)
#     ylim(1600, 2400)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     tight_layout()
#     return variabilitybreakdown
# end

# let 
#     Ymaxrange = 120.0:1.0:200.0
#     I0data225abs = [calc_I0_abs(225, Ymax, 139, 6.70) for Ymax in Ymaxrange]
#     I0data75abs = [calc_I0_abs(75, Ymax, 139, 6.70) for Ymax in Ymaxrange]
#     abs = figure()
#     plot(1 ./ I0data225abs, Ymaxrange, linestyle="dashed", color="black", label="rev-exp = 225")
#     plot(1 ./ I0data75abs, Ymaxrange, linestyle="dotted", color="black", label="rev-exp = 75")
#     xlabel("1/I0", fontsize = 20)
#     ylabel("Ymax", fontsize = 20)
#     return abs
#     # savefig(joinpath(abpath(), "figs/abs_constrainedgraph.pdf"))
# end

# # Showing that changing I0 and c keeps geometry the same (as long as rev/exp is constrained)
# #setting I0 and c arbitrarily but still ratio is 1.33

# calc_c(1.33, 174, 10, 6.70)
# parratio2 = FarmBasePar(I0 = 10, Ymax = 174, p = 6.70, c = 138.59335)

# param_ratio(FarmBasePar(I0 = 10, Ymax = 120, p = 6.70, c = 138.59335))
# param_ratio(FarmBasePar(I0 = 5, Ymax = 120, p = 6.70, c = 138.59335))
# param_ratio(parratio2)
# let 
#     par1 = FarmBasePar(I0 = 10, Ymax = 174, p = 6.70, c = 138.59335)
#     par2 = FarmBasePar(I0 = 10, Ymax = 120, p = 6.70, c = 138.59335)
#     par3 = FarmBasePar(I0 = 5, Ymax = 174, p = 6.70, c = 138.59335)
#     par4 = FarmBasePar(I0 = 5, Ymax = 120, p = 6.70, c = 138.59335)
#     Irange = 0.0:0.01:10.0
#     Yield1 = [yieldIII(I, par1) for I in Irange]
#     MC1 = [margcostIII(I, par1) for I in Irange]
#     AVC1 = [avvarcostIII(I,par1) for I in Irange]
#     Yield2 = [yieldIII(I, par2) for I in Irange]
#     MC2 = [margcostIII(I, par2) for I in Irange]
#     AVC2 = [avvarcostIII(I,par2) for I in Irange]
#     Yield3 = [yieldIII(I, par3) for I in Irange]
#     MC3 = [margcostIII(I, par3) for I in Irange]
#     AVC3 = [avvarcostIII(I,par3) for I in Irange]
#     Yield4 = [yieldIII(I, par4) for I in Irange]
#     MC4 = [margcostIII(I, par4) for I in Irange]
#     AVC4 = [avvarcostIII(I,par4) for I in Irange]
#     costcurves = figure()
#     subplot(2,2,1)
#     plot(Yield1, MC1, color="blue", label="MC")
#     plot(Yield1, AVC1, color="orange", label="AVC")
#     hlines(par1.p, 0.0, 174, colors="black", label = "MR")
#     legend()
#     ylim(0.0, 50.0)
#     # xlim(0.0, 1.0)
#     xlabel("Yield (Q)")
#     ylabel("Revenue & Cost")
#     subplot(2,2,2)
#     plot(Yield2, MC2, color="blue", label="MC")
#     plot(Yield2, AVC2, color="orange", label="AVC")
#     hlines(par2.p, 0.0, 174, colors="black", label = "MR")
#     legend()
#     ylim(0.0, 50.0)
#     # xlim(0.0, 1.0)
#     xlabel("Yield (Q)")
#     ylabel("Revenue & Cost")
#     subplot(2,2,3)
#     plot(Yield3, MC3, color="blue", label="MC")
#     plot(Yield3, AVC3, color="orange", label="AVC")
#     hlines(par3.p, 0.0, 174, colors="black", label = "MR")
#     legend()
#     ylim(0.0, 50.0)
#     # xlim(0.0, 1.0)
#     xlabel("Yield (Q)")
#     ylabel("Revenue & Cost")
#     subplot(2,2,4)
#     plot(Yield4, MC4, color="blue", label="MC")
#     plot(Yield4, AVC4, color="orange", label="AVC")
#     hlines(par4.p, 0.0, 174, colors="black", label = "MR")
#     legend()
#     ylim(0.0, 50.0)
#     # xlim(0.0, 1.0)
#     xlabel("Yield (Q)")
#     ylabel("Revenue & Cost")
#     tight_layout()
#     return costcurves
#     # savefig(joinpath(abpath(), "figs/costcurves.png"))
# end  


# #checking what happens between low ymax and hymax our assumption
# let 
#     YmaxI0valshigh = calcYmaxI0vals_Ymaxrelprof(200, [1.08,1.33], EconomicPar())
#     YmaxI0valslow = calcYmaxI0vals_Ymaxrelprof(150, [1.08,1.33], EconomicPar())
#     inputsyield1high = maxprofitIII_vals(YmaxI0valshigh[1,1], YmaxI0valshigh[1,2], EconomicPar())
#     inputsyield2high = maxprofitIII_vals(YmaxI0valshigh[2,1], YmaxI0valshigh[2,2], EconomicPar())
#     inputsyield1low = maxprofitIII_vals(YmaxI0valslow[1,1], YmaxI0valslow[1,2], EconomicPar())
#     inputsyield2low = maxprofitIII_vals(YmaxI0valslow[2,1], YmaxI0valslow[2,2], EconomicPar())
#     Irange = 0.0:0.01:20.0
#     Yrange = 0.0:0.1:180.0
#     Yield1high = [yieldIII(I, YmaxI0valshigh[1,1], YmaxI0valshigh[1,2]) for I in Irange]
#     MC1high = [margcostIII(I, YmaxI0valshigh[1,1], YmaxI0valshigh[1,2], EconomicPar()) for I in Irange]
#     AVC1high = [avvarcostIII(I, YmaxI0valshigh[1,1], YmaxI0valshigh[1,2], EconomicPar()) for I in Irange]
#     Yield2high = [yieldIII(I, YmaxI0valshigh[2,1], YmaxI0valshigh[2,2]) for I in Irange]
#     MC2high = [margcostIII(I, YmaxI0valshigh[2,1], YmaxI0valshigh[2,2], EconomicPar()) for I in Irange]
#     AVC2high = [avvarcostIII(I, YmaxI0valshigh[2,1], YmaxI0valshigh[2,2], EconomicPar()) for I in Irange]
#     Yield1low = [yieldIII(I, YmaxI0valslow[1,1], YmaxI0valslow[1,2]) for I in Irange]
#     MC1low = [margcostIII(I, YmaxI0valslow[1,1], YmaxI0valslow[1,2], EconomicPar()) for I in Irange]
#     AVC1low = [avvarcostIII(I, YmaxI0valslow[1,1], YmaxI0valslow[1,2], EconomicPar()) for I in Irange]
#     Yield2low = [yieldIII(I, YmaxI0valslow[2,1], YmaxI0valslow[2,2]) for I in Irange]
#     MC2low = [margcostIII(I, YmaxI0valshigh[2,1], YmaxI0valslow[2,2], EconomicPar()) for I in Irange]
#     AVC2low = [avvarcostIII(I, YmaxI0valslow[2,1], YmaxI0valslow[2,2], EconomicPar()) for I in Irange]
#     errorresistance = figure(figsize=(10,8))
#     subplot(2,2,1)
#     plot(Yield1high, MC1high, color="#238A8DFF", label="Marginal Costs", linewidth = 3)
#     plot(Yield1high, AVC1high, color="#404788FF", label="Average Variable Costs", linewidth = 3)
#     hlines(EconomicPar().p, 0.0, 200.0, colors="#FDE725FF", label = "Marginal Revenue", linewidth = 3)
#     vlines(inputsyield1high[2], 0.0, 10.0, colors="black", linestyle="dashed", linewidth=2)
#     ylim(0.0, 10.0)
#     xlim(0.0, 174.0)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     legend()
#     xlabel("Yield", fontsize = 15)
#     ylabel("Revenue & Cost", fontsize = 15)
#     subplot(2,2,2)
#     plot(Yield2high, MC2high, color="#238A8DFF", label="Marginal Costs", linewidth = 3)
#     plot(Yield2high, AVC2high, color="#404788FF", label="Average Variable Costs", linewidth = 3)
#     hlines(EconomicPar().p, 0.0, 200.0, colors="#FDE725FF", label = "Marginal Revenue", linewidth = 3)
#     vlines(inputsyield2high[2], 0.0, 10.0, colors="black", linestyle="dashed", linewidth=2)
#     ylim(0.0, 10.0)
#     xlim(0.0, 174.0)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     legend()
#     xlabel("Yield", fontsize = 15)
#     ylabel("Revenue & Cost", fontsize = 15)
#     subplot(2,2,3)
#     plot(Yield1low, MC1low, color="#238A8DFF", label="Marginal Costs", linewidth = 3)
#     plot(Yield1low, AVC1low, color="#404788FF", label="Average Variable Costs", linewidth = 3)
#     hlines(EconomicPar().p, 0.0, 150.0, colors="#FDE725FF", label = "Marginal Revenue", linewidth = 3)
#     vlines(inputsyield1low[2], 0.0, 10.0, colors="black", linestyle="dashed", linewidth=2)
#     ylim(0.0, 10.0)
#     xlim(0.0, 174.0)
#     xticks(fontsize=12)
#     yticks(fontsize=12)
#     legend()
#     xlabel("Yield", fontsize = 15)
#     ylabel("Revenue & Cost", fontsize = 15)
#     subplot(2,2,4)
#     plot(Yield2low, MC2low, color="#238A8DFF", label="Marginal Costs", linewidth = 3)
#     plot(Yield2low, AVC2low, color="#404788FF", label="Average Variable Costs", linewidth = 3)
#     hlines(EconomicPar().p, 0.0, 150.0, colors="#FDE725FF", label = "Marginal Revenue", linewidth = 3)
#     vlines(inputsyield2low[2], 0.0, 10.0, colors="black", linestyle="dashed", linewidth=2)
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

# let 
#     YmaxI0valshigh = calcYmaxI0vals_Ymaxrelprof(200, [1.08,1.33], EconomicPar())
#     YmaxI0valslow = calcYmaxI0vals_Ymaxrelprof(150, [1.08,1.33], EconomicPar())
#     inputsyield1high = maxprofitIII_vals(YmaxI0valshigh[1,1], YmaxI0valshigh[1,2], EconomicPar())
#     avc1high = (inputsyield1high[1]*863.56)/inputsyield1high[2]
#     inputsyield1low = maxprofitIII_vals(YmaxI0valslow[1,1], YmaxI0valslow[1,2], EconomicPar())
#     avc1low = (inputsyield1low[1]*863.56)/inputsyield1low[2]
#     return avc1low, avc1high
# end