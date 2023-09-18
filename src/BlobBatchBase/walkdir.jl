import Base.walkdir
# 'walkdir' all directories and parse them as BlobBatch
function Base.walkdir(::Type{BlobBatch}, root::AbstractString; 
        topdown=true, follow_symlinks=false, onerror=throw, 
        skipempty = true
    )
    return Channel{BlobBatch}() do _ch
        for (currdir, dirs, _) in walkdir(root; topdown, follow_symlinks, onerror)
            for dir in dirs
                # path to directories
                bb = BlobBatch(joinpath(currdir, dir))
                skipempty && isempty(bb) && continue
                put!(_ch, bb)
            end
        end
    end
end