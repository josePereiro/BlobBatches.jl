rootdir(bb::BlobBatch) = bb.rootdir

# Keep it simple, the set/get/get! interface is 
# i) retrive the dict/vector
# ii) Do what you want

batchmeta(bb::BlobBatch) = bb.batchmeta

blobframes(bb::BlobBatch) = bb.blobframes

# TODO: test if required, I belive not
# current state of frame 'fname'
# function blobframe(bb::BlobBatch, fname) 
#     fname = string(fname)
#     bfs = blobframes(bb)
#     !haskey(bfs, fname) && error("Frame '", fname, "' non loaded/created. See blobframe!")
#     getindex(bb.blobframes, string(fname))
# end
# # default to frame 1
# blobframe(bb::BlobBatch) = blobframe(bb, _DEFAULT_FRAME_NAME)

# TODO: add mtime checking? Maybe just for warning
# 
function blobframe!(bb::BlobBatch, fname)
    fname = string(fname)
    frame = get!(bb.blobframes, fname) do 
        BLOBFRAME_DATATYPE()
    end
    # try load is empty (do not check unsync)
    isempty(frame) || return frame
    fn = build_blobframe_path(bb, fname)
    if isfile(fn) 
        frame = deserialize(fn)::BLOBFRAME_DATATYPE
        bb.blobframes[fname] = frame
    end
    return frame
end
# default to frame 1
blobframe!(bb::BlobBatch) = blobframe!(bb::BlobBatch, _DEFAULT_FRAME_NAME)

blobframes_names(bb::BlobBatch) = keys(bb.blobframes)


