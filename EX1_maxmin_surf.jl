if !(@isdefined peaks)
    include("peaks.jl")
end


####################
## main
####################

# Parameters
const N=31
xmat, ymat, P = peaks(N)
xvec = vec(xmat[1,:])
yvec = vec(ymat[:,1])

# find min
minval, ind = findmin(P)
cind = CartesianIndices(P)[ind]
row_min, col_min = cind[1], cind[2]

# find max
maxval, ind = findmax(P)
cind = CartesianIndices(P)[ind]
row_max, col_max = cind[1], cind[2]

####################


####################
## plot
####################

# directory output
figdir="./fig"
if !isdir(figdir); mkdir(figdir); end

using Plots
pyplot()
#gr()

# see http://docs.juliaplots.org/latest/colors/#colorschemes
clibrary(:misc)

# Two-dimensional contour
contour(xvec, yvec, P, c=(:rainbow), fill=false, tickfont=12,
        xlims=(-3.,3.), ylims=(-3.,3.), clims=(-6.,8.),
        xlabel="X", ylabel="Y", axis_ratio=:equal)
# max and min
scatter!([xvec[col_min]], [yvec[row_min]], ms=10., color=:yellow, lab="min")
scatter!([xvec[col_max]], [yvec[row_max]], ms=10., color=:magenta, lab="max",
         legendfont=12,legend=:bottomleft, size=(800,600))
# save
savefig(joinpath(figdir,"contour_2d.png"))


# Three dimensional surface plot
# plot(..., linetype=:surface) , or surface(...)
# plot(xvec,yvec,P,c=(:rainbow),linetype=:surface,fillalpha=0.9, tickfont=12,
surface(xvec,yvec,P,c=(:rainbow),fillalpha=0.9, tickfont=12,
        xlims=(-3.,3.), ylims=(-3.,3.), zlims=(-8.,10.), clims=(-6.,8.),
        xlabel="X", ylabel="Y", zlabel="Z", size=(800,600), colorbar=:best)
# max and min
scatter!([xvec[col_min]], [yvec[row_min]], [minval], ms=8., color=:yellow, lab="min")
scatter!([xvec[col_max]], [yvec[row_max]], [maxval], ms=8., color=:magenta, lab="max",
         legendfont=12, legend=:bottomleft)
# save
savefig(joinpath(figdir,"surface_3d.png"))
#######################
