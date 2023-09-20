module BlobBatches

    using Serialization
    using SimpleLockFiles
    using OrderedCollections
    using Base.Threads

    export BlobBatch
    export deserializa, serialize
    export hasframe, unloadframe!, loadframe!, isframeloaded
    export hasfilesys, rootdir, rootdir!, framefile
    export getlock, setlock!
    
    #! include .
    
    #! include 0_Types
    include("0_Types/BlobBatch.jl")
    
    #! include BlobBatchBase
    include("BlobBatchBase/base.jl")
    include("BlobBatchBase/filesys.jl")
    include("BlobBatchBase/frames.jl")
    include("BlobBatchBase/lock.jl")
    include("BlobBatchBase/serialization.jl")
    include("BlobBatchBase/utils.jl")
end