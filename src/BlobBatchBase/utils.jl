function filesize(bb::BlobBatch)
    fsize = 0.0;
    for fn in readdir(rootdir(bb); join = true)
        isfile(fn) || continue
        endswith(basename(fn), ".bb.jls") || continue
        fsize += filesize(fn)
    end
    return fsize
end