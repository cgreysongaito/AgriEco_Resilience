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
#Read in data
# #Standard Deviation
# #Rev/Exp = 1.33
# highymax_133_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/highymax_133_posfeed_data.csv"), DataFrame))
# medymax_133_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/medymax_133_posfeed_data.csv"), DataFrame))
# lowymax_133_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/lowymax_133_posfeed_data.csv"), DataFrame))
# #Rev/Exp = 1.08
# highymax_108_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/highymax_108_posfeed_data.csv"), DataFrame))
# medymax_108_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/medymax_108_posfeed_data.csv"), DataFrame))
# lowymax_108_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/lowymax_108_posfeed_data.csv"), DataFrame))
# medymax_115_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/medymax_115_posfeed_data.csv"), DataFrame))

# medy0_133_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/medy0_133_posfeed_data.csv"), DataFrame))
# medy0_115_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/medy0_115_posfeed_data.csv"), DataFrame))
# medy0_108_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/medy0_108_posfeed_data.csv"), DataFrame))



#Variability Terminal Assets
#Changing both ymax and y0
changeboth_133_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/changeboth_133_posfeed_data.csv"), DataFrame))
changeboth_115_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/changeboth_115_posfeed_data.csv"), DataFrame))
changeboth_108_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/changeboth_108_posfeed_data.csv"), DataFrame))

let 
    changeboth_133 = variabilityterminalassets_rednoise(changeboth_133_posfeed_data)
    changeboth_115 = variabilityterminalassets_rednoise(changeboth_115_posfeed_data)
    changeboth_108 = variabilityterminalassets_rednoise(changeboth_108_posfeed_data)
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
constrainymax_133_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainymax_133_posfeed_data.csv"), DataFrame))
constrainymax_115_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainymax_115_posfeed_data.csv"), DataFrame))
constrainymax_108_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainymax_108_posfeed_data.csv"), DataFrame))
let 
    constrainymax_133 = variabilityterminalassets_rednoise(constrainymax_133_posfeed_data)
    constrainymax_115 = variabilityterminalassets_rednoise(constrainymax_115_posfeed_data)
    constrainymax_108 = variabilityterminalassets_rednoise(constrainymax_108_posfeed_data)
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
constrainy0_133_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainy0_133_posfeed_data.csv"), DataFrame))
constrainy0_115_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainy0_115_posfeed_data.csv"), DataFrame))
constrainy0_108_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainy0_108_posfeed_data.csv"), DataFrame))
let 
    constrainy0_133 = variabilityterminalassets_rednoise(constrainy0_133_posfeed_data)
    constrainy0_115 = variabilityterminalassets_rednoise(constrainy0_115_posfeed_data)
    constrainy0_108 = variabilityterminalassets_rednoise(constrainy0_108_posfeed_data)
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
 

## Time Delay ##
#Read in data
#SD
#Rev/Exp = 1.33
# highymax_133_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/highymax_133_timedelay_data.csv"), DataFrame))
# medymax_133_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/medymax_133_timedelay_data.csv"), DataFrame))
# lowymax_133_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/lowymax_133_timedelay_data.csv"), DataFrame))
# #Rev/Exp = 1.08
# highymax_108_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/highymax_108_timedelay_data.csv"), DataFrame))
# medymax_108_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/medymax_108_timedelay_data.csv"), DataFrame))
# lowymax_108_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/lowymax_108_timedelay_data.csv"), DataFrame))

# medymax_115_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/medymax_115_timedelay_data.csv"), DataFrame))


# medy0_133_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/medy0_133_timedelay_data.csv"), DataFrame))
# medy0_115_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/medy0_115_timedelay_data.csv"), DataFrame))
# medy0_108_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/medy0_108_timedelay_data.csv"), DataFrame))

#Variability Terminal Assets
#Changing both ymax and y0
changeboth_133_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/changeboth_133_timedelay_data.csv"), DataFrame))
changeboth_115_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/changeboth_115_timedelay_data.csv"), DataFrame))
changeboth_108_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/changeboth_108_timedelay_data.csv"), DataFrame))

let 
    changeboth_133 = variabilityterminalassets_rednoise(changeboth_133_timedelay_data)
    changeboth_115 = variabilityterminalassets_rednoise(changeboth_115_timedelay_data)
    changeboth_108 = variabilityterminalassets_rednoise(changeboth_108_timedelay_data)
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

# Changing Rev/Exp ratio constrain ymax
constrainymax_133_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainymax_133_timedelay_data.csv"), DataFrame))
constrainymax_115_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainymax_115_timedelay_data.csv"), DataFrame))
constrainymax_108_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainymax_108_timedelay_data.csv"), DataFrame))
let 
    constrainymax_133 = variabilityterminalassets_rednoise(constrainymax_133_timedelay_data)
    constrainymax_115 = variabilityterminalassets_rednoise(constrainymax_115_timedelay_data)
    constrainymax_108 = variabilityterminalassets_rednoise(constrainymax_108_timedelay_data)
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

# Changing Rev/Exp ratio constrain y0
constrainy0_133_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainy0_133_timedelay_data.csv"), DataFrame))
constrainy0_115_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainy0_115_timedelay_data.csv"), DataFrame))
constrainy0_108_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/constrainy0_108_timedelay_data.csv"), DataFrame))
let 
    constrainy0_133 = variabilityterminalassets_rednoise(constrainy0_133_timedelay_data)
    constrainy0_115 = variabilityterminalassets_rednoise(constrainy0_115_timedelay_data)
    constrainy0_108 = variabilityterminalassets_rednoise(constrainy0_108_timedelay_data)
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

#Variability Terminal Assets - #CV IS DOING CRAZY STUFF - DON"T KNOW WHY!
#Changing both ymax and y0 - CV
changeboth_133_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/changeboth_133_timedelay_data_CV.csv"), DataFrame))
changeboth_115_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/changeboth_115_timedelay_data_CV.csv"), DataFrame))
changeboth_108_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/changeboth_108_timedelay_data_CV.csv"), DataFrame))

let 
    changeboth_133 = variabilityterminalassets_rednoise(changeboth_133_timedelay_data_CV)
    changeboth_115 = variabilityterminalassets_rednoise(changeboth_115_timedelay_data_CV)
    # changeboth_108 = variabilityterminalassets_rednoise(changeboth_108_timedelay_data_CV)
    var_changingrevexp = figure(figsize=(5,4))    
    plot(changeboth_133[:,1], changeboth_133[:,4], linestyle="solid", color="black", label="Rev/Exp = 1.33")
    plot(changeboth_115[:,1], changeboth_115[:,4], linestyle="dashed", color="black", label="Rev/Exp = 1.15")
    # plot(changeboth_108[:,1], changeboth_108[:,4], linestyle="dotted", color="black", label="Rev/Exp = 1.08")
    xlabel("Autocorrelation")
    ylabel("VarwNL/VarwoNL")
    legend()
    return var_changingrevexp
    # savefig(joinpath(abpath(), "figs/var_changingrevexp_timedelaybacks.pdf")) 
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

### Supporting Information
include("AgriEco_supportinginformation.jl")

## comparing when rev/exp constrained
#Coefficient of variation
highymax_133_posfeed_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/highymax_133_posfeed_data_CV.csv"), DataFrame))
medymax_133_posfeed_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/medymax_133_posfeed_data_CV.csv"), DataFrame))
lowymax_133_posfeed_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/lowymax_133_posfeed_data_CV.csv"), DataFrame))
#Rev/Exp = 1.08
highymax_108_posfeed_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/highymax_108_posfeed_data_CV.csv"), DataFrame))
medymax_108_posfeed_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/medymax_108_posfeed_data_CV.csv"), DataFrame))
lowymax_108_posfeed_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/lowymax_108_posfeed_data_CV.csv"), DataFrame))

#Rev-exp=225
highymax_225_posfeed_data_abs = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/highymax_225_posfeed_data_abs.csv"), DataFrame))
medymax_225_posfeed_data_abs = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/medymax_225_posfeed_data_abs.csv"), DataFrame))
lowymax_225_posfeed_data_abs = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/lowymax_225_posfeed_data_abs.csv"), DataFrame))
#Rev-Exp = 75
highymax_75_posfeed_data_abs = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/highymax_75_posfeed_data_abs.csv"), DataFrame))
medymax_75_posfeed_data_abs = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/medymax_75_posfeed_data_abs.csv"), DataFrame))
lowymax_75_posfeed_data_abs = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/lowymax_75_posfeed_data_abs.csv"), DataFrame))


# Positive feedbacks
# Examining sustainability and incremental productivity #SD
let 
    highymax_133 = variabilityterminalassets_rednoise(highymax_133_posfeed_data)
    highymax_108 = variabilityterminalassets_rednoise(highymax_108_posfeed_data)
    medymax_133 = variabilityterminalassets_rednoise(medymax_133_posfeed_data)
    medymax_108 = variabilityterminalassets_rednoise(medymax_108_posfeed_data)
    lowymax_133 = variabilityterminalassets_rednoise(lowymax_133_posfeed_data)
    lowymax_108 = variabilityterminalassets_rednoise(lowymax_108_posfeed_data)
    rednoise_var_exptermassets = figure(figsize=(4,6))    
    subplot(2,1,1)
    plot(highymax_133[:,1], highymax_133[:,4], color="blue", label="High ymax")
    plot(medymax_133[:,1], medymax_133[:,4], color="red", label="Med ymax")
    plot(lowymax_133[:,1], lowymax_133[:,4], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("VarwNL/VarwoNL")
    title("Rev/Exp = 1.33")
    subplot(2,1,2)
    plot(highymax_108[:,1], highymax_108[:,4], color="blue", label="High ymax")
    plot(medymax_108[:,1], medymax_108[:,4], color="red", label="Med ymax")
    plot(lowymax_108[:,1], lowymax_108[:,4], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("VarwNL/VarwoNL")
    title("Rev/Exp = 1.08")
    tight_layout()
    # return rednoise_var_exptermassets
    savefig(joinpath(abpath(), "figs/posfeed_variabilityterminalassets.pdf")) 
end 

# Examining sustainability and incremental productivity #CV
let 
    highymax_133 = variabilityterminalassets_rednoise(highymax_133_posfeed_data_CV)
    highymax_108 = variabilityterminalassets_rednoise(highymax_108_posfeed_data_CV)
    medymax_133 = variabilityterminalassets_rednoise(medymax_133_posfeed_data_CV)
    medymax_108 = variabilityterminalassets_rednoise(medymax_108_posfeed_data_CV)
    lowymax_133 = variabilityterminalassets_rednoise(lowymax_133_posfeed_data_CV)
    lowymax_108 = variabilityterminalassets_rednoise(lowymax_108_posfeed_data_CV)
    rednoise_var_exptermassets = figure(figsize=(4,6))    
    subplot(2,1,1)
    plot(highymax_133[:,1], highymax_133[:,4], color="blue", label="High ymax")
    plot(medymax_133[:,1], medymax_133[:,4], color="red", label="Med ymax")
    plot(lowymax_133[:,1], lowymax_133[:,4], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("VarwNL/VarwoNL")
    title("Rev/Exp = 1.33")
    subplot(2,1,2)
    plot(highymax_108[:,1], highymax_108[:,4], color="blue", label="High ymax")
    plot(medymax_108[:,1], medymax_108[:,4], color="red", label="Med ymax")
    plot(lowymax_108[:,1], lowymax_108[:,4], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("VarwNL/VarwoNL")
    title("Rev/Exp = 1.08")
    tight_layout()
    # return rednoise_var_exptermassets
    savefig(joinpath(abpath(), "figs/posfeed_variabilityterminalassets_CV.pdf")) 
end 

#Rev-exp
let 
    highymax_225 = variabilityterminalassets_rednoise(highymax_225_posfeed_data_abs)
    highymax_75 = variabilityterminalassets_rednoise(highymax_75_posfeed_data_abs)
    medymax_225 = variabilityterminalassets_rednoise(medymax_225_posfeed_data_abs)
    medymax_75 = variabilityterminalassets_rednoise(medymax_75_posfeed_data_abs)
    lowymax_225 = variabilityterminalassets_rednoise(lowymax_225_posfeed_data_abs)
    lowymax_75 = variabilityterminalassets_rednoise(lowymax_75_posfeed_data_abs)
    rednoise_var_exptermassets = figure(figsize=(4,6))    
    subplot(2,1,1)
    plot(highymax_225[:,1], highymax_225[:,4], color="blue", label="High ymax")
    plot(medymax_225[:,1], medymax_225[:,4], color="red", label="Med ymax")
    plot(lowymax_225[:,1], lowymax_225[:,4], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("VarwNL/VarwoNL")
    title("Rev-Exp = 225")
    subplot(2,1,2)
    plot(highymax_75[:,1], highymax_75[:,4], color="blue", label="High ymax")
    plot(medymax_75[:,1], medymax_75[:,4], color="red", label="Med ymax")
    plot(lowymax_75[:,1], lowymax_75[:,4], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("VarwNL/VarwoNL")
    title("Rev-Exp = 75")
    tight_layout()
    # return rednoise_var_exptermassets
    savefig(joinpath(abpath(), "figs/posfeed_variabilityterminalassets_abs.pdf")) 
end


#CV
highymax_133_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/highymax_133_timedelay_data_CV.csv"), DataFrame))
medymax_133_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/medymax_133_timedelay_data_CV.csv"), DataFrame))
lowymax_133_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/lowymax_133_timedelay_data_CV.csv"), DataFrame))
#Rev/Exp = 1.08
highymax_108_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/highymax_108_timedelay_data_CV.csv"), DataFrame))
medymax_108_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/medymax_108_timedelay_data_CV.csv"), DataFrame))
lowymax_108_timedelay_data_CV = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/lowymax_108_timedelay_data_CV.csv"), DataFrame))

#Rev-exp=225
highymax_225_timedelay_data_abs = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/highymax_225_timedelay_data_abs.csv"), DataFrame))
medymax_225_timedelay_data_abs = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/medymax_225_timedelay_data_abs.csv"), DataFrame))
lowymax_225_timedelay_data_abs = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/lowymax_225_timedelay_data_abs.csv"), DataFrame))
#Rev-Exp = 75
highymax_75_timedelay_data_abs = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/highymax_75_timedelay_data_abs.csv"), DataFrame))
medymax_75_timedelay_data_abs = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/medymax_75_timedelay_data_abs.csv"), DataFrame))
lowymax_75_timedelay_data_abs = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/lowymax_75_timedelay_data_abs.csv"), DataFrame))


# Time delay
#Variability Terminal Assets #SD
let 
    highymax_133 = variabilityterminalassets_rednoise(highymax_133_timedelay_data)
    highymax_108 = variabilityterminalassets_rednoise(highymax_108_timedelay_data)
    medymax_133 = variabilityterminalassets_rednoise(medymax_133_timedelay_data)
    medymax_108 = variabilityterminalassets_rednoise(medymax_108_timedelay_data)
    lowymax_133 = variabilityterminalassets_rednoise(lowymax_133_timedelay_data)
    lowymax_108 = variabilityterminalassets_rednoise(lowymax_108_timedelay_data)
    rednoise_var_exptermassets = figure(figsize=(4,6))        
    subplot(2,1,1)
    plot(highymax_133[:,1], highymax_133[:,4], color="blue", label="High ymax")
    plot(medymax_133[:,1], medymax_133[:,4], color="red", label="Med ymax")
    plot(lowymax_133[:,1], lowymax_133[:,4], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("VarwNL/VarwoNL")
    # xlim(0.0,0.8)
    title("Rev/Exp = 1.33")
    subplot(2,1,2)
    plot(highymax_108[:,1], highymax_108[:,4], color="blue", label="High ymax")
    plot(medymax_108[:,1], medymax_108[:,4], color="red", label="Med ymax")
    plot(lowymax_108[:,1], lowymax_108[:,4], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("VarwNL/VarwoNL")
    # xlim(0.0,0.8)
    title("Rev/Exp = 1.08")
    tight_layout()
    # return rednoise_var_exptermassets
    savefig(joinpath(abpath(), "figs/timedelay_variabilityterminalassets.pdf")) 
end

#Variability Terminal Assets #CV
let 
    highymax_133 = variabilityterminalassets_rednoise(highymax_133_timedelay_data_CV)
    highymax_108 = variabilityterminalassets_rednoise(highymax_108_timedelay_data_CV)
    medymax_133 = variabilityterminalassets_rednoise(medymax_133_timedelay_data_CV)
    medymax_108 = variabilityterminalassets_rednoise(medymax_108_timedelay_data_CV)
    lowymax_133 = variabilityterminalassets_rednoise(lowymax_133_timedelay_data_CV)
    lowymax_108 = variabilityterminalassets_rednoise(lowymax_108_timedelay_data_CV)
    rednoise_var_exptermassets = figure(figsize=(4,6))        
    subplot(2,1,1)
    plot(highymax_133[:,1], highymax_133[:,4], color="blue", label="High ymax")
    plot(medymax_133[:,1], medymax_133[:,4], color="red", label="Med ymax")
    plot(lowymax_133[:,1], lowymax_133[:,4], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("VarwNL/VarwoNL")
    # xlim(0.0,0.8)
    title("Rev/Exp = 1.33")
    subplot(2,1,2)
    plot(highymax_108[:,1], highymax_108[:,4], color="blue", label="High ymax")
    plot(medymax_108[:,1], medymax_108[:,4], color="red", label="Med ymax")
    plot(lowymax_108[:,1], lowymax_108[:,4], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("VarwNL/VarwoNL")
    # xlim(0.0,0.8)
    title("Rev/Exp = 1.08")
    tight_layout()
    # return rednoise_var_exptermassets
    savefig(joinpath(abpath(), "figs/timedelay_variabilityterminalassets_CV.pdf")) 
end

#Rev-exp
let 
    highymax_225 = variabilityterminalassets_rednoise(highymax_225_timedelay_data_abs)
    highymax_75 = variabilityterminalassets_rednoise(highymax_75_timedelay_data_abs)
    medymax_225 = variabilityterminalassets_rednoise(medymax_225_timedelay_data_abs)
    medymax_75 = variabilityterminalassets_rednoise(medymax_75_timedelay_data_abs)
    lowymax_225 = variabilityterminalassets_rednoise(lowymax_225_timedelay_data_abs)
    lowymax_75 = variabilityterminalassets_rednoise(lowymax_75_timedelay_data_abs)
    rednoise_var_exptermassets = figure(figsize=(4,6))    
    subplot(2,1,1)
    plot(highymax_225[:,1], highymax_225[:,4], color="blue", label="High ymax")
    plot(medymax_225[:,1], medymax_225[:,4], color="red", label="Med ymax")
    plot(lowymax_225[:,1], lowymax_225[:,4], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("VarwNL/VarwoNL")
    title("Rev-Exp = 225")
    subplot(2,1,2)
    plot(highymax_75[:,1], highymax_75[:,4], color="blue", label="High ymax")
    plot(medymax_75[:,1], medymax_75[:,4], color="red", label="Med ymax")
    plot(lowymax_75[:,1], lowymax_75[:,4], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("VarwNL/VarwoNL")
    title("Rev-Exp = 75")
    tight_layout()
    # return rednoise_var_exptermassets
    savefig(joinpath(abpath(), "figs/timedelay_variabilityterminalassets_abs.pdf")) 
end 


## Positive feedbacks
#Expected Terminal Assets
let
    highymax_133 = expectedterminalassets_absolute(highymax_133_posfeed_data)
    highymax_108 = expectedterminalassets_absolute(highymax_108_posfeed_data)
    medymax_133 = expectedterminalassets_absolute(medymax_133_posfeed_data)
    medymax_108 = expectedterminalassets_absolute(medymax_108_posfeed_data)
    lowymax_133 = expectedterminalassets_absolute(lowymax_133_posfeed_data)
    lowymax_108 = expectedterminalassets_absolute(lowymax_108_posfeed_data)
    rednoise_exptermassets = figure(figsize=(4,6))
    subplot(2,1,1)
    plot(highymax_133[:,1], highymax_133[:,2], color="blue", label="High ymax")
    plot(medymax_133[:,1], medymax_133[:,2], color="red", label="Med ymax")
    plot(lowymax_133[:,1], lowymax_133[:,2], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("ETA")
    title("Rev/Exp = 1.33")
    subplot(2,1,2)
    plot(highymax_108[:,1], highymax_108[:,2], color="blue", label="High ymax")
    plot(medymax_108[:,1], medymax_108[:,2], color="red", label="Med ymax")
    plot(lowymax_108[:,1], lowymax_108[:,2], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("ETA")
    title("Rev/Exp = 1.08")
    tight_layout()
    # return rednoise_exptermassets
    savefig(joinpath(abpath(), "figs/posfeed_expectedterminalassets_absolute.pdf")) 
end

## Time delay
#Expected Terminal Assets
let
    highymax_133 = expectedterminalassets_absolute(highymax_133_timedelay_data)
    highymax_108 = expectedterminalassets_absolute(highymax_108_timedelay_data)
    medymax_133 = expectedterminalassets_absolute(medymax_133_timedelay_data)
    medymax_108 = expectedterminalassets_absolute(medymax_108_timedelay_data)
    lowymax_133 = expectedterminalassets_absolute(lowymax_133_timedelay_data)
    lowymax_108 = expectedterminalassets_absolute(lowymax_108_timedelay_data)
    rednoise_exptermassets = figure(figsize=(4,6))    
    subplot(2,1,1)
    plot(highymax_133[:,1], highymax_133[:,2], color="blue", label="High ymax")
    plot(medymax_133[:,1], medymax_133[:,2], color="red", label="Med ymax")
    plot(lowymax_133[:,1], lowymax_133[:,2], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("ETA")
    title("Rev/Exp = 1.33")
    subplot(2,1,2)
    plot(highymax_108[:,1], highymax_108[:,2], color="blue", label="High ymax")
    plot(medymax_108[:,1], medymax_108[:,2], color="red", label="Med ymax")
    plot(lowymax_108[:,1], lowymax_108[:,2], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("ETA")
    title("Rev/Exp = 1.08")
    tight_layout()
    # return rednoise_exptermassets
    savefig(joinpath(abpath(), "figs/timedelay_expectedterminalassets_absolute.pdf")) 
end

#Rev/Exp = 1.15
highymax_115_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/highymax_115_posfeed_data.csv"), DataFrame))
medymax_115_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/medymax_115_posfeed_data.csv"), DataFrame))
lowymax_115_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/lowymax_115_posfeed_data.csv"), DataFrame))
#Rev/Exp = 1.15
highymax_115_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/highymax_115_timedelay_data.csv"), DataFrame))
medymax_115_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/medymax_115_timedelay_data.csv"), DataFrame))
lowymax_115_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/lowymax_115_timedelay_data.csv"), DataFrame))

#Positive feedbacks
let 
    highymax_115_exp = expectedterminalassets_rednoise(highymax_115_posfeed_data)
    medymax_115_exp = expectedterminalassets_rednoise(medymax_115_posfeed_data)
    lowymax_115_exp = expectedterminalassets_rednoise(lowymax_115_posfeed_data)
    highymax_115_var = variabilityterminalassets_rednoise(highymax_115_posfeed_data)
    medymax_115_var = variabilityterminalassets_rednoise(medymax_115_posfeed_data)
    lowymax_115_var = variabilityterminalassets_rednoise(lowymax_115_posfeed_data)
    shortfallval = 0
    highymax_115_shortfall = termassetsshortfall_rednoise(highymax_115_posfeed_data, shortfallval)
    medymax_115_shortfall = termassetsshortfall_rednoise(medymax_115_posfeed_data, shortfallval)
    lowymax_115_shortfall = termassetsshortfall_rednoise(lowymax_115_posfeed_data, shortfallval)
    rednoise_posfeed_115 = figure(figsize=(8,3))       
    subplot(1,3,1)
    plot(highymax_115_exp[:,1], highymax_115_exp[:,4], color="blue", label="High ymax")
    plot(medymax_115_exp[:,1], medymax_115_exp[:,4], color="red", label="Med ymax")
    plot(lowymax_115_exp[:,1], lowymax_115_exp[:,4], color="purple", label="Low ymax")
    xlabel("Autocorrelation")
    ylabel("ETAwNL/ETAwoNL")
    subplot(1,3,2)
    plot(highymax_115_var[:,1], highymax_115_var[:,4], color="blue", label="High ymax")
    plot(medymax_115_var[:,1], medymax_115_var[:,4], color="red", label="Med ymax")
    plot(lowymax_115_var[:,1], lowymax_115_var[:,4], color="purple", label="Low ymax")
    xlabel("Autocorrelation")
    ylabel("VarwNL/VarwoNL")
    subplot(1,3,3)
    plot(highymax_115_shortfall[:,1], highymax_115_shortfall[:,4], color="blue", label="High ymax")
    plot(medymax_115_shortfall[:,1], medymax_115_shortfall[:,4], color="red", label="Med ymax")
    plot(lowymax_115_shortfall[:,1], lowymax_115_shortfall[:,4], color="purple", label="Low ymax")
    xlabel("Autocorrelation")
    ylabel("ShortwNL/ShortwoNL")
    tight_layout()
    return rednoise_posfeed_115
    # savefig(joinpath(abpath(), "figs/rednoise_timedelay_115.pdf")) 
end 

#Time delay

let 
    highymax_115_exp = expectedterminalassets_rednoise(highymax_115_timedelay_data)
    medymax_115_exp = expectedterminalassets_rednoise(medymax_115_timedelay_data)
    lowymax_115_exp = expectedterminalassets_rednoise(lowymax_115_timedelay_data)
    highymax_115_var = variabilityterminalassets_rednoise(highymax_115_timedelay_data)
    medymax_115_var = variabilityterminalassets_rednoise(medymax_115_timedelay_data)
    lowymax_115_var = variabilityterminalassets_rednoise(lowymax_115_timedelay_data)
    shortfallval = 0
    highymax_115_shortfall = termassetsshortfall_rednoise(highymax_115_timedelay_data, shortfallval)
    medymax_115_shortfall = termassetsshortfall_rednoise(medymax_115_timedelay_data, shortfallval)
    lowymax_115_shortfall = termassetsshortfall_rednoise(lowymax_115_timedelay_data, shortfallval)
    rednoise_timedelay_115 = figure(figsize=(8,3))      
    subplot(1,3,1)
    plot(highymax_115_exp[:,1], highymax_115_exp[:,4], color="blue", label="High ymax")
    plot(medymax_115_exp[:,1], medymax_115_exp[:,4], color="red", label="Med ymax")
    plot(lowymax_115_exp[:,1], lowymax_115_exp[:,4], color="purple", label="Low ymax")
    xlabel("Autocorrelation")
    ylabel("ETAwNL/ETAwoNL")
    subplot(1,3,2)
    plot(highymax_115_var[:,1], highymax_115_var[:,4], color="blue", label="High ymax")
    plot(medymax_115_var[:,1], medymax_115_var[:,4], color="red", label="Med ymax")
    plot(lowymax_115_var[:,1], lowymax_115_var[:,4], color="purple", label="Low ymax")
    xlabel("Autocorrelation")
    ylabel("VarwNL/VarwoNL")
    subplot(1,3,3)
    plot(highymax_115_shortfall[:,1], highymax_115_shortfall[:,4], color="blue", label="High ymax")
    plot(medymax_115_shortfall[:,1], medymax_115_shortfall[:,4], color="red", label="Med ymax")
    plot(lowymax_115_shortfall[:,1], lowymax_115_shortfall[:,4], color="purple", label="Low ymax")
    xlabel("Autocorrelation")
    ylabel("ShortwNL/ShortwoNL")
    tight_layout()
    return rednoise_timedelay_115
    # savefig(joinpath(abpath(), "figs/rednoise_timedelay_115.pdf")) 
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


