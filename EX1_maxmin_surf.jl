if !isdefined(:peaks)
    include("peaks.jl");
end

####################
## main
####################
# directory output
figdir="./fig"
if !isdir(figdir); mkdir(figdir); end

# Parameters
N=31
xmat, ymat, P = peaks(N);
xvec = vec(xmat[1,:])
yvec = vec(ymat[:,1])
# min & max
minval, ind = findmin(P);
row_min,col_min = ind2sub(P,ind);
maxval, ind = findmax(P);
row_max,col_max = ind2sub(P,ind);



# import (not using) in order to avoid conflicts
import GMT
include("./GMTprint.jl")

# Two-dimensional contour
# params and options
crange="-6/8/1"
xyrange=[xvec[1] xvec[end] yvec[1] yvec[end]]
Δ=(xvec[end]-xvec[1])/2(N-1)
afg="-Ba1f1 -Bx+lX-axis -By+lY-axis -BWSne"
proj="X12/12"
medge="-W0.1,black"
msize="c0.25"

# GMT commands
#cpt = GMT.makecpt(C="seis",T=crange,N=1,I="c")
cpt = GMT.makecpt(C="rainbow",T=crange,N=1)
G = GMT.surface([xmat[:] ymat[:] P[:]], R=xyrange, I=Δ)
GMT.grdcontour(afg, G, J=proj, R=xyrange, color=cpt, W="+c")
GMT.xy!(afg*" "*medge, [xvec[col_min] yvec[row_min]], J=proj, R=xyrange, S=msize,G="blue")
GMT.xy!(afg*" "*medge, [xvec[col_max] yvec[row_max]], J=proj, R=xyrange, S=msize,G="orange")
GMTprint("contour.ps",dirname=figdir)

# Three dimensional surface plot
# params and options
xyzrange="-3/3/-3/3/-8/9"
proj="X10"
afg="-Ba1f1g1 -Bx+lX -By+lY -Bza2f2g1+lZ -BnSEwZ+"
vw="135/25"
zratio="0.5"
crange="-6/8/0.1"
cbxy="15.5/5.5/11/0.4"
cbafg="-Ba2f1 -By+lZ"

## psxyzに該当するものがない？
#psname,_,_ = GMT.fname_out("ps")
#medge="-W0.1,black"
#msize="-Sc0.25"
#markermin=string([xvec[col_min] yvec[row_min] minval])
#markermax=string([xvec[col_max] yvec[row_max] maxval])

# GMT commands
#cpt = GMT.makecpt("-Z -D",C="rainbow",T=crange)
# GMT.makecptのDオプションでは,色の外挿ができなかったので
cpt = GMT.gmt("makecpt -Crainbow -T$crange -Z -D -N")
G = GMT.surface([xmat[:] ymat[:] P[:]], R=xyrange, I=Δ)
GMT.grdview(afg, G, J=proj, R=xyzrange, Jz=zratio, C=cpt, Q="sm", p=vw)
GMT.scale!(cbafg, D=cbxy, C=cpt)
GMTprint("surface3D.ps",dirname=figdir)
