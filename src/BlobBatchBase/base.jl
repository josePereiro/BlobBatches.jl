## --------------------------------------------------------
import Base.empty!
function Base.empty!(bb::BlobBatch)
    empty!(bb.frames)
    return bb
end

## --------------------------------------------------------
import Base.isempty
Base.isempty(bb::BlobBatch) = isempty(bb.frames)