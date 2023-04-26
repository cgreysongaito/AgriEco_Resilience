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
    xticks([])
    yticks([])
    tight_layout()
    return figure2schematicprep
    # savefig(joinpath(abpath(), "figs/figure2schematicprep.pdf"))
end

## Positive feedbacks ##
#Read in data
#Rev/Exp = 1.33
highymax_133_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/highymax_133_posfeed_data.csv"), DataFrame))
medymax_133_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/medymax_133_posfeed_data.csv"), DataFrame))
lowymax_133_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/lowymax_133_posfeed_data.csv"), DataFrame))
#Rev/Exp = 1.08
highymax_108_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/highymax_108_posfeed_data.csv"), DataFrame))
medymax_108_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/medymax_108_posfeed_data.csv"), DataFrame))
lowymax_108_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/lowymax_108_posfeed_data.csv"), DataFrame))

medymax_115_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/medymax_115_posfeed_data.csv"), DataFrame))
#Rev/Exp = 1.05 (just for changing Rev/Exp ratio)
medymax_105_posfeed_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/medymax_105_posfeed_data.csv"), DataFrame))

#Variability Terminal Assets

# Changing Rev/Exp ratio
let 
    medymax_133 = variabilityterminalassets_rednoise(medymax_133_posfeed_data)
    medymax_115 = variabilityterminalassets_rednoise(medymax_115_posfeed_data)
    medymax_108 = variabilityterminalassets_rednoise(medymax_108_posfeed_data)
    medymax_105 = variabilityterminalassets_rednoise(medymax_105_posfeed_data)
    rednoise_var_exptermassets = figure(figsize=(5,4))    
    plot(medymax_133[:,1], medymax_133[:,4], linestyle="solid", color="black", label="Rev/Exp = 1.33")
    plot(medymax_115[:,1], medymax_115[:,4], linestyle="dashed", color="black", label="Rev/Exp = 1.15")
    plot(medymax_108[:,1], medymax_108[:,4], linestyle="dotted", color="black", label="Rev/Exp = 1.08")
    # plot(medymax_105[:,1], medymax_105[:,4], linestyle="dashdot", color="black", label="Rev/Exp = 1.05")
    xlabel("Autocorrelation")
    ylabel("VarwNL/VarwoNL")
    legend()
    return rednoise_var_exptermassets
    # savefig(joinpath(abpath(), "figs/posfeed_variabilityterminalassets.pdf")) 
end 

# Examining sustainability and incremental productivity
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


## Time Delay ##
#Read in data
#Rev/Exp = 1.33
highymax_133_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/highymax_133_timedelay_data.csv"), DataFrame))
medymax_133_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/medymax_133_timedelay_data.csv"), DataFrame))
lowymax_133_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/lowymax_133_timedelay_data.csv"), DataFrame))
#Rev/Exp = 1.08
highymax_108_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/highymax_108_timedelay_data.csv"), DataFrame))
medymax_108_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/medymax_108_timedelay_data.csv"), DataFrame))
lowymax_108_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/lowymax_108_timedelay_data.csv"), DataFrame))

medymax_115_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/medymax_115_timedelay_data.csv"), DataFrame))
#Rev/Exp = 1.05 (just for changing Rev/Exp ratio)
medymax_105_timedelay_data = CSVtoArrayVector(CSV.read(joinpath(abpath(),"data/medymax_105_timedelay_data.csv"), DataFrame))

# Changing Rev/Exp ratio
let 
    medymax_133 = variabilityterminalassets_rednoise(medymax_133_timedelay_data)
    medymax_115 = variabilityterminalassets_rednoise(medymax_115_timedelay_data)
    medymax_108 = variabilityterminalassets_rednoise(medymax_108_timedelay_data)
    medymax_105 = variabilityterminalassets_rednoise(medymax_105_timedelay_data)
    rednoise_var_exptermassets = figure(figsize=(5,4))    
    plot(medymax_133[:,1], medymax_133[:,4], linestyle="solid", color="black", label="Rev/Exp = 1.33")
    plot(medymax_115[:,1], medymax_115[:,4], linestyle="dashed", color="black", label="Rev/Exp = 1.15")
    plot(medymax_108[:,1], medymax_108[:,4], linestyle="dotted", color="black", label="Rev/Exp = 1.08")
    # plot(medymax_105[:,1], medymax_105[:,4], linestyle="dashdot", color="black", label="Rev/Exp = 1.05")
    xlabel("Autocorrelation")
    ylabel("VarwNL/VarwoNL")
    legend()
    return rednoise_var_exptermassets
    # savefig(joinpath(abpath(), "figs/posfeed_variabilityterminalassets.pdf")) 
end 

#Variability Terminal Assets
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



### Supporting Information
include("AgriEco_supportinginformation.jl")


## Positive feedbacks
#Expected Terminal Assets
let
    highymax_133 = expectedterminalassets_rednoise(highymax_133_posfeed_data)
    highymax_108 = expectedterminalassets_rednoise(highymax_108_posfeed_data)
    medymax_133 = expectedterminalassets_rednoise(medymax_133_posfeed_data)
    medymax_108 = expectedterminalassets_rednoise(medymax_108_posfeed_data)
    lowymax_133 = expectedterminalassets_rednoise(lowymax_133_posfeed_data)
    lowymax_108 = expectedterminalassets_rednoise(lowymax_108_posfeed_data)
    rednoise_exptermassets = figure(figsize=(4,6))
    subplot(2,1,1)
    plot(highymax_133[:,1], highymax_133[:,4], color="blue", label="High ymax")
    plot(medymax_133[:,1], medymax_133[:,4], color="red", label="Med ymax")
    plot(lowymax_133[:,1], lowymax_133[:,4], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("ETAwNL/ETAwoNL")
    title("Rev/Exp = 1.33")
    subplot(2,1,2)
    plot(highymax_108[:,1], highymax_108[:,4], color="blue", label="High ymax")
    plot(medymax_108[:,1], medymax_108[:,4], color="red", label="Med ymax")
    plot(lowymax_108[:,1], lowymax_108[:,4], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("ETAwNL/ETAwoNL")
    title("Rev/Exp = 1.08")
    tight_layout()
    # return rednoise_exptermassets
    savefig(joinpath(abpath(), "figs/posfeed_expectedterminalassets.pdf")) 
end

let
    highymax_133 = expectedterminalassets_absolute_detrend(highymax_133_posfeed_data)
    highymax_108 = expectedterminalassets_absolute_detrend(highymax_108_posfeed_data)
    medymax_133 = expectedterminalassets_absolute_detrend(medymax_133_posfeed_data)
    medymax_108 = expectedterminalassets_absolute_detrend(medymax_108_posfeed_data)
    lowymax_133 = expectedterminalassets_absolute_detrend(lowymax_133_posfeed_data)
    lowymax_108 = expectedterminalassets_absolute_detrend(lowymax_108_posfeed_data)
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
    return rednoise_exptermassets
    # savefig(joinpath(abpath(), "figs/posfeed_expectedterminalassets.pdf")) 
end

#Terminal Assets Shortfall
let 
    shortfallval = 0
    highymax_133 = termassetsshortfall_rednoise(highymax_133_posfeed_data, shortfallval)
    highymax_108 = termassetsshortfall_rednoise(highymax_108_posfeed_data, shortfallval)
    medymax_133 = termassetsshortfall_rednoise(medymax_133_posfeed_data, shortfallval)
    medymax_108 = termassetsshortfall_rednoise(medymax_108_posfeed_data, shortfallval)
    lowymax_133 = termassetsshortfall_rednoise(lowymax_133_posfeed_data, shortfallval)
    lowymax_108 = termassetsshortfall_rednoise(lowymax_108_posfeed_data, shortfallval)
    rednoise_shortfall_exptermassets = figure(figsize=(4,6))    
    subplot(2,1,1)
    plot(highymax_133[:,1], highymax_133[:,4], color="blue", label="High ymax")
    plot(medymax_133[:,1], medymax_133[:,4], color="red", label="Med ymax")
    plot(lowymax_133[:,1], lowymax_133[:,4], color="purple", label="Low ymax")
    xlabel("Autocorrelation")
    ylabel("ShortwNL/ShortwoNL")
    title("Rev/Exp = 1.33")
    subplot(2,1,2)
    plot(highymax_108[:,1], highymax_108[:,4], color="blue", label="High ymax")
    plot(medymax_108[:,1], medymax_108[:,4], color="red", label="Med ymax")
    plot(lowymax_108[:,1], lowymax_108[:,4], color="purple", label="Low ymax")
    xlabel("Autocorrelation")
    ylabel("ShortwNL/ShortwoNL")
    title("Rev/Exp = 1.08")
    tight_layout()
    # return rednoise_shortfall_exptermassets
    savefig(joinpath(abpath(), "figs/posfeed_terminalassetsshortfall.pdf")) 
end 

let 
    shortfallval = 0
    highymax_133 = termassetsshortfall_absolute_detrend(highymax_133_posfeed_data, shortfallval)
    highymax_108 = termassetsshortfall_absolute_detrend(highymax_108_posfeed_data, shortfallval)
    medymax_133 = termassetsshortfall_absolute_detrend(medymax_133_posfeed_data, shortfallval)
    medymax_108 = termassetsshortfall_absolute_detrend(medymax_108_posfeed_data, shortfallval)
    lowymax_133 = termassetsshortfall_absolute_detrend(lowymax_133_posfeed_data, shortfallval)
    lowymax_108 = termassetsshortfall_absolute_detrend(lowymax_108_posfeed_data, shortfallval)
    rednoise_shortfall_exptermassets = figure(figsize=(4,6))    
    subplot(2,1,1)
    plot(highymax_133[:,1], highymax_133[:,2], color="blue", label="High ymax")
    plot(medymax_133[:,1], medymax_133[:,2], color="red", label="Med ymax")
    plot(lowymax_133[:,1], lowymax_133[:,2], color="purple", label="Low ymax")
    xlabel("Autocorrelation")
    ylabel("Shortfall")
    title("Rev/Exp = 1.33")
    subplot(2,1,2)
    plot(highymax_108[:,1], highymax_108[:,2], color="blue", label="High ymax")
    plot(medymax_108[:,1], medymax_108[:,2], color="red", label="Med ymax")
    plot(lowymax_108[:,1], lowymax_108[:,2], color="purple", label="Low ymax")
    xlabel("Autocorrelation")
    ylabel("Shortfall")
    title("Rev/Exp = 1.08")
    tight_layout()
    return rednoise_shortfall_exptermassets
    # savefig(joinpath(abpath(), "figs/posfeed_terminalassetsshortfall.pdf")) 
end

## Time delay
#Expected Terminal Assets
let
    highymax_133 = expectedterminalassets_rednoise(highymax_133_timedelay_data)
    highymax_108 = expectedterminalassets_rednoise(highymax_108_timedelay_data)
    medymax_133 = expectedterminalassets_rednoise(medymax_133_timedelay_data)
    medymax_108 = expectedterminalassets_rednoise(medymax_108_timedelay_data)
    lowymax_133 = expectedterminalassets_rednoise(lowymax_133_timedelay_data)
    lowymax_108 = expectedterminalassets_rednoise(lowymax_108_timedelay_data)
    rednoise_exptermassets = figure(figsize=(4,6))    
    subplot(2,1,1)
    plot(highymax_133[:,1], highymax_133[:,4], color="blue", label="High ymax")
    plot(medymax_133[:,1], medymax_133[:,4], color="red", label="Med ymax")
    plot(lowymax_133[:,1], lowymax_133[:,4], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("ETAwNL/ETAwoNL")
    title("Rev/Exp = 1.33")
    subplot(2,1,2)
    plot(highymax_108[:,1], highymax_108[:,4], color="blue", label="High ymax")
    plot(medymax_108[:,1], medymax_108[:,4], color="red", label="Med ymax")
    plot(lowymax_108[:,1], lowymax_108[:,4], color="purple", label="Low ymax")
    # ylim(-90,40)
    xlabel("Autocorrelation")
    ylabel("ETAwNL/ETAwoNL")
    title("Rev/Exp = 1.08")
    tight_layout()
    # return rednoise_exptermassets
    savefig(joinpath(abpath(), "figs/timedelay_expectedterminalassets.pdf")) 
end

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
    return rednoise_exptermassets
    # savefig(joinpath(abpath(), "figs/timedelay_expectedterminalassets.pdf")) 
end

#Terminal Assets Shortfall
let 
    shortfallval = 0
    highymax_133 = termassetsshortfall_rednoise(highymax_133_timedelay_data, shortfallval)
    highymax_108 = termassetsshortfall_rednoise(highymax_108_timedelay_data, shortfallval)
    medymax_133 = termassetsshortfall_rednoise(medymax_133_timedelay_data, shortfallval)
    medymax_108 = termassetsshortfall_rednoise(medymax_108_timedelay_data, shortfallval)
    lowymax_133 = termassetsshortfall_rednoise(lowymax_133_timedelay_data, shortfallval)
    lowymax_108 = termassetsshortfall_rednoise(lowymax_108_timedelay_data, shortfallval)
    rednoise_shortfall_exptermassets = figure(figsize=(4,6))       
    subplot(2,1,1)
    plot(highymax_133[:,1], highymax_133[:,4], color="blue", label="High ymax")
    plot(medymax_133[:,1], medymax_133[:,4], color="red", label="Med ymax")
    plot(lowymax_133[:,1], lowymax_133[:,4], color="purple", label="Low ymax")
    xlabel("Autocorrelation")
    ylabel("ShortwNL/ShortwoNL")
    title("Rev/Exp = 1.33")
    subplot(2,1,2)
    plot(highymax_108[:,1], highymax_108[:,4], color="blue", label="High ymax")
    plot(medymax_108[:,1], medymax_108[:,4], color="red", label="Med ymax")
    plot(lowymax_108[:,1], lowymax_108[:,4], color="purple", label="Low ymax")
    xlabel("Autocorrelation")
    ylabel("ShortwNL/ShortwoNL")
    title("Rev/Exp = 1.08")
    tight_layout()
    # return rednoise_shortfall_exptermassets
    savefig(joinpath(abpath(), "figs/timedelay_terminalassetsshortfall.pdf")) 
end 

let 
    shortfallval = 0
    highymax_133 = termassetsshortfall_absolute(highymax_133_timedelay_data, shortfallval)
    highymax_108 = termassetsshortfall_absolute(highymax_108_timedelay_data, shortfallval)
    medymax_133 = termassetsshortfall_absolute(medymax_133_timedelay_data, shortfallval)
    medymax_108 = termassetsshortfall_absolute(medymax_108_timedelay_data, shortfallval)
    lowymax_133 = termassetsshortfall_absolute(lowymax_133_timedelay_data, shortfallval)
    lowymax_108 = termassetsshortfall_absolute(lowymax_108_timedelay_data, shortfallval)
    rednoise_shortfall_exptermassets = figure(figsize=(4,6))       
    subplot(2,1,1)
    plot(highymax_133[:,1], highymax_133[:,2], color="blue", label="High ymax")
    plot(medymax_133[:,1], medymax_133[:,2], color="red", label="Med ymax")
    plot(lowymax_133[:,1], lowymax_133[:,2], color="purple", label="Low ymax")
    xlabel("Autocorrelation")
    ylabel("Shortfall")
    title("Rev/Exp = 1.33")
    subplot(2,1,2)
    plot(highymax_108[:,1], highymax_108[:,2], color="blue", label="High ymax")
    plot(medymax_108[:,1], medymax_108[:,2], color="red", label="Med ymax")
    plot(lowymax_108[:,1], lowymax_108[:,2], color="purple", label="Low ymax")
    xlabel("Autocorrelation")
    ylabel("Shortfall")
    title("Rev/Exp = 1.08")
    tight_layout()
    return rednoise_shortfall_exptermassets
    # savefig(joinpath(abpath(), "figs/timedelay_terminalassetsshortfall.pdf")) 
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


