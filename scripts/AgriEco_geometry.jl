include("packages.jl")
include("AgriEco_commoncode.jl")


#Yield curves - type III
let 
    Irange = 0.0:0.01:20.0
    datahymaxhyo = [yieldIII(I, FarmBasePar(ymax = 174.0, y0 = 10, p = 6.70, c = 139)) for I in Irange]
    datalymaxhyo = [yieldIII(I, FarmBasePar(ymax = 124.0, y0 = 10, p = 6.70, c = 139)) for I in Irange]
    datahymaxlyo = [yieldIII(I, FarmBasePar(ymax = 174.0, y0 = 2, p = 6.70, c = 139)) for I in Irange]
    datalymaxlyo = [yieldIII(I, FarmBasePar(ymax = 124.0, y0 = 2, p = 6.70, c = 139)) for I in Irange]
    typeIIIparamfigure = figure()
    subplot(2,2,1)
    plot(Irange, datahymaxhyo)
    xlabel("Inputs")
    ylabel("Yield")
    ylim(0.0, 180.0)
    subplot(2,2,2)
    plot(Irange, datalymaxhyo)
    xlabel("Inputs")
    ylabel("Yield")
    ylim(0.0, 180.0)
    subplot(2,2,3)
    plot(Irange, datahymaxlyo)
    xlabel("Inputs")
    ylabel("Yield")
    ylim(0.0, 180.0)
    subplot(2,2,4)
    plot(Irange, datalymaxlyo)
    xlabel("Inputs")
    ylabel("Yield")
    ylim(0.0, 180.0)
    tight_layout()
    return typeIIIparamfigure
    # savefig(joinpath(abpath(), "figs/typeIIIparamfigure.png"))
end

#https://www.economics.utoronto.ca/osborne/2x3/tutorial/MPFRM.HTM
#Marginal revenue versus marginal cost figures
let 
    par1 = FarmBasePar(ymax = 174.0, y0 = 10, p = 6.70, c = 139)
    par2 = FarmBasePar(ymax = 124.0, y0 = 10, p = 6.70, c = 139)
    par3 = FarmBasePar(ymax = 174.0, y0 = 2, p = 6.70, c = 139)
    par4 = FarmBasePar(ymax = 124.0, y0 = 2, p = 6.70, c = 139)
    Irange = 0.0:0.01:20.0
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
    par3 = FarmBasePar(ymax = 174.0, y0 = 2, p = 6.70, c = 139)
    par4 = FarmBasePar(ymax = 124.0, y0 = 2, p = 6.70, c = 139)
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
    Yield3 = [yieldIII(I, par3) for I in Irange]
    MC3 = [margcostIII(I, par3) for I in Irange]
    AVC3 = [avvarcostIII(I,par3) for I in Irange]
    AVCK3 = [avvarcostkickIII(Y, par3, "profit") for Y in Yrange]
    Yield4 = [yieldIII(I, par4) for I in Irange]
    MC4 = [margcostIII(I, par4) for I in Irange]
    AVC4 = [avvarcostIII(I,par4) for I in Irange]
    AVCK4 = [avvarcostkickIII(Y, par4, "profit") for Y in Yrange]
    costcurveskick = figure()
    subplot(2,2,1)
    # plot(Yield1, MC1, color="blue", label="MC")
    # plot(Yield1, AVC1, color="orange", label="AVC")
    plot(Yrange, AVCK1, color="green", label="AVCK")
    hlines(par1.p, 0.0, 180.0, colors="black", label = "MR")
    vlines(maxprofitIII_vals(par1)[2], 0.0, 10.0, colors="red", label="Input Decision")
    legend()
    ylim(0.0, 10.0)
    xlim(0.0, 180.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(2,2,2)
    # plot(Yield2, MC2, color="blue", label="MC")
    # plot(Yield2, AVC2, color="orange", label="AVC")
    plot(Yrange, AVCK2, color="green", label="AVCK")
    hlines(par2.p, 0.0, 180.0, colors="black", label = "MR")
    vlines(maxprofitIII_vals(par2)[2], 0.0, 10.0, colors="red", label="Input Decision")
    legend()
    ylim(0.0, 10.0)
    xlim(0.0, 180.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(2,2,3)
    # plot(Yield3, MC3, color="blue", label="MC")
    # plot(Yield3, AVC3, color="orange", label="AVC")
    plot(Yrange, AVCK3, color="green", label="AVCK")
    hlines(par3.p, 0.0, 180.0, colors="black", label = "MR")
    vlines(maxprofitIII_vals(par3)[2], 0.0, 10.0, colors="red", label="Input Decision")
    legend()
    ylim(0.0, 10.0)
    xlim(0.0, 180.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(2,2,4)
    # plot(Yield4, MC4, color="blue", label="MC")
    # plot(Yield4, AVC4, color="orange", label="AVC")
    plot(Yrange, AVCK4, color="green", label="AVCK")
    hlines(par4.p, 0.0, 180.0, colors="black", label = "MR")
    vlines(maxprofitIII_vals(par4)[2], 0.0, 10.0, colors="red", label="Input Decision")
    legend()
    ylim(0.0, 10.0)
    xlim(0.0, 180.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    tight_layout()
    return costcurveskick
    # savefig(joinpath(abpath(), "figs/costcurveskick.png"))
end 

let #MIGHT NEED TO WORK ON CHANGING RATIO OF y0/c OR changing slope for maxyield
    par1 = FarmBasePar(ymax = 174.0, y0 = 10, p = 6.70, c = 139)
    maxyieldslope = 1.0
    Irange = 0.0:0.01:50.0
    Yrange = 0.0:0.01:180.0
    Yield1 = [yieldIII(I, par1) for I in Irange]
    MC1 = [margcostIII(I, par1) for I in Irange]
    AVC1 = [avvarcostIII(I,par1) for I in Irange]
    AVCK_profit = [avvarcostkickIII(Y, par1, "profit") for Y in Yrange]
    AVCK_yield = [avvarcostkickIII(Y, par1, "yield", maxyieldslope) for Y in Yrange]
    costcurves = figure(figsize=(8,3.8))
    subplot(1,2,1)
    plot(Yield1, MC1, color="blue", label="MC")
    plot(Yield1, AVC1, color="orange", label="AVC")
    hlines(par1.p, 0.0, 180.0, colors="black", label = "MR")
    plot(Yrange, AVCK_profit, color="green", label="DAVC")
    vlines(maxprofitIII_vals(par1)[2], 0.0, 30.0, colors="red", label="Max Profit\nInput Decision")
    ylim(0.0, 30.0)
    xlim(0.0, 180.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    legend()
    subplot(1,2,2)
    plot(Yield1, MC1, color="blue", label="MC")
    plot(Yield1, AVC1, color="orange", label="AVC")
    hlines(par1.p, 0.0, 180.0, colors="black", label = "MR")
    plot(Yrange, AVCK_yield, color="green", label="DAVC")
    vlines(maxyieldIII_vals(maxyieldslope, par1)[2], 0.0, 30.0, colors="red", label="Max Yield\nInput Decision")
    legend()
    ylim(0.0, 30.0)
    xlim(0.0, 180.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    tight_layout()
    return costcurves
    # savefig(joinpath(abpath(), "figs/costcurves_schematic.png"))
end

let 
    par1 = FarmBasePar(ymax = 174.0, y0 = 10, p = 6.70, c = 139)
    par3 = FarmBasePar(ymax = 174.0, y0 = 2, p = 6.70, c = 139)
    Irange = 0.0:0.01:20.0
    Yrange = 0.0:0.01:180.0
    Yield1 = [yieldIII(I, par1) for I in Irange]
    MC1 = [margcostIII(I, par1) for I in Irange]
    AVC1 = [avvarcostIII(I,par1) for I in Irange]
    AVCK1 = [avvarcostkickIII(Y, par1, "profit") for Y in Yrange]
    Yield3 = [yieldIII(I, par3) for I in Irange]
    MC3 = [margcostIII(I, par3) for I in Irange]
    AVC3 = [avvarcostIII(I,par3) for I in Irange]
    AVCK3 = [avvarcostkickIII(Y, par3, "profit") for Y in Yrange]
    costcurveskick = figure(figsize=(3.5,5))
    subplot(2,1,1)
    # plot(Yield1, MC1, color="blue", label="MC")
    # plot(Yield1, AVC1, color="orange", label="AVC")
    plot(Yrange, AVCK1, color="green", label="AVCK")
    hlines(par1.p, 0.0, 180.0, colors="black", label = "MR")
    vlines(maxprofitIII_vals(par1)[2], 0.0, 10.0, colors="red", label="Input Decision")
    legend()
    ylim(0.0, 10.0)
    xlim(0.0, 180.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(2,1,2)
    # plot(Yield3, MC3, color="blue", label="MC")
    # plot(Yield3, AVC3, color="orange", label="AVC")
    plot(Yrange, AVCK3, color="green", label="AVCK")
    hlines(par3.p, 0.0, 180.0, colors="black", label = "MR")
    vlines(maxprofitIII_vals(par3)[2], 0.0, 10.0, colors="red", label="Input Decision")
    legend()
    ylim(0.0, 10.0)
    xlim(0.0, 180.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    tight_layout()
    return costcurveskick
    # savefig(joinpath(abpath(), "figs/costcurveskick_small.png"))
end

let 
    par1 = FarmBasePar(ymax = 174.0, y0 = 10, p = 6.70, c = 139)
    par3 = FarmBasePar(ymax = 174.0, y0 = 2, p = 6.70, c = 139)
    Irange = 0.0:0.01:20.0
    Yrange = 0.0:0.01:180.0
    Yield1 = [yieldIII(I, par1) for I in Irange]
    MC1 = [margcostIII(I, par1) for I in Irange]
    AVC1 = [avvarcostIII(I,par1) for I in Irange]
    AVCK1 = [avvarcostkickIII(Y, par1, "profit") for Y in Yrange]
    Yield3 = [yieldIII(I, par3) for I in Irange]
    MC3 = [margcostIII(I, par3) for I in Irange]
    AVC3 = [avvarcostIII(I,par3) for I in Irange]
    AVCK3 = [avvarcostkickIII(Y, par3, "profit") for Y in Yrange]
    costcurveskick = figure(figsize=(3.5,5))
    subplot(2,1,1)
    # plot(Yield1, MC1, color="blue", label="MC")
    plot(Yield1, AVC1, color="orange", label="AVC")
    # plot(Yrange, AVCK1, color="green", label="AVCK")
    hlines(par1.p, 0.0, 180.0, colors="black", label = "MR")
    hlines(par1.p+0.8, 0.0, 180.0, colors="black", linestyles="dashed")
    hlines(par1.p-0.8, 0.0, 180.0, colors="black", linestyles="dashed")
    vlines(maxprofitIII_vals(par1)[2], 0.0, 10.0, colors="red", label="Input Decision")
    legend()
    ylim(0.0, 10.0)
    xlim(0.0, 180.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(2,1,2)
    # plot(Yield3, MC3, color="blue", label="MC")
    plot(Yield3, AVC3, color="orange", label="AVC")
    # plot(Yrange, AVCK3, color="green", label="AVCK")
    hlines(par3.p, 0.0, 180.0, colors="black", label = "MR")
    hlines(par3.p+0.8, 0.0, 180.0, colors="black", linestyles="dashed")
    hlines(par3.p-0.8, 0.0, 180.0, colors="black", linestyles="dashed")
    vlines(maxprofitIII_vals(par3)[2], 0.0, 10.0, colors="red", label="Input Decision")
    legend()
    ylim(0.0, 10.0)
    xlim(0.0, 180.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    tight_layout()
    return costcurveskick
    # savefig(joinpath(abpath(), "figs/costcurveskick_pricevariability.png"))
end

let #MIGHT NEED TO WORK ON CHANGING RATIO OF y0/c OR changing slope for maxyield
    par1 = FarmBasePar(ymax = 174.0, y0 = 10, p = 6.70, c = 139)
    Irange = 0.0:0.01:30.0
    Yrange = 0.0:0.01:180.0
    Yield1 = [yieldIII(I, par1) for I in Irange]
    MC1 = [margcostIII(I, par1) for I in Irange]
    AVC1 = [avvarcostIII(I,par1) for I in Irange]
    AVCK1 = [avvarcostkickIII(Y, par1, "profit") for Y in Yrange]
    costcurveskick = figure(figsize=(3.5,2.5))
    # plot(Yield1, MC1, color="blue", label="MC")
    plot(Yield1, AVC1, color="orange", label="AVC")
    # plot(Yrange, AVCK1, color="green", label="AVCK")
    hlines(par1.p, 0.0, 180.0, colors="black", label = "MR")
    vlines(maxprofitIII_vals(par1)[2], 0.0, 10.0, colors="red", label="Max profit")
    vlines(maxyieldIII_vals(1.0, par1)[2], 0.0, 10.0, colors="red", linestyles="dashed", label="Max yield")
    legend()
    ylim(0.0, 10.0)
    xlim(0.0, 180.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    return costcurveskick
    # savefig(joinpath(abpath(), "figs/costcurvesmaxprofitvsmaxyield.png"))
end


# Trying out visulisation of max yield curves
let #MIGHT NEED TO WORK ON CHANGING RATIO OF y0/c OR changing slope for maxyield
    par1 = FarmBasePar(ymax = 174.0, y0 = 10, p = 6.70, c = 139)
    par2 = FarmBasePar(ymax = 124.0, y0 = 10, p = 6.70, c = 139)
    par3 = FarmBasePar(ymax = 174.0, y0 = 2, p = 6.70, c = 139)
    par4 = FarmBasePar(ymax = 124.0, y0 = 2, p = 6.70, c = 139)
    maxyieldslope = 1.0
    Irange = 0.0:0.01:30.0
    Yrange = 0.0:0.01:1.0
    Yield1 = [yieldIII(I, par1) for I in Irange]
    MC1 = [margcostIII(I, par1) for I in Irange]
    AVC1 = [avvarcostIII(I,par1) for I in Irange]
    AVCK1 = [avvarcostkickIII(Y, par1, "yield", maxyieldslope) for Y in Yrange]
    Yield2 = [yieldIII(I, par2) for I in Irange]
    MC2 = [margcostIII(I, par2) for I in Irange]
    AVC2 = [avvarcostIII(I,par2) for I in Irange]
    AVCK2 = [avvarcostkickIII(Y, par2, "yield", maxyieldslope) for Y in Yrange]
    Yield3 = [yieldIII(I, par3) for I in Irange]
    MC3 = [margcostIII(I, par3) for I in Irange]
    AVC3 = [avvarcostIII(I,par3) for I in Irange]
    AVCK3 = [avvarcostkickIII(Y, par3, "yield", maxyieldslope) for Y in Yrange]
    Yield4 = [yieldIII(I, par4) for I in Irange]
    MC4 = [margcostIII(I, par4) for I in Irange]
    AVC4 = [avvarcostIII(I,par4) for I in Irange]
    AVCK4 = [avvarcostkickIII(Y, par4, "yield", maxyieldslope) for Y in Yrange]
    costcurveskick = figure()
    subplot(2,2,1)
    plot(Yield1, MC1, color="blue", label="MC")
    plot(Yield1, AVC1, color="orange", label="AVC")
    plot(Yrange, AVCK1, color="green", label="AVCK")
    hlines(par1.p, 0.0, 180.0, colors="black", label = "MR")
    vlines(maxyieldIII_vals(maxyieldslope, par1)[2], 0.0, 10.0, label = "MxY")
    legend()
    ylim(0.0, 10.0)
    xlim(0.0, 180.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(2,2,2)
    plot(Yield2, MC2, color="blue", label="MC")
    plot(Yield2, AVC2, color="orange", label="AVC")
    plot(Yrange, AVCK2, color="green", label="AVCK")
    hlines(par2.p, 0.0, 180.0, colors="black", label = "MR")
    vlines(maxyieldIII_vals(maxyieldslope, par2)[2], 0.0, 10.0, label = "MxY")
    legend()
    ylim(0.0, 10.0)
    xlim(0.0, 180.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(2,2,3)
    plot(Yield3, MC3, color="blue", label="MC")
    plot(Yield3, AVC3, color="orange", label="AVC")
    plot(Yrange, AVCK3, color="green", label="AVCK")
    hlines(par3.p, 0.0, 180.0, colors="black", label = "MR")
    vlines(maxyieldIII_vals(maxyieldslope, par3)[2], 0.0, 10.0, label = "MxY")
    legend()
    ylim(0.0, 10.0)
    xlim(0.0, 180.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(2,2,4)
    plot(Yield4, MC4, color="blue", label="MC")
    plot(Yield4, AVC4, color="orange", label="AVC")
    plot(Yrange, AVCK4, color="green", label="AVCK")
    hlines(par4.p, 0.0, 180.0, colors="black", label = "MR")
    vlines(maxyieldIII_vals(maxyieldslope, par4)[2], 0.0, 10.0, label = "MxY")
    legend()
    ylim(0.0, 10.0)
    xlim(0.0, 180.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    tight_layout()
    return costcurveskick
    # savefig(joinpath(abpath(), "figs/costcurveskick.png"))
end 