using Printf: @printf, @sprintf
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

horz=collect(1:N)
horz2=collect(-5:N+5)
m=repeat([x_mean], outer=(length(horz2),1))
stdstr=@sprintf("%0.2f",x_std)

# GMT options
Bopts="-Bxa10f5 -Bya20f10 -BSWne+tstd=$stdstr"
Jopt="X12"
Ropt="-1/52/0/105"
Sopt1="-Sb1u"
Wopt1="0.2,black"

# figure with GMT
import GMT
GMT.xy(Bopts*" "*Sopt1,[horz[:] x[:]], J=Jopt, R=Ropt, G="gray", W=Wopt1)
GMT.xy!([horz2[:] m[:]], J=Jopt, R=Ropt, W="1,blue")
GMTprint("rand_hist.ps", figdir)
