using BlobBatches
using Test

@testset "BlobBatches.jl" begin
    
    # basic serialization/loading test
    let
        bbroot = joinpath(@__DIR__, "0x77cfa1eef01bca90")
        rm(bbroot; force = true, recursive = true)
        @assert !isdir(bbroot)
        try
            bb0 = BlobBatch(bbroot)
            for it in 1:10
                bf = blobframe!(bb0) # load
                obj = Dict("A" => rand(), "B" => :KAKA)
                push!(bf, obj)
            end
            # bf0 = blobframe(bb0, 1)
            # @test !isempty(bf0)
            bf0 = blobframe!(bb0, 1)
            @test !isempty(bf0)
            serialize(bb0)
            
            bb1 = BlobBatch(bbroot)
            # bf1 = blobframe(bb1, 1)
            # @test isempty(bf1) # unloaded
            bf1 = blobframe!(bb1, 1)
            @test !isempty(bf1) # loaded
            @test all(bf0 .== bf1)
        finally
            rm(bbroot; force = true, recursive = true)
        end
    end

    # walkdir test
    let
        root = joinpath(@__DIR__, "blobs")
        rm(root; force = true, recursive = true)
        mkpath(root)
    
        try
            # create blobbatches
            for it in 1:10
                bdir = joinpath(root, string("batch_", it))
                bb = BlobBatch(bdir)
                # fill some stuff
                bm = batchmeta(bb)
                bm["time"] = time()
                bm["it"] = it
                for oi in 1:10
                    bf = blobframe!(bb) # load
                    obj = Dict("r" => rand(), "time" => time())
                    push!(bf, obj)
                end
                serialize(bb);
                @test isdir(bb);
            end
    
            # check
            bbs = []
            for bb in walkdir(BlobBatch, root; skipempty = true) 
                @test !isempty(bb)
                
                bm = batchmeta(bb)
                @test haskey(bm, "time")
                @test bm["time"] < time()
                
                # bf = blobframe(bb)
                # @test isempty(bf) # non loaded
                bf = blobframe!(bb)
                @test !isempty(bf) # loaded
                for blob in bf
                    @test haskey(blob, "time")
                    @test blob["time"] < time()
                end
    
                # empty
                @test !isempty(bb)
                empty!(bb)
                @test isempty(bb)

                # collect
                push!(bbs, bb)
            end
            @test length(bbs) == 10
        finally
            rm(root; force = true, recursive = true)
        end
    end
end

nothing