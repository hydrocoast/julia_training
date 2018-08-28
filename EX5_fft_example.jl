# Include packages
import FFTW

##############
## functions
##############
function fftfreq(nt::Int,dt)
    # 演習で使用するデータのサンプル数が偶数個なので調整
    # 奇数の場合は正常に動かないかも．未確認
    if isodd(nt); nt2 = Int((nt-1)/2); else; nt2 = Int(nt/2); end
    T =nt*dt;
    freq = zeros(nt);
    for it = 2:nt2
        freq[it] = (it-1)/T;
    end
    for it = nt2+1:nt
        freq[it] = (it-(nt+2))/T;
    end
    return freq
end
##############
function loadmat()
    # define the filepath & filename
    fdir = "./data";
    fname = "crf_wind.mat";
    # file open & get variables
    matfile = matopen(join([fdir,fname],"/"));
    dt, nt, nz = read(matfile,"dt"), Int(read(matfile,"nt")), Int(read(matfile,"nz"));
    z, u = read(matfile,"z"), read(matfile,"u");
    return dt, nt, nz, z, u
end
##############
function loadtxt()
    # define the filepath & filename
    fdir = "./data"
    fname = "crf_wind.dat"
    # file open & get variables
    f = open(join([fdir,fname],"/"),"r")
    txtorg = readlines(f)
    close(f)
    head = split(txtorg[1],r"\s+")
    nt = parse(Int64, head[1])
    nz = parse(Int64, head[2])
    dt = parse(Float64, txtorg[2])
    z = [parse(Float64, txtorg[3][12(i-1)+1:12i]) for i=1:nz]
    u = [parse(Float64, txtorg[i+3][12(j-1)+1:12j]) for i=1:nz, j=1:nt]
    # return varout
   return dt, nt, nz, z, u
end
##############

####################
## main
####################
# directory output
figdir="./fig"
if !isdir(figdir); mkdir(figdir); end

# Data source mat or txt
#using MAT
#dt, nt, nz, z, u = loadmat();
dt, nt, nz, z, u = loadtxt()

# Fourier transform
data = u[1,:];
F0 = FFTW.fft(data,1);
P = abs.(F0/(nt/2)); # Power
freq = fftfreq(nt,dt);
# figure: Power spectrum density
if isodd(nt); nt2 = Int((nt-1)/2); else; nt2 = Int(nt/2); end

import GMT
include("./GMTprint.jl")
psname,_,_ = GMT.fname_out(Dict())

# figure 1
proj="X12l/10l"
region="2e-4/1e+1/1e-4/2e+0"
Baxes="-Bsg3 -Bpxa1g1p+l\"Frequency (Hz)\" -Bpya1g1p+l\"Power (m@+2@+/s@+2@+)\" -BSWne"
Baxes2="--MAP_GRID_PEN_PRIMARY=thinner,black --MAP_GRID_PEN_SECONDARY=thinner,gray,-"
pen="-W0.25,blue"
# GMT plot
GMT.gmt("psbasemap -J$proj -R$region $Baxes $Baxes2 -K -P -V > $psname")
GMT.xy!(pen,[freq[2:nt2] P[2:nt2]],J=proj,R=region)
# save the figure
GMTprint("PSD.ps",figdir)

# noise reduction
fc = 1/100dt # cut off　※この値に根拠はありません．
cutoff = abs.(freq) .> fc;
freq0 = iszero.(freq);
F0[cutoff .& .!freq0] .= 0.0
<<<<<<< HEAD
datamod = FFTW.ifft(F0);

# figure 2
t = 0:dt:(nt-1)*dt # time: x-axis

# Appearances
proj="X16/8"
region="0/2600/0/70"
Baxes="-Bx500g500+l\"Time (s)\" -By10g10+l\"Wind speed (m/s)\" -BSW"
Baxes2="--MAP_GRID_PEN_PRIMARY=thinner,gray"
pen="-W0.25,skyblue"
pen2="-W0.5,plum"

# GMT plot
GMT.gmt("psbasemap -J$proj -R$region $Baxes $Baxes2 -K -P -V > $psname")
GMT.xy!(pen, [collect(t) data], J=proj, R=region)
GMT.xy!(pen2, [collect(t) real.(datamod)], J=proj, R=region)
# GMT legend
lfile="tmplegend.txt"
open( lfile, "w" ) do fileIO
    print(fileIO, "S 0.7 - 0.7 - 1p,skyblue 1.5 Raw data\n")
    print(fileIO, "S 0.7 - 0.7 - 1p,plum 1.5 Noise reduced\n")
end
GMT.gmt("pslegend -J$proj -R$region -DjTR+w5+o0.2/0.2 -F+p0.5+gwhite -O -P -V $lfile >> $psname")
rm(lfile)
# save the figure
GMTprint("noise_reduced.ps",figdir)
