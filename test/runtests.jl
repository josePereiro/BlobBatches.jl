using BlobBatches
using Test

@testset "BlobBatches.jl" begin
    # TEST 1
    let
        #
        root = joinpath(@__DIR__, "blob")
        rm(root; force = true, recursive = true)
        mkpath(root)
        try
            bb = BlobBatch()
            @test !hasfilesys(bb)
            rootdir!(bb, root)
            @test hasfilesys(bb)
            
            # create frame1
            bb["frame1"] = 123
            @test !isfile(bb, "frame1")                # yet only in ram
            serialize(bb)
            @test !isfile(bb, "meta")                  # ignore empty meta
            @test !isfile(bb, "extras")                # ignore extras
            bb["extras"]["A"] = 234
            @test !isfile(bb, "extras")                # really ignore extras
            @test isfile(bb, "frame1")                 # must be on disk
            @test bb["frame1"] == 123
            bb["meta"]["A"] = 234
            serialize(bb)
            @test isfile(bb, "meta")                   # meta is wasn't empty
            
            bb = BlobBatch(root)
            @test !haskey(bb["extras"], "A")            # extras are trancient
            @test bb["meta"]["A"] == 234             # meta don't
            @test hasfilesys(bb)
            @test hasframe(bb, "frame1")               # on disk
            @test !isframeloaded(bb, "frame1")         # but not yet loaded
            loadframe!(bb, "frame1")
            @test isframeloaded(bb, "frame1")          # now we are talking
            unloadframe!(bb, "frame1")
            @test !isframeloaded(bb, "frame1")         
            @test bb["frame1"] == 123

            # load unload
        finally
            rm(root; force = true, recursive = true)
        end
    end
    
end

nothing