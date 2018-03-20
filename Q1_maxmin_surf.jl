if !isdefined(:peaks)
    include("peaks.jl");
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
# create mesh data
xmat = repmat(xvec',ny,1);
ymat = repmat(yvec,1,nx);
P = peaks.(xmat,ymat);
# min & max
minval, ind = findmin(P);
row_min,col_min = ind2sub(P,ind);
maxval, ind = findmax(P);
row_max,col_max = ind2sub(P,ind);

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
