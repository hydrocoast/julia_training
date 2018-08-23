using Plots
pyplot()
#gr()

# Include packages
if !(@isdefined peaks)
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
figdir="./fig"
if !isdir(figdir); mkdir(figdir); end

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

# Two-dimensional non-filled contour
clibrary(:misc)
contour(xvec, yvec, ϕ, c=(:rainbow), fill=false, tickfont=12,
        xlims=(-3.,3.), ylims=(-3.,3.), clims=(-6.,8.),
        xlabel="X", ylabel="Y", axis_ratio=:equal, size=(800,600),
        )
quiver!(vec(xmat[1:qs:end,1:qs:end]), vec(ymat[1:qs:end,1:qs:end]),
        quiver=(-L*vec(ϕx[1:qs:end,1:qs:end]), -L*vec(ϕy[1:qs:end,1:qs:end])),
        color=:black, arrow=(0.3,0.3))
savefig(joinpath(figdir,"contour_grad2d.png"))

# filled contour
clibrary(:misc)
contour(xvec, yvec, ϕ, c=(:rainbow), fill=true, tickfont=12,
        xlims=(-3.,3.), ylims=(-3.,3.), clims=(-6.,8.),
        xlabel="X", ylabel="Y", axis_ratio=:equal, size=(800,600),
        )
quiver!(vec(xmat[1:qs:end,1:qs:end]), vec(ymat[1:qs:end,1:qs:end]),
        quiver=(L*vec(ϕxx[1:qs:end,1:qs:end]), L*vec(ϕyy[1:qs:end,1:qs:end])),
        color=:black, arrow=(0.3,0.3))
savefig(joinpath(figdir,"contour-filled_grad2d.png"))
