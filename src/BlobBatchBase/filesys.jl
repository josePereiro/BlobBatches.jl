## --------------------------------------------------------
# files
rootdir(bb::BlobBatch) = abspath(getindex(bb["extras"], "_rootdir"))
rootdir!(bb::BlobBatch, dir) = setindex!(bb["extras"], abspath(dir), "_rootdir")

## --------------------------------------------------------
hasfilesys(bb::BlobBatch) = haskey(bb["extras"], "_rootdir")

## --------------------------------------------------------
const _BLOBBATCH_FRAME_EXT = ".bbframe.jls"
framefile(bb::BlobBatch, k, ks...) = joinpath(
    rootdir(bb::BlobBatch), 
    string(framekey(k, ks...), _BLOBBATCH_FRAME_EXT)
)

## --------------------------------------------------------
import Base.readdir
function framefiles(bb::BlobBatch)
    filter(readdir(rootdir(bb); join = true)) do path
        isfile(path) && endswith(basename(path), _BLOBBATCH_FRAME_EXT)
    end
end

## --------------------------------------------------------
import Base.isfile
Base.isfile(bb::BlobBatch, k, ks...) = isfile(framefile(bb, k, ks...))

## --------------------------------------------------------
import Base.filesize
function Base.filesize(bb::BlobBatch)
    fsize = 0.0;
    for fn in framefiles(bb)
        fsize += filesize(fn)
    end
    return fsize
end

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