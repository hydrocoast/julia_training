# Include packages
using OffsetArrays # OffsetArraysを使ってみたが，あまり使いやすくはないかも
using PyPlot, PyCall
anim = pyimport("matplotlib.animation")
if !isdefined(:peaks)
    include("peaks.jl")
end
##############
## functions
##############
function OpenBoundAll!(D::Array{T,2}, mgn::Int,
                       IS::Int, IE::Int, JS::Int, JE::Int,
                       ny::Int, nx::Int) where T<:AbstractFloat
    D[IS+mgn:0+mgn   ,1+mgn:nx+mgn] = repmat(D[1+mgn ,1+mgn:nx+mgn],mgn,1) # Northern
    D[ny+1+mgn:IE+mgn,1+mgn:nx+mgn] = repmat(D[ny+mgn,1+mgn:nx+mgn],mgn,1) # Southern
    D[IS+mgn:IE+mgn,   JS+mgn:0+mgn] = repmat(D[IS+mgn:IE+mgn, 1+mgn],1,mgn) # Western
    D[IS+mgn:IE+mgn,nx+1+mgn:JE+mgn] = repmat(D[IS+mgn:IE+mgn,nx+mgn],1,mgn) # Eastern
    return D
end
##############
function ForAnim(k::Int, ax::PyCall.PyObject,
                 xmat::Array{T,2}, ymat::Array{T,2}, P::Array{T,3},
                 t::Array{T,1}) where T<:AbstractFloat
    @printf("%d, ",k)
    ax[:clear]()
    C = ax[:plot_surface](xmat, ymat, P[:,:,k+1], cmap="jet")
    C[:set_clim](-6,6)
    ax[:set_zlim](-8,10)
    ax[:set_title](@sprintf("%6.2f", t[k+1])*" s")
end
##############

####################
## main
####################

# Parameters
N=31
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
P = OffsetArray(Float64, IS:IE, JS:JE, 0:nstep);
# Initial condition t=0
P[1:ny,1:nx,0] = copy(P0)

# Bonundary
P[IS:IE,JS:JE,0] = OpenBoundAll!(P[IS:IE,JS:JE,0],mgn, IS,IE,JS,JE,ny,nx)
# Draw initial conditions
#SnapShot(xvec, yvec, P[1:ny,1:nx,0], @sprintf("%6.2f",t[1])*" s")

# Calculation
for k = 1:nstep
    P0 = OffsetArray(Float64, IS:IE, JS:JE)
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

# For Animation
fig = figure()
ax = Axes3D(fig) # ax = fig[:add_subplot](111, projection="3d")はエラー
#== check 1st step
ForAnim(0,ax,xmat,ymat,P[1:ny,1:nx,0:nstep],t)
==#
myanim = anim[:FuncAnimation](fig, ForAnim,fargs=(ax, xmat, ymat, P[1:ny,1:nx,0:10:nstep], t[1:10:end]), interval=100, frames=size(t[1:10:end],1))
myanim[:save]("ConAdvEq_PyPlot.gif", writer="imagemagick")
close(fig)
