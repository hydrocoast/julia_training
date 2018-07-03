# Learning Julia
Julia traininig course  

# Overview
This repository follows [this page](http://hydrocoast.jp/index.php?Julia).   
This repo contains examples of the codes, which may help you learn JuliaLang.  
You can make figures and animations as shown below.   
<img src="https://github.com/hydrocoast/julia_training/blob/master/ConAdvEq.gif" width="640">   
master branch is designed to make figures with Plots.
PyPlot is also available by `git checkout pyplot`.   
Please contact the author if you find a bug.  

# Requirements
- Julia (>=0.6.2)
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

# Usage
- Install the required packages by `Pkg.add("NameOfThePackage")`   
- Clone this repository
```bash
git clone https://github.com/hydrocoast/julia_training
```
- `cd julia_training` and then excecute the scripts in REPL of the JuliaLang
```julia
 julia> include("EX1_maxmin_surf.jl")
```

# License
MIT  

# Author
Takuya Miyashita   
Doctoral student, Kyoto University  
([personal web site](http://hydrocoast.jp))  
