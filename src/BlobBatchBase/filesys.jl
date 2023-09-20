## --------------------------------------------------------
# files
rootdir(bb::BlobBatch) = abspath(getindex(bb["extras"], "_rootdir"))
rootdir!(bb::BlobBatch, dir) = setindex!(bb["extras"], abspath(dir), "_rootdir")

## --------------------------------------------------------
hasfilesys(bb::BlobBatch) = haskey(bb["extras"], "_rootdir")

## --------------------------------------------------------
framefile(bb::BlobBatch, k, ks...) = joinpath(
    rootdir(bb::BlobBatch), 
    string(framekey(k, ks...), ".bb.jls")
)

## --------------------------------------------------------
import Base.isdir
Base.isdir(bb::BlobBatch) = isdir(rootdir(bb))

## --------------------------------------------------------
import Base.isfile
Base.isfile(bb::BlobBatch, k, ks...) = isfile(framefile(bb, k, ks...))