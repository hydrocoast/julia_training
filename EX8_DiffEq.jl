# Include packages
using OffsetArrays # OffsetArraysを使ってみたが，あまり使いやすくはないかも
using Plots
pyplot()
clibrary(:misc)
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
    surface(xvec,yvec,D,c=(:rainbow),fillalpha=0.9, tickfont=12,
            xlims=(-3.,3.), ylims=(-3.,3.), zlims=(-8.,10.), clims=(-6.,6.),
            xlabel="X", ylabel="Y", zlabel="Z", size=(800,600),
            colorbar=:best, colorbar_title=" ", title=titlestr, titlefont=14,
            )
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

# For Animation
#anim = @animate for k=0:10:nstep
anim = @animate for k=0:10:nstep
    @printf("%d, ",k)
    SnapShot(xvec, yvec, P[1:ny,1:nx,k], @sprintf("%6.2f",t[k+1])*" s")
end
gifname = "./tmp_DiffEq.gif"
if isfile(gifname); rm(gifname); end
gif(anim, gifname, fps=10) #save the animation

# Make animation gif when using linux
#==
sdirname="./forgif"
pref="DiffEq-"
if !isdir(sdirname); mkdir(sdirname); end
cnt = 0
for k=0:5:nstep
    SnapShot(xvec, yvec, P[1:ny,1:nx,k], @sprintf("%6.2f",t[k+1])*" s")
    savefig(sdirname*"/"*pref*@sprintf("%03d",cnt)*".png")
    cnt += 1
end
if contains(Sys.MACHINE,"linux")
    run(`ffmpeg -i $sdirname/$pref%03d.png -vf palettegen palette.png -y`)
    run(`ffmpeg -r 20 -i $sdirname/$pref%03d.png -i palette.png -filter_complex paletteuse DiffEq_sample.gif -y`)
    run(`rm palette.png`)
end
==#
