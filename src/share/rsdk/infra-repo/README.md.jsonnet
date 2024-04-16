function(
    target,
    repo_org,
    pkg_org,
) |||
    # %(target)s

    [![Update packages](https://github.com/%(repo_org)s/%(target)s/actions/workflows/update.yaml/badge.svg)](https://github.com/%(repo_org)s/%(target)s/actions/workflows/update.yaml)

    ## Usage

    ```bash
    temp="$(mktemp)"
    version="$(curl -L https://github.com/%(pkg_org)s/radxa-archive-keyring/releases/latest/download/VERSION)"
    curl -L --output "$temp" "https://github.com/%(pkg_org)s/radxa-archive-keyring/releases/latest/download/radxa-archive-keyring_${version}_all.deb"
    sudo dpkg -i "$temp"
    rm -f "$temp"
    source /etc/os-release
    sudo tee /etc/apt/sources.list.d/20-radxa.list <<< "deb [signed-by=/usr/share/keyrings/radxa-archive-keyring.gpg] https://%(repo_org)s.github.io/%(target)s/ $VERSION_CODENAME main"
    sudo apt-get update
    ```
||| % {
    target: target,
    repo_org: repo_org,
    pkg_org: pkg_org,
}
