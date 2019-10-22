include("packages.jl")


#Monod function (without critical value)
@with_kw mutable struct MonodPar
    r = 0.1
    k1 = 0.5
end

function monod(N, p)
    @unpack r, k1 = p
    r * N / ( k1 + N )
end

function monod_plot(gro, k1val)
    par = MonodPar(r = gro, k1 = k1val)
    plot!(N -> monod(N, par), 0, 10, label = "r $gro k1 $k1val")
end

let
    plot()
    monod_plot(0.5, 0.5)
    monod_plot(0.5, 0.9)
    monod_plot(0.5, 3)
end

let
    plot()
    monod_plot(0.5, 0.5)
    monod_plot(0.8, 0.5)
    monod_plot(1, 0.5)
end

# r changes where the top plateua occurs but not shape. k1 changes shape ie gradient

#Monod function (with critical value)

@with_kw mutable struct MonodCritPar
    r = 0.1
    k1 = 0.5
    nc = 0.4
end

function monodcrit(N, p)
    @unpack r, k1, nc = p
    r * ( N - nc ) / ( k1 + ( N - nc ) )
end

function monodcrit_plot(gro, k1val, ncval)
    par = MonodCritPar(r = gro, k1 = k1val, nc = ncval)
    plot(N -> monodcrit(N, par), 0, 10, label = "r $gro k1 $k1val nc $ncval")
end

monodcrit_plot(0.5, 0.5, 0.5)
monodcrit_plot(0.5, 0.5, 0.4)
monodcrit_plot(0.5, 0.5, 0.1)

let
    plot()
    monod_plot(0.5, 0.5)
    monod_plot(0.8, 0.5)
    monod_plot(1, 0.5)
end

#note for model - Can vary r depending on the amount of water within a year. Keep k1 larger so that slope is smaller.
#white and red noise can be created by an AR process – equation 1 in ruokolainen et al 2009
