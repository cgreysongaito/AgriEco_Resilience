include("packages.jl")
include("AgriEco_commoncode.jl")

#Data

OERatiocurve071_lowymax_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/OERatiocurve071_lowymax_posfeed_data.csv"), DataFrame))
OERatiocurve071_medymax_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/OERatiocurve071_medymax_posfeed_data.csv"), DataFrame))
OERatiocurve071_highymax_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/OERatiocurve071_highymax_posfeed_data.csv"), DataFrame))
OERatiocurve09_lowymax_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/OERatiocurve09_lowymax_posfeed_data.csv"), DataFrame))
OERatiocurve09_medymax_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/OERatiocurve09_medymax_posfeed_data.csv"), DataFrame))
OERatiocurve09_highymax_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/OERatiocurve09_highymax_posfeed_data.csv"), DataFrame))
OERatiocurve099_lowymax_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/OERatiocurve099_lowymax_posfeed_data.csv"), DataFrame))
OERatiocurve099_medymax_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/OERatiocurve099_medymax_posfeed_data.csv"), DataFrame))
OERatiocurve099_highymax_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/OERatiocurve099_highymax_posfeed_data.csv"), DataFrame))


OERatiocurve071_lowymax_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/OERatiocurve071_lowymax_timedelay_data.csv"), DataFrame))
OERatiocurve071_medymax_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/OERatiocurve071_medymax_timedelay_data.csv"), DataFrame))
OERatiocurve071_highymax_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/OERatiocurve071_highymax_timedelay_data.csv"), DataFrame))
OERatiocurve09_lowymax_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/OERatiocurve09_lowymax_timedelay_data.csv"), DataFrame))
OERatiocurve09_medymax_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/OERatiocurve09_medymax_timedelay_data.csv"), DataFrame))
OERatiocurve09_highymax_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/OERatiocurve09_highymax_timedelay_data.csv"), DataFrame))
OERatiocurve099_lowymax_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/OERatiocurve099_lowymax_timedelay_data.csv"), DataFrame))
OERatiocurve099_medymax_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/OERatiocurve099_medymax_timedelay_data.csv"), DataFrame))
OERatiocurve099_highymax_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/OERatiocurve099_highymax_timedelay_data.csv"), DataFrame))


##Figure 2 Schematic
let 
    Irange = 0.0:0.01:20.0
    datahYmaxhyo = [yieldIII(I, 174.0, 10) for I in Irange]
    Ymaxrange = 140.0:1.0:210.0
    I0data09OERatio = [calc_I0(0.90, Ymax, EconomicPar()) for Ymax in Ymaxrange]
    I0data071OERatio = [calc_I0(0.71, Ymax, EconomicPar()) for Ymax in Ymaxrange]
    figure2schematicprep = figure(figsize = (5,6.5))
    subplot(2,1,1)
    plot(Irange, datahYmaxhyo, color = "black", linewidth = 3)
    xlabel("Inputs", fontsize = 20)
    ylabel("Yield", fontsize = 20)
    xticks([])
    yticks([])
    ylim(0.0, 180.0)
    subplot(2,1,2)
    plot(1 ./ I0data09OERatio, Ymaxrange, linestyle="dotted", color="black", label="rev/exp = 0.90")
    plot(1 ./ I0data071OERatio, Ymaxrange, linestyle="solid", color="black", label="rev/exp = 1.10")
    xlabel("1/I0", fontsize = 20)
    ylabel("Ymax", fontsize = 20)
    xticks([])
    yticks([])
    tight_layout()
    # return figure2schematicprep
    savefig(joinpath(abpath(), "figs/figure2schematicprep.pdf"))
end

## Positive feedbacks ##
#Figure 3
#Expected final assets residual (along OER curve)
let 
    lowymax_099 = expectedfinalassets_residual(OERatiocurve099_lowymax_posfeed_data)
    medymax_099 = expectedfinalassets_residual(OERatiocurve099_medymax_posfeed_data)
    highymax_099 = expectedfinalassets_residual(OERatiocurve099_highymax_posfeed_data)
    lowymax_09 = expectedfinalassets_residual(OERatiocurve09_lowymax_posfeed_data)
    medymax_09 = expectedfinalassets_residual(OERatiocurve09_medymax_posfeed_data)
    highymax_09 = expectedfinalassets_residual(OERatiocurve09_highymax_posfeed_data)
    lowymax_071 = expectedfinalassets_residual(OERatiocurve071_lowymax_posfeed_data)
    medymax_071 = expectedfinalassets_residual(OERatiocurve071_medymax_posfeed_data)
    highymax_071 = expectedfinalassets_residual(OERatiocurve071_highymax_posfeed_data)
    posfeed_efaresidual_alongOERatiocurve = figure(figsize=(4,6))    
    subplot(2,1,1)
    plot(lowymax_071[:,1], lowymax_071[:,2], linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_071[:,1], medymax_071[:,2], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_071[:,1], highymax_071[:,2], linestyle="dotted", color="black", label="High Ymax")
    title("OER = 0.71", fontsize=15)
    xlabel("Noise correlation", fontsize = 15)
    ylabel("EFAwNL - EFAwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    subplot(2,1,2)
    plot(lowymax_09[:,1], lowymax_09[:,2], linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_09[:,1], medymax_09[:,2], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_09[:,1], highymax_09[:,2], linestyle="dotted", color="black", label="High Ymax")
    title("OER = 0.90", fontsize=15)
    xlabel("Noise correlation", fontsize = 15)
    ylabel("EFAwNL - EFAwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    tight_layout()
    # return posfeed_efaresidual_alongOERatiocurve
    savefig(joinpath(abpath(), "figs/posfeed_efaresidual_alongOERatiocurve.pdf")) 
end

#Figure 4 Amplification or muting of white to reddened noise with positive feedback
#Variability along OER curve
let 
    lowymax_09 = variabilityfinalassets_rednoise(OERatiocurve09_lowymax_posfeed_data)
    medymax_09 = variabilityfinalassets_rednoise(OERatiocurve09_medymax_posfeed_data)
    highymax_09 = variabilityfinalassets_rednoise(OERatiocurve09_highymax_posfeed_data)
    lowymax_071 = variabilityfinalassets_rednoise(OERatiocurve071_lowymax_posfeed_data)
    medymax_071 = variabilityfinalassets_rednoise(OERatiocurve071_medymax_posfeed_data)
    highymax_071 = variabilityfinalassets_rednoise(OERatiocurve071_highymax_posfeed_data)
    posfeed_var_alongOERatiocurve = figure(figsize=(4,6))    
    subplot(2,1,1)
    plot(lowymax_071[:,1], lowymax_071[:,4].+0.001, linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_071[:,1], medymax_071[:,4], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_071[:,1], highymax_071[:,4].-0.001, linestyle="dotted", color="black", label="High Ymax")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwNL/CVwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    ylim(1.00,1.14)
    title("OER = 0.71")
    legend()
    subplot(2,1,2)
    plot(lowymax_09[:,1], lowymax_09[:,4].+0.001, linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_09[:,1], medymax_09[:,4], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_09[:,1], highymax_09[:,4].-0.001, linestyle="dotted", color="black", label="High Ymax")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwNL/CVwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    ylim(1.00,1.14)
    title("OER = 0.90")
    legend()
    tight_layout()
    # return posfeed_var_alongOERatiocurve
    savefig(joinpath(abpath(), "figs/posfeed_var_alongOERatiocurve.pdf")) 
end 

#Figure 5 Resistance to yield disturbance
let 
    YmaxI0vals = calcYmaxI0vals_YmaxOERatio(174, [0.71,0.9], EconomicPar())
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
    lowYmax = AVCK_MC_distance_ymaxOERatiocurve_data(150, 0.70:0.01:0.9, 0.02, EconomicPar())
    medYmax = AVCK_MC_distance_ymaxOERatiocurve_data(174, 0.70:0.01:0.9, 0.02, EconomicPar())
    highYmax = AVCK_MC_distance_ymaxOERatiocurve_data(200, 0.70:0.01:0.9, 0.02, EconomicPar())
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
    xlabel("Operating Expense Ratio", fontsize = 15)
    ylabel("Standardized \nResistance to yield disturbance", fontsize = 15)
    xticks([0.70, 0.75, 0.80, 0.85, 0.90], fontsize=12)
    yticks(fontsize=12)
    legend()
    tight_layout()
    # return yielddisturbanceresistance
    savefig(joinpath(abpath(), "figs/yielddisturbanceresistance_OERcurve.pdf"))
end 

## Time Delay ##
#Figure 6
#Expected final assets residuals along the relative profits curves
let 
    lowymax_09 = expectedfinalassets_residual(OERatiocurve09_lowymax_timedelay_data)
    medymax_09 = expectedfinalassets_residual(OERatiocurve09_medymax_timedelay_data)
    highymax_09 = expectedfinalassets_residual(OERatiocurve09_highymax_timedelay_data)
    lowymax_071 = expectedfinalassets_residual(OERatiocurve071_lowymax_timedelay_data)
    medymax_071 = expectedfinalassets_residual(OERatiocurve071_medymax_timedelay_data)
    highymax_071 = expectedfinalassets_residual(OERatiocurve071_highymax_timedelay_data)
    timedelay_efaresidual_alongOERatiocurve = figure(figsize=(4,6))    
    subplot(2,1,1)
    plot(lowymax_071[:,1], lowymax_071[:,2], linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_071[:,1], medymax_071[:,2], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_071[:,1], highymax_071[:,2], linestyle="dotted", color="black", label="High Ymax")
    title("OER = 0.71", fontsize=15)
    xlabel("Noise correlation", fontsize = 15)
    ylabel("EFAwNL - EFAwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    ylim(-400,850)
    legend()
    subplot(2,1,2)
    plot(lowymax_09[:,1], lowymax_09[:,2], linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_09[:,1], medymax_09[:,2], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_09[:,1], highymax_09[:,2], linestyle="dotted", color="black", label="High Ymax")
    title("OER = 0.90", fontsize=15)
    xlabel("Noise correlation", fontsize = 15)
    ylabel("EFAwNL - EFAwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    ylim(-400,850)
    legend()
    tight_layout()
    # return timedelay_efaresidual_alongOERatiocurve
    savefig(joinpath(abpath(), "figs/timedelay_efaresidual_alongOERatiocurve.pdf")) 
end


#Figure 7 Amplification or muting of white to reddened noise with time delay
#Variability along OER curves
let 
    lowymax_099 = variabilityfinalassets_rednoise(OERatiocurve099_lowymax_timedelay_data)
    medymax_099 = variabilityfinalassets_rednoise(OERatiocurve099_medymax_timedelay_data)
    highymax_099 = variabilityfinalassets_rednoise(OERatiocurve099_highymax_timedelay_data)
    lowymax_09 = variabilityfinalassets_rednoise(OERatiocurve09_lowymax_timedelay_data)
    medymax_09 = variabilityfinalassets_rednoise(OERatiocurve09_medymax_timedelay_data)
    highymax_09 = variabilityfinalassets_rednoise(OERatiocurve09_highymax_timedelay_data)
    lowymax_071 = variabilityfinalassets_rednoise(OERatiocurve071_lowymax_timedelay_data)
    medymax_071 = variabilityfinalassets_rednoise(OERatiocurve071_medymax_timedelay_data)
    highymax_071 = variabilityfinalassets_rednoise(OERatiocurve071_highymax_timedelay_data)
    timedelay_var_alongOERatiocurve = figure(figsize=(4,6))    
    subplot(2,1,1)
    plot(lowymax_071[:,1], lowymax_071[:,4].+0.0017, linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_071[:,1], medymax_071[:,4], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_071[:,1], highymax_071[:,4].-0.0017, linestyle="dotted", color="black", label="High Ymax")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwNL/CVwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    ylim(0.80,1.05)
    title("OER = 0.71")
    legend()
    subplot(2,1,2)
    plot(lowymax_09[:,1], lowymax_09[:,4].+0.0017, linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_09[:,1], medymax_09[:,4], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_09[:,1], highymax_09[:,4].-0.0017, linestyle="dotted", color="black", label="High Ymax")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwNL/CVwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    ylim(0.80,1.05)
    title("OER = 0.90")
    legend()
    tight_layout()
    # return timedelay_var_alongOERatiocurve
    savefig(joinpath(abpath(), "figs/timedelay_var_alongOERatiocurve.pdf")) 
end

# Figure 8 - Resistance to error
let 
    YmaxI0vals = calcYmaxI0vals_YmaxOERatio(174, [0.71,0.9], EconomicPar())
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
    lowYmax = AVCmin_MR_distance_ymaxOERatiocurve_data(150, 0.70:0.01:0.90, Irange, EconomicPar())
    medYmax = AVCmin_MR_distance_ymaxOERatiocurve_data(174, 0.70:0.01:0.90, Irange, EconomicPar())
    highYmax = AVCmin_MR_distance_ymaxOERatiocurve_data(200, 0.70:0.01:0.90, Irange, EconomicPar())
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
    xlabel("Operating Expense Ratio", fontsize = 15)
    ylabel("Resistance to error", fontsize = 15)
    xticks([0.70,0.75,0.80,0.85,0.90], fontsize=12)
    yticks(fontsize=12)
    legend()
    tight_layout()
    # return errorresistance
    savefig(joinpath(abpath(), "figs/errorresistance_OERatiocurveymax.pdf"))
end 

### Supporting Information

#Maintaining geometry while changing I₀ and c
let 
    newI0 = 2500
    newc = calc_c(0.71, 174, newI0, EconomicPar())
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

##Table SI1
df = DataFrame(OER = [0.71, 0.71, 0.71, 0.90, 0.90, 0.90,0.99,0.99,0.99], Ymax = [200, 174, 150, 200, 174, 150, 200, 174, 150])

@chain df begin
  @transform!(@byrow :IO = calc_I0(:OER, :Ymax, EconomicPar()))
  @transform!(@byrow :InEff=1/:IO)
  @transform!(@byrow :FourFifthsInputs=2*sqrt(:IO))
  @transform!(@byrow :DeltaFourFifths=(:FourFifthsInputs-1)*100)
end

#Operating Expense Ratio versus Profits
let 
    Irange = 0.0:0.01:20.0
    Ymaxrange = 160.0:1.0:230.0
    I0data275abs = [calc_I0_abs(275, Ymax, EconomicPar()) for Ymax in Ymaxrange]
    I0data175abs = [calc_I0_abs(175, Ymax, EconomicPar()) for Ymax in Ymaxrange]
    I0data75abs = [calc_I0_abs(75, Ymax, EconomicPar()) for Ymax in Ymaxrange]
    I0data071OERatio = [calc_I0(0.71, Ymax, EconomicPar()) for Ymax in Ymaxrange]
    I0data08OERatio = [calc_I0(0.80, Ymax, EconomicPar()) for Ymax in Ymaxrange]
    I0data09OERatio = [calc_I0(0.90, Ymax, EconomicPar()) for Ymax in Ymaxrange]
    OERvsabsplot = figure(figsize = (6,4))
    plot(1 ./ I0data75abs, Ymaxrange, color="#440154FF", label="Profits = \$75")
    plot(1 ./ I0data175abs,Ymaxrange, color="#1F968BFF", label="Profits = \$175")
    plot(1 ./ I0data275abs, Ymaxrange, color="#73D055FF", label="Profits = \$275")
    plot(1 ./ I0data071OERatio, Ymaxrange, linewidth=3, linestyle="solid", color="black", label="OER = 0.71")
    plot(1 ./ I0data08OERatio, Ymaxrange, linewidth=3, linestyle="dashed", color="black", label="OER = 0.80")
    plot(1 ./ I0data09OERatio, Ymaxrange, linewidth=3, linestyle="dotted", color="black", label="OER = 0.90")
    xlabel("1/I0", fontsize = 15)
    ylabel("Ymax", fontsize = 15)
    legend()
    # return OERvsabsplot
    savefig(joinpath(abpath(), "figs/OERvsabsplot.pdf"))
end

# Separating CVwNL and CVwoNL
#CVwoNL (NOTE that the CVwoNL is exactly the same whether generated from the positive feedback or time delay functions)
let 
    lowymax_099 = variabilityfinalassets_rednoise(OERatiocurve099_lowymax_timedelay_data)
    medymax_099 = variabilityfinalassets_rednoise(OERatiocurve099_medymax_timedelay_data)
    highymax_099 = variabilityfinalassets_rednoise(OERatiocurve099_highymax_timedelay_data)
    lowymax_09 = variabilityfinalassets_rednoise(OERatiocurve09_lowymax_timedelay_data)
    medymax_09 = variabilityfinalassets_rednoise(OERatiocurve09_medymax_timedelay_data)
    highymax_09 = variabilityfinalassets_rednoise(OERatiocurve09_highymax_timedelay_data)
    lowymax_071 = variabilityfinalassets_rednoise(OERatiocurve071_lowymax_timedelay_data)
    medymax_071 = variabilityfinalassets_rednoise(OERatiocurve071_medymax_timedelay_data)
    highymax_071 = variabilityfinalassets_rednoise(OERatiocurve071_highymax_timedelay_data)
    varwoNL_OERcurve = figure(figsize=(4,9))    
    subplot(3,1,1)
    plot(lowymax_071[:,1], lowymax_071[:,3].*1.025, linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_071[:,1], medymax_071[:,3], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_071[:,1], highymax_071[:,3].*0.975, linestyle="dotted", color="black", label="High Ymax")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    ylim(0.0,1.0)
    title("OER = 0.71")
    legend()
    subplot(3,1,2)
    plot(lowymax_09[:,1], lowymax_09[:,3].*1.025, linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_09[:,1], medymax_09[:,3], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_09[:,1], highymax_09[:,3].*0.975, linestyle="dotted", color="black", label="High Ymax")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    ylim(0.0,1.0)
    title("OER = 0.90")
    legend()
    subplot(3,1,3)
    plot(lowymax_099[:,1], lowymax_099[:,3].*1.025, linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_099[:,1], medymax_099[:,3], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_099[:,1], highymax_099[:,3].*0.975, linestyle="dotted", color="black", label="High Ymax")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    ylim(0.0,1.0)
    title("OER = 0.99")
    legend()
    tight_layout()
    # return varwoNL_OERcurve
    savefig(joinpath(abpath(), "figs/varwoNL_OERcurve.pdf")) 
end

#CVwNL positive feedback
let 
    lowymax_099 = variabilityfinalassets_rednoise(OERatiocurve099_lowymax_posfeed_data)
    medymax_099 = variabilityfinalassets_rednoise(OERatiocurve099_medymax_posfeed_data)
    highymax_099 = variabilityfinalassets_rednoise(OERatiocurve099_highymax_posfeed_data)   
    lowymax_09 = variabilityfinalassets_rednoise(OERatiocurve09_lowymax_posfeed_data)
    medymax_09 = variabilityfinalassets_rednoise(OERatiocurve09_medymax_posfeed_data)
    highymax_09 = variabilityfinalassets_rednoise(OERatiocurve09_highymax_posfeed_data)
    lowymax_071 = variabilityfinalassets_rednoise(OERatiocurve071_lowymax_posfeed_data)
    medymax_071 = variabilityfinalassets_rednoise(OERatiocurve071_medymax_posfeed_data)
    highymax_071 = variabilityfinalassets_rednoise(OERatiocurve071_highymax_posfeed_data)
    posfeed_varwNL_OERcurve = figure(figsize=(4,9))    
    subplot(3,1,1)
    plot(lowymax_071[:,1], lowymax_071[:,2].*1.025, linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_071[:,1], medymax_071[:,2], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_071[:,1], highymax_071[:,2].*0.975, linestyle="dotted", color="black", label="High Ymax")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    ylim(0.0,1.2)
    legend()
    title("OER = 0.71")
    subplot(3,1,2)
    plot(lowymax_09[:,1], lowymax_09[:,2].*1.025, linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_09[:,1], medymax_09[:,2], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_09[:,1], highymax_09[:,2].*0.975, linestyle="dotted", color="black", label="High Ymax")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    ylim(0.0,1.2)
    legend()
    title("OER = 0.90")
    subplot(3,1,3)
    plot(lowymax_099[:,1], lowymax_099[:,2].*1.025, linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_099[:,1], medymax_099[:,2], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_099[:,1], highymax_099[:,2].*0.975, linestyle="dotted", color="black", label="High Ymax")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    ylim(0.0,1.2)
    legend()
    title("OER = 0.99")
    tight_layout()
    # return posfeed_varwNL_OERcurve
    savefig(joinpath(abpath(), "figs/posfeed_varwNL_OERcurve.pdf")) 
end

#CVwNL time delay
let 
    lowymax_099 = variabilityfinalassets_rednoise(OERatiocurve099_lowymax_timedelay_data)
    medymax_099 = variabilityfinalassets_rednoise(OERatiocurve099_medymax_timedelay_data)
    highymax_099 = variabilityfinalassets_rednoise(OERatiocurve099_highymax_timedelay_data)
    lowymax_09 = variabilityfinalassets_rednoise(OERatiocurve09_lowymax_timedelay_data)
    medymax_09 = variabilityfinalassets_rednoise(OERatiocurve09_medymax_timedelay_data)
    highymax_09 = variabilityfinalassets_rednoise(OERatiocurve09_highymax_timedelay_data)
    lowymax_071 = variabilityfinalassets_rednoise(OERatiocurve071_lowymax_timedelay_data)
    medymax_071 = variabilityfinalassets_rednoise(OERatiocurve071_medymax_timedelay_data)
    highymax_071 = variabilityfinalassets_rednoise(OERatiocurve071_highymax_timedelay_data)
    timedelays_varwNL_OERcurve = figure(figsize=(4,9))    
    subplot(3,1,1)
    plot(lowymax_071[:,1], lowymax_071[:,2].*1.025, linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_071[:,1], medymax_071[:,2], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_071[:,1], highymax_071[:,2].*0.975, linestyle="dotted", color="black", label="High Ymax")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    ylim(0.0,0.8)
    legend()
    title("OER = 0.71")
    subplot(3,1,2)
    plot(lowymax_09[:,1], lowymax_09[:,2].*1.025, linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_09[:,1], medymax_09[:,2], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_09[:,1], highymax_09[:,2].*0.975, linestyle="dotted", color="black", label="High Ymax")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    ylim(0.0,0.8)
    legend()
    title("OER = 0.90")
    subplot(3,1,3)
    plot(lowymax_099[:,1], lowymax_099[:,2].*1.025, linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_099[:,1], medymax_099[:,2], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_099[:,1], highymax_099[:,2].*0.975, linestyle="dotted", color="black", label="High Ymax")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    ylim(0.0,0.8)
    legend()
    title("OER = 0.99")
    tight_layout()
    # return timedelays_varwNL_OERcurve
    savefig(joinpath(abpath(), "figs/timedelays_varwNL_OERcurve.pdf")) 
end 

## OER = 0.99
#Positive Feedback
let 
    lowymax_099_EFA = expectedfinalassets_residual(OERatiocurve099_lowymax_posfeed_data)
    medymax_099_EFA = expectedfinalassets_residual(OERatiocurve099_medymax_posfeed_data)
    highymax_099_EFA = expectedfinalassets_residual(OERatiocurve099_highymax_posfeed_data)
    lowymax_099_var = variabilityfinalassets_rednoise(OERatiocurve099_lowymax_posfeed_data)
    medymax_099_var = variabilityfinalassets_rednoise(OERatiocurve099_medymax_posfeed_data)
    highymax_099_var = variabilityfinalassets_rednoise(OERatiocurve099_highymax_posfeed_data)
    posfeed_efavar_alongOERatiocurve_099 = figure(figsize=(4,6))    
    subplot(2,1,1)
    plot(lowymax_099_EFA[:,1], lowymax_099_EFA[:,2], linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_099_EFA[:,1], medymax_099_EFA[:,2], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_099_EFA[:,1], highymax_099_EFA[:,2], linestyle="dotted", color="black", label="High Ymax")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("EFAwNL - EFAwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    subplot(2,1,2)
    plot(lowymax_099_var[:,1], lowymax_099_var[:,4].*1.002, linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_099_var[:,1], medymax_099_var[:,4], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_099_var[:,1], highymax_099_var[:,4].*0.998, linestyle="dotted", color="black", label="High Ymax")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwNL/CVwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    tight_layout()
    # return posfeed_efavar_alongOERatiocurve_099
    savefig(joinpath(abpath(), "figs/posfeed_efavar_alongOERatiocurve_099.pdf")) 
end

#Time Delay
let 
    lowymax_099_EFA = expectedfinalassets_residual(OERatiocurve099_lowymax_timedelay_data)
    medymax_099_EFA = expectedfinalassets_residual(OERatiocurve099_medymax_timedelay_data)
    highymax_099_EFA = expectedfinalassets_residual(OERatiocurve099_highymax_timedelay_data)
    lowymax_099_var = variabilityfinalassets_rednoise(OERatiocurve099_lowymax_timedelay_data)
    medymax_099_var = variabilityfinalassets_rednoise(OERatiocurve099_medymax_timedelay_data)
    highymax_099_var = variabilityfinalassets_rednoise(OERatiocurve099_highymax_timedelay_data)
    timedelay_efavar_alongOERatiocurve_099 = figure(figsize=(4,6))    
    subplot(2,1,1)
    plot(lowymax_099_EFA[:,1], lowymax_099_EFA[:,2], linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_099_EFA[:,1], medymax_099_EFA[:,2], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_099_EFA[:,1], highymax_099_EFA[:,2], linestyle="dotted", color="black", label="High Ymax")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("EFAwNL - EFAwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    subplot(2,1,2)
    plot(lowymax_099_var[:,1], lowymax_099_var[:,4].*1.002, linestyle="solid", color="black", label="Low Ymax")
    plot(medymax_099_var[:,1], medymax_099_var[:,4], linestyle="dashed", color="black", label="Med Ymax")
    plot(highymax_099_var[:,1], highymax_099_var[:,4].*0.998, linestyle="dotted", color="black", label="High Ymax")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwNL/CVwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    tight_layout()
    # return timedelay_efavar_alongOERatiocurve_099
    savefig(joinpath(abpath(), "figs/timedelay_efavar_alongOERatiocurve_099.pdf")) 
end
