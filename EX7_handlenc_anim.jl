using Plots
pyplot()

# Include packages
using NetCDF
using Printf
using Dates

##############
## function(s)
##############
function DrawSnapShot(k::Int, lon, lat, wspd, T::Array{DateTime,1})
    # setup for ticks
    xt = collect(Int64, 0:60:360)
    xtl = [collect(0:60:180);collect(-120:60:0)]
    xtl = [@sprintf("%d",xtl[i]) for i=1:length(xtl)]
    # clibrary
    clibrary(:misc)
    # filled contour
    ## (2018/03 メモ)pyplotバックエンドでは，clims=()の設定は反映されない。なぜ？
    contour(lon, lat, wspd[:,:,k],fill=true, clims=(0.,16.), color=(:rainbow),
             size=(800, 400), tickfont=12, axis_ratio=:equal,
             xlabel="Longitude", ylabel="Latitude", guidefont=12,
             colorbar_title="(m/s)",
             title=Dates.format(T[k], "yyyy/mm"), titlefont=14,
             xticks=(xt, xtl),
             )
end

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
T = DateTime(1800,1,1)+Hour.(Int.(torg))
# Figures & animation
# DrawSnapShot(1, lon, lat, wspd, T) # 1st step
#if !isdir("./forgif"); mkdir("./forgif"); end
anim = @animate for k=1:24
    @printf("%d, ",k)
    DrawSnapShot(k, lon, lat, wspd, T)
end
gifname = "./tmp_monthlywspd.gif"
if isfile(gifname); rm(gifname); end
gif(anim, gifname, fps=4) #save the animation
