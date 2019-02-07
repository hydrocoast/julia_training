# Include packages
using NetCDF
using Printf: @printf, @sprintf
using Dates


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

####################

####################
## plot
####################
# directory where figures are printed
figdir="./fig"
if !isdir(figdir); mkdir(figdir); end

# Figures & animation
using GMT: GMT
include("./GMTprint.jl")
GMT.gmt("set FONT_TITLE 16p")

##############
## function(s)
##############
function DrawSnapShot(k::Int, lon, lat, wspd, T::Array{Dates.DateTime,1})
    psname,_,_ = GMT.fname_out(Dict())
    titlestr=Dates.format(T[k], "yyyy/mm")
    # makecpt
    crange="0/14/1"
    cbxy="15.8/3.5/7.5/0.4"
    cafg="-Bxa2f1 -By+l(m/s)"
    afg="-Bxa60f30 -Bya60f30 -BSWNe+t$titlestr"
    proj="X15/7.5"
    region="g0/360/-90/90"
    #
    latmat=repeat(lat, outer=(1,length(lon)))
    lonmat=repeat(lon', outer=(length(lat),1))
    llrange=[lon[1] lon[end] lat[1] lat[end]]
    Δ=(lon[end]-lon[1])/(length(lon)-1)
    # GMT scripts
    cpt = GMT.gmt("makecpt -Chaxby -T$crange -D")
    G = GMT.surface([lonmat[:] latmat[:] vec(wspd[:,:,k])], R=llrange, I=Δ)
    GMT.gmt("psbasemap -J$proj -R$region $afg -P -K > $psname")
    GMT.grdview!(G, J=proj, R=region, C=cpt, Q="i")
    GMT.gmt("pscoast -J -R -Dc -Wthinnest,black -P -K -O >> $psname")
    #GMT.scale!(cafg, D=cbxy, C=cpt)
end
##############


# test to make figure at initial step
#DrawSnapShot(1, lon, lat, wspd, T)

# animation
if Sys.islinux()
    gifdir="./forgif"
    if !isdir(gifdir); mkdir(gifdir); end
    for i=1:24
        @printf("%d,",i)
        DrawSnapShot(i, lon, lat, wspd, T)
        tmpname="time"*@sprintf("%03d",i)
        GMTprint(tmpname,gifdir)
        run(`convert -density 300 $gifdir/$tmpname.eps $gifdir/$tmpname.png`)
    end
    #=
    run(`ffmpeg -i $gifdir/time%03d.png -vf palettegen palette.png -y`)
    run(`ffmpeg -r 3 -i $gifdir/time%03d.png -i palette.png -filter_complex paletteuse MonthlyWspd.gif -y`)
    run(`rm palette.png`)
    =#
end

####################
