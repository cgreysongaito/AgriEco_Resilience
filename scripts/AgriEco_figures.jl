include("packages.jl")
include("AgriEco_commoncode.jl")

##Figure 2 Schematic
let 
    Irange = 0.0:0.01:20.0
    datahymaxhyo = [yieldIII(I, FarmBasePar(ymax = 174.0, y0 = 10, p = 6.70, c = 139)) for I in Irange]
    ymaxrange = 120.0:1.0:200.0
    y0data133rel = [calc_y0(1.33, ymax, 139, 6.70) for ymax in ymaxrange]
    y0data108rel = [calc_y0(1.08, ymax, 139, 6.70) for ymax in ymaxrange]
    figure2schematicprep = figure(figsize = (5,6.5))
    subplot(2,1,1)
    plot(Irange, datahymaxhyo, color = "black", linewidth = 3)
    xlabel("Inputs", fontsize = 20)
    ylabel("Yield", fontsize = 20)
    xticks([])
    yticks([])
    ylim(0.0, 180.0)
    subplot(2,1,2)
    plot(1 ./ y0data133rel, ymaxrange, linestyle="dashed", color="black", label="rev/exp = 1.33")
    plot(1 ./ y0data108rel, ymaxrange, linestyle="dotted", color="black", label="rev/exp = 1.08")
    xlabel("1/y0", fontsize = 20)
    ylabel("ymax", fontsize = 20)
    # xticks([])
    # yticks([])
    tight_layout()
    return figure2schematicprep
    # savefig(joinpath(abpath(), "figs/figure2schematicprep.pdf"))
end

let 
    ymaxrange = 120.0:1.0:200.0
    y0data225abs = [calc_y0_abs(225, ymax, 139, 6.70) for ymax in ymaxrange]
    y0data75abs = [calc_y0_abs(75, ymax, 139, 6.70) for ymax in ymaxrange]
    abs = figure()
    plot(1 ./ y0data225abs, ymaxrange, linestyle="dashed", color="black", label="rev-exp = 225")
    plot(1 ./ y0data75abs, ymaxrange, linestyle="dotted", color="black", label="rev-exp = 75")
    xlabel("1/y0", fontsize = 20)
    ylabel("ymax", fontsize = 20)
    # return abs
    savefig(joinpath(abpath(), "figs/abs_constrainedgraph.pdf"))
end

## Positive feedbacks ##
#Variability Terminal Assets
#CV
#Changing both ymax and y0
changeboth_133_posfeed_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/changeboth_133_posfeed_data_CV.csv"), DataFrame))
changeboth_115_posfeed_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/changeboth_115_posfeed_data_CV.csv"), DataFrame))
changeboth_108_posfeed_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/changeboth_108_posfeed_data_CV.csv"), DataFrame))

let 
    changeboth_133 = variabilityterminalassets_rednoise(changeboth_133_posfeed_data_CV)
    changeboth_115 = variabilityterminalassets_rednoise(changeboth_115_posfeed_data_CV)
    changeboth_108 = variabilityterminalassets_rednoise(changeboth_108_posfeed_data_CV)
    var_changingrevexp = figure(figsize=(5,4))    
    plot(changeboth_133[:,1], changeboth_133[:,4], linestyle="solid", color="black", label="Rev/Exp = 1.33")
    plot(changeboth_115[:,1], changeboth_115[:,4], linestyle="dashed", color="black", label="Rev/Exp = 1.15")
    plot(changeboth_108[:,1], changeboth_108[:,4], linestyle="dotted", color="black", label="Rev/Exp = 1.08")
    xlabel("Autocorrelation")
    ylabel("VarwNL/VarwoNL")
    legend()
    return var_changingrevexp
    # savefig(joinpath(abpath(), "figs/var_changingrevexp_posfeedbacks.pdf")) 
end 

# Changing Rev/Exp ratio constrain ymax
constrainymax_133_posfeed_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainymax_133_posfeed_data_CV.csv"), DataFrame))
constrainymax_115_posfeed_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainymax_115_posfeed_data_CV.csv"), DataFrame))
constrainymax_108_posfeed_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainymax_108_posfeed_data_CV.csv"), DataFrame))
let 
    constrainymax_133 = variabilityterminalassets_rednoise(constrainymax_133_posfeed_data_CV)
    constrainymax_115 = variabilityterminalassets_rednoise(constrainymax_115_posfeed_data_CV)
    constrainymax_108 = variabilityterminalassets_rednoise(constrainymax_108_posfeed_data_CV)
    var_changingrevexp = figure(figsize=(5,4))    
    plot(constrainymax_133[:,1], constrainymax_133[:,4], linestyle="solid", color="black", label="Rev/Exp = 1.33")
    plot(constrainymax_115[:,1], constrainymax_115[:,4], linestyle="dashed", color="black", label="Rev/Exp = 1.15")
    plot(constrainymax_108[:,1], constrainymax_108[:,4], linestyle="dotted", color="black", label="Rev/Exp = 1.08")
    xlabel("Autocorrelation")
    ylabel("VarwNL/VarwoNL")
    legend()
    return var_changingrevexp
    # savefig(joinpath(abpath(), "figs/var_changingrevexp_posfeedbacks.pdf")) 
end 

# Changing Rev/Exp ratio constrain y0
constrainy0_133_posfeed_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainy0_133_posfeed_data_CV.csv"), DataFrame))
constrainy0_115_posfeed_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainy0_115_posfeed_data_CV.csv"), DataFrame))
constrainy0_108_posfeed_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainy0_108_posfeed_data_CV.csv"), DataFrame))
let 
    constrainy0_133 = variabilityterminalassets_rednoise(constrainy0_133_posfeed_data_CV)
    constrainy0_115 = variabilityterminalassets_rednoise(constrainy0_115_posfeed_data_CV)
    constrainy0_108 = variabilityterminalassets_rednoise(constrainy0_108_posfeed_data_CV)
    var_changingrevexp = figure(figsize=(5,4))    
    plot(constrainy0_133[:,1], constrainy0_133[:,4], linestyle="solid", color="black", label="Rev/Exp = 1.33")
    plot(constrainy0_115[:,1], constrainy0_115[:,4], linestyle="dashed", color="black", label="Rev/Exp = 1.15")
    plot(constrainy0_108[:,1], constrainy0_108[:,4], linestyle="dotted", color="black", label="Rev/Exp = 1.08")
    xlabel("Autocorrelation")
    ylabel("VarwNL/VarwoNL")
    legend()
    return var_changingrevexp
    # savefig(joinpath(abpath(), "figs/var_changingrevexp_posfeedbacks.pdf")) 
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

## Time Delay ##
#Variability Terminal Assets
#Changing both ymax and y0 - CV
changeboth_133_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/changeboth_133_timedelay_data_CV.csv"), DataFrame))
changeboth_115_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/changeboth_115_timedelay_data_CV.csv"), DataFrame))
changeboth_108_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/changeboth_108_timedelay_data_CV.csv"), DataFrame))

let 
    changeboth_133 = variabilityterminalassets_rednoise(changeboth_133_timedelay_data_CV)
    changeboth_115 = variabilityterminalassets_rednoise(changeboth_115_timedelay_data_CV)
    changeboth_108 = variabilityterminalassets_rednoise(changeboth_108_timedelay_data_CV)
    var_changingrevexp = figure(figsize=(5,4))    
    plot(changeboth_133[:,1], changeboth_133[:,4], linestyle="solid", color="black", label="Rev/Exp = 1.33")
    plot(changeboth_115[:,1], changeboth_115[:,4], linestyle="dashed", color="black", label="Rev/Exp = 1.15")
    plot(changeboth_108[:,1], changeboth_108[:,4], linestyle="dotted", color="black", label="Rev/Exp = 1.08")
    xlabel("Autocorrelation")
    ylabel("VarwNL/VarwoNL")
    legend()
    return var_changingrevexp
    # savefig(joinpath(abpath(), "figs/var_changingrevexp_timedelaybacks.pdf")) 
end 


let 
    test = figure()
    subplot(2,1,1)
    hist(changeboth_108_timedelay_data_CV[end, 2], 20)
    subplot(2,1,2)
    hist(changeboth_108_timedelay_data_CV[end, 3], 20)
    return test
end

# Changing Rev/Exp ratio constrain ymax - CV
constrainymax_133_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainymax_133_timedelay_data_CV.csv"), DataFrame))
constrainymax_115_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainymax_115_timedelay_data_CV.csv"), DataFrame))
constrainymax_108_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainymax_108_timedelay_data_CV.csv"), DataFrame))
let 
    constrainymax_133 = variabilityterminalassets_rednoise(constrainymax_133_timedelay_data_CV)
    constrainymax_115 = variabilityterminalassets_rednoise(constrainymax_115_timedelay_data_CV)
    constrainymax_108 = variabilityterminalassets_rednoise(constrainymax_108_timedelay_data_CV)
    var_changingrevexp = figure(figsize=(5,4))    
    plot(constrainymax_133[:,1], constrainymax_133[:,4], linestyle="solid", color="black", label="Rev/Exp = 1.33")
    plot(constrainymax_115[:,1], constrainymax_115[:,4], linestyle="dashed", color="black", label="Rev/Exp = 1.15")
    plot(constrainymax_108[:,1], constrainymax_108[:,4], linestyle="dotted", color="black", label="Rev/Exp = 1.08")
    xlabel("Autocorrelation")
    ylabel("VarwNL/VarwoNL")
    legend()
    return var_changingrevexp
    # savefig(joinpath(abpath(), "figs/var_changingrevexp_timedelaybacks.pdf")) 
end 

# Changing Rev/Exp ratio constrain y0 -CV
constrainy0_133_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainy0_133_timedelay_data_CV.csv"), DataFrame))
constrainy0_115_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainy0_115_timedelay_data_CV.csv"), DataFrame))
constrainy0_108_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainy0_108_timedelay_data_CV.csv"), DataFrame))
let 
    constrainy0_133 = variabilityterminalassets_rednoise(constrainy0_133_timedelay_data_CV)
    constrainy0_115 = variabilityterminalassets_rednoise(constrainy0_115_timedelay_data_CV)
    constrainy0_108 = variabilityterminalassets_rednoise(constrainy0_108_timedelay_data_CV)
    var_changingrevexp = figure(figsize=(5,4))    
    plot(constrainy0_133[:,1], constrainy0_133[:,4], linestyle="solid", color="black", label="Rev/Exp = 1.33")
    plot(constrainy0_115[:,1], constrainy0_115[:,4], linestyle="dashed", color="black", label="Rev/Exp = 1.15")
    plot(constrainy0_108[:,1], constrainy0_108[:,4], linestyle="dotted", color="black", label="Rev/Exp = 1.08")
    xlabel("Autocorrelation")
    ylabel("VarwNL/VarwoNL")
    legend()
    return var_changingrevexp
    # savefig(joinpath(abpath(), "figs/var_changingrevexp_timedelaybacks.pdf")) 
end 

#Variability Terminal Assets
#Changing both ymax and y0 - CV - 6 years
changeboth_133_timedelay_data_CV_6 = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/changeboth_133_timedelay_data_CV_6.csv"), DataFrame))
changeboth_115_timedelay_data_CV_6 = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/changeboth_115_timedelay_data_CV_6.csv"), DataFrame))
changeboth_108_timedelay_data_CV_6 = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/changeboth_108_timedelay_data_CV_6.csv"), DataFrame))

let 
    changeboth_133 = variabilityterminalassets_rednoise(changeboth_133_timedelay_data_CV_6)
    changeboth_115 = variabilityterminalassets_rednoise(changeboth_115_timedelay_data_CV_6)
    changeboth_108 = variabilityterminalassets_rednoise(changeboth_108_timedelay_data_CV_6)
    var_changingrevexp = figure(figsize=(5,4))    
    plot(changeboth_133[:,1], changeboth_133[:,4], linestyle="solid", color="black", label="Rev/Exp = 1.33")
    plot(changeboth_115[:,1], changeboth_115[:,4], linestyle="dashed", color="black", label="Rev/Exp = 1.15")
    plot(changeboth_108[:,1], changeboth_108[:,4], linestyle="dotted", color="black", label="Rev/Exp = 1.08")
    xlabel("Autocorrelation")
    ylabel("VarwNL/VarwoNL")
    legend()
    return var_changingrevexp
    # savefig(joinpath(abpath(), "figs/var_changingrevexp_timedelaybacks.pdf")) 
end 

# Changing Rev/Exp ratio constrain ymax - CV - 6 years
constrainymax_133_timedelay_data_CV_6 = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainymax_133_timedelay_data_CV_6.csv"), DataFrame))
constrainymax_115_timedelay_data_CV_6 = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainymax_115_timedelay_data_CV_6.csv"), DataFrame))
constrainymax_108_timedelay_data_CV_6 = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainymax_108_timedelay_data_CV_6.csv"), DataFrame))
let 
    constrainymax_133 = variabilityterminalassets_rednoise(constrainymax_133_timedelay_data_CV_6)
    constrainymax_115 = variabilityterminalassets_rednoise(constrainymax_115_timedelay_data_CV_6)
    constrainymax_108 = variabilityterminalassets_rednoise(constrainymax_108_timedelay_data_CV_6)
    var_changingrevexp = figure(figsize=(5,4))    
    plot(constrainymax_133[:,1], constrainymax_133[:,4], linestyle="solid", color="black", label="Rev/Exp = 1.33")
    plot(constrainymax_115[:,1], constrainymax_115[:,4], linestyle="dashed", color="black", label="Rev/Exp = 1.15")
    plot(constrainymax_108[:,1], constrainymax_108[:,4], linestyle="dotted", color="black", label="Rev/Exp = 1.08")
    xlabel("Autocorrelation")
    ylabel("VarwNL/VarwoNL")
    legend()
    return var_changingrevexp
    # savefig(joinpath(abpath(), "figs/var_changingrevexp_timedelaybacks.pdf")) 
end 

# Changing Rev/Exp ratio constrain y0 -CV 6 years
constrainy0_133_timedelay_data_CV_6 = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainy0_133_timedelay_data_CV_6.csv"), DataFrame))
constrainy0_115_timedelay_data_CV_6 = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainy0_115_timedelay_data_CV_6.csv"), DataFrame))
constrainy0_108_timedelay_data_CV_6 = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainy0_108_timedelay_data_CV_6.csv"), DataFrame))
let 
    constrainy0_133 = variabilityterminalassets_rednoise(constrainy0_133_timedelay_data_CV_6)
    constrainy0_115 = variabilityterminalassets_rednoise(constrainy0_115_timedelay_data_CV_6)
    constrainy0_108 = variabilityterminalassets_rednoise(constrainy0_108_timedelay_data_CV_6)
    var_changingrevexp = figure(figsize=(5,4))    
    plot(constrainy0_133[:,1], constrainy0_133[:,4], linestyle="solid", color="black", label="Rev/Exp = 1.33")
    plot(constrainy0_115[:,1], constrainy0_115[:,4], linestyle="dashed", color="black", label="Rev/Exp = 1.15")
    plot(constrainy0_108[:,1], constrainy0_108[:,4], linestyle="dotted", color="black", label="Rev/Exp = 1.08")
    xlabel("Autocorrelation")
    ylabel("VarwNL/VarwoNL")
    legend()
    return var_changingrevexp
    # savefig(joinpath(abpath(), "figs/var_changingrevexp_timedelaybacks.pdf")) 
end 

### Supporting Information
include("AgriEco_supportinginformation.jl")



#Figure profit variability (with yield disturbance)  ### CHANGE to 1.02

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

# Showing that changing y0 and c keeps geometry the same (as long as rev/exp is constrained)
#setting y0 and c arbitrarily but still ratio is 1.33

calc_c(1.33, 174, 10, 6.70)
parratio2 = FarmBasePar(y0 = 10, ymax = 174, p = 6.70, c = 138.59335)

param_ratio(FarmBasePar(y0 = 10, ymax = 120, p = 6.70, c = 138.59335))
param_ratio(FarmBasePar(y0 = 5, ymax = 120, p = 6.70, c = 138.59335))
param_ratio(parratio2)
let 
    par1 = FarmBasePar(y0 = 10, ymax = 174, p = 6.70, c = 138.59335)
    par2 = FarmBasePar(y0 = 10, ymax = 120, p = 6.70, c = 138.59335)
    par3 = FarmBasePar(y0 = 5, ymax = 174, p = 6.70, c = 138.59335)
    par4 = FarmBasePar(y0 = 5, ymax = 120, p = 6.70, c = 138.59335)
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


