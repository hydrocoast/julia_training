# Include packages
using Interpolations
using Printf: @printf, @sprintf
using Polynomials: polyfit, polyval
using DSP: welch_pgram
using DelimitedFiles: readdlm
import Dates

# function
function loadcsvsample()
    # define the filepath & filename
    fdir = "./data"
    fname = "dat_climate.csv"
    dataorg = readdlm(joinpath(fdir,fname), ',', skipstart=1)
    return dataorg
end

####################
## main
####################
# directory output
figdir = "./fig"
if !isdir(figdir); mkdir(figdir); end

# read csv data
dataorg = loadcsvsample()
torg = Dates.DateTime.(dataorg[:,1], "yyyy/mm/dd HH:MM")
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
lin_p = Polynomials.polyfit(tsec, Vint, 1)
# power spectral
# (注)360*2は結果を合わせにいった値のため根拠なし
pdg = DSP.welch_pgram(Vint, 360*2, onesided=true; fs=1.0)
days = 1.0./convert.(Float64, pdg.freq)
PSD = pdg.power
maxval, Tc = findmax(PSD[2:end])


# ticklabel format
xt = collect(Dates.DateTime(2012):Dates.Year(1):Dates.DateTime(2017))
xtl = Dates.format.(xt, Dates.DateFormat("Y"))
#xt = Dates.value.(xt);

# Figure 1
using PyPlot
fig1 = figure()
ax1 = fig1[:add_subplot](111)
ax1[:plot](t,Vint,"r-")
ax1[:plot](t,polyval(lin_p,tsec),"b-")
ax1[:set_xlim](xt[1]-Dates.Day(100), xt[end])
ax1[:xaxis][:set_ticks](xt)
ax1[:xaxis][:set_ticklabels](xtl)
ax1[:grid](which="major",ls="-",alpha=0.5)
ax1[:legend](["Uniformed","Regression"],fontsize=12,loc=4)
fig1[:savefig](joinpath(figdir,"uniformed_data_PyPlot.png"),format="png",dpi=300)

# Figure 2
fig2 = figure()
ax2 = fig2[:add_subplot](111)
ax2[:semilogx](days[2:end], PSD[2:end],"c-",label="PSD")
ax2[:semilogx](days[Tc+1], PSD[Tc+1],"mo",label="Period: "*@sprintf("%.0f",days[Tc+1])*"days")
ax2[:legend](fontsize=12,loc=2)
ax2[:set_xlim](1e0,1e3)
ax2[:set_xlabel]("Days",fontsize=12)
ax2[:grid](which="major",color="k",ls="--",alpha=0.5)
ax2[:grid](which="minor",color="#7D7D7D",ls="--",alpha=0.5)
fig2[:savefig](joinpath(figdir,"trend_PyPlot.png"),format="png",dpi=300)
