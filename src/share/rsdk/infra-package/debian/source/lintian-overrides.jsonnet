function(target) |||
    # Our package is built on GitHub-hosted runner,
    # which uses Ubuntu, and will default to zstd compression.
    # This is currently not supported in Debian.
    %(target)s source: custom-compression-in-debian-rules
||| % {
    target: target,
}
