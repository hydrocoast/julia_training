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

# directory output
figdir="./fig"
if !isdir(figdir); mkdir(figdir); end

using Plots
pyplot()
#gr()
#plotlyjs()

# bar
bar(x, xlims=(0.0, Float64(N+1)), ylims=(0.0,105.), legend=false, tickfont=font(12,"sans-serif"),
    title="N=$(N), mean="*@sprintf("%.2f",x_mean)*", σ="*@sprintf("%0.2f",x_std), # GRバックエンドの場合はσが正しく表示されない
    size=(800,600))

# horizontal line
xm = [0.0,Float64(N+1)]
ym = [x_mean, x_mean]
plot!(xm, ym, line=:solid, c=:green, lab="mean")

# 1st - 5th large
scatter!(ind, x[ind], ms=8., color=:red)

# save
savefig(joinpath(figdir,"rand_bar.png"))

####################
