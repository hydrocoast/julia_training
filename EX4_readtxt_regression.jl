# Include packages
using Polynomials: polyfit, polyval
using DelimitedFiles: readdlm
# define the filepath & filename
fdir = "./data"
fname = "windspeed.dat"
# directory output
figdir = "./fig"
# load ascii file
dataorg = readdlm(joinpath(fdir,fname))
years = dataorg[:,1]
wind = dataorg[:,2]
stdval = dataorg[:,3]
# regression analysis
lin_p = polyfit(years, wind, 1)
quad_p = polyfit(years, wind, 2)
years_ext = years[end]:2100.0

using PyPlot
#figure
fig = figure()
ax = fig[:add_subplot](111)
ax[:scatter](years, wind, marker="o", s=25)
ax[:plot](years, polyval(lin_p,years), "-", c="r", lw=1.5)
ax[:plot](years, polyval(quad_p,years), "-", c="g", lw=1.5)
ax[:legend](["Quad","Linear","Raw data"]) # 逆順？
ax[:plot](years_ext, polyval(lin_p,years_ext), "--", c="r", lw=1.5)
ax[:plot](years_ext, polyval(quad_p,years_ext), "--", c="g", lw=1.5)
ax[:set_xlim](1940,2105)
ax[:grid](color="k",linestyle="--", alpha=0.5)
ax[:set_xlabel]("Year",fontsize=12)
ax[:set_ylabel]("Wind speed (m/s)",fontsize=12)
# save figure
if !isdir(figdir); mkdir(figdir); end
fig[:savefig](joinpath(figdir,"regression_analysis.png"),format="png",dpi=300)
