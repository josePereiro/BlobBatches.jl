## --------------------------------------------------------
import Base.empty!
function Base.empty!(bb::BlobBatch)
    empty!(bb.frames)
    # reserved
    # bb.frames["meta"] = Dict{String, Any}()
    # bb.frames["extras"] = Dict{String, Any}()
    return bb
end