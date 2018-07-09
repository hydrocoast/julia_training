#!/bin/bash

interp=0.125
cint=1
aint=2
proj="X12/12"
crange=-6/8
region=-3/3/-3/3
xyzfile="tmp0.txt"
grdname="tmp.grd"
cpt="tmp.cpt"
psfile="tmp.ps"

# cpt
gmt makecpt -Crainbow -T$crange -D > $cpt

# make grid
gmt xyz2grd ${xyzfile} -R$region -G${grdname} -I$interp

# grdimage or grdview
#gmt grdimage ${grdname} -J$proj -R$region -C$cpt -K -P -V > $psfile
gmt grdview ${grdname} -J$proj -Jz1 -R$region -C$cpt -Qi -K -P -V > $psfile

# contour
gmt grdcontour ${grdname} -J$proj -R$region -C$cint -A$aint -L$crange -K -V -O >> $psfile

