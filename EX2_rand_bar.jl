using Printf: @printf, @sprintf
using Statistics: mean, std


####################
## main
####################
const N = 50 # the number of vector
x = 100(rand(N)) #
x_mean = mean(x)
x_std = std(x)
ind = sortperm(x)[end:-1:end-4]
####################


####################
## plot
####################

# directory where figures are printed
figdir="./fig"
if !isdir(figdir); mkdir(figdir); end

using PyPlot
fig = plt.figure()
ax = fig.add_subplot(111)
ax.bar(LinRange(1,N,50), x, align="center")
ax.plot([0, N+1], [x_mean, x_mean], "-", color="#00ff00", lw=2.0) # ","([x1,x2] [y2,y2]) are necessary
ax.scatter(ind, x[ind], marker="o", s=25) # Top 5
ax.set_xlim(0,N+1)
ax.set_ylim(0,105)
ax.set_title("N=$(N), mean="*@sprintf("%.2f",x_mean)*", σ="*@sprintf("%0.2f",x_std))
ax.grid(color="k", linestyle="--", alpha=0.5)
# save figure
fig.savefig(joinpath(figdir,"rand_bar.png"), format="png", dpi=300)

####################
