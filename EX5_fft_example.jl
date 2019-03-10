# Include packages
using FFTW: fft, ifft

# MAT package is not mature.
# When it returns a error, comment the following line and
# read data from the txt formatted file.
using MAT: MAT


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
    matfile = MAT.matopen(join([fdir,fname],"/"));
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

# Data source mat or txt
#using MAT
#dt, nt, nz, z, u = loadmat();
dt, nt, nz, z, u = loadtxt()

# Fourier transform
data = u[1,:];
F0 = fft(data,1);
P = abs.(F0/(nt/2)); # Power
freq = fftfreq(nt,dt);
if isodd(nt); nt2 = Int((nt-1)/2); else; nt2 = Int(nt/2); end

# noise reduction
fc = 1/100dt # cut off　※この値に根拠はありません．
cutoff = abs.(freq) .> fc;
freq0 = iszero.(freq);
F0[cutoff .& .!freq0] .= 0.0
datamod = ifft(F0);
####################


####################
## plot
####################

# directory where figures are printed
figdir="./fig"
if !isdir(figdir); mkdir(figdir); end

using PyPlot

########
## Figure 1
#  Power spectrum density
fig1 = figure(figsize=(12,6))
ax1 = fig1.add_subplot(111)
ax1.loglog(freq[2:nt2], P[2:nt2], "b-")
ax1.set_xlim(2e-4,1e+1)
ax1.set_ylim(1e-4,2e+0)
ax1.set_xlabel("Frequency (Hz)", fontsize=12)
ax1.set_ylabel("Power (m²/s²)", fontsize=12)
ax1.grid(which="major", color="k", linestyle="--", alpha=0.5)
ax1.grid(which="minor", color="#7D7D7D", linestyle="--", alpha=0.2)
# save figure
fig1.savefig("./fig/PSD_PyPlot.png", format="png", dpi=300)
########

########
## Figure 2
# original and noise reduced data
t = 0:dt:(nt-1)*dt;
fig2 = figure(figsize=(15,6))
ax2 = fig2.add_subplot(111)
ax2.plot(t, data,"c-")
ax2.plot(t, real.(datamod), "m-")
ax2.grid(which="major", color="k", linestyle="--", alpha=0.5)
ax2.legend(["Raw data","Noise reduced"], fontsize=12, loc=1)
ax2.set_xlabel("Time (s)", fontsize=12)
ax2.set_ylabel("Wind Speed (m/s)", fontsize=12)
# save figure
fig2.savefig(joinpath(figdir,"Noise_reduction_PyPlot.png"), format="png", dpi=300)
########

####################
