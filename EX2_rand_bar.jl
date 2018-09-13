using Plots
pyplot()
#gr()
#plotlyjs()

using Printf
using Statistics: mean, std
####################
## main
####################
# directory output
figdir="./fig"
if !isdir(figdir); mkdir(figdir); end

const N = 50; # the number of vector
x = 100(rand(N)); #
x_mean = mean(x);
x_std = std(x);
ind = sortperm(x)[end:-1:end-4];
# Figure
bar(x, xlims=(0.0, Float64(N+1)), ylims=(0.0,105.), legend=false, tickfont=font(12,"sans-serif"),
    title="N=$(N), mean="*@sprintf("%.2f",x_mean)*", σ="*@sprintf("%0.2f",x_std), # GRバックエンドの場合はσが正しく表示されない
    size=(800,600))
xm = [0.0,Float64(N+1)]; ym = [x_mean, x_mean];
plot!(xm,ym, line=:solid, c=:green, lab="mean")
scatter!(ind, x[ind], ms=8., color=:red)
savefig(joinpath(figdir,"rand_bar.png"));
