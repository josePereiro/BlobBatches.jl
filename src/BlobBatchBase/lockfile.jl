lock_kwargs = (;tout = Inf, vtime = Inf, wtime = 0.001, ctime = 0.05, force = false)
function lockfile(bb::BlobBatch)
    return get!(bb.extras, "_lockfile") do
        fn = joinpath(rootdir(bb), "bb.lockfile")
        SimpleLockFile(fn)
    end
end

function lockid(bb::BlobBatch)
    return get!(bb.extras, "_lockid") do
        string(rand(UInt))
    end
end

import Base.lock
# lock_kwargs = (;)
Base.lock(f::Function, bb::BlobBatch; 
        tout = Inf, vtime = Inf, wtime = 0.01, ctime = 0.05, force = false
    ) = lock(f, lockfile(bb), lockid(bb); tout, vtime, wtime, ctime, force)
Base.lock(bb::BlobBatch; 
        tout = Inf, vtime = Inf, wtime = 0.01, ctime = 0.05, force = false
    ) = lock(lockfile(bb), lockid(bb); tout, vtime, wtime, ctime, force)

import Base.islocked
Base.islocked(bb::BlobBatch) = islocked(lockfile(bb), lockid(bb))

import Base.unlock
Base.unlock(bb::BlobBatch; force = false) = unlock(lockfile(bb), lockid(bb); force)