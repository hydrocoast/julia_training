################################
## Tentative function
################################
function GMTprint(filename="tmp.ps"::String, dirname="."::String)
    if !Sys.islinux()
        println("Not Linux -- nothing to be done")
        return nothing
    end
    psorg, _, _ = GMT.fname_out(Dict())
    outpath=joinpath(dirname,filename)
    #GMT.gmt(psconvert )
    #run(`cp -p $psorg $outpath`)
    run(`cp -p $psorg $outpath`)
    run(`ps2eps -f -q $outpath`)
    run(`rm $outpath`)
    return nothing
end
