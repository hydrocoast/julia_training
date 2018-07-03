# Include packages
using Polynomials, Interpolations, DSP
using Plots
pyplot()
#gr()
#plotlyjs()

# ※Q5のようにFFTを使っても良いが，前回と同じパッケージを利用するのも面白くないので，ここでは DSPを使用する

# function
function loadcsvsample()
    # define the filepath & filename
    fdir = "./data"
    fname = "dat_climate.csv"
    dataorg = readcsv(join([fdir,fname],"/"), skipstart=1)
    return dataorg
end

####################
## main
####################
# directory output
figdir="./fig"
if !isdir(figdir); mkdir(figdir); end

# read csv data
dataorg = loadcsvsample()
torg = DateTime.(dataorg[:,1], "yyyy/mm/dd HH:MM")
tsecorg = convert.(Float64, Dates.value.((torg-torg[1])/1000)) # ms to s
V = convert.(Float64, dataorg[:,2])
dataorg = nothing

# Interpolate
t = collect(torg[1]:Dates.Day(1):torg[end])
tsec = convert.(Float64, Dates.value.((t-t[1])/1000)) # ms to s
nt = size(t,1)
itp = interpolate((tsecorg, ), V, Gridded(Linear()))
#itp = interpolate((tsecorg, ), V, Gridded(Constant()))
Vint = itp[tsec]
# regression
lin_p = polyfit(tsec, Vint, 1)
# power spectral
# (注)360*2は結果を合わせにいった値のため根拠なし
pdg = welch_pgram(Vint, 360*2, onesided=true; fs=1.0)
days = 1./convert.(Float64, pdg.freq)
PSD = pdg.power
maxval, Tc = findmax(PSD[2:end])


# figure 1
# ticklabel format
xt = collect(DateTime(2012):Dates.Year(1):DateTime(2017))
xtl = Dates.format(xt, "Y")
xt = Dates.value.(xt);
plot(t, Vint, line=(:solid, 1), lab="Uniformed", size=(800,600),
     tickfont=12, legend=:topleft, legendfont=14,
     xticks=(xt, xtl), xlims=(xt[1]-(0.5*365*86400*1e3), xt[end]),
     xlabel="Year", guidefont=12,
     ylims=(62,72),
     )
# plot!(torg, V, line=(:dash, 1), lab="Raw")
plot!(t, polyval(lin_p, tsec), lab="Regression 1")
savefig(joinpath(figdir,"uniformed_data.png"))

plot(days[2:end], PSD[2:end], xscale=:log10, tickfont=12, size=(800, 600),
     lab="Power", legend=:topleft, legendfont=14,
     xlabel="Days", guidefont=14,
     xlims=(1e+00, 1e3),
     )
scatter!([days[Tc+1]], [PSD[Tc+1]], ms=10.,
         lab="Period: "*@sprintf("%.0f",days[Tc+1])*"days",
         )
         #ylims=(0., 550.),
savefig(joinpath(figdir,"trend.png"))
