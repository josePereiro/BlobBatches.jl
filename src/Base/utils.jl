_lock(f::Function, ::Nothing; kwargs...) = f()
_lock(f::Function, lk; kwargs...) = lock(f, lk; kwargs...)

function _canonical_bytes(bytes)
    bytes < 1024 && return (bytes, "b")
    bytes /= 1024
    bytes < 1024 && return (bytes, "kb")
    bytes /= 1024
    bytes < 1024 && return (bytes, "Mb")
    bytes /= 1024
    bytes < 1024 && return (bytes, "Gb")
    bytes /= 1024
    return (bytes, "Tb")
end

function _pretty_str_keys(col)
    strs = String[]
    for el in col
        push!(strs, string("\"", el, "\""))
    end
    return string("[", join(strs, ", "), "]")
end