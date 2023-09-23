_pidfile(bb::BlobBatch) = joinpath(rootdir(bb), "bb.pidfile")
getlock(bb::BlobBatch) = get!(() -> _pidfile(bb), bb["extras"], "_getlock")
setlock!(bb::BlobBatch, lock) = setindex!(bb["extras"], lock, "_getlock")
setlock!(bb::BlobBatch) = setlock!(bb, _pidfile(bb))

function _isvalid_pidfile(lkf)
    pid, host, _ = Pidfile.parse_pidfile(lkf)
    return Pidfile.isvalidpid(host, pid)
end

function _its_mypid(lkf)
    pid, host, _ = Pidfile.parse_pidfile(lkf)
    Pidfile.isvalidpid(host, pid) || return false
    return getpid() == Int(pid)
end

import Base.lock
function Base.lock(f::Function, bb::BlobBatch; kwargs...) 
    lkf = getlock(bb)
    isnothing(lkf) && return f() # ignore locking
    mkpath(dirname(lkf))
    _its_mypid(lkf) && return f()
    lk = mkpidlock(lkf; kwargs...) 
    try
        bb["extras"]["_Pidfile.LockMonitor"] = lk
        return f()
    finally
        close(lk)
    end
end
function Base.lock(bb::BlobBatch; kwargs...) 
    lkf = getlock(bb)
    isnothing(lkf) && return # ignore locking 
    mkpath(dirname(lkf))
    _its_mypid(lkf) && return get(bb["extras"], "_Pidfile.LockMonitor", nothing)
    lk = mkpidlock(lkf; kwargs...)
    bb["extras"]["_Pidfile.LockMonitor"] = lk
    return bb
end

import Base.islocked
function Base.islocked(bb::BlobBatch) 
    lkf = BlobBatches.getlock(bb)
    isnothing(lkf) && return false # ignore locking 
    # check mine
    lk = get(bb["extras"], "_Pidfile.LockMonitor", nothing)
    !isnothing(lk) && isopen(lk.fd) && return true 
    # check other
    return _isvalid_pidfile(lkf)
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
    