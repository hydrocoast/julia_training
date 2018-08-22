# Include packages
using NetCDF
using PyPlot, PyCall
anim = pyimport("matplotlib.animation")
using Printf
import Dates
##############
## functions
##############
function ArrangeAxes(ax::PyCall.PyObject)
    xt = collect(Int64, 0:60:360)
    xtl = [collect(0:60:180);collect(-120:60:0)]
    xtl = [@sprintf("%d",xtl[i]) for i=1:length(xtl)]
    yt = collect(Int64, -90:30:90)
    ax[:axis]("scaled")
    ax[:set_xlim](xt[1], xt[end])
    ax[:set_xticks](xt)
    ax[:set_xticklabels](xtl)
    ax[:set_xlabel]("Longitude", fontsize=14)
    ax[:set_yticks](yt)
    ax[:set_ylim](-90., 90.)
    ax[:set_ylabel]("Latitude", fontsize=14)
end
##############
function SetColorbar(fig::PyPlot.Figure, PC::PyCall.PyObject)
    PC[:set_clim](0., 16.)
    cbar = fig[:colorbar](PC, ticks=linspace(0.,16.,9))
    cbar[:ax][:set_ylabel]("mean wind speed (m/s)", fontsize=14)
end
##############
function DrawSnapShot(k::Int, ax::PyCall.PyObject,
                      lon, lat, wspd, Tstr::Array{String,1})
    @printf("%d, ",k+1)
    ax[:clear]()
    #fig[:clear]()
    PC = ax[:pcolor](lon, lat, wspd[:,:,k+1], cmap="jet")
    ax[:set_title](Tstr[k+1], fontsize=14)
    ArrangeAxes(ax)
    return PC
end
##############

####################
## main
####################

# Name of NetCDF file
ncfile="./data/wspd.mon.mean.nc"
if !isfile(ncfile)
    # download NetCDF file
    # These data were collected and distributed by
    # Research Institute for Sustainable Humanosphere,
    # Kyoto University (http://database.rish.kyoto-u.ac.jp/index-e.html).
    url="http://database.rish.kyoto-u.ac.jp/arch/ncep/data/ncep.reanalysis.derived/surface/wspd.mon.mean.nc"
    download(url, ncfile)
end

# Get information
# ncinfo(ncfile)

# Get variables
lon = convert.(Float64, ncread(ncfile,"lon"))
lat = convert.(Float64, ncread(ncfile,"lat"))
wspd = permutedims(ncread(ncfile,"wspd"), [2 1 3])
# convert the order of latitudes, 90:-90 to -90:90
lat = reverse(lat, dims=1)
wspd = reverse(wspd, dims=1)
torg = ncread(ncfile,"time")
nt = length(torg);
T = Dates.DateTime(1800,1,1)+Dates.Hour.(Int.(torg))
# Figures & animation
# figure
fig = figure(figsize=(9,5))
ax = fig[:add_subplot](111)
Tstr = Dates.format.(T, "yyyy/mm")

# 1st step
PC = DrawSnapShot(0, ax, lon, lat, wspd, Tstr)
SetColorbar(fig, PC)
# animation
wanim = anim[:FuncAnimation](fig, DrawSnapShot, fargs=(ax, lon, lat, wspd, Tstr), interval=400, frames=24)
wanim[:save]("monthly_wspd_PyPlot.gif", writer="imagemagick")
# closeをしないとなぜか無限ループになる？ (PyPlot 2.5.0, PyCall 1.15.0時点)
fig[:clear]()
close(fig)
