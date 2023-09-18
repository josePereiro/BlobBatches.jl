module BlobBatches

    using Serialization
    using SimpleLockFiles
    using OrderedCollections
    using Base.Threads

    # exports
    export BlobBatch, rootdir, 
           batchmeta, batchmeta!, 
           blobframes, blobframe, blobframe!, blobframes_names
    export deserialize, serialize
    export lockfile, lockid
    export test_blobdb

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
    include("BlobBatchBase/testdb.jl")
    include("BlobBatchBase/utils.jl")
    include("BlobBatchBase/walkdir.jl")

end