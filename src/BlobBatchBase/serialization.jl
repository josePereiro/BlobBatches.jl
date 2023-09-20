## --------------------------------------------------------
import Serialization.serialize
function Serialization.serialize(bb::BlobBatch)
    lock(bb) do
        for (fkey, dat) in bb.frames
            # handle reserved
            fkey == "meta" && isempty(dat) && continue
            fkey == "extras" && continue
            serialize(framefile(bb, fkey), dat)
        end
    end
end

function Serialization.serialize(bb::BlobBatch, k, ks...)
    key = framekey(bb, k, ks...)
    key == "extras" && error("extras is reserved, do not serialize it!")
    lock(bb) do
        serialize(framefile(bb, key), bb[key])
    end
    nothing
end

import Serialization.deserialize
# load all frames
function Serialization.deserialize(::Type{BlobBatch}, dir::AbstractString)
    bb = BlobBatch(dir)
    loadallframe!(bb)
    return bb
end

deserialize!(bb::BlobBatch, k, ks...) = loadframe!(bb, k, ks...)