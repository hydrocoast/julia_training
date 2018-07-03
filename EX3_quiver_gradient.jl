# Include packages
using Plots
pyplot()
#gr()
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
N=31
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

# Two-dimensional non-filled contour
clibrary(:misc)
contour(xvec, yvec, ϕ, c=(:rainbow), fill=false, tickfont=12,
        xlims=(-3.,3.), ylims=(-3.,3.), clims=(-6.,8.),
        xlabel="X", ylabel="Y", axis_ratio=:equal, size=(800,600),
        )
quiver!(vec(xmat[1:qs:end,1:qs:end]), vec(ymat[1:qs:end,1:qs:end]),
        quiver=(-L*vec(ϕx[1:qs:end,1:qs:end]), -L*vec(ϕy[1:qs:end,1:qs:end])),
        color=:black, arrow=(0.3,0.3))
#savefig("./fig/contour_grad2d.png")

# filled contour
clibrary(:misc)
contour(xvec, yvec, ϕ, c=(:rainbow), fill=true, tickfont=12,
        xlims=(-3.,3.), ylims=(-3.,3.), clims=(-6.,8.),
        xlabel="X", ylabel="Y", axis_ratio=:equal, size=(800,600),
        )
quiver!(vec(xmat[1:qs:end,1:qs:end]), vec(ymat[1:qs:end,1:qs:end]),
        quiver=(L*vec(ϕxx[1:qs:end,1:qs:end]), L*vec(ϕyy[1:qs:end,1:qs:end])),
        color=:black, arrow=(0.3,0.3))
#savefig("./fig/contour-filled_grad2d.png")
