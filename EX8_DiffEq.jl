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

using Printf
using Plots
pyplot()

# 軸目盛り
xt = -π:π/2:π
xtl = ["-π","-π/2","0","π/2","π"]


# profiles
d = 50
plt = plot3d(repeat(X,outer=(1,length(1:d:nt))),
             permutedims(repeat(T[1:d:nt],outer=(1,nx))),
             u[:,1:d:nt],
             legend=false,
             )
plt = plot3d!(plt, aspect_ratio=1.0, view_angle=(55,35))
plt = plot3d!(plt, xlabel="space", ylabel="time", guidefont=9, xtick=(xt, xtl))
savefig(joinpath(figdir,"WaveProfiles.svg"))
##

##
# animation
anim = @animate for t = 1:5:nt
    @printf("%d, ",t)
    Plots.plot(X, u[:,t], linestyle=:solid, lw=2.0,
               ylim=(-0.5,1.0), xtick=(xt, xtl), tickfont=10,
               title=@sprintf("%0.3f s", (t-1)*dt), legend=false)
end
gifname = joinpath(figdir,"WaveEq.gif")
if isfile(gifname); rm(gifname); end
gif(anim, gifname, fps=20) #save the animation
##

#######################
