# Include packages
using Polynomials: polyfit, polyval
using DelimitedFiles: readdlm


####################
## main
####################

# define the filepath & filename
fdir = "./data"
fname = "windspeed.dat"

# load ascii file
dataorg = readdlm(joinpath(fdir,fname))
years = dataorg[:,1]
wind = dataorg[:,2]
stdval = dataorg[:,3]
# regression analysis
lin_p = polyfit(years, wind, 1)
quad_p = polyfit(years, wind, 2)
years_ext = years[end]:2100.0

####################

####################
## plot
####################

# directory where figures are printed
figdir="./fig"
if !isdir(figdir); mkdir(figdir); end

using Plots
pyplot()
#gr()
#plotlyjs()

# original data
plot(years, wind, linetype=:scatter, ms=10., tickfont=12, lab="Raw data",
     legendfont=font(14,"sans-serif"), legend=:bottomleft,
     title="Regression analysis", titlefont=font("sans-serif",16),
     xlabel="Year", ylabel="Wind speed (m/s)",guidefont=font("sans-serif",16),
     size=(800,600),
     )
# linear
plot!(years, polyval(lin_p,years), line=(:solid,2), linecolor=:red, lab="Linear")
plot!(years_ext, polyval(lin_p,years_ext), line=(:dash,2), linecolor=:red, lab="Linear to 2100")
# quad
plot!(years, polyval(quad_p,years), line=(:solid,2), linecolor=:green, lab="Quad")
plot!(years_ext, polyval(quad_p,years_ext), line=(:dash,2), linecolor=:green, lab="Quad to 2100")
xlims!(1945, 2105)

# save figure
savefig(joinpath(figdir,"regression.png"))
####################
