include("packages.jl")
include("AgriEco_commoncode.jl")

#Distance to MR AVC intersection
#Marginal revenue versus marginal cost figures
let 
    lowymaxvalue = 140
    rise= 10
    run = 0.02
    ymaxy0vals = calcymaxy0vals("ymax", lowymaxvalue, [1.08,1.15,1.33], rise, run, EconomicPar())
    Irange = 0.0:0.01:20.0
    Yield1 = [yieldIII(I, ymaxy0vals[1,1],ymaxy0vals[1,2]) for I in Irange]
    MC1 = [margcostIII(I, ymaxy0vals[1,1],ymaxy0vals[1,2], EconomicPar()) for I in Irange]
    AVC1 = [avvarcostIII(I, ymaxy0vals[1,1],ymaxy0vals[1,2], EconomicPar()) for I in Irange]
    Yield2 = [yieldIII(I, ymaxy0vals[2,1],ymaxy0vals[2,2]) for I in Irange]
    MC2 = [margcostIII(I, ymaxy0vals[2,1],ymaxy0vals[2,2], EconomicPar()) for I in Irange]
    AVC2 = [avvarcostIII(I, ymaxy0vals[2,1],ymaxy0vals[2,2], EconomicPar()) for I in Irange]
    Yield3 = [yieldIII(I, ymaxy0vals[3,1],ymaxy0vals[3,2]) for I in Irange]
    MC3 = [margcostIII(I, ymaxy0vals[3,1],ymaxy0vals[3,2], EconomicPar()) for I in Irange]
    AVC3 = [avvarcostIII(I, ymaxy0vals[3,1],ymaxy0vals[3,2], EconomicPar()) for I in Irange]
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
    lowymaxvalue = 140
    rise= 10
    run = 0.02
    ymaxy0vals = calcymaxy0vals("y0", lowymaxvalue, [1.08,1.15,1.33], rise, run, EconomicPar())
    Irange = 0.0:0.01:20.0
    Yield1 = [yieldIII(I, ymaxy0vals[1,1],ymaxy0vals[1,2]) for I in Irange]
    MC1 = [margcostIII(I, ymaxy0vals[1,1],ymaxy0vals[1,2], EconomicPar()) for I in Irange]
    AVC1 = [avvarcostIII(I, ymaxy0vals[1,1],ymaxy0vals[1,2], EconomicPar()) for I in Irange]
    Yield2 = [yieldIII(I, ymaxy0vals[2,1],ymaxy0vals[2,2]) for I in Irange]
    MC2 = [margcostIII(I, ymaxy0vals[2,1],ymaxy0vals[2,2], EconomicPar()) for I in Irange]
    AVC2 = [avvarcostIII(I, ymaxy0vals[2,1],ymaxy0vals[2,2], EconomicPar()) for I in Irange]
    Yield3 = [yieldIII(I, ymaxy0vals[3,1],ymaxy0vals[3,2]) for I in Irange]
    MC3 = [margcostIII(I, ymaxy0vals[3,1],ymaxy0vals[3,2], EconomicPar()) for I in Irange]
    AVC3 = [avvarcostIII(I, ymaxy0vals[3,1],ymaxy0vals[3,2], EconomicPar()) for I in Irange]
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
function IYset(ymaxy0vals, economicpar)
    IYdata = zeros(size(ymaxy0vals,1), 2)
    for i in 1:size(ymaxy0vals,1)
        IY = maxprofitIII_vals(ymaxy0vals[i,1],ymaxy0vals[i,2], economicpar)
        IYdata[i,1] = IY[1]
        IYdata[i,2] = IY[2]
    end
    return IYdata
end


lowymaxvalue = 140
rise= 10
run = 0.02
Yrange = 0.0:0.1:180.0
ymaxy0vals = calcymaxy0vals("ymax", lowymaxvalue, [1.08,1.15,1.33], rise, run, EconomicPar())
IYvals = IYset(ymaxy0vals, EconomicPar())
DAVC1a = [avvarcostkickIII(IYvals[1,1]-1, Y, EconomicPar()) for Y in Yrange]
DAVC1b = [avvarcostkickIII(IYvals[1,1]+1, Y, EconomicPar()) for Y in Yrange]
DAVC3a = [avvarcostkickIII(IYvals[3,1]-1, Y, EconomicPar()) for Y in Yrange]
DAVC3b = [avvarcostkickIII(IYvals[3,1]+1, Y, EconomicPar()) for Y in Yrange]

ymaxy0vals2 = calcymaxy0vals("y0", lowymaxvalue, [1.08,1.15,1.33], rise, run, EconomicPar())
IYvals2 = IYset(ymaxy0vals2, EconomicPar())


let 
    lowymaxvalue = 140
    rise= 10
    run = 0.02
    ymaxy0vals = calcymaxy0vals("ymax", lowymaxvalue, [1.08,1.15,1.33], rise, run, EconomicPar())
    IYvals = IYset(ymaxy0vals, EconomicPar())
    Irange = 0.0:0.01:20.0
    Yrange = 0.0:0.1:180.0
    Yield1 = [yieldIII(I, ymaxy0vals[1,1],ymaxy0vals[1,2]) for I in Irange]
    MC1 = [margcostIII(I, ymaxy0vals[1,1],ymaxy0vals[1,2], EconomicPar()) for I in Irange]
    AVC1 = [avvarcostIII(I, ymaxy0vals[1,1],ymaxy0vals[1,2], EconomicPar()) for I in Irange]
    DAVC1a = [avvarcostkickIII(IYvals[1,1]-1, Y, EconomicPar()) for Y in Yrange]
    DAVC1b = [avvarcostkickIII(IYvals[1,1]+1, Y, EconomicPar()) for Y in Yrange]
    Yield2 = [yieldIII(I, ymaxy0vals[2,1],ymaxy0vals[2,2]) for I in Irange]
    MC2 = [margcostIII(I, ymaxy0vals[2,1],ymaxy0vals[2,2], EconomicPar()) for I in Irange]
    AVC2 = [avvarcostIII(I, ymaxy0vals[2,1],ymaxy0vals[2,2], EconomicPar()) for I in Irange]
    DAVC2a = [avvarcostkickIII(IYvals[2,1]-1, Y, EconomicPar()) for Y in Yrange]
    DAVC2b = [avvarcostkickIII(IYvals[2,1]+1, Y, EconomicPar()) for Y in Yrange]
    Yield3 = [yieldIII(I, ymaxy0vals[3,1],ymaxy0vals[3,2]) for I in Irange]
    MC3 = [margcostIII(I, ymaxy0vals[3,1],ymaxy0vals[3,2], EconomicPar()) for I in Irange]
    AVC3 = [avvarcostIII(I, ymaxy0vals[3,1],ymaxy0vals[3,2], EconomicPar()) for I in Irange]
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
    lowymaxvalue = 140
    rise= 10
    run = 0.02
    ymaxy0vals = calcymaxy0vals("y0", lowymaxvalue, [1.08,1.15,1.33], rise, run, EconomicPar())
    Irange = 0.0:0.01:20.0
    Yield1 = [yieldIII(I, ymaxy0vals[1,1],ymaxy0vals[1,2]) for I in Irange]
    MC1 = [margcostIII(I, ymaxy0vals[1,1],ymaxy0vals[1,2], EconomicPar()) for I in Irange]
    AVC1 = [avvarcostIII(I, ymaxy0vals[1,1],ymaxy0vals[1,2], EconomicPar()) for I in Irange]
    Yield2 = [yieldIII(I, ymaxy0vals[2,1],ymaxy0vals[2,2]) for I in Irange]
    MC2 = [margcostIII(I, ymaxy0vals[2,1],ymaxy0vals[2,2], EconomicPar()) for I in Irange]
    AVC2 = [avvarcostIII(I, ymaxy0vals[2,1],ymaxy0vals[2,2], EconomicPar()) for I in Irange]
    Yield3 = [yieldIII(I, ymaxy0vals[3,1],ymaxy0vals[3,2]) for I in Irange]
    MC3 = [margcostIII(I, ymaxy0vals[3,1],ymaxy0vals[3,2], EconomicPar()) for I in Irange]
    AVC3 = [avvarcostIII(I, ymaxy0vals[3,1],ymaxy0vals[3,2], EconomicPar()) for I in Irange]
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


#Comparing the geometry when keeping revenue/expenses the same but changing y0 and c
param_ratio(FarmBasePar(ymax = 174.0, y0 = 10, p = 6.70, c = 139))
param_ratio(FarmBasePar(ymax = 124.0, y0 = 10, p = 6.70, c = 139))
param_ratio(FarmBasePar(ymax = 174.0, y0 = 20.0, p = 6.70, c = 98.2878))
param_ratio(FarmBasePar(ymax = 124.0, y0 = 20.0, p = 6.70, c = 98.2878))

calc_c(1.32611,174.0,10.0,6.70)
calc_c(1.32611,174.0,40.0,6.70)
let 
    par1 = FarmBasePar(ymax = 174.0, y0 = 10, p = 6.70, c = 139)
    par2 = FarmBasePar(ymax = 124.0, y0 = 10, p = 6.70, c = 139)
    par3 = FarmBasePar(ymax = 174.0, y0 = 40.0, p = 6.70, c = 69.5)
    par4 = FarmBasePar(ymax = 124.0, y0 = 40.0, p = 6.70, c = 69.5)
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
    par1 = FarmBasePar(ymax = 174.0, y0 = 10, p = 6.70, c = 139)
    par2 = FarmBasePar(ymax = 124.0, y0 = 10, p = 6.70, c = 139)
    par3 = FarmBasePar(ymax = 174.0, y0 = 40.0, p = 6.70, c = 69.5)
    par4 = FarmBasePar(ymax = 124.0, y0 = 40.0, p = 6.70, c = 69.5)
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
    ymaxrange = 120.0:1.0:200.0
    y0data133 = [calc_y0(1.33, ymax, 139, 6.70) for ymax in ymaxrange]
    y0data140 = [calc_y0(1.40, ymax, 139, 6.70) for ymax in ymaxrange]
    y0data110 = [calc_y0(1.10, ymax, 139, 6.70) for ymax in ymaxrange]
    y0data090 = [calc_y0(0.90, ymax, 139, 6.70) for ymax in ymaxrange]
    revexpparamfigure = figure()
    plot(y0data140, ymaxrange, color="red", label="rev/exp = 1.40")
    plot(y0data133, ymaxrange, color="blue", label="rev/exp = 1.33")
    plot(y0data110, ymaxrange, color="orange", label="rev/exp = 1.10")
    plot(y0data090, ymaxrange, color="purple", label="rev/exp = 0.90")
    xlabel("y0")
    ylabel("ymax")
    legend()
    # return revexpparamfigure
    savefig(joinpath(abpath(), "figs/revexpparamfigure.png"))
end

#figure of lines where same rev-exp
let 
    ymaxrange = 120.0:1.0:200.0
    y0data133rat = [calc_y0(1.33, ymax, 139, 6.70) for ymax in ymaxrange]
    y0data140rat = [calc_y0(1.40, ymax, 139, 6.70) for ymax in ymaxrange]
    y0data110rat = [calc_y0(1.10, ymax, 139, 6.70) for ymax in ymaxrange]
    y0data090rat = [calc_y0(0.90, ymax, 139, 6.70) for ymax in ymaxrange]
    y0data133 = [calc_y0_abs(400, ymax, 139, 6.70) for ymax in ymaxrange]
    y0data140 = [calc_y0_abs(200, ymax, 139, 6.70) for ymax in ymaxrange]
    y0data110 = [calc_y0_abs(100, ymax, 139, 6.70) for ymax in ymaxrange]
    y0data090 = [calc_y0_abs(-50, ymax, 139, 6.70) for ymax in ymaxrange]
    revexpparamfigure = figure()
    plot(y0data140rat, ymaxrange, color="red", label="rev/exp = 1.40", linestyle="dashed")
    plot(y0data133rat, ymaxrange, color="blue", label="rev/exp = 1.33", linestyle="dashed")
    plot(y0data110rat, ymaxrange, color="orange", label="rev/exp = 1.10", linestyle="dashed")
    plot(y0data090rat, ymaxrange, color="purple", label="rev/exp = 0.90", linestyle="dashed")
    plot(y0data140, ymaxrange, color="red", label="rev-exp = 400")
    plot(y0data133, ymaxrange, color="blue", label="rev-exp = 200")
    plot(y0data110, ymaxrange, color="orange", label="rev-exp = 100")
    plot(y0data090, ymaxrange, color="purple", label="rev-exp = -50")
    xlabel("y0")
    ylabel("ymax")
    legend()
    return revexpparamfigure
    # savefig(joinpath(abpath(), "figs/absrevexpparamfigure.png"))
end

calc_y0_abs(400, 170, 139, 6.70)
calc_y0_abs(400, 120, 139, 6.70)

param_absolute(FarmBasePar(ymax=170,y0=7.066417369701361,p=6.70,c=139))
param_absolute(FarmBasePar(ymax=120,y0=2.111898970032607,p=6.70,c=139))
param_ratio(FarmBasePar(ymax=170,y0=7.066417369701361,p=6.70,c=139))
param_ratio(FarmBasePar(ymax=120,y0=2.111898970032607,p=6.70,c=139))

#Comparing the geometry when keeping revenue/expenses the same but changing ymax and y0
calc_y0(0.90, 174, 139, 6.70)
calc_y0(0.90, 130, 139, 6.70)

let 
    par1 = FarmBasePar(ymax = 174.0, y0 = 21.712, p = 6.70, c = 139)
    par2 = FarmBasePar(ymax = 130.0, y0 = 12.119, p = 6.70, c = 139)
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

calc_y0(1.33, 174, 139, 6.70)
calc_y0(1.33, 130, 139, 6.70)

let 
    par1 = FarmBasePar(ymax = 174.0, y0 = 9.94158, p = 6.70, c = 139)
    par2 = FarmBasePar(ymax = 130.0, y0 = 5.54937, p = 6.70, c = 139)
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