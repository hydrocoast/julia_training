# Learning Julia
Julia traininig course  
2018/03   

# Overview
This repository follows [this page](http://hydrocoast.jp/index.php?Julia).   
This repo contains examples of the codes, which may allow us to understand how to use JuliaLang.  
You can make figures and movies as shown below.   
<img src="https://github.com/hydrocoast/julia_training/blob/master/ConAdvEq.gif" width="640">   
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
```bash
 julia> include("Q1_maxmin_surf.jl")
```

# License
MIT  

# Author
Takuya Miyashita   
Doctoral student, Kyoto University  
([personal web site](http://hydrocoast.jp))  
