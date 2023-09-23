_pidfile(bb::BlobBatch) = joinpath(rootdir(bb), "bb.pidfile")
getlock(bb::BlobBatch) = get!(() -> _pidfile(bb), bb["extras"], "_getlock")
setlock!(bb::BlobBatch, lock) = setindex!(bb["extras"], lock, "_getlock")
setlock!(bb::BlobBatch) = setlock!(bb, _pidfile(bb))

import Base.lock
function Base.lock(f::Function, bb::BlobBatch; kwargs...) 
    lkf = getlock(bb)
    isnothing(lkf) && return f() # ignore locking
    mkpath(dirname(lkf))
    return mkpidlock(f, lkf; kwargs...)
end
function Base.lock(bb::BlobBatch; kwargs...) 
    lkf = getlock(bb)
    isnothing(lkf) && return # ignore locking 
    mkpath(dirname(lkf))
    lk = mkpidlock(lkf; kwargs...)
    bb["extras"]["_Pidfile.LockMonitor"] = lk
    return bb
end

import Base.islocked
function Base.islocked(bb::BlobBatch) 
    lkf = getlock(bb)
    isnothing(lkf) && return false # ignore locking 
    # check mine
    lk = get(bb["extras"], "_Pidfile.LockMonitor", nothing)
    !isnothing(lk) && isopen(lk.fd) && return true 
    # check other
    lk = Pidfile.tryopen_exclusive(lkf)
    if isnothing(lk)
        rm(lkf; force = true)
        return true
    end
    close(lk)
    return false
end

import Base.unlock
function Base.unlock(bb::BlobBatch; force = false) 
    lkf = getlock(bb)
    isnothing(lkf) && return # ignore locking 
    force && rm(lkf; force)
    lk = get(bb["extras"], "_Pidfile.LockMonitor", nothing)
    isnothing(lk) && return 
    close(lk)
end
    