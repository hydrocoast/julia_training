# Learning Julia
Julia training course  

# Overview
This repository follows [this page](https://hydrocoast.jp/index.php?Julia).   
This repo contains examples of the codes, which may help you learn JuliaLang.  
You can make figures and animations as shown below.   
<img src="https://github.com/hydrocoast/julia_training/blob/master/ConAdvEq.gif" width="640">   
The branch `master` is designed to make figures with Plots.  
PyPlot and GMT are also available by `git checkout pyplot` and `git checkout gmt`.   
Please contact the author if you find a bug.  

# Requirements
- Julia v1.0.0
### Julia Packages
- DSP
- FFTW
- Interpolations
- MAT
- NetCDF
- OffsetArrays
- Plots
- Polynomials
- PyPlot
- GMT (in case of using GMT visualization)

# Usage
- Install the required packages   
- Clone this repository
```bash
git clone https://github.com/hydrocoast/julia_training
```
- `cd julia_training` and then run the scripts in REPL of the JuliaLang
```julia
 julia> include("EX1_maxmin_surf.jl")
```

# License
MIT  

# Author
Takuya Miyashita   
Doctoral student, Kyoto University  
([personal web site](https://hydrocoast.jp))  
