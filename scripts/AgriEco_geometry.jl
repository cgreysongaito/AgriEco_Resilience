include("packages.jl")
include("AgriEco_commoncode.jl")


#Yield curves - type III
let 
    data = [yieldIII(I, BMPPar(y0 = 1.0)) for I in 0.0:0.01:5.0]
    typeIII = figure()
    plot(0.0:0.01:5.0, data)
    xlabel("Inputs")
    ylabel("Yield")
    # return typeIII
    savefig(joinpath(abpath(), "figs/typeIIIexample.png"))
end


let 
    Irange = 0.0:0.01:5.0
    data2010 = [yieldIII(I, BMPPar(y0 = 2.0, ymax = 1.0)) for I in Irange]
    data2005 = [yieldIII(I, BMPPar(y0 = 2.0, ymax = 0.5)) for I in Irange]
    data0210 = [yieldIII(I, BMPPar(y0 = 0.2, ymax = 1.0)) for I in Irange]
    data0205 = [yieldIII(I, BMPPar(y0 = 0.2, ymax = 0.5)) for I in Irange]
    typeIIIparamfigure = figure()
    subplot(2,2,1)
    plot(Irange, data2010)
    xlabel("Inputs")
    ylabel("Yield")
    ylim(0.0, 1.0)
    subplot(2,2,2)
    plot(Irange, data2005)
    xlabel("Inputs")
    ylabel("Yield")
    ylim(0.0, 1.0)
    subplot(2,2,3)
    plot(Irange, data0210)
    xlabel("Inputs")
    ylabel("Yield")
    ylim(0.0, 1.0)
    subplot(2,2,4)
    plot(Irange, data0205)
    xlabel("Inputs")
    ylabel("Yield")
    ylim(0.0, 1.0)
    tight_layout()
    # return typeIIIparamfigure
    savefig(joinpath(abpath(), "figs/typeIIIparamfigure.png"))
end

#https://www.economics.utoronto.ca/osborne/2x3/tutorial/MPFRM.HTM
#Marginal revenue versus marginal cost figures
let 
    par1 = BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2)
    par2 = BMPPar(y0 = 2.0, ymax = 0.5, c = 0.5, p = 2.2)
    par3 = BMPPar(y0 = 0.2, ymax = 1.0, c = 0.5, p = 2.2)
    par4 = BMPPar(y0 = 0.2, ymax = 0.5, c = 0.5, p = 2.2)
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
    hlines(par1.p, 0.0, 1.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(2,2,2)
    plot(Yield2, MC2, color="blue", label="MC")
    plot(Yield2, AVC2, color="orange", label="AVC")
    hlines(par2.p, 0.0, 1.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(2,2,3)
    plot(Yield3, MC3, color="blue", label="MC")
    plot(Yield3, AVC3, color="orange", label="AVC")
    hlines(par3.p, 0.0, 1.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(2,2,4)
    plot(Yield4, MC4, color="blue", label="MC")
    plot(Yield4, AVC4, color="orange", label="AVC")
    hlines(par4.p, 0.0, 1.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    tight_layout()
    # return costcurves
    savefig(joinpath(abpath(), "figs/costcurves.png"))
end            

let 
    par1 = BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2)
    par2 = BMPPar(y0 = 2.0, ymax = 0.5, c = 0.5, p = 2.2)
    par3 = BMPPar(y0 = 0.2, ymax = 1.0, c = 0.5, p = 2.2)
    par4 = BMPPar(y0 = 0.2, ymax = 0.5, c = 0.5, p = 2.2)
    Irange = 0.0:0.01:10.0
    Yrange = 0.0:0.01:1.0
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
    hlines(par1.p, 0.0, 1.0, colors="black", label = "MR")
    vlines(maxprofitIII_vals(par1)[2], 0.0, 4.0, colors="red", label="Input Decision")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(2,2,2)
    # plot(Yield2, MC2, color="blue", label="MC")
    # plot(Yield2, AVC2, color="orange", label="AVC")
    plot(Yrange, AVCK2, color="green", label="AVCK")
    hlines(par2.p, 0.0, 1.0, colors="black", label = "MR")
    vlines(maxprofitIII_vals(par2)[2], 0.0, 4.0, colors="red", label="Input Decision")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(2,2,3)
    # plot(Yield3, MC3, color="blue", label="MC")
    # plot(Yield3, AVC3, color="orange", label="AVC")
    plot(Yrange, AVCK3, color="green", label="AVCK")
    hlines(par3.p, 0.0, 1.0, colors="black", label = "MR")
    vlines(maxprofitIII_vals(par3)[2], 0.0, 4.0, colors="red", label="Input Decision")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(2,2,4)
    # plot(Yield4, MC4, color="blue", label="MC")
    # plot(Yield4, AVC4, color="orange", label="AVC")
    plot(Yrange, AVCK4, color="green", label="AVCK")
    hlines(par4.p, 0.0, 1.0, colors="black", label = "MR")
    vlines(maxprofitIII_vals(par4)[2], 0.0, 4.0, colors="red", label="Input Decision")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    tight_layout()
    # return costcurveskick
    savefig(joinpath(abpath(), "figs/costcurveskick.png"))
end 

let 
    par1 = BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2)
    Irange = 0.0:0.01:10.0
    Yrange = 0.0:0.01:1.0
    Yield1 = [yieldIII(I, par1) for I in Irange]
    MC1 = [margcostIII(I, par1) for I in Irange]
    AVC1 = [avvarcostIII(I,par1) for I in Irange]
    AVCK_profit = [avvarcostkickIII(Y, par1, "profit") for Y in Yrange]
    AVCK_yield = [avvarcostkickIII(Y, par1, "yield") for Y in Yrange]
    costcurves = figure(figsize=(8,3.8))
    subplot(1,2,1)
    plot(Yield1, MC1, color="blue", label="MC")
    plot(Yield1, AVC1, color="orange", label="AVC")
    hlines(par1.p, 0.0, 1.0, colors="black", label = "MR")
    plot(Yrange, AVCK_profit, color="green", label="DAVC")
    vlines(maxprofitIII_vals(par1)[2], 0.0, 4.0, colors="red", label="Max Profit\nInput Decision")
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    legend()
    subplot(1,2,2)
    plot(Yield1, MC1, color="blue", label="MC")
    plot(Yield1, AVC1, color="orange", label="AVC")
    hlines(par1.p, 0.0, 1.0, colors="black", label = "MR")
    plot(Yrange, AVCK_yield, color="green", label="DAVC")
    vlines(maxyieldIII_vals(0.1, par1)[2], 0.0, 4.0, colors="red", label="Max Yield\nInput Decision")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    tight_layout()
    # return costcurves
    savefig(joinpath(abpath(), "figs/costcurves_schematic.png"))
end

let 
    par1 = BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2)
    par3 = BMPPar(y0 = 0.2, ymax = 1.0, c = 0.5, p = 2.2)
    Irange = 0.0:0.01:10.0
    Yrange = 0.0:0.01:1.0
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
    hlines(par1.p, 0.0, 1.0, colors="black", label = "MR")
    vlines(maxprofitIII_vals(par1)[2], 0.0, 4.0, colors="red", label="Input Decision")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(2,1,2)
    # plot(Yield3, MC3, color="blue", label="MC")
    # plot(Yield3, AVC3, color="orange", label="AVC")
    plot(Yrange, AVCK3, color="green", label="AVCK")
    hlines(par3.p, 0.0, 1.0, colors="black", label = "MR")
    vlines(maxprofitIII_vals(par3)[2], 0.0, 4.0, colors="red", label="Input Decision")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    tight_layout()
    # return costcurveskick
    savefig(joinpath(abpath(), "figs/costcurveskick_small.png"))
end

let 
    par1 = BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2)
    par3 = BMPPar(y0 = 0.2, ymax = 1.0, c = 0.5, p = 2.2)
    Irange = 0.0:0.01:10.0
    Yrange = 0.0:0.01:1.0
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
    hlines(par1.p, 0.0, 1.0, colors="black", label = "MR")
    hlines(par1.p+0.8, 0.0, 1.0, colors="black", linestyles="dashed")
    hlines(par1.p-0.8, 0.0, 1.0, colors="black", linestyles="dashed")
    vlines(maxprofitIII_vals(par1)[2], 0.0, 4.0, colors="red", label="Input Decision")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(2,1,2)
    # plot(Yield3, MC3, color="blue", label="MC")
    plot(Yield3, AVC3, color="orange", label="AVC")
    # plot(Yrange, AVCK3, color="green", label="AVCK")
    hlines(par3.p, 0.0, 1.0, colors="black", label = "MR")
    hlines(par3.p+0.8, 0.0, 1.0, colors="black", linestyles="dashed")
    hlines(par3.p-0.8, 0.0, 1.0, colors="black", linestyles="dashed")
    vlines(maxprofitIII_vals(par3)[2], 0.0, 4.0, colors="red", label="Input Decision")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    tight_layout()
    # return costcurveskick
    savefig(joinpath(abpath(), "figs/costcurveskick_pricevariability.png"))
end

let 
    par1 = BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2)
    Irange = 0.0:0.01:10.0
    Yrange = 0.0:0.01:1.0
    Yield1 = [yieldIII(I, par1) for I in Irange]
    MC1 = [margcostIII(I, par1) for I in Irange]
    AVC1 = [avvarcostIII(I,par1) for I in Irange]
    AVCK1 = [avvarcostkickIII(Y, par1, "profit") for Y in Yrange]
    costcurveskick = figure(figsize=(3.5,2.5))
    # plot(Yield1, MC1, color="blue", label="MC")
    plot(Yield1, AVC1, color="orange", label="AVC")
    # plot(Yrange, AVCK1, color="green", label="AVCK")
    hlines(par1.p, 0.0, 1.0, colors="black", label = "MR")
    vlines(maxprofitIII_vals(par1)[2], 0.0, 4.0, colors="red", label="Max profit")
    vlines(maxyieldIII_vals(0.1, par1)[2], 0.0, 4.0, colors="red", linestyles="dashed", label="Max yield")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    # return costcurveskick
    savefig(joinpath(abpath(), "figs/costcurvesmaxprofitvsmaxyield.png"))
end


# Trying out visulisation of max yield curves
let 
    par1 = BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2)
    par2 = BMPPar(y0 = 2.0, ymax = 0.5, c = 0.5, p = 2.2)
    par3 = BMPPar(y0 = 0.2, ymax = 1.0, c = 0.5, p = 2.2)
    par4 = BMPPar(y0 = 0.2, ymax = 0.5, c = 0.5, p = 2.2)
    maxyieldslope = 0.15
    Irange = 0.0:0.01:10.0
    Yrange = 0.0:0.01:1.0
    Yield1 = [yieldIII(I, par1) for I in Irange]
    MC1 = [margcostIII(I, par1) for I in Irange]
    AVC1 = [avvarcostIII(I,par1) for I in Irange]
    AVCK1 = [avvarcostkickIII_maxyield(Y, maxyieldslope, par1) for Y in Yrange]
    Yield2 = [yieldIII(I, par2) for I in Irange]
    MC2 = [margcostIII(I, par2) for I in Irange]
    AVC2 = [avvarcostIII(I,par2) for I in Irange]
    AVCK2 = [avvarcostkickIII_maxyield(Y, maxyieldslope, par2) for Y in Yrange]
    Yield3 = [yieldIII(I, par3) for I in Irange]
    MC3 = [margcostIII(I, par3) for I in Irange]
    AVC3 = [avvarcostIII(I,par3) for I in Irange]
    AVCK3 = [avvarcostkickIII_maxyield(Y, maxyieldslope, par3) for Y in Yrange]
    Yield4 = [yieldIII(I, par4) for I in Irange]
    MC4 = [margcostIII(I, par4) for I in Irange]
    AVC4 = [avvarcostIII(I,par4) for I in Irange]
    AVCK4 = [avvarcostkickIII_maxyield(Y, maxyieldslope, par4) for Y in Yrange]
    costcurveskick = figure()
    subplot(2,2,1)
    plot(Yield1, MC1, color="blue", label="MC")
    plot(Yield1, AVC1, color="orange", label="AVC")
    plot(Yrange, AVCK1, color="green", label="AVCK")
    hlines(par1.p, 0.0, 1.0, colors="black", label = "MR")
    vlines(maxyieldIII_vals(maxyieldslope, par1)[2], 0.0, 4.0, label = "MxY")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(2,2,2)
    plot(Yield2, MC2, color="blue", label="MC")
    plot(Yield2, AVC2, color="orange", label="AVC")
    plot(Yrange, AVCK2, color="green", label="AVCK")
    hlines(par2.p, 0.0, 1.0, colors="black", label = "MR")
    vlines(maxyieldIII_vals(maxyieldslope, par2)[2], 0.0, 4.0, label = "MxY")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(2,2,3)
    plot(Yield3, MC3, color="blue", label="MC")
    plot(Yield3, AVC3, color="orange", label="AVC")
    plot(Yrange, AVCK3, color="green", label="AVCK")
    hlines(par3.p, 0.0, 1.0, colors="black", label = "MR")
    vlines(maxyieldIII_vals(maxyieldslope, par3)[2], 0.0, 4.0, label = "MxY")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(2,2,4)
    plot(Yield4, MC4, color="blue", label="MC")
    plot(Yield4, AVC4, color="orange", label="AVC")
    plot(Yrange, AVCK4, color="green", label="AVCK")
    hlines(par4.p, 0.0, 1.0, colors="black", label = "MR")
    vlines(maxyieldIII_vals(maxyieldslope, par4)[2], 0.0, 4.0, label = "MxY")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    tight_layout()
    return costcurveskick
    # savefig(joinpath(abpath(), "figs/costcurveskick.png"))
end 




# monod
let 
    par1 = BMPPar(ymax=5.0, c = 2.0)
    par2 = BMPPar(ymax=3.0, c = 2.0)
    Irange = 0.0:0.01:10.0
    Yrange = 0.0:0.01:5.0
    Yield1 = [yieldII(I, par1) for I in Irange]
    MC1 = [margcost(I, par1) for I in Irange]
    AVC1 = [avvarcost(I,par1) for I in Irange]
    AVCK1 = [avvarcostkick(Y,par1) for Y in Yrange]
    Yield2 = [yieldII(I, par2) for I in Irange]
    MC2 = [margcost(I, par2) for I in Irange]
    AVC2 = [avvarcost(I,par2) for I in Irange]
    AVCK2 = [avvarcostkick(Y,par2) for Y in Yrange]
    test = figure()
    subplot(2,1,1)
    plot(Yield1, MC1)
    plot(Yield1, AVC1)
    plot(Yrange, AVCK1)
    hlines(1, 0.0, 5.0)
    ylim(0.0, 5.0)
    subplot(2,1,2)
    plot(Yield2, MC2)
    plot(Yield2, AVC2)
    plot(Yrange, AVCK2)
    hlines(1, 0.0, 5.0)
    ylim(0.0, 3.0)
    tight_layout()
    return test
end

let 
    par1 = BMPPar(ymax=5.0, y0=1.0, c = 2.0)
    par2 = BMPPar(ymax=5.0, y0=0.5, c = 2.0)
    Irange = 0.0:0.01:10.0
    Yrange = 0.0:0.01:5.0
    Yield1 = [yieldII(I, par1) for I in Irange]
    MC1 = [margcost(I, par1) for I in Irange]
    AVC1 = [avvarcost(I,par1) for I in Irange]
    AVCK1 = [avvarcostkick(Y,par1) for Y in Yrange]
    Yield2 = [yieldII(I, par2) for I in Irange]
    MC2 = [margcost(I, par2) for I in Irange]
    AVC2 = [avvarcost(I,par2) for I in Irange]
    AVCK2 = [avvarcostkick(Y,par2) for Y in Yrange]
    test = figure()
    subplot(2,1,1)
    plot(Yield1, MC1)
    plot(Yield1, AVC1)
    plot(Yrange, AVCK1)
    hlines(1, 0.0, 5.0)
    ylim(0.0, 5.0)
    subplot(2,1,2)
    plot(Yield2, MC2)
    plot(Yield2, AVC2)
    plot(Yrange, AVCK2)
    hlines(1, 0.0, 5.0)
    ylim(0.0, 3.0)
    tight_layout()
    return test
end


#Monod vs type III
let 
    par = BMPPar(y0 = 2.0, ymax = 1.0, c = 0.5, p = 2.2)
    Irange = 0.0:0.01:10.0
    YieldII = [yieldII(I, par) for I in Irange]
    MCII = [margcostII(I, par) for I in Irange]
    AVCII = [avvarcostII(I,par) for I in Irange]
    YieldIII = [yieldIII(I, par) for I in Irange]
    MCIII = [margcostIII(I, par) for I in Irange]
    AVCIII = [avvarcostIII(I,par) for I in Irange]
    monodvstypeIII = figure()
    subplot(2,2,1)
    plot(Irange, YieldII)
    xlabel("Inputs")
    ylabel("Yield")
    ylim(0.0, 1.0)
    subplot(2,2,2)
    plot(Irange, YieldIII)
    xlabel("Inputs")
    ylabel("Yield")
    ylim(0.0, 1.0)
    subplot(2,2,3)
    plot(YieldII, MCII, color="blue", label="MC")
    plot(YieldII, AVCII, color="orange", label="AVC")
    hlines(par.p, 0.0, 1.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    subplot(2,2,4)
    plot(YieldIII, MCIII, color="blue", label="MC")
    plot(YieldIII, AVCIII, color="orange", label="AVC")
    hlines(par.p, 0.0, 1.0, colors="black", label = "MR")
    legend()
    ylim(0.0, 4.0)
    xlim(0.0, 1.0)
    xlabel("Yield (Q)")
    ylabel("Revenue & Cost")
    tight_layout()
    # return monodvstypeIII
    savefig(joinpath(abpath(), "figs/monodvstypeIII.png"))
end