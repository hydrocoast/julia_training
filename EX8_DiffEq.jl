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
U(x,t) = 0.5*exp(-10((x-c*t)^2)) + 0.5*exp(-10((x+c*t)^2))
u_solution = [ U(x,t) for x in X, t in T ]
#######################


#######################
# numerical simulation
#######################
# preallocate
u = zeros(nx, nt)

# initial condition
f(x) = exp(-10(x^2))
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
using PyPlot, PyCall
anim = pyimport("matplotlib.animation")

##############
function ForAnim(k::Int, ax::PyCall.PyObject,
                 X::Array{T,1}, P::Array{T,2}, t::Array{T,1}) where T<:AbstractFloat

    @printf("%d, ",k+1)
    # 軸目盛り
    xt = -π:π/2:π
    xtl = ["-π","-π/2","0","π/2","π"]

    ax[:clear]()
    ax[:plot](X, P[:,k+1])
    ax[:set_xticks](xt)
    ax[:set_xticklabels](xtl)
    ax[:set_ylim](-0.5,1.0)
    ax[:set_title](@sprintf("%6.2f", t[k+1])*" s")
end
##############

# For Animation
fig = figure()
ax = fig[:add_subplot](111)
##== check 1st step
#ForAnim(1, ax, X, u, T)
#==#
myanim = anim[:FuncAnimation](fig, ForAnim, fargs=(ax, X, u[:,1:5:end], T[1:5:end]),
                              interval=50, frames=size(T[1:5:end],1))
myanim[:save](joinpath(figdir,"WaveEq_PyPlot.gif"), writer="imagemagick")
close(fig)

#######################
