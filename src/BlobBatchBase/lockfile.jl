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
Base.lock(f::Function, bb::BlobBatch; 
        time_out = Inf, valid_time = Inf, retry_time = 1e-2, recheck_time = 1e-3, force = false
    ) = lock(f, lockfile(bb), lockid(bb); time_out, valid_time, retry_time, recheck_time, force)
Base.lock(bb::BlobBatch; 
        time_out = Inf, valid_time = Inf, retry_time = 1e-2, recheck_time = 1e-3, force = false
    ) = lock(lockfile(bb), lockid(bb); time_out, valid_time, retry_time, recheck_time, force)

import Base.islocked
Base.islocked(bb::BlobBatch) = islocked(lockfile(bb), lockid(bb))

import Base.unlock
Base.unlock(bb::BlobBatch; force = false) = unlock(lockfile(bb), lockid(bb); force)