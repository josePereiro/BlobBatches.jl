## --------------------------------------------------------
function test_blobdb(root::AbstractString; 
        nbatches = 5,
        nblobs = 10,
        datfun = () -> rand(100), 
        verbose = false,
    )
    mkpath(root)
    # create blobbatches
    info_t = -1.0
    for it in 1:nbatches
        bdir = joinpath(root, string("batch_", it))
        bb = BlobBatch(bdir)
        # fill some stuff
        bm = batchmeta(bb)
        bm["time"] = time()
        for _ in 1:nblobs
            bf = blobframe!(bb) # load
            obj = Dict("dat" => datfun(), "time" => time())
            push!(bf, obj)
        end
        serialize(bb);
        verbose && if time() > info_t
            print("creating blobs: ", it, "/", nbatches, "             \r")
            info_t = time() + 1.0
        end
    end
    verbose && println(" "^80)
    return root
end