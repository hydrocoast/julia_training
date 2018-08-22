<<<<<<< HEAD
if !isdefined(:peaks)
=======
# Include packages
using Plots
pyplot()
#gr()
if !(@isdefined peaks)
>>>>>>> 33ecb64... support Julia v1.0.0
    include("peaks.jl");
end

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
figdir = "./fig"

# Parameters
const N=31
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

using PyPlot
nContour = 14
# Two-dimensional non-filled contour
fig1 = figure()
ax1 = fig1[:add_subplot](111)
CS1 = ax1[:contour](xmat, ymat, ϕ, nContour, cmap="jet")
ax1[:clabel](CS1, collect(Int64,-6:2:8))
Q = ax1[:quiver](xmat[1:qs:end,1:qs:end], ymat[1:qs:end,1:qs:end],
                 -ϕx[1:qs:end,1:qs:end], -ϕy[1:qs:end,1:qs:end])
ax1[:quiverkey](Q, 0.5, 0.90, 1, "1.0",labelpos="E", coordinates="figure")
ax1[:set_xlabel]("X-axis", fontsize=12)
ax1[:set_ylabel]("Y-axis", fontsize=12)
ax1[:axis]("scaled")

# filled contour
fig2 = figure()
ax2 = fig2[:add_subplot](111)
CS2 = ax2[:contourf](xmat, ymat, ϕ, linspace(-6,8,nContour+1), extend="both", cmap="jet")
cbar = fig2[:colorbar](CS2)
cbar[:ax][:set_xlabel]("Z", fontsize=12)
Q = ax2[:quiver](xmat[1:qs:end,1:qs:end], ymat[1:qs:end,1:qs:end],
                 ϕxx[1:qs:end,1:qs:end], ϕyy[1:qs:end,1:qs:end])
ax2[:quiverkey](Q, 0.5, 0.90, 1, "1.0",labelpos="E", coordinates="figure")
ax2[:set_xlabel]("X-axis", fontsize=12)
ax2[:set_ylabel]("Y-axis", fontsize=12)
ax2[:axis]("scaled")

# save figures
if !isdir(figdir); mkdir(figdir); end
fig1[:savefig](joinpath(figdir,"contour_grad2d_PyPlot.png"),format="png",dpi=300)
fig2[:savefig](joinpath(figdir,"contourf_grad2d_PyPlot.png"), format="png",dpi=300)
