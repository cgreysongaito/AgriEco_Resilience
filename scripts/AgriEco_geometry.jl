include("packages.jl")
include("AgriEco_commoncode.jl")

let 
    Irange = 0.0:0.01:20.0
    datahYmaxhyo = [yieldIII(I, 174.0, 0.25) for I in Irange]
    yield = figure(figsize = (5,6.5))
    plot(Irange, datahYmaxhyo, color = "black", linewidth = 3)
    xlabel("Inputs", fontsize = 20)
    ylabel("Yield", fontsize = 20)
    xticks([])
    yticks([])
    ylim(0.0, 180.0)
    xlim(0.0,2.0)
    return yield
end
#Marginal revenue versus marginal cost figures
let 
    lowYmaxvalue = 174
    rise= 10
    run = 0.02
    YmaxI0vals = calcYmaxI0vals("Ymax", lowYmaxvalue, [1.08,1.15,1.33], rise, run, EconomicPar())
    Irange = 0.0:0.01:20.0
    Yield1 = [yieldIII(I, YmaxI0vals[1,1],YmaxI0vals[1,2]) for I in Irange]
    MC1 = [margcostIII(I, YmaxI0vals[1,1],YmaxI0vals[1,2], EconomicPar()) for I in Irange]
    AVC1 = [avvarcostIII(I, YmaxI0vals[1,1],YmaxI0vals[1,2], EconomicPar()) for I in Irange]
    Yield2 = [yieldIII(I, YmaxI0vals[2,1],YmaxI0vals[2,2]) for I in Irange]
    MC2 = [margcostIII(I, YmaxI0vals[2,1],YmaxI0vals[2,2], EconomicPar()) for I in Irange]
    AVC2 = [avvarcostIII(I, YmaxI0vals[2,1],YmaxI0vals[2,2], EconomicPar()) for I in Irange]
    Yield3 = [yieldIII(I, YmaxI0vals[3,1],YmaxI0vals[3,2]) for I in Irange]
    MC3 = [margcostIII(I, YmaxI0vals[3,1],YmaxI0vals[3,2], EconomicPar()) for I in Irange]
    AVC3 = [avvarcostIII(I, YmaxI0vals[3,1],YmaxI0vals[3,2], EconomicPar()) for I in Irange]
    costcurves = figure()
    subplot(3,1,1)
    plot(Yield1, MC1, color="blue", label="MC")
    plot(Yield1, AVC1, color="orange", label="AVC")
    hlines(EconomicPar().p, 0.0, 180.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 10.0)
    xlim(0.0, 180.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(3,1,2)
    plot(Yield2, MC2, color="blue", label="MC")
    plot(Yield2, AVC2, color="orange", label="AVC")
    hlines(EconomicPar().p, 0.0, 180.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 10.0)
    xlim(0.0, 180.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(3,1,3)
    plot(Yield3, MC3, color="blue", label="MC")
    plot(Yield3, AVC3, color="orange", label="AVC")
    hlines(EconomicPar().p, 0.0, 180.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 10.0)
    xlim(0.0, 180.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    tight_layout()
    return costcurves
    # savefig(joinpath(abpath(), "figs/costcurves.png"))
end   

let 
    lowYmaxvalue = 140
    rise= 10
    run = 0.02
    YmaxI0vals = calcYmaxI0vals("I0", lowYmaxvalue, [1.08,1.15,1.33], rise, run, EconomicPar())
    Irange = 0.0:0.01:20.0
    Yield1 = [yieldIII(I, YmaxI0vals[1,1],YmaxI0vals[1,2]) for I in Irange]
    MC1 = [margcostIII(I, YmaxI0vals[1,1],YmaxI0vals[1,2], EconomicPar()) for I in Irange]
    AVC1 = [avvarcostIII(I, YmaxI0vals[1,1],YmaxI0vals[1,2], EconomicPar()) for I in Irange]
    Yield2 = [yieldIII(I, YmaxI0vals[2,1],YmaxI0vals[2,2]) for I in Irange]
    MC2 = [margcostIII(I, YmaxI0vals[2,1],YmaxI0vals[2,2], EconomicPar()) for I in Irange]
    AVC2 = [avvarcostIII(I, YmaxI0vals[2,1],YmaxI0vals[2,2], EconomicPar()) for I in Irange]
    Yield3 = [yieldIII(I, YmaxI0vals[3,1],YmaxI0vals[3,2]) for I in Irange]
    MC3 = [margcostIII(I, YmaxI0vals[3,1],YmaxI0vals[3,2], EconomicPar()) for I in Irange]
    AVC3 = [avvarcostIII(I, YmaxI0vals[3,1],YmaxI0vals[3,2], EconomicPar()) for I in Irange]
    costcurves = figure()
    subplot(3,1,1)
    plot(Yield1, MC1, color="blue", label="MC")
    plot(Yield1, AVC1, color="orange", label="AVC")
    hlines(EconomicPar().p, 0.0, 180.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 10.0)
    xlim(0.0, 180.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(3,1,2)
    plot(Yield2, MC2, color="blue", label="MC")
    plot(Yield2, AVC2, color="orange", label="AVC")
    hlines(EconomicPar().p, 0.0, 180.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 10.0)
    xlim(0.0, 180.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(3,1,3)
    plot(Yield3, MC3, color="blue", label="MC")
    plot(Yield3, AVC3, color="orange", label="AVC")
    hlines(EconomicPar().p, 0.0, 180.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 10.0)
    xlim(0.0, 180.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    tight_layout()
    return costcurves
    # savefig(joinpath(abpath(), "figs/costcurves.png"))
end  

#Absorbing of errors (DAVC)
function IYset(YmaxI0vals, economicpar)
    IYdata = zeros(size(YmaxI0vals,1), 2)
    for i in 1:size(YmaxI0vals,1)
        IY = maxprofitIII_vals(YmaxI0vals[i,1],YmaxI0vals[i,2], economicpar)
        IYdata[i,1] = IY[1]
        IYdata[i,2] = IY[2]
    end
    return IYdata
end


lowYmaxvalue = 140
rise= 10
run = 0.02
Yrange = 0.0:0.1:180.0
YmaxI0vals = calcYmaxI0vals("Ymax", lowYmaxvalue, [1.08,1.15,1.33], rise, run, EconomicPar())
IYvals = IYset(YmaxI0vals, EconomicPar())
DAVC1a = [avvarcostkickIII(IYvals[1,1]-1, Y, EconomicPar()) for Y in Yrange]
DAVC1b = [avvarcostkickIII(IYvals[1,1]+1, Y, EconomicPar()) for Y in Yrange]
DAVC3a = [avvarcostkickIII(IYvals[3,1]-1, Y, EconomicPar()) for Y in Yrange]
DAVC3b = [avvarcostkickIII(IYvals[3,1]+1, Y, EconomicPar()) for Y in Yrange]

YmaxI0vals2 = calcYmaxI0vals("I0", lowYmaxvalue, [1.08,1.15,1.33], rise, run, EconomicPar())
IYvals2 = IYset(YmaxI0vals2, EconomicPar())


let 
    lowYmaxvalue = 140
    rise= 10
    run = 0.02
    YmaxI0vals = calcYmaxI0vals("Ymax", lowYmaxvalue, [1.08,1.15,1.33], rise, run, EconomicPar())
    IYvals = IYset(YmaxI0vals, EconomicPar())
    Irange = 0.0:0.01:20.0
    Yrange = 0.0:0.1:180.0
    Yield1 = [yieldIII(I, YmaxI0vals[1,1],YmaxI0vals[1,2]) for I in Irange]
    MC1 = [margcostIII(I, YmaxI0vals[1,1],YmaxI0vals[1,2], EconomicPar()) for I in Irange]
    AVC1 = [avvarcostIII(I, YmaxI0vals[1,1],YmaxI0vals[1,2], EconomicPar()) for I in Irange]
    DAVC1a = [avvarcostkickIII(IYvals[1,1]-1, Y, EconomicPar()) for Y in Yrange]
    DAVC1b = [avvarcostkickIII(IYvals[1,1]+1, Y, EconomicPar()) for Y in Yrange]
    Yield2 = [yieldIII(I, YmaxI0vals[2,1],YmaxI0vals[2,2]) for I in Irange]
    MC2 = [margcostIII(I, YmaxI0vals[2,1],YmaxI0vals[2,2], EconomicPar()) for I in Irange]
    AVC2 = [avvarcostIII(I, YmaxI0vals[2,1],YmaxI0vals[2,2], EconomicPar()) for I in Irange]
    DAVC2a = [avvarcostkickIII(IYvals[2,1]-1, Y, EconomicPar()) for Y in Yrange]
    DAVC2b = [avvarcostkickIII(IYvals[2,1]+1, Y, EconomicPar()) for Y in Yrange]
    Yield3 = [yieldIII(I, YmaxI0vals[3,1],YmaxI0vals[3,2]) for I in Irange]
    MC3 = [margcostIII(I, YmaxI0vals[3,1],YmaxI0vals[3,2], EconomicPar()) for I in Irange]
    AVC3 = [avvarcostIII(I, YmaxI0vals[3,1],YmaxI0vals[3,2], EconomicPar()) for I in Irange]
    DAVC3a = [avvarcostkickIII(IYvals[3,1]-1, Y, EconomicPar()) for Y in Yrange]
    DAVC3b = [avvarcostkickIII(IYvals[3,1]+1, Y, EconomicPar()) for Y in Yrange]
    costcurves = figure(figsize=(7,9))
    subplot(3,1,1)
    plot(Yield1, MC1, color="blue", label="MC")
    plot(Yield1, AVC1, color="orange", label="AVC")
    plot(Yrange, DAVC1a, color="black", linestyle="dashed")
    plot(Yrange, DAVC1b, color="black")
    hlines(EconomicPar().p, 0.0, 180.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 10.0)
    xlim(0.0, 180.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(3,1,2)
    plot(Yield2, MC2, color="blue", label="MC")
    plot(Yield2, AVC2, color="orange", label="AVC")
    plot(Yrange, DAVC2a, color="black", linestyle="dashed")
    plot(Yrange, DAVC2b, color="black")
    hlines(EconomicPar().p, 0.0, 180.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 10.0)
    xlim(0.0, 180.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(3,1,3)
    plot(Yield3, MC3, color="blue", label="MC")
    plot(Yield3, AVC3, color="orange", label="AVC")
    plot(Yrange, DAVC3a, color="black", linestyle="dashed")
    plot(Yrange, DAVC3b, color="black")
    hlines(EconomicPar().p, 0.0, 180.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 10.0)
    xlim(0.0, 180.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    tight_layout()
    return costcurves
    # savefig(joinpath(abpath(), "figs/costcurves.png"))
end   

let 
    lowYmaxvalue = 140
    rise= 10
    run = 0.02
    YmaxI0vals = calcYmaxI0vals("I0", lowYmaxvalue, [1.08,1.15,1.33], rise, run, EconomicPar())
    Irange = 0.0:0.01:20.0
    Yield1 = [yieldIII(I, YmaxI0vals[1,1],YmaxI0vals[1,2]) for I in Irange]
    MC1 = [margcostIII(I, YmaxI0vals[1,1],YmaxI0vals[1,2], EconomicPar()) for I in Irange]
    AVC1 = [avvarcostIII(I, YmaxI0vals[1,1],YmaxI0vals[1,2], EconomicPar()) for I in Irange]
    Yield2 = [yieldIII(I, YmaxI0vals[2,1],YmaxI0vals[2,2]) for I in Irange]
    MC2 = [margcostIII(I, YmaxI0vals[2,1],YmaxI0vals[2,2], EconomicPar()) for I in Irange]
    AVC2 = [avvarcostIII(I, YmaxI0vals[2,1],YmaxI0vals[2,2], EconomicPar()) for I in Irange]
    Yield3 = [yieldIII(I, YmaxI0vals[3,1],YmaxI0vals[3,2]) for I in Irange]
    MC3 = [margcostIII(I, YmaxI0vals[3,1],YmaxI0vals[3,2], EconomicPar()) for I in Irange]
    AVC3 = [avvarcostIII(I, YmaxI0vals[3,1],YmaxI0vals[3,2], EconomicPar()) for I in Irange]
    costcurves = figure()
    subplot(3,1,1)
    plot(Yield1, MC1, color="blue", label="MC")
    plot(Yield1, AVC1, color="orange", label="AVC")
    hlines(EconomicPar().p, 0.0, 180.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 10.0)
    xlim(0.0, 180.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(3,1,2)
    plot(Yield2, MC2, color="blue", label="MC")
    plot(Yield2, AVC2, color="orange", label="AVC")
    hlines(EconomicPar().p, 0.0, 180.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 10.0)
    xlim(0.0, 180.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(3,1,3)
    plot(Yield3, MC3, color="blue", label="MC")
    plot(Yield3, AVC3, color="orange", label="AVC")
    hlines(EconomicPar().p, 0.0, 180.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 10.0)
    xlim(0.0, 180.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    tight_layout()
    return costcurves
    # savefig(joinpath(abpath(), "figs/costcurves.png"))
end  


#Comparing the geometry when keeping revenue/expenses the same but changing I0 and c
param_ratio(FarmBasePar(Ymax = 174.0, I0 = 10, p = 6.70, c = 139))
param_ratio(FarmBasePar(Ymax = 124.0, I0 = 10, p = 6.70, c = 139))
param_ratio(FarmBasePar(Ymax = 174.0, I0 = 20.0, p = 6.70, c = 98.2878))
param_ratio(FarmBasePar(Ymax = 124.0, I0 = 20.0, p = 6.70, c = 98.2878))

calc_c(1.32611,174.0,10.0,6.70)
calc_c(1.32611,174.0,40.0,6.70)
let 
    par1 = FarmBasePar(Ymax = 174.0, I0 = 10, p = 6.70, c = 139)
    par2 = FarmBasePar(Ymax = 124.0, I0 = 10, p = 6.70, c = 139)
    par3 = FarmBasePar(Ymax = 174.0, I0 = 40.0, p = 6.70, c = 69.5)
    par4 = FarmBasePar(Ymax = 124.0, I0 = 40.0, p = 6.70, c = 69.5)
    Irange = 0.0:0.01:40.0
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
    hlines(par1.p, 0.0, 180.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 10.0)
    xlim(0.0, 180.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(2,2,2)
    plot(Yield2, MC2, color="blue", label="MC")
    plot(Yield2, AVC2, color="orange", label="AVC")
    hlines(par2.p, 0.0, 180.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 10.0)
    xlim(0.0, 180.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(2,2,3)
    plot(Yield3, MC3, color="blue", label="MC")
    plot(Yield3, AVC3, color="orange", label="AVC")
    hlines(par3.p, 0.0, 180.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 10.0)
    xlim(0.0, 180.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(2,2,4)
    plot(Yield4, MC4, color="blue", label="MC")
    plot(Yield4, AVC4, color="orange", label="AVC")
    hlines(par4.p, 0.0, 180.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 10.0)
    xlim(0.0, 180.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    tight_layout()
    return costcurves
    # savefig(joinpath(abpath(), "figs/costcurves.png"))
end    

let 
    par1 = FarmBasePar(Ymax = 174.0, I0 = 10, p = 6.70, c = 139)
    par2 = FarmBasePar(Ymax = 124.0, I0 = 10, p = 6.70, c = 139)
    par3 = FarmBasePar(Ymax = 174.0, I0 = 40.0, p = 6.70, c = 69.5)
    par4 = FarmBasePar(Ymax = 124.0, I0 = 40.0, p = 6.70, c = 69.5)
    Irange = 0.0:0.01:40.0
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
    subplot(1,2,1)
    plot(Yield1, MC1, color="blue", label="MC1")
    plot(Yield1, AVC1, color="orange", label="AVC1")
    plot(Yield3, MC3, color="purple", label="MC2")
    plot(Yield3, AVC3, color="red", label="AVC2")
    hlines(par1.p, 0.0, 180.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 10.0)
    xlim(0.0, 180.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(1,2,2)
    plot(Yield2, MC2, color="blue", label="MC1")
    plot(Yield2, AVC2, color="orange", label="AVC1")
    plot(Yield4, MC4, color="purple", label="MC2")
    plot(Yield4, AVC4, color="red", label="AVC2")
    hlines(par2.p, 0.0, 180.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 10.0)
    xlim(0.0, 180.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    tight_layout()
    return costcurves
    # savefig(joinpath(abpath(), "figs/costcurves.png"))
end

#figure of lines where same rev/exp

let 
    Ymaxrange = 120.0:1.0:200.0
    I0data133 = [calc_I0(1.33, Ymax, 139, 6.70) for Ymax in Ymaxrange]
    I0data140 = [calc_I0(1.40, Ymax, 139, 6.70) for Ymax in Ymaxrange]
    I0data110 = [calc_I0(1.10, Ymax, 139, 6.70) for Ymax in Ymaxrange]
    I0data090 = [calc_I0(0.90, Ymax, 139, 6.70) for Ymax in Ymaxrange]
    revexpparamfigure = figure()
    plot(I0data140, Ymaxrange, color="red", label="rev/exp = 1.40")
    plot(I0data133, Ymaxrange, color="blue", label="rev/exp = 1.33")
    plot(I0data110, Ymaxrange, color="orange", label="rev/exp = 1.10")
    plot(I0data090, Ymaxrange, color="purple", label="rev/exp = 0.90")
    xlabel("I0")
    ylabel("Ymax")
    legend()
    # return revexpparamfigure
    savefig(joinpath(abpath(), "figs/revexpparamfigure.png"))
end

#figure of lines where same rev-exp
let 
    Ymaxrange = 120.0:1.0:200.0
    I0data133rat = [calc_I0(1.33, Ymax, 139, 6.70) for Ymax in Ymaxrange]
    I0data140rat = [calc_I0(1.40, Ymax, 139, 6.70) for Ymax in Ymaxrange]
    I0data110rat = [calc_I0(1.10, Ymax, 139, 6.70) for Ymax in Ymaxrange]
    I0data090rat = [calc_I0(0.90, Ymax, 139, 6.70) for Ymax in Ymaxrange]
    I0data133 = [calc_I0_abs(400, Ymax, 139, 6.70) for Ymax in Ymaxrange]
    I0data140 = [calc_I0_abs(200, Ymax, 139, 6.70) for Ymax in Ymaxrange]
    I0data110 = [calc_I0_abs(100, Ymax, 139, 6.70) for Ymax in Ymaxrange]
    I0data090 = [calc_I0_abs(-50, Ymax, 139, 6.70) for Ymax in Ymaxrange]
    revexpparamfigure = figure()
    plot(I0data140rat, Ymaxrange, color="red", label="rev/exp = 1.40", linestyle="dashed")
    plot(I0data133rat, Ymaxrange, color="blue", label="rev/exp = 1.33", linestyle="dashed")
    plot(I0data110rat, Ymaxrange, color="orange", label="rev/exp = 1.10", linestyle="dashed")
    plot(I0data090rat, Ymaxrange, color="purple", label="rev/exp = 0.90", linestyle="dashed")
    plot(I0data140, Ymaxrange, color="red", label="rev-exp = 400")
    plot(I0data133, Ymaxrange, color="blue", label="rev-exp = 200")
    plot(I0data110, Ymaxrange, color="orange", label="rev-exp = 100")
    plot(I0data090, Ymaxrange, color="purple", label="rev-exp = -50")
    xlabel("I0")
    ylabel("Ymax")
    legend()
    return revexpparamfigure
    # savefig(joinpath(abpath(), "figs/absrevexpparamfigure.png"))
end

calc_I0_abs(400, 170, 139, 6.70)
calc_I0_abs(400, 120, 139, 6.70)

param_absolute(FarmBasePar(Ymax=170,I0=7.066417369701361,p=6.70,c=139))
param_absolute(FarmBasePar(Ymax=120,I0=2.111898970032607,p=6.70,c=139))
param_ratio(FarmBasePar(Ymax=170,I0=7.066417369701361,p=6.70,c=139))
param_ratio(FarmBasePar(Ymax=120,I0=2.111898970032607,p=6.70,c=139))

#Comparing the geometry when keeping revenue/expenses the same but changing Ymax and I0
calc_I0(0.90, 174, 139, 6.70)
calc_I0(0.90, 130, 139, 6.70)

let 
    par1 = FarmBasePar(Ymax = 174.0, I0 = 21.712, p = 6.70, c = 139)
    par2 = FarmBasePar(Ymax = 130.0, I0 = 12.119, p = 6.70, c = 139)
    Irange = 0.0:0.01:40.0
    Yield1 = [yieldIII(I, par1) for I in Irange]
    MC1 = [margcostIII(I, par1) for I in Irange]
    AVC1 = [avvarcostIII(I,par1) for I in Irange]
    Yield2 = [yieldIII(I, par2) for I in Irange]
    MC2 = [margcostIII(I, par2) for I in Irange]
    AVC2 = [avvarcostIII(I,par2) for I in Irange]
    costcurves = figure()
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
    return costcurves
    # savefig(joinpath(abpath(), "figs/costcurves.png"))
end   

calc_I0(1.33, 174, 139, 6.70)
calc_I0(1.33, 130, 139, 6.70)

let 
    par1 = FarmBasePar(Ymax = 174.0, I0 = 9.94158, p = 6.70, c = 139)
    par2 = FarmBasePar(Ymax = 130.0, I0 = 5.54937, p = 6.70, c = 139)
    Irange = 0.0:0.01:40.0
    Yrange = 0.0:0.01:180.0
    Yield1 = [yieldIII(I, par1) for I in Irange]
    MC1 = [margcostIII(I, par1) for I in Irange]
    AVC1 = [avvarcostIII(I,par1) for I in Irange]
    AVCK1 = [avvarcostkickIII(Y, par1, "profit") for Y in Yrange]
    Yield2 = [yieldIII(I, par2) for I in Irange]
    MC2 = [margcostIII(I, par2) for I in Irange]
    AVC2 = [avvarcostIII(I,par2) for I in Irange]
    AVCK2 = [avvarcostkickIII(Y, par2, "profit") for Y in Yrange]
    costcurves = figure()
    subplot(1,2,1)
    plot(Yield1, MC1, color="blue", label="MC")
    plot(Yield1, AVC1, color="orange", label="AVC")
    plot(Yrange, AVCK1, color="green", label="DAVC")
    hlines(par1.p, 0.0, 180.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 10.0)
    xlim(0.0, 180.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(1,2,2)
    plot(Yield2, MC2, color="blue", label="MC")
    plot(Yield2, AVC2, color="orange", label="AVC")
    plot(Yrange, AVCK2, color="green", label="DAVC")
    hlines(par2.p, 0.0, 180.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 10.0)
    xlim(0.0, 180.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    tight_layout()
    return costcurves
    # savefig(joinpath(abpath(), "figs/costcurves.png"))
end   