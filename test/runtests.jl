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

            # test lock
            _t = nothing
            for it in 1:10
                lock(bb) do
                    _t = @async lock(bb) do
                        @async lock(bb) do
                            bb["task2"] = time() # this must wait the lock
                        end
                        sleep(0.1) # discard race
                        bb["task1"] = time() # this must wait the lock
                    end
                    sleep(0.1) # discard race
                    bb["task0"] = time()
                end 
                wait(_t)
                sleep(0.1) # discard race
                @test bb["task0"] < bb["task1"]
                @test bb["task1"] < bb["task2"]
            end

            # no lock
            _t = nothing
            setlock!(bb, nothing)
            for it in 1:10
                lock(bb) do # ignored
                    _t = @async lock(bb) do # ignored
                        @async lock(bb) do # ignored
                            bb["task2"] = time()
                        end
                        sleep(0.01) # discard race
                        bb["task1"] = time() # this must wait the lock
                    end
                    sleep(0.1) # discard race
                    bb["task0"] = time()
                end 
                wait(_t)
                sleep(0.1) # discard race
                @test bb["task2"] < bb["task1"]
                @test bb["task1"] < bb["task0"]
            end

            # load unload
        finally
            rm(root; force = true, recursive = true)
        end
    end

    ## --------------------------------------------------------
    # walkdir test
    let
        root = joinpath(@__DIR__, "blobs")
        rm(root; force = true, recursive = true)
        mkpath(root)

        try
            # create blobbatches
            test_blobdb(root; nbatches = 10)
            
            # check
            bbs = []
            for bb in walkdir(BlobBatch, root; skipempty = true) 
                @test !isempty(bb)
                
                @test haskey(bb["meta"], "time")
                @test bb["meta"]["time"] < time()
                
                @test !isempty(bb[1]) # loaded
                for el in bb[1]
                    @test haskey(el, "time")
                    @test el["time"] < time()
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
            # rm(root; force = true, recursive = true)
        end
    end
    
end

nothing