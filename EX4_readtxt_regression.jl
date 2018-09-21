using Polynomials: polyfit, polyval
using DelimitedFiles: readdlm
# define the filepath & filename
fdir = "./data"
fname = "windspeed.dat"
# directory output
figdir="./fig"
if !isdir(figdir); mkdir(figdir); end

# load ascii file
dataorg = DelimitedFiles.readdlm(joinpath(fdir,fname))
years = dataorg[:,1]
wind = dataorg[:,2]
stdval = dataorg[:,3]
# regression analysis
lin_p = polyfit(years, wind, 1)
quad_p = polyfit(years, wind, 2)
years_ext = years[end]:2100.0

# import GMT
import GMT
include("./GMTprint.jl")
psname,_,_ = GMT.fname_out(Dict())

afg="-Bxa20f10+lYear -Bya0.4f0.20+l\"Wind speed (m/s)\" -BSWne"
region="1940/2105/4.2/6.2"
proj="X15/8"
msize="c0.2"
medge="-W0.2,black"
mfc="skyblue"
lwc1="-W0.5,blue"
lwc2="-W0.5,tomato"
GMT.xy(afg*" "*lwc1, [years polyval(lin_p,years)], J=proj, R=region)
GMT.xy!(lwc1*",-", [years_ext polyval(lin_p,years_ext)], J=proj, R=region)
GMT.xy!(lwc2, [years polyval(quad_p,years)], J=proj, R=region)
GMT.xy!(lwc2*",-", [years_ext polyval(quad_p,years_ext)], J=proj, R=region)
GMT.xy!(medge,[years  wind], J=proj, R=region, G=mfc, S=msize)

lfile="tmplegend.txt"
open( lfile, "w" ) do fileIO
    print(fileIO, "S 0.7 c 0.3 skyblue 0.2p,black 1.5 Obs.\n")
    print(fileIO, "S 0.7 - 0.7 - 1p,blue 1.5 linear\n")
    print(fileIO, "S 0.7 - 0.7 - 1p,blue,- 1.5 linear to 2100\n")
    print(fileIO, "S 0.7 - 0.7 - 1p,tomato 1.5 quad\n")
    print(fileIO, "S 0.7 - 0.7 - 1p,tomato,- 1.5 quad to 2100\n")
end
GMT.gmt("pslegend -J$proj -R$region -DjBL+w4.75+o0.25 -F+p0.5+gwhite -O -P -V $lfile >> $psname")
rm(lfile)
GMTprint("regression.ps", figdir)
