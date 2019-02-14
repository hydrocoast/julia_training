#######################
# basic setup
#######################

# simulation time and interval
tmin = 0.0
tmax = 4.0
dt = 0.01

# domain and spacing
xmin = -π
xmax = π
dx = 0.02

c = π/2 # celerity
λ² = (c*dt/dx)^2

nx = convert(Int64, round((xmax-xmin)/dx) + 1)
nt = convert(Int64, round((tmax-tmin)/dt) + 1)

X = collect(Float64, LinRange(xmin, xmax, nx))
T = collect(Float64, LinRange(tmin, tmax, nt))

#######################


#######################
# general solution
#######################
# Gaussian distribution
σ = 1/sqrt(2pi)
U(x,t) = 0.5*(1/(sqrt(2pi)σ))*exp(-(x-c*t)^2/(2σ^2)) + 0.5*(1/(sqrt(2pi)σ))*exp(-(x+c*t)^2/(2σ^2))
u_solution = [ U(x,t) for x in X, t in T ]
#######################


#######################
# numerical simulation
#######################
# preallocate
u = zeros(nx, nt)

# initial condition
# Gaussian distribution
f(x) = 1/(sqrt(2pi)σ)*exp(-x^2/(2σ^2))
u_0 = map(f, X)
u[:,1] = u_0


# 2nd step
#u[:,2] = u[:,1]
for x in 2:nx-1
    u[x,2] = 2(1-λ²)*u[x,1] -u[x,1] +λ²*(u[x-1,1]+u[x+1,1])
    #u[x,2] = u[x,1] + λ²*(u[x+1,1] - 2u[x,1] + u[x-1,1])
end
# Neumann boundary condition
u[1,2] = u[2,2]
u[nx,2] = u[nx-1,2]

#
for t = 3:nt
    for x in 2:nx-1
        u[x,t] = 2(1-λ²)*u[x,t-1] -u[x,t-2] +λ²*(u[x-1,t-1]+u[x+1,t-1])
    end
    # Neumann boundary condition
    u[1,t] = u[2,t]
    u[nx,t] = u[nx-1,t]
end
#######################


#######################
# plot
#######################
# directory where figures are printed
figdir="./fig"
if !isdir(figdir); mkdir(figdir); end

# Figures & animation
using GMT: GMT
include("./GMTprint.jl")
GMT.gmt("set FONT_TITLE 16p")
GMT.gmt("set MAP_GRID_PEN_PRIMARY thinner,gray,-")

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

#######################
