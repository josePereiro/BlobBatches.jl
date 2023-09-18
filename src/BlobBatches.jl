module BlobBatches

    using Serialization
    using SimpleLockFiles
    using OrderedCollections

    # exports
    export BlobBatch, rootdir, 
           batchmeta, batchmeta!, 
           blobframes, blobframe, blobframe!, blobframes_names
    export deserialize, serialize
    export lockfile, lockid

    #! include .
    
    #! include Base
    include("Base/utils.jl")
    
    #! include Types
    include("Types/BlobBatch.jl")
    
    #! include BlobBatchBase
    include("BlobBatchBase/base.jl")
    include("BlobBatchBase/constants.jl")
    include("BlobBatchBase/interface.jl")
    include("BlobBatchBase/lockfile.jl")
    include("BlobBatchBase/serialization.jl")
    include("BlobBatchBase/walkdir.jl")

end