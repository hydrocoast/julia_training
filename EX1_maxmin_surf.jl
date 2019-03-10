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

# directory where figures are printed
figdir="./fig"
if !isdir(figdir); mkdir(figdir); end

using PyCall
using PyPlot
pyimport("mpl_toolkits.mplot3d")

# Three dimensional surface plot
fig1 = plt.figure()
ax1 = fig1.add_subplot(111, projection="3d")
ax1.plot_surface(xmat, ymat, P, cmap="jet")
ax1.plot3D([xvec[col_min]], [yvec[row_min]], [minval], "o", color="#ffff00", ms=10, mec="k", mew=1)
ax1.plot3D([xvec[col_max]], [yvec[row_max]], [maxval], "o", color="#ff00ff", ms=10, mec="k", mew=1)
fig1.savefig(joinpath(figdir,"surface_3d.png"),format="png",dpi=300)

# Two-dimensional contour
nContour = 10
fig2 = plt.figure()
ax2 = fig2.add_subplot(111)
ax2.contour(xmat, ymat, P, nContour, cmap="jet")
ax2.plot([xvec[col_min]], [yvec[row_min]], "o", color="#ffff00", ms=10, mec="k", mew=1)
ax2.plot([xvec[col_max]], [yvec[row_max]], "o", color="#ff00ff", ms=10, mec="k", mew=1)
ax2.axis("image")
fig2.savefig(joinpath(figdir,"contour_2d.png"),format="png",dpi=300)

####################
