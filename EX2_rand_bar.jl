using Printf
import Statistics
####################
## main
####################
# directory output
figdir="./fig"
if !isdir(figdir); mkdir(figdir); end

const N = 50; # the number of vector
x = 100(rand(N)); #
x_mean = Statistics.mean(x);
x_std = Statistics.std(x);
ind = sortperm(x)[end:-1:end-4];

# Figure
using PyPlot
fig = figure()
ax = fig[:add_subplot](111)
#ax[:bar](linspace(1,N,50), x, align="center")
ax[:bar](linspace(1,N,50), x) #綺麗にセンタリングされない？
ax[:plot]([0,N+1], [x_mean,x_mean],"-",color="#00ff00",lw=2.0) # ","([x1,x2] [y2,y2]) are necessary
ax[:scatter](ind, x[ind], marker="o", s=25) # Top 5
ax[:set_xlim](0,N+1)
ax[:set_ylim](0,105)
ax[:set_title]("N=$(N), mean="*@sprintf("%.2f",x_mean)*", σ="*@sprintf("%0.2f",x_std))
ax[:grid](color="k", linestyle="--", alpha=0.5)
