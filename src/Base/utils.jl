_lock(f::Function, ::Nothing; kwargs...) = f()
_lock(f::Function, lk; kwargs...) = lock(f, lk; kwargs...)