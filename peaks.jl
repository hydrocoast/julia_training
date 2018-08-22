# See https://jp.mathworks.com/help/matlab/ref/peaks.html
function peaks(N=49::Int)
    function formula(x::T, y::T) where T<:Float64
        z = 3(1-x)^2*exp(-(x^2)-(y+1)^2)-10(x/5 - x^3 - y^5)*exp(-x^2-y^2)-(1/3)exp(-(x+1)^2-y^2)
    end
    vec = collect(Float64, LinRange(-3.,3.,N))
    x = repeat(vec', outer=(N,1))
    y = repeat(vec, outer=(1,N))
    z = formula.(x,y)
    return (x,y,z)
end
