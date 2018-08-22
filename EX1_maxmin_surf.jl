<<<<<<< HEAD
if !isdefined(:peaks)
=======
#if !isdefined(:Plots)
    using Plots
    pyplot()
    #gr()
#end
if !(@isdefined peaks)
>>>>>>> 33ecb64... support Julia v1.0.0
    include("peaks.jl");
end

####################
## main
####################

# Parameters
const N=31
xmat, ymat, P = peaks(N);
xvec = vec(xmat[1,:])
yvec = vec(ymat[:,1])
# min & max
minval, ind = findmin(P);
cind = CartesianIndices(P)[ind]
row_min, col_min = cind[1], cind[2];
maxval, ind = findmax(P);
cind = CartesianIndices(P)[ind]
row_max, col_max = cind[1], cind[2];

using PyPlot
# Three dimensional surface plot
fig1 = figure()
ax1 = Axes3D(fig1) # ax = fig[:add_subplot](111, projection="3d")はエラー
ax1[:plot_surface](xmat, ymat, P, cmap="jet")
ax1[:plot3D]([xvec[col_min]], [yvec[row_min]], [minval], "o", color="#ffff00", ms=10, mec="k", mew=1)
ax1[:plot3D]([xvec[col_max]], [yvec[row_max]], [maxval], "o", color="#ff00ff", ms=10, mec="k", mew=1)

# Two-dimensional contour
nContour = 10
fig2 = figure()
ax2 = fig2[:add_subplot](111)
ax2[:contour](xmat, ymat, P, nContour, cmap="jet")
ax2[:plot]([xvec[col_min]], [yvec[row_min]], "o", color="#ffff00", ms=10, mec="k", mew=1)
ax2[:plot]([xvec[col_max]], [yvec[row_max]], "o", color="#ff00ff", ms=10, mec="k", mew=1)
ax2[:axis]("image")
