_lock(f::Function, ::Nothing; kwargs...) = f()
_lock(f::Function, lk; kwargs...) = lock(f, lk; kwargs...)

function _canonical_bytes(bytes)
    bytes < 1024 && return (bytes, "bytes")
    bytes /= 1024
    bytes < 1024 && return (bytes, "kilobytes")
    bytes /= 1024
    bytes < 1024 && return (bytes, "Megabytes")
    bytes /= 1024
    bytes < 1024 && return (bytes, "Gigabytes")
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