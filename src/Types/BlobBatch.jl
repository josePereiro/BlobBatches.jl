const BLOBFRAME_DATATYPE = Vector{Dict{String, Any}}
const BLOBFRAMES_DATATYPE = OrderedDict{String, 
    BLOBFRAME_DATATYPE
}
const BATCHMETA_DATATYPE = OrderedDict{String, Any}
const EXTRAS_DATATYPE = Dict{String, Any}

struct BlobBatch
    rootdir::String
    # batch level data
    # batchmeta: frame_file => frame_data
    batchmeta::BATCHMETA_DATATYPE
    # blobframes: frame_file => frame_data
    blobframes::BLOBFRAMES_DATATYPE
    extras::EXTRAS_DATATYPE # for config (non disk backed data)
end

# deserialize or create a brand new BlobBatch
function BlobBatch(rootdir::String)
    isdir(rootdir) || mkpath(rootdir)
    return deserialize(BlobBatch, rootdir)
end