#if !isdefined(:Plots)
    using Plots
    pyplot()
    #gr()
#end
if !isdefined(:peaks)
    include("peaks.jl");
end

####################
## main
####################
# directory output
figdir="./fig"
if !isdir(figdir); mkdir(figdir); end

# Parameters
N=31
xmat, ymat, P = peaks(N);
xvec = vec(xmat[1,:])
yvec = vec(ymat[:,1])
# min & max
minval, ind = findmin(P);
row_min,col_min = ind2sub(P,ind);
maxval, ind = findmax(P);
row_max,col_max = ind2sub(P,ind);

# see http://docs.juliaplots.org/latest/colors/#colorschemes
clibrary(:misc)
# Two-dimensional contour
contour(xvec, yvec, P, c=(:rainbow), fill=false, tickfont=12,
        xlims=(-3.,3.), ylims=(-3.,3.), clims=(-6.,8.),
        xlabel="X", ylabel="Y", axis_ratio=:equal)
scatter!([xvec[col_min]], [yvec[row_min]], ms=10., color=:yellow, lab="min")
scatter!([xvec[col_max]], [yvec[row_max]], ms=10., color=:magenta, lab="max",
         legendfont=12,legend=:bottomleft, size=(800,600))
savefig(joinpath(figdir,"contour_2d.png"));  # save figure

# Three dimensional surface plot
# plot(..., linetype=:surface) , or surface(...)
# plot(xvec,yvec,P,c=(:rainbow),linetype=:surface,fillalpha=0.9, tickfont=12,
surface(xvec,yvec,P,c=(:rainbow),fillalpha=0.9, tickfont=12,
        xlims=(-3.,3.), ylims=(-3.,3.), zlims=(-8.,10.), clims=(-6.,8.),
        xlabel="X", ylabel="Y", zlabel="Z", size=(800,600), colorbar=:best)
scatter!([xvec[col_min]], [yvec[row_min]], [minval], ms=8., color=:yellow, lab="min")
scatter!([xvec[col_max]], [yvec[row_max]], [maxval], ms=8., color=:magenta, lab="max",
         legendfont=12, legend=:bottomleft)
savefig(joinpath(figdir,"surface_3d.png")); # save figure
