# Include packages
using FFTW, Plots
pyplot()
#gr()
#plotlyjs()
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
    using MAT
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
#dt, nt, nz, z, u = loadmat();
dt, nt, nz, z, u = loadtxt()

# Fourier transform
data = u[1,:];
F0 = fft(data,1);
P = abs.(F0/(nt/2)); # Power
freq = fftfreq(nt,dt);
# figure: Power spectrum density
if isodd(nt); nt2 = Int((nt-1)/2); else; nt2 = Int(nt/2); end
plot(freq[2:nt2], P[2:nt2], lab="Power spectrum", legend=false,
     xscale=:log10, yscale=:log10,
     xlabel="Frequency (Hz)", ylabel="Power (m²/s²)",
     xlims=(2e-4,1e+1), ylims=(1e-4, 2e+0),
     );
savefig(joinpath(figdir,"PSD2.png"));

# noise reduction
fc = 1/100dt # cut off　※この値に根拠はありません．
cutoff = abs.(freq) .> fc;
freq0 = iszero.(freq);
F0[cutoff .& .!freq0] = 0.0;
datamod = ifft(F0);
# figure 2
t = 0:dt:(nt-1)*dt;
plot(t,data, line=(:solid, 1), lab="Raw data", size=(1500, 600),
     xlabel="Time (s)", ylabel="Wind Speed (m/s)", guidefont=14,
     tickfont=12,
     );
plot!(t,real.(datamod), line=(:solid, 2), color=:magenta, lab="Noise reduced",
      legend=:topright, legendfont=14,
      );
savefig(joinpath(figdir,"noise_reduced.png"))
