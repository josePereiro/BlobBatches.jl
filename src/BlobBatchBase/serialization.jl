## --------------------------------------------------------
import Serialization.serialize
function Serialization.serialize(bb::BlobBatch)
    for (fkey, dat) in bb.frames
        # handle reserved
        fkey == "meta" && isempty(dat) && continue
        fkey == "extras" && continue
        serialize(framefile(bb, fkey), dat)
    end
end