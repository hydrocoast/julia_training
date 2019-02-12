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

horz=collect(1:N)
horz2=collect(-5:N+5)
m=repeat([x_mean], outer=(length(horz2),1))
stdstr=@sprintf("%0.2f",x_std)

# GMT options
axes="xa10f5 ya20f10 SWne+tstd=$stdstr"
proj="X12"
region="-1/52/0/105"
pen1="thin,black"
pen2="1,blue"
fill=:gray
# figure with GMT
using GMT: GMT
#GMT.xy(Bopts*" "*Sopt1,[horz[:] x[:]], J=Jopt, R=Ropt, G="gray", W=Wopt1)
#GMT.xy!([horz2[:] m[:]], J=Jopt, R=Ropt, W="1,blue")
### size keywordを設定するとplotになる、
### check_caller
### psxy: Warning: 1u+ not a valid number and may not be decoded properly.
GMT.bar(horz[:], x[:], J=proj, R=region, G=fill, W=pen1, size=1)
#GMT.plot!(horz2[:], m[:], J=proj, R=region, B=axes, S="-", W=pen2)
GMTprint("rand_hist.ps", figdir)

####################
