# Include packages
using Interpolations
using Printf
using Polynomials
import DSP
import DelimitedFiles
import Dates

# function
function loadcsvsample()
    # define the filepath & filename
    fdir = "./data"
    fname = "dat_climate.csv"
    dataorg = DelimitedFiles.readdlm(joinpath(fdir,fname), ',', skipstart=1)
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

# figure 1
# ticklabel format
tx = Dates.format.(t,"YYYY-mm-dd")

import GMT
include("./GMTprint.jl")
psname,_,_ = GMT.fname_out(Dict())

# Appearances
proj="X14"
region="2011-7-1T/2017-1-1T/62/72"
Baxes="-Bsxg3O -Bpxa1Yg1Y+lYear -By2g2 -BSW+ggray90"
pen1="-W0.5,orange"
pen2="-W0.5,skyblue"


open( "tmp1.txt", "w" ) do fileIO
    [@printf(fileIO,"%s %8.3f\n",tx[k],Vint[k]) for k=1:nt]
end
open( "tmp2.txt", "w" ) do fileIO
    [@printf(fileIO,"%s %8.3f\n",tx[k],polyval(lin_p, tsec[k])) for k=1:nt]
end
lfile="tmplegend.txt"
open( lfile, "w" ) do fileIO
    print(fileIO, "S 0.7 - 0.7 - 1p,orange 1.5 Daily data\n")
    print(fileIO, "S 0.7 - 0.7 - 1p,skyblue 1.5 Linear regression\n")
end

# GMT conf
GMT.gmt("set FORMAT_DATE_IN yyyy-mm-dd")
GMT.gmt("set FORMAT_DATE_MAP o")
GMT.gmt("set FORMAT_TIME_PRIMARY_MAP abbreviated")
GMT.gmt("set MAP_GRID_PEN_PRIMARY thinner,gray,-")
GMT.gmt("set MAP_GRID_PEN_SECONDARY thinner,gray,-")

# GMT scripts
GMT.gmt("psbasemap -J$proj -R$region $Baxes -K -P -V > $psname")
GMT.gmt("psxy -J -R $pen1 -P -K -V -O tmp1.txt >> $psname")
GMT.gmt("psxy -J -R $pen2 -P -K -V -O tmp2.txt >> $psname")
GMT.gmt("pslegend -J -R -DjTL+w5.5+o0.2/0.2 -F+p0.5+gwhite -O -P -V $lfile >> $psname")
GMTprint("dayly.ps",figdir)


# figure 2
# Appearances
proj="X15l/10"
region="1e+0/2e+3/-30/600"
Baxes="-Bxa1pg1+lDay -Bya100f100g100 -BSWne+ggray95"
pen1="-W0.5,blue"
lfile="tmplegend.txt"
msize="c0.25"
pen2="-W0.2,black"
mfc="tomato"
per = @sprintf("%.0f",days[Tc+1])*"days"
open( lfile, "w" ) do fileIO
    print(fileIO, "S 0.7 - 0.7 - 1p,blue 1.5 Power \n")
    print(fileIO, "S 0.7 c 0.2 tomato thinner,black 1.5 Period: $per \n")
end

# GMT scripts
GMT.gmt("psbasemap -J$proj -R$region $Baxes -K -P -V > $psname")
GMT.xy!(pen1, [days[2:end] PSD[2:end]], J=proj, R=region)
GMT.xy!(pen2, [days[Tc+1] PSD[Tc+1]], J=proj, R=region, G=mfc, S=msize)
GMT.gmt("pslegend -J -R -DjTL+w5.5+o0.2/0.2 -F+p0.5+gwhite -O -P -V $lfile >> $psname")
GMTprint("trend.ps",figdir)

# remove temporary files
rm.(filter(x->occursin(r"tmp*\.*",x), readdir()))
