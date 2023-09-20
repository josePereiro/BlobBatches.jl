
_simplelockfile(bb::BlobBatch) = SimpleLockFile(joinpath(rootdir(bb), "bb.lockfile"))
getlock(bb::BlobBatch) = get!(() -> _simplelockfile(bb), bb["extras"], "_getlock")
setlock!(bb::BlobBatch, lock) = setindex!(bb["extras"], lock, "_getlock")
setlock!(bb::BlobBatch) = setlock!(bb, _simplelockfile(bb))

import Base.lock
function Base.lock(f::Function, bb::BlobBatch; 
        time_out = Inf, valid_time = Inf, retry_time = 1e-2, recheck_time = 1e-3, force = false
    ) 
    lkf = getlock(bb)
    isnothing(lkf) && return f() # ignore locking 
    lock(f, lkf; time_out, valid_time, retry_time, recheck_time, force)
end
function Base.lock(bb::BlobBatch; 
        time_out = Inf, valid_time = Inf, retry_time = 1e-2, recheck_time = 1e-3, force = false
    ) 
    lkf = getlock(bb)
    isnothing(lkf) && return # ignore locking 
    lock(lkf; time_out, valid_time, retry_time, recheck_time, force)
end

import Base.islocked
function Base.islocked(bb::BlobBatch) 
    lkf = getlock(bb)
    isnothing(lkf) && return false# ignore locking 
    return islocked(lkf)
end

import Base.unlock
function Base.unlock(bb::BlobBatch; force = false) 
    lkf = getlock(bb)
    isnothing(lkf) && return # ignore locking 
    unlock(lkf; force)
end
    