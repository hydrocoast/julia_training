if !isdefined(:peaks)
    include("peaks.jl");
end
# gradient function
function grad2d(dataorg::Array{Float64,2})
    ny, nx = size(dataorg);
    Gy = zeros(ny,nx);
    Gx = zeros(ny,nx);
    for i = 1:ny
        Gx[i,:] = gradient(dataorg[i,:]);
    end
    for j = 1:nx
        Gy[:,j] = gradient(dataorg[:,j]);
    end
    return(Gx, Gy)
end

####################
## main
####################
# directory output
figdir="./fig"
if !isdir(figdir); mkdir(figdir); end

# Parameters
N=31
qs = Int64(2);
L=0.25;
# create mesh data
xmat, ymat, ϕ = peaks(N);
xvec = vec(xmat[1,:])
yvec = vec(ymat[:,1])
# gradient
ϕx,ϕy = grad2d(ϕ);
ϕxx,_ = grad2d(ϕx);
_,ϕyy = grad2d(ϕy);


# import (not using) in order to avoid conflicts
import GMT
include("./GMTprint.jl")

# Two-dimensional contour
# params and options
# cpt
crange="-6/8/1"
# xyz2grd
xyrange=[xvec[1] xvec[end] yvec[1] yvec[end]]
Δ=(xvec[end]-xvec[1])/2(N-1)
# pscontour
afg="-Ba1f1 -Bx+lX-axis -By+lY-axis -BWSne"
proj="X12/12"
medge="-W0.1,black"
msize="c0.25"

# GMT commands
#cpt = GMT.makecpt(C="seis",T=crange,N=1,I="c")
cpt = GMT.gmt("makecpt -Crainbow -T$crange -Z -D -N")
#cpt = GMT.makecpt(C="rainbow",T=crange,N=1)
G = GMT.surface([xmat[:] ymat[:] ϕ[:]], R=xyrange, I=Δ)
GMT.grdcontour(afg, G, J=proj, R=xyrange, color=cpt, W="+c")
psname,_,_ = GMT.fname_out("")

tmp1 = 0.1; tmp2=0.1; tmp3 = 0.0;
itv=2
#optA="0.05/0.30/0.10" # LineWidth/HeadLength/HeadSize
optA="+a15+e" # LineWidth/HeadLength/HeadSize
sc="0.4"
conf="0.39"

#=
open( "tmp.txt", "w" ) do fileIO
    [@printf(fileIO, "%8.3f %8.3f %12.3e %12.3e %3.1f %3.1f %3.1f %3.1f\n",
     xmat[k], ymat[k], ϕx[k], ϕy[k],tmp1,tmp1,tmp2,tmp3) for k=1:itv:length(ϕx[:])]
end
GMT.gmt("psvelo tmp.txt -J -R -A$optA -Gblack -Se$sc/$conf/0 -P -K -O -V >> $psname")
GMTprint("contour_grad.eps")
=#

#=
#GMT.surface([xmat[:] ymat[:] ϕ[:]], R=xyrange, I=Δ,G="tmp.grd")
open( "tmp.txt", "w" ) do fileIO
    [@printf(fileIO, "%8.3f %8.3f %12.3e\n",
     xmat[k], ymat[k], ϕ[k]) for k=1:length(ϕ[:])]
end
region = join(xyrange,"/")

GMT.gmt("xyz2grd tmp.txt -R$region -Gtmp.grd -I0.2")


xyzrange="-3/3/-3/3/-8/9"
zratio="1.0"
GMT.gmt("makecpt -Crainbow -T$crange -Z -D -N > tmp.cpt")
=#
GMT.grdcontour(afg, "tmp.grd", J=proj, R=xyrange,C=1, A=2,L="-6/8",show=1)
GMT.grdview(afg, G, J=proj, R=xyzrange, Jz=zratio, C=cpt, Q="s")
#gmt grdcontour $grdfile -R$region -J$proj -C$cint -A$aint -L$limit -K -V -O >> $psfile
GMT.grdcontour(G, cont=1, annot=2, frame="a", show=1)
#=
arohs=+a30+e
arohs2=0.2/0.4/0.2
sc=0.02
sc2=1.0
conf=0.39

awk '{print $1, $2, 100*$3, 100*$4, 0.1, 0.1, 0.1, 0}' $xyzfile > dat.xy
gmt psvelo dat.xy -JM$size -R$lonw/$lone/$lats/$latn -A$arohs2 -Gblack -Se$sc/$conf/0 -O -P -K -V >> $psfile

awk '{print $2, $3, 100*$5, 100*$6, 100*$8, 100*$9, 0.1, 0}' $obsfile > dat.xy
gmt psvelo dat.xy -JM$size -R$lonw/$lone/$lats/$latn  -Se$sc/$conf/0 -Ggreen -A$arohs2 -W1 -L -O -P -K -V >> $psfile

gmt psxy flt.xy -JM -R -L -W2p,0/160/0 -O -K -V -P >> $psfile
gmt psxy upm.xy -JM -R -W5p,0/160/0 -O -K -V -P >> $psfile
awk '{print $1, $2, $3, $4, 0.001, 0.001, 0.001, 0}' prs.xy | gmt psvelo -JM -R -O -P -K -V -Se$sc2/$conf/0 -GBLUE -A$arohs2 -W1/0/0/0 -L >> $psfile
=#
#=
# Two-dimensional non-filled contour
clibrary(:misc)
contour(xvec, yvec, ϕ, c=(:rainbow), fill=false, tickfont=12,
        xlims=(-3.,3.), ylims=(-3.,3.), clims=(-6.,8.),
        xlabel="X", ylabel="Y", axis_ratio=:equal, size=(800,600),
        )
quiver!(vec(xmat[1:qs:end,1:qs:end]), vec(ymat[1:qs:end,1:qs:end]),
        quiver=(-L*vec(ϕx[1:qs:end,1:qs:end]), -L*vec(ϕy[1:qs:end,1:qs:end])),
        color=:black, arrow=(0.3,0.3))
savefig(joinpath(figdir,"contour_grad2d.png"))

# filled contour
clibrary(:misc)
contour(xvec, yvec, ϕ, c=(:rainbow), fill=true, tickfont=12,
        xlims=(-3.,3.), ylims=(-3.,3.), clims=(-6.,8.),
        xlabel="X", ylabel="Y", axis_ratio=:equal, size=(800,600),
        )
quiver!(vec(xmat[1:qs:end,1:qs:end]), vec(ymat[1:qs:end,1:qs:end]),
        quiver=(L*vec(ϕxx[1:qs:end,1:qs:end]), L*vec(ϕyy[1:qs:end,1:qs:end])),
        color=:black, arrow=(0.3,0.3))
savefig(joinpath(figdir,"contour-filled_grad2d.png"))
=#
