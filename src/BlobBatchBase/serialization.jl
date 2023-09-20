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

import Serialization.deserialize
# load all frames
function Serialization.deserialize(::Type{BlobBatch}, dir::AbstractString)
    bb = BlobBatch(dir)
    loadallframe!(bb)
    return bb
end