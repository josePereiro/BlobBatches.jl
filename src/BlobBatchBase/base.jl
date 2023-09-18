## --------------------------------------------------------
import Base.merge!
function Base.merge!(bb0::BlobBatch, bb1::BlobBatch)
    merge!(batchmeta(bb0), batchmeta(bb1))
    merge!(blobframes(bb0), blobframes(bb1))
end

## --------------------------------------------------------
import Base.show
function Base.show(io::IO, bb::BlobBatch)
    println(io, "BlobBatch")
    println(io, "rootdir:")
    println(io, "    ", rootdir(bb))
    println(io, "size:")
    val, unit = _canonical_bytes(filesize(bb))
    println(io, "    ", round(val; digits = 3), " ", unit)

    # batchmeta
    bmeta = batchmeta(bb)
    if !isempty(bmeta)
        println(io, "batchmeta:  ")
        println(io, "    ", _pretty_str_keys(keys(bmeta)))
    end

    # blobframes
    bframes = blobframes(bb)
    if !isempty(bframes)
        println(io, "blobframes: ")
        for (ffn, dat) in bframes
            print(io, "    ", basename(ffn), " => ")
            print(io, length(dat), " blobs")
            if length(dat) > 0 
                print(io, ", first keys: ")
                print(io, _pretty_str_keys(keys(first(dat))))
            end
            println(io)
            
        end
    end


end
show(bb::BlobBatch) = show(stdout, bb)

## --------------------------------------------------------
# import Base.push!
# # default to frame 1
# function Base.push!(bb::BlobBatch, obj::Dict; frame = _DEFAULT_FRAME_NAME)
#     bframe = blobframe!(bb, frame)::Vector
#     push!(bframe, obj)
# end
# function Base.push!(f::Function, bb::BlobBatch; frame = _DEFAULT_FRAME_NAME)
#     push!(bb, Dict(f()); frame)
# end

import Base.isempty
# Check only the ram version
Base.isempty(bb::BlobBatch) = isempty(batchmeta(bb)) && isempty(blobframes(bb))

import Base.empty!
# Empty the ram version
function Base.empty!(bb::BlobBatch)
    empty!(batchmeta(bb))
    empty!(blobframes(bb))
    return bb
end

## --------------------------------------------------------
import Base.rm
function Base.rm(bb::BlobBatch; force = false)
    rm(rootdir(bb); force, recursive = true)
end

import Base.mkpath
function Base.mkpath(bb::BlobBatch; kwargs...)
    mkpath(rootdir(bb); kwargs...)
end

import Base.isdir
function Base.isdir(bb::BlobBatch)
    isdir(rootdir(bb))
end

