################################
## Tentative function
################################
function GMTprint(filename::String; dirname="."::String)
    if !is_linux()
        println("Not Linux -- nothing to be done")
        return nothing
    end
    psorg, _, _ = GMT.fname_out("")
    outpath=joinpath(dirname,filename)
    run(`cp -p $psorg $outpath`)
    return nothing
end
