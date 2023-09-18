function _is_batchmeta_fn(path::String)
    isequal("meta.bb.jls", basename(path))
end

function _is_blobframe_fn(path::String)
    endswith(basename(path), ".frame.bb.jls") 
end

# return frame name
function _parse_blobframe_fn(path)
    _is_blobframe_fn(path) || return ""
    return replace(basename(path), ".frame.bb.jls" => "")
end

## ----------------------------------------------
# Create a BlobBatch from a folder
# only meta data is loaded
function _unsafe_deserialize(::Type{BlobBatch}, rootdir::String)
    isdir(rootdir) || error("Root folder not found, folde: ", rootdir)
    bmeta = BATCHMETA_DATATYPE()
    bframes = BLOBFRAMES_DATATYPE()
    extras = EXTRAS_DATATYPE()

    isdir(rootdir) && for fn in readdir(rootdir; join = true)
        if _is_blobframe_fn(fn)
            fname = _parse_blobframe_fn(fn)
            # just 'register' frame (load at demand)
            bframes[fname] = BLOBFRAME_DATATYPE()
            continue
        end
        if _is_batchmeta_fn(fn)
            # load meta
            merge!(bmeta, deserialize(fn))
            continue
        end
        # ignore 
    end
    return BlobBatch(rootdir, bmeta, bframes, extras)
end

import Serialization.deserialize
function Serialization.deserialize(::Type{BlobBatch}, rootdir::String; lk = nothing)
    return _lock(lk) do
        _unsafe_deserialize(BlobBatch, rootdir::String)
    end
end


## ----------------------------------------------
function build_blobframe_path(bb::BlobBatch, name)
    return joinpath(rootdir(bb), string(name, ".frame.bb.jls"))
end

function build_batchmeta_path(bb::BlobBatch)
    return joinpath(rootdir(bb), "meta.bb.jls")
end

function _unsafe_serialize(bb::BlobBatch)
    isdir(bb) || mkpath(bb)
    bfpath = build_batchmeta_path(bb)
    serialize(bfpath, batchmeta(bb))
    for (name, frame) in blobframes(bb)
        ffname = build_blobframe_path(bb, name)
        # Only serialize loaded frames
        !isempty(frame) && serialize(ffname, frame)
    end
end

import Serialization.serialize
function Serialization.serialize(bb::BlobBatch; lk = bb)
    return _lock(lk) do
        _unsafe_serialize(bb)
    end
end