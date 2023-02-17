include("packages.jl") 
include("AgriEco_commoncode.jl") 

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