if !(@isdefined peaks)
    include("peaks.jl")
end


####################
## main
####################

# Parameters
const N=31
xmat, ymat, P = peaks(N)
xvec = vec(xmat[1,:])
yvec = vec(ymat[:,1])

# find min
minval, ind = findmin(P)
cind = CartesianIndices(P)[ind]
row_min, col_min = cind[1], cind[2]

# find max
maxval, ind = findmax(P)
cind = CartesianIndices(P)[ind]
row_max, col_max = cind[1], cind[2]

####################


####################
## plot
####################

# directory where figures are printed
figdir="./fig"
if !isdir(figdir); mkdir(figdir); end

# import GMT
using GMT: GMT
include("./GMTprint.jl")

# Two-dimensional contour
# params and options
crange=(-6,8,1)
xyrange=[xvec[1] xvec[end] yvec[1] yvec[end]]
Δ=(xvec[end]-xvec[1])/2(N-1)
#afg="-Ba1f1 -Bx+lX-axis -By+lY-axis -BWSne"
ax="a1f1 x+lX-axis y+lY-axis WSne"
proj="X12/12"
medge="-W0.1,black"
msize="c0.25"

# GMT commands
#cpt = GMT.makecpt(C="seis", T=crange, N=1, I="c")
cpt = GMT.makecpt(C=:rainbow, T=crange)
G = GMT.surface([xmat[:] ymat[:] P[:]], R=xyrange, I=Δ)
GMT.grdcontour(G, J=proj, R=xyrange, B=ax, color=cpt, W="+c")
GMT.plot!(xvec[col_min], yvec[row_min], J=proj, R=xyrange, S=msize, G=:blue)
GMT.plot!(xvec[col_max], yvec[row_max], J=proj, R=xyrange, S=msize, G=:red)
GMTprint("contour.ps",figdir)

# Three dimensional surface plot
# params and options
xyzrange="-3/3/-3/3/-8/9"
proj="X10"
projZ="Z10"
ax="a1f1g1 x+lX y+lY za2f2g1+lZ nSEwZ+"
vw="135/25"
zratio="0.5"
crange="-6/8/0.1"
cbD="jBR+w10.0/0.3+o-5.5/0.0"
cbax="xa2f1 y+lZ"

msize="U0.15"

# GMT commands
# GMT.makecptの -D オプションにバグあり
cpt = GMT.gmt("makecpt -Crainbow -T$crange -D -Z -N")
G = GMT.surface([xmat[:] ymat[:] P[:]], R=xyrange, I=Δ)
GMT.grdview(G, J=proj, R=xyzrange, Jz=zratio, B=ax, C=cpt, Q="sm", p=vw, Z=0.0)
GMT.colorbar!(J=proj, Jz=zratio, R=G, B=cbax, D=cbD, C=cpt)
GMT.scatter3!([xvec[col_min]], [yvec[row_min]], [minval], J=proj, Jz=zratio, R=xyzrange, S=msize, G=:blue, p=vw)
GMT.scatter3!([xvec[col_max]], [yvec[row_max]], [maxval], J=proj, Jz=zratio, R=xyzrange, S=msize, G=:red, p=vw)
GMTprint("surface3D.ps",figdir)

####################
