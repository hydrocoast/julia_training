if !(@isdefined peaks)
    include("peaks.jl");
end
using Printf: @printf, @sprintf

####################
## function
####################
function grad2d(dataorg::Array{Float64,2})
    ny, nx = size(dataorg);
    Gx = zeros(ny,nx);
    Gy = zeros(ny,nx);

    diffx = diff(dataorg, dims=2)
    Gx[:,1], Gx[:,end] = diffx[:,1], diffx[:,end]
    Gx[:,2:nx-1] = [(dataorg[i,j+1]-dataorg[i,j-1])/2 for i=1:ny, j=2:nx-1];

    diffy = diff(dataorg, dims=1)
    Gy[1,:], Gy[end,:] = diffy[1,:], diffy[end,:]
    Gy[2:ny-1,:] = [(dataorg[i+1,j]-dataorg[i-1,j])/2 for i=2:ny-1, j=1:nx];

    return(Gx, Gy)
end

####################
## main
####################
# directory output
figdir="./fig"
if !isdir(figdir); mkdir(figdir); end

# Parameters
const N=49
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


# output to draw arrows
tmp1 = 0.1; tmp2=0.1; tmp3 = 0.0;
itv=2
open( "tmp1.txt", "w" ) do fileIO
    [@printf(fileIO, "%8.3f %8.3f %12.3e %12.3e %3.1f %3.1f %3.1f %3.1f\n",
     xmat[k], ymat[k], ϕx[k], ϕy[k],tmp1,tmp1,tmp2,tmp3) for k=1:itv:length(ϕx[:])]
end
open( "tmp2.txt", "w" ) do fileIO
    [@printf(fileIO, "%8.3f %8.3f %12.3e %12.3e %3.1f %3.1f %3.1f %3.1f\n",
     xmat[k], ymat[k], ϕxx[k], ϕyy[k],tmp1,tmp1,tmp2,tmp3) for k=1:itv:length(ϕxx[:])]
end

arrowX=-2.35
arrowY=2.8
arrowsc=1.0
open( "tmpscale1.txt", "w" ) do fileIO
    @printf(fileIO,"%0.2f %0.2f %0.2f 0.00 1.0 1.0 1.0 %0.2f",arrowX,arrowY,arrowsc,arrowsc)
end
arrowsc=0.5
open( "tmpscale2.txt", "w" ) do fileIO
    @printf(fileIO,"%0.2f %0.2f %0.2f 0.00 1.0 1.0 1.0 %0.2f",arrowX,arrowY,arrowsc,arrowsc)
end

# import GMT
import GMT
include("./GMTprint.jl")

# Two-dimensional contour
# params and options
# cpt
crange="-6/8/1"
# xyz2grd
xyrange=[xvec[1] xvec[end] yvec[1] yvec[end]]
Δ=(xvec[end]-xvec[1])/(N-1)
# contour
afg="-Ba1f1 -Bx+lX-axis -By+lY-axis -BWSne"
proj="X12/12"
medge="-W0.1,black"
msize="c0.25"
# arrow
#optA="0.05/0.30/0.10" # LineWidth/HeadLength/HeadSize
optA="+a20+e" # LineWidth/HeadLength/HeadSize
sc="0.4"

# GMT commands
cpt = GMT.gmt("makecpt -Crainbow -T$crange -D")
G = GMT.surface([xmat[:] ymat[:] ϕ[:]], R=xyrange, I=Δ)
psname,_,_ = GMT.fname_out(Dict())

# contours and gradient
GMT.grdcontour(afg, G, J=proj, R=xyrange, color=cpt, W="+c")
GMT.gmt("psvelo tmp1.txt -J -R -A$optA -Gblack -Se$sc/0/0 -P -K -O -V >> $psname")
GMT.gmt("psvelo tmpscale1.txt -J -R -A$optA -Gblack -Se$sc/0/12 -P -K -O -V >> $psname")
GMTprint("contour_grad.ps", figdir)

# filled contours and grad grad
optA="0.05/0.30/0.10" # LineWidth/HeadLength/HeadSize
sc="1.0"
#GMT.grdimage(afg, G, J=proj, R=xyrange, C=cpt)
GMT.grdview(afg, G, J=proj, R=xyrange, C=cpt, Q="i")
GMT.grdcontour!(G, J=proj, R=xyrange,C=1, A=2,L="-6/8")
GMT.gmt("psvelo tmp2.txt -J -R -A$optA -Gblack -Se$sc/0/0 -P -K -O -V >> $psname")
GMT.gmt("psvelo tmpscale2.txt -J -R -A$optA -Gblack -Se$sc/0/12 -P -K -O -V >> $psname")
#GMT.scale!("-Ba2f1", D="12.5/6/12/0.4", C=cpt)
GMTprint("filled_contour.ps", figdir)

# remove temporary files
rm.(filter(x->occursin(r"tmp*\.*",x), readdir()))
