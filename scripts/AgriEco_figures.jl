include("packages.jl")
include("AgriEco_commoncode.jl")

##Figure 2 Schematic
let 
    Irange = 0.0:0.01:20.0
    datahYmaxhyo = [yieldIII(I, 174.0, 10) for I in Irange]
    Ymaxrange = 160.0:1.0:230.0
    I0data133rel = [calc_I0(1.33, Ymax, EconomicPar()) for Ymax in Ymaxrange]
    I0data115rel = [calc_I0(1.15, Ymax, EconomicPar()) for Ymax in Ymaxrange]
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
    plot(1 ./ I0data115rel, Ymaxrange, linestyle="dashed", color="black", label="rev/exp = 1.15")
    plot(1 ./ I0data108rel, Ymaxrange, linestyle="dotted", color="black", label="rev/exp = 1.08")
    xlabel("1/I0", fontsize = 20)
    ylabel("Ymax", fontsize = 20)
    xticks([])
    yticks([])
    tight_layout()
    # return figure2schematicprep
    savefig(joinpath(abpath(), "figs/figure2schematicprep.pdf"))
end

## Positive feedbacks ##
#Figure 3 Amplification or muting of white to reddened noise with positive feedback
constrainYmax_133_posfeed_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainYmax_133_posfeed_data_CV.csv"), DataFrame))
constrainYmax_115_posfeed_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainYmax_115_posfeed_data_CV.csv"), DataFrame))
constrainYmax_108_posfeed_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainYmax_108_posfeed_data_CV.csv"), DataFrame))
constrainI0_133_posfeed_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainI0_133_posfeed_data_CV.csv"), DataFrame))
constrainI0_115_posfeed_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainI0_115_posfeed_data_CV.csv"), DataFrame))
constrainI0_108_posfeed_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainI0_108_posfeed_data_CV.csv"), DataFrame))

let 
    constrainYmax_133 = variabilityterminalassets_rednoise(constrainYmax_133_posfeed_data_CV)
    constrainYmax_115 = variabilityterminalassets_rednoise(constrainYmax_115_posfeed_data_CV)
    constrainYmax_108 = variabilityterminalassets_rednoise(constrainYmax_108_posfeed_data_CV)
    constrainI0_133 = variabilityterminalassets_rednoise(constrainI0_133_posfeed_data_CV)
    constrainI0_115 = variabilityterminalassets_rednoise(constrainI0_115_posfeed_data_CV)
    constrainI0_108 = variabilityterminalassets_rednoise(constrainI0_108_posfeed_data_CV)
    posfeed_var_changingrevexp = figure(figsize=(4,6))    
    subplot(2,1,1)
    plot(constrainYmax_133[:,1], constrainYmax_133[:,4], linestyle="solid", color="black", label="Rev/Exp = 1.33")
    plot(constrainYmax_115[:,1], constrainYmax_115[:,4], linestyle="dashed", color="black", label="Rev/Exp = 1.15")
    plot(constrainYmax_108[:,1], constrainYmax_108[:,4], linestyle="dotted", color="black", label="Rev/Exp = 1.08")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwNL/CVwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    subplot(2,1,2)
    plot(constrainI0_133[:,1], constrainI0_133[:,4], linestyle="solid", color="black", label="Rev/Exp = 1.33")
    plot(constrainI0_115[:,1], constrainI0_115[:,4], linestyle="dashed", color="black", label="Rev/Exp = 1.15")
    plot(constrainI0_108[:,1], constrainI0_108[:,4], linestyle="dotted", color="black", label="Rev/Exp = 1.08")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwNL/CVwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    tight_layout()
    # return posfeed_var_changingrevexp
    savefig(joinpath(abpath(), "figs/posfeed_var_changingrevexp.pdf")) 
end 

#Figure 4 Resistance to yield disturbance
let 
    YmaxI0vals = calcYmaxI0vals("I0", 174, [1.08,1.33], 10, 0.02, EconomicPar())
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
    conYmax = AVCK_MC_distance_revexp_data("Ymax", 174, 1.08:0.01:1.33, 10, 0.02, EconomicPar())
    conI0 = AVCK_MC_distance_revexp_data("I0", 174, 1.08:0.01:1.33, 10, 0.02, EconomicPar())
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
    plot(conYmax[:,1], conYmax[:,2], color="#440154FF", label="Ymax constrained",linewidth = 3)
    plot(conI0[:,1], conI0[:,2], color="#73D055FF", label="I0 constrained", linewidth = 3)
    xlabel("Relative Profits", fontsize = 15)
    ylabel("Resistance to yield disturbance", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    tight_layout()
    # return yielddisturbanceresistance
    savefig(joinpath(abpath(), "figs/Figure4yielddisturbanceresistance_prep.pdf"))
end 

## Time Delay ##
# Figure 5 Amplification or muting of white to reddened noise with time delay
constrainYmax_133_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainYmax_133_timedelay_data_CV.csv"), DataFrame))
constrainYmax_115_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainYmax_115_timedelay_data_CV.csv"), DataFrame))
constrainYmax_108_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainYmax_108_timedelay_data_CV.csv"), DataFrame))
constrainI0_133_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainI0_133_timedelay_data_CV.csv"), DataFrame))
constrainI0_115_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainI0_115_timedelay_data_CV.csv"), DataFrame))
constrainI0_108_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainI0_108_timedelay_data_CV.csv"), DataFrame))

let 
    constrainYmax_133 = variabilityterminalassets_rednoise(constrainYmax_133_timedelay_data_CV)
    constrainYmax_115 = variabilityterminalassets_rednoise(constrainYmax_115_timedelay_data_CV)
    constrainYmax_108 = variabilityterminalassets_rednoise(constrainYmax_108_timedelay_data_CV)
    constrainI0_133 = variabilityterminalassets_rednoise(constrainI0_133_timedelay_data_CV)
    constrainI0_115 = variabilityterminalassets_rednoise(constrainI0_115_timedelay_data_CV)
    constrainI0_108 = variabilityterminalassets_rednoise(constrainI0_108_timedelay_data_CV)
    timedelays_var_changingrevexp = figure(figsize=(4,6))    
    subplot(2,1,1)
    plot(constrainYmax_133[:,1], constrainYmax_133[:,4], linestyle="solid", color="black", label="Rev/Exp = 1.33")
    plot(constrainYmax_115[:,1], constrainYmax_115[:,4], linestyle="dashed", color="black", label="Rev/Exp = 1.15")
    plot(constrainYmax_108[:,1], constrainYmax_108[:,4], linestyle="dotted", color="black", label="Rev/Exp = 1.08")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwNL/CVwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    subplot(2,1,2)
    plot(constrainI0_133[:,1], constrainI0_133[:,4], linestyle="solid", color="black", label="Rev/Exp = 1.33")
    plot(constrainI0_115[:,1], constrainI0_115[:,4], linestyle="dashed", color="black", label="Rev/Exp = 1.15")
    plot(constrainI0_108[:,1], constrainI0_108[:,4], linestyle="dotted", color="black", label="Rev/Exp = 1.08")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwNL/CVwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    tight_layout()
    # return timedelays_var_changingrevexp
    savefig(joinpath(abpath(), "figs/timedelays_var_changingrevexp.pdf")) 
end 

# Figure 6 - Resistance to error
let 
    YmaxI0vals = calcYmaxI0vals("I0", 174, [1.08,1.33], 10, 0.02, EconomicPar())
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
    conYmax = AVCmin_MR_distance_revexp_data("Ymax", 174, 1.08:0.01:1.33, Irange, 10, 0.02, EconomicPar())
    conI0 = AVCmin_MR_distance_revexp_data("I0", 174, 1.08:0.01:1.33, Irange, 10, 0.02, EconomicPar())
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
    # plot(conYmax[:,1], conYmax[:,2], color="#440154FF", label="Ymax constrained",linewidth = 3)
    plot(conI0[:,1], conI0[:,2], color="#29AF7FFF", label="Ymax or I0 constrained", linewidth = 3)
    xlabel("Relative Profits", fontsize = 15)
    ylabel("Resistance to error", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    tight_layout()
    # return errorresistance
    savefig(joinpath(abpath(), "figs/Figure6errorresistance_prep.pdf"))
end 

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

# Separating CVwNL and CVwoNL
#CVwoNL (NOTE that the CVwoNL is exactly the same whether generated from the positive feedback or time delay functions)
let 
    constrainYmax_133 = variabilityterminalassets_rednoise(constrainYmax_133_posfeed_data_CV)
    constrainYmax_115 = variabilityterminalassets_rednoise(constrainYmax_115_posfeed_data_CV)
    constrainYmax_108 = variabilityterminalassets_rednoise(constrainYmax_108_posfeed_data_CV)
    constrainI0_133 = variabilityterminalassets_rednoise(constrainI0_133_posfeed_data_CV)
    constrainI0_115 = variabilityterminalassets_rednoise(constrainI0_115_posfeed_data_CV)
    constrainI0_108 = variabilityterminalassets_rednoise(constrainI0_108_posfeed_data_CV)
    varwoNL_changingrevexp = figure(figsize=(4,6))    
    subplot(2,1,1)
    plot(constrainYmax_133[:,1], constrainYmax_133[:,3], linestyle="solid", color="black", label="Rev/Exp = 1.33")
    plot(constrainYmax_115[:,1], constrainYmax_115[:,3], linestyle="dashed", color="black", label="Rev/Exp = 1.15")
    plot(constrainYmax_108[:,1], constrainYmax_108[:,3], linestyle="dotted", color="black", label="Rev/Exp = 1.08")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    subplot(2,1,2)
    plot(constrainI0_133[:,1], constrainI0_133[:,3], linestyle="solid", color="black", label="Rev/Exp = 1.33")
    plot(constrainI0_115[:,1], constrainI0_115[:,3], linestyle="dashed", color="black", label="Rev/Exp = 1.15")
    plot(constrainI0_108[:,1], constrainI0_108[:,3], linestyle="dotted", color="black", label="Rev/Exp = 1.08")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    tight_layout()
    # return varwoNL_changingrevexp
    savefig(joinpath(abpath(), "figs/varwoNL_changingrevexp.pdf")) 
end

#CVwNL positive feedback
let 
    constrainYmax_133 = variabilityterminalassets_rednoise(constrainYmax_133_posfeed_data_CV)
    constrainYmax_115 = variabilityterminalassets_rednoise(constrainYmax_115_posfeed_data_CV)
    constrainYmax_108 = variabilityterminalassets_rednoise(constrainYmax_108_posfeed_data_CV)
    constrainI0_133 = variabilityterminalassets_rednoise(constrainI0_133_posfeed_data_CV)
    constrainI0_115 = variabilityterminalassets_rednoise(constrainI0_115_posfeed_data_CV)
    constrainI0_108 = variabilityterminalassets_rednoise(constrainI0_108_posfeed_data_CV)
    posfeed_varwNL_changingrevexp = figure(figsize=(4,6))    
    subplot(2,1,1)
    plot(constrainYmax_133[:,1], constrainYmax_133[:,2], linestyle="solid", color="black", label="Rev/Exp = 1.33")
    plot(constrainYmax_115[:,1], constrainYmax_115[:,2], linestyle="dashed", color="black", label="Rev/Exp = 1.15")
    plot(constrainYmax_108[:,1], constrainYmax_108[:,2], linestyle="dotted", color="black", label="Rev/Exp = 1.08")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    subplot(2,1,2)
    plot(constrainI0_133[:,1], constrainI0_133[:,2], linestyle="solid", color="black", label="Rev/Exp = 1.33")
    plot(constrainI0_115[:,1], constrainI0_115[:,2], linestyle="dashed", color="black", label="Rev/Exp = 1.15")
    plot(constrainI0_108[:,1], constrainI0_108[:,2], linestyle="dotted", color="black", label="Rev/Exp = 1.08")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    tight_layout()
    # return posfeed_varwNL_changingrevexp
    savefig(joinpath(abpath(), "figs/posfeed_varwNL_changingrevexp.pdf")) 
end

#CVwNL time delay
let 
    constrainYmax_133 = variabilityterminalassets_rednoise(constrainYmax_133_timedelay_data_CV)
    constrainYmax_115 = variabilityterminalassets_rednoise(constrainYmax_115_timedelay_data_CV)
    constrainYmax_108 = variabilityterminalassets_rednoise(constrainYmax_108_timedelay_data_CV)
    constrainI0_133 = variabilityterminalassets_rednoise(constrainI0_133_timedelay_data_CV)
    constrainI0_115 = variabilityterminalassets_rednoise(constrainI0_115_timedelay_data_CV)
    constrainI0_108 = variabilityterminalassets_rednoise(constrainI0_108_timedelay_data_CV)
    timedelays_varwNL_changingrevexp = figure(figsize=(4,6))    
    subplot(2,1,1)
    plot(constrainYmax_133[:,1], constrainYmax_133[:,2], linestyle="solid", color="black", label="Rev/Exp = 1.33")
    plot(constrainYmax_115[:,1], constrainYmax_115[:,2], linestyle="dashed", color="black", label="Rev/Exp = 1.15")
    plot(constrainYmax_108[:,1], constrainYmax_108[:,2], linestyle="dotted", color="black", label="Rev/Exp = 1.08")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    subplot(2,1,2)
    plot(constrainI0_133[:,1], constrainI0_133[:,2], linestyle="solid", color="black", label="Rev/Exp = 1.33")
    plot(constrainI0_115[:,1], constrainI0_115[:,2], linestyle="dashed", color="black", label="Rev/Exp = 1.15")
    plot(constrainI0_108[:,1], constrainI0_108[:,2], linestyle="dotted", color="black", label="Rev/Exp = 1.08")
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    tight_layout()
    # return timedelays_varwNL_changingrevexp
    savefig(joinpath(abpath(), "figs/timedelays_varwNL_changingrevexp.pdf")) 
end 

#Rev/Exp=0.95
constrainYmax_095_posfeed_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainYmax_095_posfeed_data_CV.csv"), DataFrame))
constrainI0_095_posfeed_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainI0_095_posfeed_data_CV.csv"), DataFrame))
constrainYmax_095_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainYmax_095_timedelay_data_CV.csv"), DataFrame))
constrainI0_095_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainI0_095_timedelay_data_CV.csv"), DataFrame))

let 
    constrainYmax_095_posfeed = variabilityterminalassets_rednoise(constrainYmax_095_posfeed_data_CV)
    constrainI0_095_posfeed = variabilityterminalassets_rednoise(constrainI0_095_posfeed_data_CV)
    constrainYmax_095_timedelay = variabilityterminalassets_rednoise(constrainYmax_095_timedelay_data_CV)
    constrainI0_095_timedelay = variabilityterminalassets_rednoise(constrainI0_095_timedelay_data_CV)
    var095 = figure(figsize=(4,6))    
    subplot(2,1,1)
    plot(constrainYmax_095_posfeed[:,1], constrainYmax_095_posfeed[:,4], linestyle="solid", color="black", label="Constrain Ymax or I0")
    # plot(constrainI0_095_posfeed[:,1], constrainI0_095_posfeed[:,4], linestyle="dotted", color="black", label="I0")
    title("Positive Feedbacks", fontsize = 15)
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwNL/CVwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    subplot(2,1,2)
    plot(constrainYmax_095_timedelay[:,1], constrainYmax_095_timedelay[:,4], linestyle="solid", color="black", label="Constrain Ymax or I0")
    # plot(constrainI0_095_timedelay[:,1], constrainI0_095_timedelay[:,4], linestyle="dotted", color="black", label="I0")
    title("Time Delays", fontsize = 15)
    xlabel("Noise correlation", fontsize = 15)
    ylabel("CVwNL/CVwoNL", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    tight_layout()
    # return var095
    savefig(joinpath(abpath(), "figs/var_095.pdf")) 
end 

#Expected Terminal Assets - Positive feedbacks
let 
    constrainYmax_133 = expectedterminalassets_absolute(constrainYmax_133_posfeed_data_CV)
    constrainYmax_115 = expectedterminalassets_absolute(constrainYmax_115_posfeed_data_CV)
    constrainYmax_108 = expectedterminalassets_absolute(constrainYmax_108_posfeed_data_CV)
    constrainYmax_095 = expectedterminalassets_absolute(constrainYmax_095_posfeed_data_CV)
    constrainI0_133 = expectedterminalassets_absolute(constrainI0_133_posfeed_data_CV)
    constrainI0_115 = expectedterminalassets_absolute(constrainI0_115_posfeed_data_CV)
    constrainI0_108 = expectedterminalassets_absolute(constrainI0_108_posfeed_data_CV)
    constrainI0_095 = expectedterminalassets_absolute(constrainI0_095_posfeed_data_CV)
    posfeed_eta_changingrevexp = figure(figsize=(4,6))    
    subplot(2,1,1)
    plot(constrainYmax_133[:,1], constrainYmax_133[:,2], linestyle="solid", color="black", label="Rev/Exp = 1.33")
    plot(constrainYmax_115[:,1], constrainYmax_115[:,2], linestyle="dashed", color="black", label="Rev/Exp = 1.15")
    plot(constrainYmax_108[:,1], constrainYmax_108[:,2], linestyle="dotted", color="black", label="Rev/Exp = 1.08")
    plot(constrainYmax_095[:,1], constrainYmax_095[:,2], linestyle="dashdot", color="black", label="Rev/Exp = 0.95")
    title("Constrain Ymax", fontsize=15)
    xlabel("Noise correlation", fontsize = 15)
    ylabel("Expected Final Assets", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    subplot(2,1,2)
    plot(constrainI0_133[:,1], constrainI0_133[:,2], linestyle="solid", color="black", label="Rev/Exp = 1.33")
    plot(constrainI0_115[:,1], constrainI0_115[:,2], linestyle="dashed", color="black", label="Rev/Exp = 1.15")
    plot(constrainI0_108[:,1], constrainI0_108[:,2], linestyle="dotted", color="black", label="Rev/Exp = 1.08")
    plot(constrainI0_095[:,1], constrainI0_095[:,2], linestyle="dashdot", color="black", label="Rev/Exp = 0.95")
    title("Constrain I0", fontsize=15)
    xlabel("Noise correlation", fontsize = 15)
    ylabel("Expected Final Assets", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    tight_layout()
    # return posfeed_eta_changingrevexp
    savefig(joinpath(abpath(), "figs/posfeed_eta_changingrevexp.pdf")) 
end

#Expected Terminal Assets - Time delay
let 
    constrainYmax_133 = expectedterminalassets_absolute(constrainYmax_133_timedelay_data_CV)
    constrainYmax_115 = expectedterminalassets_absolute(constrainYmax_115_timedelay_data_CV)
    constrainYmax_108 = expectedterminalassets_absolute(constrainYmax_108_timedelay_data_CV)
    constrainYmax_095 = expectedterminalassets_absolute(constrainYmax_095_timedelay_data_CV)
    constrainI0_133 = expectedterminalassets_absolute(constrainI0_133_timedelay_data_CV)
    constrainI0_115 = expectedterminalassets_absolute(constrainI0_115_timedelay_data_CV)
    constrainI0_108 = expectedterminalassets_absolute(constrainI0_108_timedelay_data_CV)
    constrainI0_095 = expectedterminalassets_absolute(constrainI0_095_timedelay_data_CV)
    timedelays_eta_changingrevexp = figure(figsize=(4,6))    
    subplot(2,1,1)
    plot(constrainYmax_133[:,1], constrainYmax_133[:,2], linestyle="solid", color="black", label="Rev/Exp = 1.33")
    plot(constrainYmax_115[:,1], constrainYmax_115[:,2], linestyle="dashed", color="black", label="Rev/Exp = 1.15")
    plot(constrainYmax_108[:,1], constrainYmax_108[:,2], linestyle="dotted", color="black", label="Rev/Exp = 1.08")
    plot(constrainYmax_095[:,1], constrainYmax_095[:,2], linestyle="dashdot", color="black", label="Rev/Exp = 0.95")
    title("Constrain Ymax", fontsize=15)
    xlabel("Noise correlation", fontsize = 15)
    ylabel("Expected Final Assets", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    subplot(2,1,2)
    plot(constrainI0_133[:,1], constrainI0_133[:,2], linestyle="solid", color="black", label="Rev/Exp = 1.33")
    plot(constrainI0_115[:,1], constrainI0_115[:,2], linestyle="dashed", color="black", label="Rev/Exp = 1.15")
    plot(constrainI0_108[:,1], constrainI0_108[:,2], linestyle="dotted", color="black", label="Rev/Exp = 1.08")
    plot(constrainI0_095[:,1], constrainI0_095[:,2], linestyle="dashdot", color="black", label="Rev/Exp = 0.95")
    title("Constrain I0", fontsize=15)
    xlabel("Noise correlation", fontsize = 15)
    ylabel("Expected Final Assets", fontsize = 15)
    xticks(fontsize=12)
    yticks(fontsize=12)
    legend()
    tight_layout()
    # return timedelays_eta_changingrevexp
    savefig(joinpath(abpath(), "figs/timedelays_eta_changingrevexp.pdf")) 
end 

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


