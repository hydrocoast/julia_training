# Include packages
using OffsetArrays # OffsetArraysを使ってみたが，あまり使いやすくはないかも
if !(@isdefined peaks)
    include("peaks.jl")
end
using Printf
##############
## functions
##############
function OpenBoundAll!(D::Array{T,2}, mgn::Int,
                       IS::Int, IE::Int, JS::Int, JE::Int,
                       ny::Int, nx::Int) where T<:AbstractFloat
    D[IS+mgn:0+mgn   ,1+mgn:nx+mgn] = repeat(D[1+mgn ,1+mgn:nx+mgn], outer=(mgn,1)) # Northern
    D[ny+1+mgn:IE+mgn,1+mgn:nx+mgn] = repeat(D[ny+mgn,1+mgn:nx+mgn], outer=(mgn,1)) # Southern
    D[IS+mgn:IE+mgn,   JS+mgn:0+mgn] = repeat(D[IS+mgn:IE+mgn, 1+mgn], outer=(1,mgn)) # Western
    D[IS+mgn:IE+mgn,nx+1+mgn:JE+mgn] = repeat(D[IS+mgn:IE+mgn,nx+mgn], outer=(1,mgn)) # Eastern
    return D
end
##############
function SnapShot(xvec::Array{T,1}, yvec::Array{T,1}, D::Array{T,2},
                  titlestr::String) where T<:AbstractFloat
    # params and options
    proj="X10"
    afg="-Ba1f1g1 -Bx+lX -By+lY -Bza2f2g1+lZ -BnSEwZ+b+t\"$titlestr\""
    vw="130/20"
    zratio="0.5"
    crange="-6/8/0.1"
    cbxy="15.5/6.0/11/0.4"
    cbafg="-Ba2f1"

    Δ=(xvec[end]-xvec[1])/(length(xvec)-1)
    xyrange=[xvec[1] xvec[end] yvec[1] yvec[end]]
    xyzrange="-3/3/-3/3/-8/9"
    # GMT scripts
    cpt = GMT.gmt("makecpt -Crainbow -T$crange -D")
    G = GMT.surface([xmat[:] ymat[:] D[:]], R=xyrange, I=Δ)
    GMT.grdview(afg, G, J=proj, R=xyzrange, Jz=zratio, C=cpt, Q="sm", p=vw)
    #GMT.scale!(cbafg, D=cbxy, C=cpt)
end
##############

####################
## main
####################

# Parameters
const N=31
nx = ny = N
xmat, ymat, P0 = peaks(N);
xvec = vec(xmat[1,:])
yvec = vec(ymat[:,1])
Δx = (xvec[end]-xvec[1])/(N-1)
Δy = (yvec[end]-yvec[1])/(N-1)

# Parameters 2
ν = 5.0e-02 # (m²/s)
Cu = 0.25 # (m/s)
Cv = 0.25 # (m/s)
epsv=1.0e-12

# Time
Δt = 0.02;
T = 15.0;
tlm = [0,T];
nstep = Int(T/Δt);
t = collect(Float64, tlm[1]:Δt:tlm[2]);
# Preallocate & Initialize
mgn = 1;
IS = JS = 1-mgn;
IE = ny + mgn;
JE = nx + mgn;
P = OffsetArray{Float64}(undef, IS:IE, JS:JE, 0:nstep)
# Initial condition t=0
P[1:ny,1:nx,0] = copy(P0)

# Bonundary
P[IS:IE,JS:JE,0] = OpenBoundAll!(P[IS:IE,JS:JE,0],mgn, IS,IE,JS,JE,ny,nx)
# Draw initial conditions
#SnapShot(xvec, yvec, P[1:ny,1:nx,0], @sprintf("%6.2f",t[1])*" s")

# Calculation
for k = 1:nstep
    P0 = OffsetArray{Float64}(undef, IS:IE, JS:JE)
    P0[IS:IE,JS:JE] = P[IS:IE,JS:JE,k-1]
    P1 = zeros(ny,nx)
    for i = 1:ny
        for j = 1:nx
            # advection term
            advterm = -Cv*(Δt/2Δy)*(P0[i+1,j]-P0[i-1,j])-Cu*(Δt/2Δx)*(P0[i,j+1]-P0[i,j-1])
            if abs(advterm)<epsv; advterm=0.0; end;
            # diffusion term
            difterm = ν*((Δt/Δy^2)*(P0[i+1,j]-2P0[i,j]+P0[i-1,j])+(Δt/Δx^2)*(P0[i,j+1]-2P0[i,j]+P0[i,j-1]))
            if abs(difterm)<epsv; difterm=0.0; end;

            # collect the terms
            P1[i,j] = P0[i,j] + advterm + difterm
            # clear
            advterm = difterm = nothing
        end
    end
    # upload
    P[1:nx,1:ny,k] = P1
    P[IS:IE,JS:JE,k] = OpenBoundAll!(P[IS:IE,JS:JE,k],mgn, IS,IE,JS,JE,ny,nx)
    # clear
    P1 = nothing
    #@printf("%d, ",k)
end

# Figures & animation
import GMT
include("./GMTprint.jl")
GMT.gmt("set FONT_TITLE 16p")
GMT.gmt("set MAP_GRID_PEN_PRIMARY thinner,gray,-")

# test initial step
#k=0; SnapShot(xvec, yvec, P[1:ny,1:nx,1], @sprintf("%6.2f",t[k+1])*" s")

# animation
if Sys.islinux()
    gifdir="./forgif"
    if !isdir(gifdir); mkdir(gifdir); end
    for k=0:10:nstep
        @printf("%d, ",k)
        SnapShot(xvec, yvec, P[1:ny,1:nx,k], @sprintf("%6.2f",t[k+1])*" s")
        tmpname="step"*@sprintf("%03d",Int(k/10))
        GMTprint(tmpname,gifdir)
        run(`convert -density 300 $gifdir/$tmpname.eps $gifdir/$tmpname.png`)
    end
    #=
    run(`ffmpeg -i $gifdir/step%03d.png -vf palettegen palette.png -y`)
    run(`ffmpeg -r 10 -i $gifdir/step%03d.png -i palette.png -filter_complex paletteuse ConAdvEq.gif -y`)
    run(`rm palette.png`)
    =#
end
