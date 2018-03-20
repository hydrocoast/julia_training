if !isdefined(:peaks)
    include("peaks.jl");
end
# gradient function
function grad2d(dataorg::Array{Float64,2})
    ny, nx = size(dataorg);
    Gy = zeros(ny,nx);
    Gx = zeros(ny,nx);
    for i = 1:ny
        Gx[i,:] = gradient(dataorg[i,:]);
    end
    for j = 1:nx
        Gy[:,j] = gradient(dataorg[:,j]);
    end
    return(Gx, Gy)
end

####################
## main
####################

# Parameters
Δx = 0.2; Δy = 0.2;
X = [-3. 3.]; Y = [-3. 3.];
xvec = collect(Float64, X[1]:Δx:X[2]);
yvec = collect(Float64, Y[1]:Δy:Y[2]);
nx = length(xvec); ny = length(yvec);
qs = Int64(2);
L=0.25;
# create mesh data
xmat = repmat(xvec',ny,1);
ymat = repmat(yvec,1,nx);
ϕ = peaks.(xmat,ymat);
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
fig1[:savefig]("./fig/contour_grad2d_PyPlot.png",format="png",dpi=300)
fig2[:savefig]("./fig/contourf_grad2d_PyPlot.png", format="png",dpi=300)
