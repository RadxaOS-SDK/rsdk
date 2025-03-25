function(
    target,
    pkg_org,
) |||
    # %(target)s

    [![Release](https://github.com/%(pkg_org)s/%(target)s/actions/workflows/release.yaml/badge.svg)](https://github.com/%(pkg_org)s/%(target)s/actions/workflows/release.yaml)

    ## Build

    1. `git clone --recurse-submodules https://github.com/%(pkg_org)s/%(target)s.git`
    2. Open in [`devcontainer`](https://code.visualstudio.com/docs/devcontainers/containers)
    3. `make deb`
||| % {
    target: target,
    pkg_org: pkg_org,
}
